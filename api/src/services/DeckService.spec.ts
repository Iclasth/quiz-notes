import { DeckService } from './DeckService';
import { Baralho } from '../model/Baralho';
import { Usuario } from '../model/Usuario';
import { Repository } from 'typeorm';
import { AppDataSource } from '../config/data-source';

jest.mock('../config/data-source', () => ({
    AppDataSource: {
        getRepository: jest.fn()
    }
}));

describe('DeckService', () => {
    let deckService: DeckService;
    let deckRepositoryMock: jest.Mocked<Repository<Baralho>>;
    let userRepositoryMock: jest.Mocked<Repository<Usuario>>;

    beforeEach(() => {
        deckRepositoryMock = {
            create: jest.fn(),
            save: jest.fn(),
            find: jest.fn(),
            findOneBy: jest.fn(),
        } as unknown as jest.Mocked<Repository<Baralho>>;

        userRepositoryMock = {
            findOneBy: jest.fn(),
        } as unknown as jest.Mocked<Repository<Usuario>>;

        (AppDataSource.getRepository as jest.Mock).mockImplementation((model) => {
            if (model === Baralho) return deckRepositoryMock;
            if (model === Usuario) return userRepositoryMock;
        });

        deckService = new DeckService();
    });

    it('should create a deck successfully', async () => {
        const userId = '123-uuid';
        const deckData = { nome: 'My Deck' };
        
        userRepositoryMock.findOneBy.mockResolvedValue({ id_usuario: userId } as Usuario);
        deckRepositoryMock.create.mockReturnValue({ ...deckData, id_usuario: userId } as Baralho);
        deckRepositoryMock.save.mockResolvedValue({ id_baralho: 'deck-123', ...deckData, id_usuario: userId } as Baralho);

        const result = await deckService.createDeck(userId, deckData.nome);

        expect(deckRepositoryMock.create).toHaveBeenCalledWith({ nome: deckData.nome, id_usuario: userId });
        expect(deckRepositoryMock.save).toHaveBeenCalled();
        expect(result.id_baralho).toBe('deck-123');
    });

    it('should throw NotFoundError when creating deck for non-existent user', async () => {
        userRepositoryMock.findOneBy.mockResolvedValue(null);

        await expect(deckService.createDeck('invalid-user', 'Deck')).rejects.toThrow('Usuário não encontrado');
    });

    it('should return user decks', async () => {
        const decks = [{ id_baralho: '1', nome: 'D1' }, { id_baralho: '2', nome: 'D2' }] as Baralho[];
        deckRepositoryMock.find.mockResolvedValue(decks);

        const result = await deckService.getUserDecks('user-1');

        expect(deckRepositoryMock.find).toHaveBeenCalledWith({ where: { id_usuario: 'user-1' } });
        expect(result).toEqual(decks);
    });
});
