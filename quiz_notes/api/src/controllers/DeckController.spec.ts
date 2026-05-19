import request from 'supertest';
import express from 'express';
import { DeckController } from './DeckController';
import { errorHandler } from '../middlewares/errorHandler';
import { DeckService } from '../services/DeckService';
import { NotFoundError } from '../errors/NotFoundError';
import { BadRequestError } from '../errors/BadRequestError';

jest.mock('../services/DeckService');

const app = express();
app.use(express.json());

const deckController = new DeckController();
app.post('/api/users/:userId/decks', deckController.createDeck);
app.get('/api/users/:userId/decks', deckController.getUserDecks);
app.use(errorHandler);

describe('DeckController', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    it('should create a deck and return 201', async () => {
        const mockDeck = { id_baralho: '1', nome: 'Test Deck', id_usuario: '123' };
        (DeckService.prototype.createDeck as jest.Mock).mockResolvedValue(mockDeck);

        const response = await request(app)
            .post('/api/users/123/decks')
            .send({ nome: 'Test Deck' });

        expect(response.status).toBe(201);
        expect(response.body).toEqual(mockDeck);
    });

    it('should return 400 if deck name is missing', async () => {
        (DeckService.prototype.createDeck as jest.Mock).mockRejectedValue(new BadRequestError('O nome do baralho é obrigatório'));

        const response = await request(app)
            .post('/api/users/123/decks')
            .send({});

        expect(response.status).toBe(400);
        expect(response.body.message).toBe('O nome do baralho é obrigatório');
    });

    it('should get user decks and return 200', async () => {
        const mockDecks = [{ id_baralho: '1', nome: 'D1' }];
        (DeckService.prototype.getUserDecks as jest.Mock).mockResolvedValue(mockDecks);

        const response = await request(app).get('/api/users/123/decks');

        expect(response.status).toBe(200);
        expect(response.body).toEqual(mockDecks);
    });

    it('should return 404 if user not found when creating deck', async () => {
        (DeckService.prototype.createDeck as jest.Mock).mockRejectedValue(new NotFoundError('Usuário não encontrado'));

        const response = await request(app)
            .post('/api/users/999/decks')
            .send({ nome: 'Test Deck' });

        expect(response.status).toBe(404);
        expect(response.body.message).toBe('Usuário não encontrado');
    });
});
