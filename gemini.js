// JavaScript source code


import { GoogleGenAI } from "@google/genai";

const ai = new GoogleGenAI({
  apiKey: "AIzaSyC5gPnG3zqRh6oDY1w4B1E8iTZ91qagK6k",
});

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function run(retries = 3) {
  try {
    console.log("Calling API");

    const response = await ai.models.generateContent({
      model: "gemini-1.5-flash",
      contents: "Explain Supabase",
    });

    console.log("Success:");
    console.log(response.text);

  } catch (err) {
    if (err.status === 429 && retries > 0) {
      console.log(`Rate limit... retrying (${retries} left)`);

      await new Promise(r => setTimeout(r, 5000));

      return run(retries - 1);
    }

    console.error("FINAL ERROR:", err.message);
  }
}

run();