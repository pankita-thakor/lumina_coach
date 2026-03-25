import { handleCors, json, readJson } from "../_shared/http.ts";
import { requireUser } from "../_shared/auth.ts";
import { listMessagesBody } from "../_shared/schemas.ts";

Deno.serve(async (req) => {
  const c = handleCors(req);
  if (c) return c;
  if (req.method !== "POST") {
    return json({ success: false, data: null, error: "Method not allowed" }, 405);
  }

  try {
    const { user, supabase } = await requireUser(req);
    const raw = await readJson(req);
    const q = listMessagesBody.parse(raw);

    const { data: rows, error } = await supabase
      .from("messages")
      .select("id, content, context, created_at")
      .eq("user_id", user.id)
      .order("created_at", { ascending: false })
      .range(q.offset, q.offset + q.limit - 1);
    if (error) throw error;

    return json({
      success: true,
      data: { items: rows ?? [] },
      error: null,
    });
  } catch (e) {
    const msg = e instanceof Error ? e.message : "Server error";
    console.error("list-messages:", msg);
    const status = msg === "Unauthorized" ? 401 : 400;
    return json({ success: false, data: null, error: msg }, status);
  }
});
