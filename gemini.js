// JavaScript source code

import { GoogleGenAI } from "@google/genai";

const ai = new GoogleGenAI({
  apiKey: "AIzaSyC5gPnG3zqRh6oDY1w4B1E8iTZ91qagK6k",
});

async function run() {
  const response = await ai.models.generateContent({
    model: "gemini-2.0-flash",
    contents: "Explain Supabase CLI",
  });

  console.log(response.text);
}

run();