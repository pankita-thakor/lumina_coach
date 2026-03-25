const CLAUDE_URL = "https://api.anthropic.com/v1/messages";
export const CLAUDE_MODEL = "claude-3-5-haiku-20241022";

type Msg = { role: "user" | "assistant"; content: string };

export async function callClaude(
  apiKey: string,
  system: string,
  messages: Msg[],
  maxTokens = 4096,
): Promise<string> {
  let lastErr: Error | null = null;
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      const r = await fetch(CLAUDE_URL, {
        method: "POST",
        headers: {
          "x-api-key": apiKey,
          "anthropic-version": "2023-06-01",
          "content-type": "application/json",
        },
        body: JSON.stringify({
          model: CLAUDE_MODEL,
          max_tokens: maxTokens,
          system,
          messages,
        }),
      });
      if (!r.ok) {
        const t = await r.text();
        throw new Error(`Claude ${r.status}: ${t.slice(0, 500)}`);
      }
      const j = await r.json();
      const blocks = j.content as Array<{ type: string; text?: string }>;
      const text = blocks?.find((b) => b.type === "text")?.text ?? "";
      return text.trim();
    } catch (e) {
      lastErr = e as Error;
      if (attempt < 2) await new Promise((r) => setTimeout(r, 400 * (attempt + 1)));
    }
  }
  throw lastErr ?? new Error("Claude call failed");
}

export function parseJsonFromText(text: string): Record<string, unknown> {
  const start = text.indexOf("{");
  const end = text.lastIndexOf("}");
  if (start === -1 || end === -1 || end <= start) {
    throw new Error("Model did not return JSON");
  }
  return JSON.parse(text.slice(start, end + 1)) as Record<string, unknown>;
}
