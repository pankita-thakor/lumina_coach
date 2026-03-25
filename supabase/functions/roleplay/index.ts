import { handleCors, json, readJson } from "../_shared/http.ts";
import { requireUser } from "../_shared/auth.ts";
import { callClaude } from "../_shared/claude.ts";
import { rateLimitHit } from "../_shared/rate_limit.ts";
import { roleplayBody } from "../_shared/schemas.ts";

type Turn = { role: "user" | "assistant"; content: string };

function isTurnArray(v: unknown): v is Turn[] {
  return Array.isArray(v) && v.every((x) =>
    x &&
    typeof x === "object" &&
    (x as Turn).role &&
    typeof (x as Turn).content === "string"
  );
}

Deno.serve(async (req) => {
  const c = handleCors(req);
  if (c) return c;
  if (req.method !== "POST") {
    return json({ success: false, data: null, error: "Method not allowed" }, 405);
  }

  const anthropicKey = req.headers.get("x-anthropic-key")?.trim() ?? "";
  if (!anthropicKey) {
    return json({ success: false, data: null, error: "Missing x-anthropic-key" }, 400);
  }

  try {
    const { user, supabase } = await requireUser(req);
    if (rateLimitHit(user.id, "roleplay")) {
      return json({ success: false, data: null, error: "Rate limit exceeded" }, 429);
    }

    const raw = await readJson(req);
    const body = roleplayBody.parse(raw);

    let sessionId = body.sessionId;
    let turns: Turn[] = [];
    let scenario = body.scenario;

    if (sessionId) {
      const { data: row, error } = await supabase
        .from("sessions")
        .select("messages")
        .eq("id", sessionId)
        .eq("user_id", user.id)
        .single();
      if (error || !row) throw new Error("Session not found");
      const stored = row.messages;
      if (stored && typeof stored === "object" && "turns" in stored) {
        const t = (stored as { turns?: unknown }).turns;
        if (isTurnArray(t)) turns = t;
        const sc = (stored as { scenario?: string }).scenario;
        if (sc) scenario = sc;
      } else if (isTurnArray(stored)) {
        turns = stored;
      }
    } else {
      const { data: row, error } = await supabase
        .from("sessions")
        .insert({
          user_id: user.id,
          messages: { scenario: body.scenario, turns: [] as Turn[] },
        })
        .select("id")
        .single();
      if (error) throw error;
      sessionId = row.id as string;
    }

    turns.push({ role: "user", content: body.userMessage });

    const sys =
      `You are the COUNTERPARTY in this scenario: ${scenario}. The human user is practicing communication. Stay in character, realistic, one message, under ~120 words, no meta.`;

    const claudeMessages = turns.map((t) => ({
      role: t.role,
      content: t.content,
    }));

    const reply = await callClaude(anthropicKey, sys, claudeMessages, 900);
    turns.push({ role: "assistant", content: reply });

    const payload = { scenario, turns };

    const { error: upErr } = await supabase
      .from("sessions")
      .update({
        messages: payload,
        updated_at: new Date().toISOString(),
      })
      .eq("id", sessionId!)
      .eq("user_id", user.id);
    if (upErr) throw upErr;

    return json({
      success: true,
      data: { sessionId, reply },
      error: null,
    });
  } catch (e) {
    const msg = e instanceof Error ? e.message : "Server error";
    console.error("roleplay:", msg);
    const status = msg === "Unauthorized" ? 401 : 400;
    return json({ success: false, data: null, error: msg }, status);
  }
});
