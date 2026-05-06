import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn, OneToMany } from "typeorm";
import { Usuario } from "../usuario/usuario";
import { Card } from "../card/card";

@Entity("Baralho")
export class Baralho{

    @PrimaryGeneratedColumn()
    id_baralho!: number;

    @Column ({ type: "varchar2", length: "100", nullable: false})
    nome!: string;

    @ManyToOne(() => Usuario, (usuario) => usuario.id_usuario)
    @JoinColumn({ name: "id_usuario" })
    usuario!: Usuario;

    @OneToMany(() => Card, (card) => card.id)
    card!: Card[];
}