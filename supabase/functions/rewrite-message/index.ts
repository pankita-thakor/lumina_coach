import { handleCors, json, readJson } from "../_shared/http.ts";
import { requireUser } from "../_shared/auth.ts";
import { callGemini, parseJsonFromText } from "../_shared/gemini.ts";
import { rateLimitHit } from "../_shared/rate_limit.ts";
import { rewriteBody } from "../_shared/schemas.ts";

Deno.serve(async (req) => {
  const c = handleCors(req);
  if (c) return c;
  if (req.method !== "POST") {
    return json({ success: false, data: null, error: "Method not allowed" }, 405);
  }

  const geminiKey = Deno.env.get("GEMINI_API_KEY") ?? req.headers.get("x-gemini-key")?.trim() ?? "";
  if (!geminiKey) {
    return json({ success: false, data: null, error: "Missing GEMINI_API_KEY" }, 400);
  }

  try {
    const { user, supabase } = await requireUser(req);
    if (rateLimitHit(user.id, "rewrite-message")) {
      return json({ success: false, data: null, error: "Rate limit exceeded" }, 429);
    }

    const raw = await readJson(req);
    const body = rewriteBody.parse(raw);

    const { data: msgRow, error: insErr } = await supabase
      .from("messages")
      .insert({
        user_id: user.id,
        content: body.message,
        context: body.context,
      })
      .select("id")
      .single();
    if (insErr) throw insErr;
    const messageId = msgRow.id as string;

    const sys =
      "You are a diplomatic communication coach. Respond ONLY with minified JSON: {\"suggestions\":[{\"tone\":\"gentle|assertive|diplomatic\",\"text\":\"...\",\"why\":\"...\"}]} — 2 or 3 items.";
    const claudeOut = await callGemini(
      geminiKey,
      sys,
      [
        {
          role: "user",
          content: `Context: ${body.context}\nMessage:\n${body.message}`,
        },
      ],
      2048,
    );
    const parsed = parseJsonFromText(claudeOut);

    const { error: rwErr } = await supabase.from("rewrites").insert({
      message_id: messageId,
      response: parsed,
    });
    if (rwErr) throw rwErr;

    const suggestions = (parsed.suggestions as unknown[]) ?? [];
    return json({
      success: true,
      data: { messageId, suggestions },
      error: null,
    });
  } catch (e) {
    const msg = e instanceof Error ? e.message : "Server error";
    console.error("rewrite-message:", msg);
    const status = msg === "Unauthorized" ? 401 : 400;
    return json({ success: false, data: null, error: msg }, status);
  }
});
