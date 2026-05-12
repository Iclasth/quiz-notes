import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, OneToMany } from 'typeorm';
import { Baralho } from './Baralho';

@Entity('usuarios')
export class Usuario {
    @PrimaryGeneratedColumn('uuid', { name: 'id_usuario' })
    id_usuario: string;

    @Column('text')
    nome: string;

    @Column('text')
    email: string;

    @Column('text')
    senha: string;

    @CreateDateColumn({ type: 'timestamptz', name: 'criado_em' })
    criado_em: Date;

    @OneToMany(() => Baralho, (baralho) => baralho.usuario)
    baralhos: Baralho[];
}
