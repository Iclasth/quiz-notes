import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn, OneToMany } from 'typeorm';
import { Baralho } from './Baralho';
import { HistoricoRevisao } from './HistoricoRevisao';

@Entity('cards')
export class Card {
    @PrimaryGeneratedColumn('uuid', { name: 'id_card' })
    id_card!: string;

    @Column('text')
    frente!: string;

    @Column('text')
    verso!: string;

    @Column('int4', { default: 0 })
    desempenho!: number;

    @Column('int4', { default: 0 })
    acertos!: number;

    @Column('int4', { default: 0 })
    erros!: number;

    @Column('int4', { default: 0 })
    intervalo!: number;

    @Column('timestamptz', { nullable: true })
    proxima_revisao!: Date;

    @Column('text', { nullable: true })
    imagem_url!: string;

    @Column('uuid')
    id_baralho!: string;

    @CreateDateColumn({ type: 'timestamptz', name: 'criado_em' })
    criado_em!: Date;

    @ManyToOne(() => Baralho, (baralho) => baralho.cards, { onDelete: 'CASCADE' })
    @JoinColumn({ name: 'id_baralho' })
    baralho!: Baralho;

    @OneToMany(() => HistoricoRevisao, (historico) => historico.card)
    historico_revisoes!: HistoricoRevisao[];
}
