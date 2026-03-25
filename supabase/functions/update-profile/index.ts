import { handleCors, json, readJson } from "../_shared/http.ts";
import { requireUser } from "../_shared/auth.ts";
import { updateProfileBody } from "../_shared/schemas.ts";

Deno.serve(async (req) => {
  const c = handleCors(req);
  if (c) return c;
  if (req.method !== "POST") {
    return json({ success: false, data: null, error: "Method not allowed" }, 405);
  }

  try {
    const { user, supabase } = await requireUser(req);
    const raw = await readJson(req);
    const body = updateProfileBody.parse(raw);

    const patch: Record<string, unknown> = {
      updated_at: new Date().toISOString(),
    };
    if (body.communication_goal != null) {
      patch.communication_goal = body.communication_goal;
    }
    if (body.tone_style != null) patch.tone_style = body.tone_style;
    if (body.challenges != null) patch.challenges = body.challenges;
    if (body.name != null) patch.name = body.name;

    const { error } = await supabase
      .from("users")
      .update(patch)
      .eq("id", user.id);
    if (error) throw error;

    return json({ success: true, data: { ok: true }, error: null });
  } catch (e) {
    const msg = e instanceof Error ? e.message : "Server error";
    console.error("update-profile:", msg);
    const status = msg === "Unauthorized" ? 401 : 400;
    return json({ success: false, data: null, error: msg }, status);
  }
});
