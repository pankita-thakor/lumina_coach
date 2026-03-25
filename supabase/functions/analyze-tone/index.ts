import { handleCors, json, readJson } from "../_shared/http.ts";
import { requireUser } from "../_shared/auth.ts";
import { callClaude, parseJsonFromText } from "../_shared/claude.ts";
import { rateLimitHit } from "../_shared/rate_limit.ts";
import { analyzeToneBody } from "../_shared/schemas.ts";

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
    if (rateLimitHit(user.id, "analyze-tone")) {
      return json({ success: false, data: null, error: "Rate limit exceeded" }, 429);
    }

    const raw = await readJson(req);
    const body = analyzeToneBody.parse(raw);

    const { data: msgRow, error: insErr } = await supabase
      .from("messages")
      .insert({
        user_id: user.id,
        content: body.message,
        context: "tone_analyzer",
      })
      .select("id")
      .single();
    if (insErr) throw insErr;
    const messageId = msgRow.id as string;

    const sys =
      'Return ONLY JSON: {"scores":{"empathy":0-100,"clarity":0-100,"assertiveness":0-100,"warmth":0-100}} heuristic scores only.';
    const claudeOut = await callClaude(
      anthropicKey,
      sys,
      [{ role: "user", content: body.message }],
      400,
    );
    const parsed = parseJsonFromText(claudeOut);
    const scores = parsed.scores as Record<string, number>;
    const clamp = (n: number) => Math.max(0, Math.min(100, Math.round(n)));
    const empathy = clamp(Number(scores.empathy));
    const clarity = clamp(Number(scores.clarity));
    const assertiveness = clamp(Number(scores.assertiveness));
    const warmth = clamp(Number(scores.warmth));

    const { error: taErr } = await supabase.from("tone_analysis").insert({
      message_id: messageId,
      empathy_score: empathy,
      clarity_score: clarity,
      assertiveness_score: assertiveness,
      warmth_score: warmth,
    });
    if (taErr) throw taErr;

    return json({
      success: true,
      data: {
        messageId,
        scores: { empathy, clarity, assertiveness, warmth },
      },
      error: null,
    });
  } catch (e) {
    const msg = e instanceof Error ? e.message : "Server error";
    console.error("analyze-tone:", msg);
    const status = msg === "Unauthorized" ? 401 : 400;
    return json({ success: false, data: null, error: msg }, status);
  }
});
