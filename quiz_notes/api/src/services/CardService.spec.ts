import { CardService } from './CardService';
import { Card } from '../model/Card';
import { Baralho } from '../model/Baralho';
import { Repository } from 'typeorm';
import { AppDataSource } from '../config/data-source';

jest.mock('../config/data-source', () => ({
    AppDataSource: {
        getRepository: jest.fn()
    }
}));

describe('CardService', () => {
    let cardService: CardService;
    let cardRepositoryMock: jest.Mocked<Repository<Card>>;
    let deckRepositoryMock: jest.Mocked<Repository<Baralho>>;

    beforeEach(() => {
        cardRepositoryMock = {
            create: jest.fn(),
            save: jest.fn(),
            find: jest.fn(),
            findOneBy: jest.fn(),
        } as unknown as jest.Mocked<Repository<Card>>;

        deckRepositoryMock = {
            findOneBy: jest.fn(),
        } as unknown as jest.Mocked<Repository<Baralho>>;

        (AppDataSource.getRepository as jest.Mock).mockImplementation((model) => {
            if (model === Card) return cardRepositoryMock;
            if (model === Baralho) return deckRepositoryMock;
        });

        cardService = new CardService();
    });

    it('should create a card successfully with default SM-2 values', async () => {
        const deckId = 'deck-123';
        const cardData = { frente: 'Q', verso: 'A' };
        
        deckRepositoryMock.findOneBy.mockResolvedValue({ id_baralho: deckId } as Baralho);
        cardRepositoryMock.create.mockReturnValue({ ...cardData, id_baralho: deckId } as Card);
        cardRepositoryMock.save.mockResolvedValue({ id_card: 'card-1', ...cardData, id_baralho: deckId, desempenho: 0, acertos: 0, erros: 0, intervalo: 0 } as Card);

        const result = await cardService.createCard(deckId, cardData.frente, cardData.verso);

        expect(cardRepositoryMock.create).toHaveBeenCalledWith({ 
            frente: 'Q', 
            verso: 'A', 
            id_baralho: deckId,
            desempenho: 0,
            acertos: 0,
            erros: 0,
            intervalo: 0
        });
        expect(cardRepositoryMock.save).toHaveBeenCalled();
        expect(result.frente).toBe('Q');
        expect(result.intervalo).toBe(0);
    });

    it('should throw NotFoundError if deck does not exist', async () => {
        deckRepositoryMock.findOneBy.mockResolvedValue(null);

        await expect(cardService.createCard('invalid-deck', 'Q', 'A')).rejects.toThrow('Baralho não encontrado');
    });

    it('should throw BadRequestError if front or back is missing', async () => {
        await expect(cardService.createCard('deck-123', '', 'A')).rejects.toThrow('Frente e verso são obrigatórios');
    });
});
