import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Card } from './Card';

@Entity('historico_revisoes')
export class HistoricoRevisao {
    @PrimaryGeneratedColumn('uuid', { name: 'id_historico' })
    id_historico!: string;

    @Column('uuid')
    id_card!: string;

    @Column('text')
    resultado!: string;

    @CreateDateColumn({ type: 'timestamptz', name: 'data_revisao' })
    data_revisao!: Date;

    @ManyToOne(() => Card, (card) => card.historico_revisoes, { onDelete: 'CASCADE' })
    @JoinColumn({ name: 'id_card' })
    card!: Card;
}
