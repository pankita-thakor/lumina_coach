import Groq from "groq-sdk";

const groq = new Groq({
  apiKey: "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",
});

async function run() {
  const response = await groq.chat.completions.create({
    model: "llama-3.3-70b-versatile",
    messages: [
      {
        role: "user",
        content: "Explain Supabase in simple terms",
      },
    ],
  });

  console.log(response.choices[0].message.content);
}

run();