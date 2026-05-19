import request from 'supertest';
import express from 'express';
import { CardController } from './CardController';
import { errorHandler } from '../middlewares/errorHandler';
import { CardService } from '../services/CardService';
import { NotFoundError } from '../errors/NotFoundError';
import { BadRequestError } from '../errors/BadRequestError';

jest.mock('../services/CardService');

const app = express();
app.use(express.json());

const cardController = new CardController();
app.post('/api/decks/:deckId/cards', cardController.createCard);
app.use(errorHandler);

describe('CardController', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    it('should create a card and return 201', async () => {
        const mockCard = { id_card: '1', frente: 'Q', verso: 'A', id_baralho: '123' };
        (CardService.prototype.createCard as jest.Mock).mockResolvedValue(mockCard);

        const response = await request(app)
            .post('/api/decks/123/cards')
            .send({ frente: 'Q', verso: 'A' });

        expect(response.status).toBe(201);
        expect(response.body).toEqual(mockCard);
    });

    it('should return 400 if front or back is missing', async () => {
        (CardService.prototype.createCard as jest.Mock).mockRejectedValue(new BadRequestError('Frente e verso são obrigatórios'));

        const response = await request(app)
            .post('/api/decks/123/cards')
            .send({ frente: 'Q' });

        expect(response.status).toBe(400);
        expect(response.body.message).toBe('Frente e verso são obrigatórios');
    });

    it('should return 404 if deck not found', async () => {
        (CardService.prototype.createCard as jest.Mock).mockRejectedValue(new NotFoundError('Baralho não encontrado'));

        const response = await request(app)
            .post('/api/decks/999/cards')
            .send({ frente: 'Q', verso: 'A' });

        expect(response.status).toBe(404);
        expect(response.body.message).toBe('Baralho não encontrado');
    });
});
