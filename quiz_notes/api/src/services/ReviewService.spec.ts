import { ReviewService } from './ReviewService';
import { Card } from '../model/Card';
import { HistoricoRevisao } from '../model/HistoricoRevisao';
import { Repository } from 'typeorm';
import { AppDataSource } from '../config/data-source';

jest.mock('../config/data-source', () => ({
    AppDataSource: {
        getRepository: jest.fn()
    }
}));

describe('ReviewService', () => {
    let reviewService: ReviewService;
    let cardRepositoryMock: jest.Mocked<Repository<Card>>;
    let historicoRepositoryMock: jest.Mocked<Repository<HistoricoRevisao>>;

    beforeEach(() => {
        cardRepositoryMock = {
            findOneBy: jest.fn(),
            find: jest.fn(),
            save: jest.fn(),
        } as unknown as jest.Mocked<Repository<Card>>;

        historicoRepositoryMock = {
            create: jest.fn(),
            save: jest.fn(),
        } as unknown as jest.Mocked<Repository<HistoricoRevisao>>;

        (AppDataSource.getRepository as jest.Mock).mockImplementation((model) => {
            if (model === Card) return cardRepositoryMock;
            if (model === HistoricoRevisao) return historicoRepositoryMock;
        });

        reviewService = new ReviewService();
    });

    it('should get cards for review', async () => {
        const cards = [{ id_card: '1' }] as Card[];
        cardRepositoryMock.find.mockResolvedValue(cards);

        const result = await reviewService.getCardsForReview('deck-1');

        expect(cardRepositoryMock.find).toHaveBeenCalled();
        expect(result).toEqual(cards);
    });

    it('should submit a perfect review and increase interval (quality 5)', async () => {
        const card = { id_card: '1', desempenho: 250, acertos: 0, erros: 0, intervalo: 0 } as Card;
        cardRepositoryMock.findOneBy.mockResolvedValue(card);
        cardRepositoryMock.save.mockResolvedValue({ ...card, intervalo: 1 } as Card);

        await reviewService.submitReview('1', 5);

        expect(cardRepositoryMock.save).toHaveBeenCalled();
        const savedCard = cardRepositoryMock.save.mock.calls[0][0] as Card;
        expect(savedCard.intervalo).toBe(1);
        expect(savedCard.acertos).toBe(1);
        expect(savedCard.desempenho).toBeGreaterThanOrEqual(250); // Ease factor increases or stays 2.5
        expect(historicoRepositoryMock.create).toHaveBeenCalled();
        expect(historicoRepositoryMock.save).toHaveBeenCalled();
    });

    it('should submit a bad review and reset interval (quality 0)', async () => {
        const card = { id_card: '1', desempenho: 250, acertos: 1, erros: 0, intervalo: 6 } as Card;
        cardRepositoryMock.findOneBy.mockResolvedValue(card);
        cardRepositoryMock.save.mockResolvedValue(card);

        await reviewService.submitReview('1', 0);

        const savedCard = cardRepositoryMock.save.mock.calls[0][0] as Card;
        expect(savedCard.intervalo).toBe(1); // Reset to 1 day
        expect(savedCard.erros).toBe(1);
        expect(savedCard.desempenho).toBeLessThan(250); // Ease factor decreases
    });

    it('should throw error if quality is invalid', async () => {
        await expect(reviewService.submitReview('1', 6)).rejects.toThrow('Qualidade deve ser entre 0 e 5');
    });

    it('should throw NotFoundError if card does not exist', async () => {
        cardRepositoryMock.findOneBy.mockResolvedValue(null);

        await expect(reviewService.submitReview('invalid', 5)).rejects.toThrow('Cartão não encontrado');
    });
});
