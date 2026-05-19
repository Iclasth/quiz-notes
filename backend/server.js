const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const { createClient } = require("@supabase/supabase-js");

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_KEY,
);

app.get("/", (req, res) => {
  res.send("API Quiz Notes funcionando");
});

app.get("/baralhos", async (req, res) => {
  const { data, error } = await supabase.from("baralhos").select("*");

  if (error) {
    return res.status(500).json({ erro: error.message });
  }

  return res.json(data);
});

app.get("/baralhos/:id/cards", async (req, res) => {
  const { id } = req.params;

  const { data, error } = await supabase
    .from("cards")
    .select("*")
    .eq("id_baralho", id);

  if (error) {
    return res.status(500).json({ erro: error.message });
  }

  return res.json(data);
});

app.post("/revisoes", async (req, res) => {
  const { id_card, resultado } = req.body;

  if (!id_card || !resultado) {
    return res.status(400).json({
      erro: "id_card e resultado são obrigatórios",
    });
  }

  const { data, error } = await supabase
    .from("historico_revisoes")
    .insert([
      {
        id_card,
        resultado,
      },
    ])
    .select();

  if (error) {
    return res.status(500).json({ erro: error.message });
  }

  return res.status(201).json(data[0]);
});

const port = process.env.PORT || 3000;

app.listen(port, () => {
  console.log(`Servidor rodando na porta ${port}`);
});
