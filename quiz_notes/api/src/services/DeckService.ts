import { AppDataSource } from '../config/data-source';
import { Baralho } from '../model/Baralho';
import { Usuario } from '../model/Usuario';
import { NotFoundError } from '../errors/NotFoundError';
import { BadRequestError } from '../errors/BadRequestError';

export class DeckService {
    private get deckRepository() {
        return AppDataSource.getRepository(Baralho);
    }

    private get userRepository() {
        return AppDataSource.getRepository(Usuario);
    }

    async createDeck(userId: string, nome: string): Promise<Baralho> {
        if (!nome) {
            throw new BadRequestError('O nome do baralho é obrigatório');
        }

        const user = await this.userRepository.findOneBy({ id_usuario: userId });
        if (!user) {
            throw new NotFoundError('Usuário não encontrado');
        }

        const newDeck = this.deckRepository.create({ nome, id_usuario: userId });
        return await this.deckRepository.save(newDeck);
    }

    async getUserDecks(userId: string): Promise<Baralho[]> {
        return await this.deckRepository.find({ where: { id_usuario: userId } });
    }
}
