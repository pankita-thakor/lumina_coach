import { handleCors, json, readJson } from "../_shared/http.ts";
import { requireUser } from "../_shared/auth.ts";
import { callGemini } from "../_shared/gemini.ts";
import { rateLimitHit } from "../_shared/rate_limit.ts";
import { insightsBody } from "../_shared/schemas.ts";

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
    if (rateLimitHit(user.id, "insights")) {
      return json({ success: false, data: null, error: "Rate limit exceeded" }, 429);
    }

    let raw: unknown = {};
    try {
      raw = await readJson(req);
    } catch { /* empty body ok */ }
    insightsBody.parse(raw);

    const since = new Date(Date.now() - 7 * 24 * 3600 * 1000).toISOString();
    const { data: rows, error: qErr } = await supabase
      .from("messages")
      .select("content, context, created_at")
      .gte("created_at", since)
      .order("created_at", { ascending: false })
      .limit(60);
    if (qErr) throw qErr;

    const compact = (rows ?? [])
      .map((r) => `[${r.context}] ${String(r.content).slice(0, 400)}`)
      .join("\n---\n")
      .slice(0, 12_000);

    const sys =
      "You produce a concise coaching summary for the past week. Plain text only. Three short sections separated by blank lines: (1) headline title line, (2) 2-4 sentences overview, (3) bullet lines starting with '- ' for patterns and next steps. No JSON.";
    const summary = await callGemini(
      geminiKey,
      sys,
      [
        {
          role: "user",
          content: `Snippets from the user's drafts (last 7 days):\n${compact || "(no activity yet — encourage practice)"}`,
        },
      ],
      1200,
    );

    const { error: insErr } = await supabase.from("insights").insert({
      user_id: user.id,
      summary: summary.trim(),
    });
    if (insErr) throw insErr;

    return json({
      success: true,
      data: { summary: summary.trim() },
      error: null,
    });
  } catch (e) {
    const msg = e instanceof Error ? e.message : "Server error";
    console.error("insights:", msg);
    const status = msg === "Unauthorized" ? 401 : 400;
    return json({ success: false, data: null, error: msg }, status);
  }
});
