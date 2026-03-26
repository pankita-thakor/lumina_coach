import express from "express";
import fetch from "node-fetch";

const app = express();

const FIGMA_TOKEN = "figd_8n96nxbfTz_N1kri4VviYPIvwNmVJ6sisYpXgO38";
const FILE_KEY = "obc5cR4vIWH6m6YLjGMtr8";

app.get("/figma", async (req, res) => {
  try {
    const response = await fetch(
      `https://api.figma.com/v1/files/${FILE_KEY}`,
      {
        headers: {
          "X-Figma-Token": FIGMA_TOKEN,
        },
      }
    );

    const data = await response.json();
    res.json(data);
  } catch (err) {
    res.status(500).send(err.toString());
  }
});

app.listen(3000, () => {
  console.log("MCP Server running on http://localhost:3000");
});