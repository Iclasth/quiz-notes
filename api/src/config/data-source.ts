import 'dotenv/config';
import { DataSource } from 'typeorm';

export const AppDataSource = new DataSource({
    type: 'postgres',
    url: process.env.POSTGRES_URL,
    synchronize: true, // Use only in dev, syncs schema automatically
    logging: false,
    entities: [__dirname + '/../model/*.ts'],
    subscribers: [],
    migrations: [],
});
