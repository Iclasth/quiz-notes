import { AppDataSource } from '../config/data-source';
import { Usuario } from '../model/Usuario';
import { Baralho } from '../model/Baralho';
import { Card } from '../model/Card';
import { HistoricoRevisao } from '../model/HistoricoRevisao';
import { BadRequestError } from '../errors/BadRequestError';
import { NotFoundError } from '../errors/NotFoundError';
import * as bcrypt from 'bcryptjs';

export class UserService {
    private get userRepository() {
        return AppDataSource.getRepository(Usuario);
    }

    async createUser(data: Partial<Usuario>): Promise<Usuario> {
        if (!data.nome || !data.email || !data.senha) {
            throw new BadRequestError('Nome, email e senha são obrigatórios');
        }

        const hashedPassword = await bcrypt.hash(data.senha, 10);
        const newUser = this.userRepository.create({ ...data, senha: hashedPassword });
        return await this.userRepository.save(newUser);
    }

    async login(email?: string, senha?: string): Promise<Usuario> {
        if (!email || !senha) {
            throw new BadRequestError('Email e senha são obrigatórios');
        }

        const user = await this.userRepository.findOneBy({ email });
        if (!user) {
            throw new BadRequestError('Credenciais inválidas');
        }

        const isPasswordValid = await bcrypt.compare(senha, user.senha);
        if (!isPasswordValid) {
            throw new BadRequestError('Credenciais inválidas');
        }

        return user;
    }

    async getUserById(id: string): Promise<Usuario> {
        const user = await this.userRepository.findOneBy({ id_usuario: id });
        if (!user) {
            throw new NotFoundError('Usuário não encontrado');
        }
        return user;
    }

    async getUserStats(userId: string): Promise<any> {
        const user = await this.userRepository.findOneBy({ id_usuario: userId });
        if (!user) {
            throw new NotFoundError('Usuário não encontrado');
        }

        const deckRepository = AppDataSource.getRepository(Baralho);
        const cardRepository = AppDataSource.getRepository(Card);
        const historicoRepository = AppDataSource.getRepository(HistoricoRevisao);

        const decks = await deckRepository.find({ where: { id_usuario: userId } });
        const deckIds = decks.map(d => d.id_baralho);

        let totalCards = 0;
        let totalRevisoes = 0;
        let totalAcertos = 0;
        let totalErros = 0;
        let sequenciaDias = 0;
        const dadosGrafico: number[] = Array(8).fill(0.0);

        if (deckIds.length > 0) {
            const cards = await cardRepository.find({
                where: deckIds.map(id => ({ id_baralho: id }))
            });
            totalCards = cards.length;
            const cardIds = cards.map(c => c.id_card);

            if (cardIds.length > 0) {
                const reviews = await historicoRepository.find({
                    where: cardIds.map(id => ({ id_card: id })),
                    order: { data_revisao: 'DESC' }
                });
                totalRevisoes = reviews.length;
                totalAcertos = reviews.filter(r => r.resultado === 'ACERTO').length;
                totalErros = reviews.filter(r => r.resultado === 'ERRO').length;

                const uniqueDates = new Set<string>();
                reviews.forEach(r => {
                    const dateStr = new Date(r.data_revisao).toISOString().split('T')[0]!;
                    uniqueDates.add(dateStr);
                });

                const todayStr = new Date().toISOString().split('T')[0]!;
                const yesterdayStr = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString().split('T')[0]!;

                if (uniqueDates.has(todayStr) || uniqueDates.has(yesterdayStr)) {
                    let checkDate = uniqueDates.has(todayStr) ? new Date() : new Date(Date.now() - 24 * 60 * 60 * 1000);
                    while (true) {
                        const checkStr = checkDate.toISOString().split('T')[0]!;
                        if (uniqueDates.has(checkStr)) {
                            sequenciaDias++;
                            checkDate.setDate(checkDate.getDate() - 1);
                        } else {
                            break;
                        }
                    }
                }

                const absoluteCounts = Array(8).fill(0);

                for (let i = 0; i < 4; i++) {
                    const diffDays = i - 3;
                    const targetDateStr = new Date(Date.now() + diffDays * 24 * 60 * 60 * 1000).toISOString().split('T')[0]!;
                    absoluteCounts[i] = reviews.filter(r => {
                        const rDateStr = new Date(r.data_revisao).toISOString().split('T')[0]!;
                        return rDateStr === targetDateStr;
                    }).length;
                }

                for (let i = 4; i < 8; i++) {
                    const diffDays = i - 3;
                    const targetDateStr = new Date(Date.now() + diffDays * 24 * 60 * 60 * 1000).toISOString().split('T')[0]!;
                    absoluteCounts[i] = cards.filter(c => {
                        if (!c.proxima_revisao) return false;
                        const cDateStr = new Date(c.proxima_revisao).toISOString().split('T')[0]!;
                        return cDateStr === targetDateStr;
                    }).length;
                }

                const maxCount = Math.max(...absoluteCounts);
                for (let i = 0; i < 8; i++) {
                    dadosGrafico[i] = maxCount > 0 ? Number((absoluteCounts[i] / maxCount).toFixed(2)) : 0.0;
                }
            }
        }

        const taxaAcerto = totalRevisoes > 0 ? Number(((totalAcertos / totalRevisoes) * 100).toFixed(1)) : 0.0;

        return {
            total_baralhos: decks.length,
            total_cards: totalCards,
            total_revisoes: totalRevisoes,
            total_acertos: totalAcertos,
            total_erros: totalErros,
            taxa_acerto: taxaAcerto,
            sequencia_dias: sequenciaDias,
            dados_grafico: dadosGrafico
        };
    }
}
