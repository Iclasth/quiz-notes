import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn, OneToMany } from 'typeorm';
import { Usuario } from './Usuario';
import { Card } from './Card';

@Entity('baralhos')
export class Baralho {
    @PrimaryGeneratedColumn('uuid', { name: 'id_baralho' })
    id_baralho: string;

    @Column('text')
    nome: string;

    @Column('uuid')
    id_usuario: string;

    @CreateDateColumn({ type: 'timestamptz', name: 'criado_em' })
    criado_em: Date;

    @ManyToOne(() => Usuario, (usuario) => usuario.baralhos, { onDelete: 'CASCADE' })
    @JoinColumn({ name: 'id_usuario' })
    usuario: Usuario;

    @OneToMany(() => Card, (card) => card.baralho)
    cards: Card[];
}
