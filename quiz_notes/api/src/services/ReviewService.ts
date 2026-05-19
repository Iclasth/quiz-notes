import { AppDataSource } from '../config/data-source';
import { Card } from '../model/Card';
import { HistoricoRevisao } from '../model/HistoricoRevisao';
import { NotFoundError } from '../errors/NotFoundError';
import { BadRequestError } from '../errors/BadRequestError';
import { LessThanOrEqual } from 'typeorm';

export class ReviewService {
    private get cardRepository() {
        return AppDataSource.getRepository(Card);
    }

    private get historicoRepository() {
        return AppDataSource.getRepository(HistoricoRevisao);
    }

    async getCardsForReview(deckId: string): Promise<Card[]> {
        const now = new Date();
        return await this.cardRepository.find({
            where: [
                { id_baralho: deckId, proxima_revisao: LessThanOrEqual(now) },
                { id_baralho: deckId, proxima_revisao: null as any }
            ]
        });
    }

    async submitReview(cardId: string, quality: number): Promise<Card> {
        if (quality < 0 || quality > 5) {
            throw new BadRequestError('Qualidade deve ser entre 0 e 5');
        }

        const card = await this.cardRepository.findOneBy({ id_card: cardId });
        if (!card) {
            throw new NotFoundError('Cartão não encontrado');
        }

        // SM-2 Algorithm implementation
        let { desempenho, intervalo, acertos, erros } = card;

        // Default ease factor is 250 (which represents 2.5) if not initialized (i.e. 0)
        if (desempenho === 0) desempenho = 250;

        if (quality >= 3) {
            if (acertos === 0) {
                intervalo = 1;
            } else if (acertos === 1) {
                intervalo = 6;
            } else {
                intervalo = Math.round(intervalo * (desempenho / 100));
            }
            acertos++;
        } else {
            acertos = 0;
            intervalo = 1;
            erros++;
        }

        desempenho = desempenho + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02)) * 100;
        
        if (desempenho < 130) desempenho = 130; // Minimum ease factor is 1.3

        card.desempenho = Math.round(desempenho);
        card.intervalo = intervalo;
        card.acertos = acertos;
        card.erros = erros;

        const nextReview = new Date();
        nextReview.setDate(nextReview.getDate() + intervalo);
        card.proxima_revisao = nextReview;

        await this.cardRepository.save(card);

        const historico = this.historicoRepository.create({
            id_card: card.id_card,
            resultado: quality >= 3 ? 'ACERTO' : 'ERRO',
            data_revisao: new Date()
        });
        await this.historicoRepository.save(historico);

        return card;
    }
}
