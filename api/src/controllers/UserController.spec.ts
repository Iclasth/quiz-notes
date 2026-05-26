import request from 'supertest';
import express from 'express';
import { UserController } from './UserController';
import { errorHandler } from '../middlewares/errorHandler';
import { UserService } from '../services/UserService';
import { NotFoundError } from '../errors/NotFoundError';
import { BadRequestError } from '../errors/BadRequestError';

jest.mock('../services/UserService');

const app = express();
app.use(express.json());

const userController = new UserController();
app.post('/api/users', userController.createUser);
app.get('/api/users/:id', userController.getUserById);
app.get('/api/users/:userId/stats', userController.getUserStats);
app.use(errorHandler);

describe('UserController', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    it('should create a user and return 201', async () => {
        const mockUser = { id_usuario: '123', nome: 'Test', email: 'test@test.com', senha: '123' };
        (UserService.prototype.createUser as jest.Mock).mockResolvedValue(mockUser);

        const response = await request(app)
            .post('/api/users')
            .send({ nome: 'Test', email: 'test@test.com', senha: '123' });

        expect(response.status).toBe(201);
        expect(response.body).toEqual(mockUser);
    });

    it('should return 400 if validation fails', async () => {
        (UserService.prototype.createUser as jest.Mock).mockRejectedValue(new BadRequestError('Nome, email e senha são obrigatórios'));

        const response = await request(app)
            .post('/api/users')
            .send({ nome: 'Test' });

        expect(response.status).toBe(400);
        expect(response.body.message).toBe('Nome, email e senha são obrigatórios');
    });

    it('should get a user by id and return 200', async () => {
        const mockUser = { id_usuario: '123', nome: 'Test', email: 'test@test.com' };
        (UserService.prototype.getUserById as jest.Mock).mockResolvedValue(mockUser);

        const response = await request(app).get('/api/users/123');

        expect(response.status).toBe(200);
        expect(response.body).toEqual(mockUser);
    });

    it('should return 404 if user not found', async () => {
        (UserService.prototype.getUserById as jest.Mock).mockRejectedValue(new NotFoundError('Usuário não encontrado'));

        const response = await request(app).get('/api/users/999');

        expect(response.status).toBe(404);
        expect(response.body.message).toBe('Usuário não encontrado');
    });

    it('should get user stats and return 200', async () => {
        const mockStats = {
            total_baralhos: 1,
            total_cards: 5,
            total_revisoes: 10,
            total_acertos: 8,
            total_erros: 2,
            taxa_acerto: 80.0,
            sequencia_dias: 3,
            dados_grafico: [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8]
        };
        (UserService.prototype.getUserStats as jest.Mock).mockResolvedValue(mockStats);

        const response = await request(app).get('/api/users/123/stats');

        expect(response.status).toBe(200);
        expect(response.body).toEqual(mockStats);
        expect(UserService.prototype.getUserStats).toHaveBeenCalledWith('123');
    });

    it('should return 404 if user not found when getting stats', async () => {
        (UserService.prototype.getUserStats as jest.Mock).mockRejectedValue(new NotFoundError('Usuário não encontrado'));

        const response = await request(app).get('/api/users/999/stats');

        expect(response.status).toBe(404);
        expect(response.body.message).toBe('Usuário não encontrado');
    });
});
