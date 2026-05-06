import express, { Request, Response } from 'express';

const app = express();
const port = 3000;

app.use(express.json());

app.get('/api/ping', (req: Request, res: Response) => {
    res.json({
        message: 'Servidor funcionando',
        timestamp: new Date().toISOString()
    });
});

app.listen(port, () => {
    console.log(`[Servidor]: Rodando na porta http://localhost:${port}`);
});