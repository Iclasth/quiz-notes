import { UserService } from './UserService';
import { Usuario } from '../model/Usuario';
import { Baralho } from '../model/Baralho';
import { Card } from '../model/Card';
import { HistoricoRevisao } from '../model/HistoricoRevisao';
import { Repository } from 'typeorm';
import { AppDataSource } from '../config/data-source';

jest.mock('../config/data-source', () => ({
    AppDataSource: {
        getRepository: jest.fn()
    }
}));

jest.mock('bcryptjs', () => ({
    hash: jest.fn().mockResolvedValue('hashed_password123'),
    compare: jest.fn()
}));

describe('UserService', () => {
    let userService: UserService;
    let userRepositoryMock: jest.Mocked<Repository<Usuario>>;
    let deckRepositoryMock: jest.Mocked<Repository<Baralho>>;
    let cardRepositoryMock: jest.Mocked<Repository<Card>>;
    let historicoRepositoryMock: jest.Mocked<Repository<HistoricoRevisao>>;

    beforeEach(() => {
        userRepositoryMock = {
            create: jest.fn(),
            save: jest.fn(),
            findOneBy: jest.fn(),
            find: jest.fn(),
        } as unknown as jest.Mocked<Repository<Usuario>>;

        deckRepositoryMock = {
            count: jest.fn(),
            find: jest.fn(),
        } as unknown as jest.Mocked<Repository<Baralho>>;

        cardRepositoryMock = {
            count: jest.fn(),
            find: jest.fn(),
        } as unknown as jest.Mocked<Repository<Card>>;

        historicoRepositoryMock = {
            find: jest.fn(),
            count: jest.fn(),
        } as unknown as jest.Mocked<Repository<HistoricoRevisao>>;

        (AppDataSource.getRepository as jest.Mock).mockImplementation((model) => {
            if (model === Usuario) return userRepositoryMock;
            if (model === Baralho) return deckRepositoryMock;
            if (model === Card) return cardRepositoryMock;
            if (model === HistoricoRevisao) return historicoRepositoryMock;
        });

        userService = new UserService();
    });

    it('should create a new user successfully', async () => {
        const userData = { nome: 'Test User', email: 'test@example.com', senha: 'password123' };
        const savedUser = { id_usuario: '123-uuid', ...userData, senha: 'hashed_password123', criado_em: new Date() } as Usuario;

        userRepositoryMock.create.mockReturnValue(savedUser);
        userRepositoryMock.save.mockResolvedValue(savedUser);

        const result = await userService.createUser(userData);

        expect(userRepositoryMock.create).toHaveBeenCalledWith({ ...userData, senha: 'hashed_password123' });
        expect(userRepositoryMock.save).toHaveBeenCalledWith(savedUser);
        expect(result).toEqual(savedUser);
    });

    it('should throw an error if email is missing', async () => {
        const userData = { nome: 'Test User', email: '', senha: 'password123' };

        await expect(userService.createUser(userData)).rejects.toThrow('Nome, email e senha são obrigatórios');
    });

    it('should fetch a user by id', async () => {
        const user = { id_usuario: '123-uuid', nome: 'Test', email: 'test@example.com', senha: '123', criado_em: new Date() } as Usuario;
        userRepositoryMock.findOneBy.mockResolvedValue(user);

        const result = await userService.getUserById('123-uuid');

        expect(userRepositoryMock.findOneBy).toHaveBeenCalledWith({ id_usuario: '123-uuid' });
        expect(result).toEqual(user);
    });

    it('should throw NotFoundError if user not found', async () => {
        userRepositoryMock.findOneBy.mockResolvedValue(null);

        await expect(userService.getUserById('invalid-uuid')).rejects.toThrow('Usuário não encontrado');
    });

    describe('getUserStats', () => {
        it('should throw NotFoundError if user not found for stats', async () => {
            userRepositoryMock.findOneBy.mockResolvedValue(null);

            await expect(userService.getUserStats('invalid-uuid')).rejects.toThrow('Usuário não encontrado');
        });

        it('should return user stats successfully', async () => {
            const userId = 'user-123';
            userRepositoryMock.findOneBy.mockResolvedValue({ id_usuario: userId } as Usuario);

            // Decks: total 3
            deckRepositoryMock.find.mockResolvedValue([
                { id_baralho: 'd1' },
                { id_baralho: 'd2' },
                { id_baralho: 'd3' }
            ] as Baralho[]);

            // Cards: total 5
            cardRepositoryMock.count.mockResolvedValue(5);
            cardRepositoryMock.find.mockResolvedValue([
                { id_card: 'c1', proxima_revisao: new Date() }, // due today
                { id_card: 'c2', proxima_revisao: new Date(Date.now() + 24 * 60 * 60 * 1000) }, // due tomorrow
                { id_card: 'c3' },
                { id_card: 'c4' },
                { id_card: 'c5' }
            ] as Card[]);

            // Historical reviews: total 3 (2 acertos, 1 erro)
            const dateToday = new Date();
            const dateYesterday = new Date(Date.now() - 24 * 60 * 60 * 1000);
            
            historicoRepositoryMock.find.mockResolvedValue([
                { id_card: 'c1', resultado: 'ACERTO', data_revisao: dateToday },
                { id_card: 'c2', resultado: 'ERRO', data_revisao: dateToday },
                { id_card: 'c1', resultado: 'ACERTO', data_revisao: dateYesterday }
            ] as HistoricoRevisao[]);

            const result = await userService.getUserStats(userId);

            expect(result.total_baralhos).toBe(3);
            expect(result.total_cards).toBe(5);
            expect(result.total_revisoes).toBe(3);
            expect(result.total_acertos).toBe(2);
            expect(result.total_erros).toBe(1);
            expect(result.taxa_acerto).toBeCloseTo(66.7, 1);
            expect(result.sequencia_dias).toBe(2); // today and yesterday
            expect(result.dados_grafico).toHaveLength(8);
        });
    });
});
