import 'dotenv/config';
import { DataSource } from 'typeorm';

export const AppDataSource = new DataSource({
    type: 'postgres',
    url: process.env.POSTGRES_URL!,
    synchronize: true, 
    logging: false,
    ssl: { rejectUnauthorized: false }, 
    entities: [__dirname + '/../model/*.{ts,js}'],
    subscribers: [],
    migrations: [],
});
