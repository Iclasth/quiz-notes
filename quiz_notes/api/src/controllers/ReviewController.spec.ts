import request from 'supertest';
import express from 'express';
import { ReviewController } from './ReviewController';
import { errorHandler } from '../middlewares/errorHandler';
import { ReviewService } from '../services/ReviewService';
import { NotFoundError } from '../errors/NotFoundError';
import { BadRequestError } from '../errors/BadRequestError';

jest.mock('../services/ReviewService');

const app = express();
app.use(express.json());

const reviewController = new ReviewController();
app.get('/api/decks/:deckId/revisao', reviewController.getCardsForReview);
app.post('/api/cards/:cardId/revisao', reviewController.submitReview);
app.use(errorHandler);

describe('ReviewController', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    it('deve retornar os cards para revisao com status 200', async () => {
        const mockCards = [{ id_card: '1', frente: 'Q', verso: 'A' }];
        (ReviewService.prototype.getCardsForReview as jest.Mock).mockResolvedValue(mockCards);

        const response = await request(app).get('/api/decks/deck-1/revisao');

        expect(response.status).toBe(200);
        expect(response.body).toEqual(mockCards);
    });

    it('deve processar uma revisao e retornar 200', async () => {
        const mockCard = { id_card: '1', intervalo: 1, acertos: 1 };
        (ReviewService.prototype.submitReview as jest.Mock).mockResolvedValue(mockCard);

        const response = await request(app)
            .post('/api/cards/1/revisao')
            .send({ qualidade: 5 });

        expect(response.status).toBe(200);
        expect(response.body).toEqual(mockCard);
    });

    it('deve retornar 400 se a qualidade for invalida', async () => {
        (ReviewService.prototype.submitReview as jest.Mock).mockRejectedValue(
            new BadRequestError('Qualidade deve ser entre 0 e 5')
        );

        const response = await request(app)
            .post('/api/cards/1/revisao')
            .send({ qualidade: 9 });

        expect(response.status).toBe(400);
        expect(response.body.message).toBe('Qualidade deve ser entre 0 e 5');
    });

    it('deve retornar 404 se o card nao existir', async () => {
        (ReviewService.prototype.submitReview as jest.Mock).mockRejectedValue(
            new NotFoundError('Cartão não encontrado')
        );

        const response = await request(app)
            .post('/api/cards/999/revisao')
            .send({ qualidade: 3 });

        expect(response.status).toBe(404);
        expect(response.body.message).toBe('Cartão não encontrado');
    });
});
