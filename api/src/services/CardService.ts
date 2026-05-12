import { AppDataSource } from '../config/data-source';
import { Card } from '../model/Card';
import { Baralho } from '../model/Baralho';
import { NotFoundError } from '../errors/NotFoundError';
import { BadRequestError } from '../errors/BadRequestError';

export class CardService {
    private get cardRepository() {
        return AppDataSource.getRepository(Card);
    }

    private get deckRepository() {
        return AppDataSource.getRepository(Baralho);
    }

    async createCard(deckId: string, frente: string, verso: string): Promise<Card> {
        if (!frente || !verso) {
            throw new BadRequestError('Frente e verso são obrigatórios');
        }

        const deck = await this.deckRepository.findOneBy({ id_baralho: deckId });
        if (!deck) {
            throw new NotFoundError('Baralho não encontrado');
        }

        const newCard = this.cardRepository.create({
            frente,
            verso,
            id_baralho: deckId,
            desempenho: 0,
            acertos: 0,
            erros: 0,
            intervalo: 0,
        });

        return await this.cardRepository.save(newCard);
    }
}
