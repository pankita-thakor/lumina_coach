const GEMINI_URL =
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

type Msg = { role: "user" | "assistant"; content: string };

export async function callGemini(
  apiKey: string,
  system: string,
  messages: Msg[],
  maxTokens = 4096,
): Promise<string> {
  const contents = messages.map((m) => ({
    role: m.role === "assistant" ? "model" : "user",
    parts: [{ text: m.content }],
  }));

  const r = await fetch(`${GEMINI_URL}?key=${apiKey}`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({
      system_instruction: { parts: [{ text: system }] },
      contents,
      generationConfig: { maxOutputTokens: maxTokens },
    }),
  });

  if (!r.ok) {
    const t = await r.text();
    throw new Error(`Gemini ${r.status}: ${t.slice(0, 500)}`);
  }

  const j = await r.json();
  const text: string = j.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
  return text.trim();
}

export function parseJsonFromText(text: string): Record<string, unknown> {
  const start = text.indexOf("{");
  const end = text.lastIndexOf("}");
  if (start === -1 || end === -1 || end <= start) {
    throw new Error("Model did not return JSON");
  }
  return JSON.parse(text.slice(start, end + 1)) as Record<string, unknown>;
}
