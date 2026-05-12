import 'dotenv/config';
import 'reflect-metadata';
import express from 'express';
import cors from 'cors';
import { AppDataSource } from './config/data-source';
import { router } from './routes';
import { errorHandler } from './middlewares/errorHandler';

const app = express();
const port = process.env.PORT ?? 3000;

app.use(cors());
app.use(express.json());

app.use('/api', router);

app.use(errorHandler);

AppDataSource.initialize()
    .then(() => {
        console.log('[Banco]: Conectado ao PostgreSQL com sucesso');
        app.listen(port, () => {
            console.log(`[Servidor]: Rodando em http://localhost:${port}`);
        });
    })
    .catch((err) => {
        console.error('[Banco]: Falha ao conectar ao PostgreSQL', err);
        process.exit(1);
    });

export { app };