import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from "typeorm";
import { Baralho } from "../baralho/baralho";

@Entity("Card")
export class Card{

    @PrimaryGeneratedColumn()
    id!: number;

    @Column ({ type: "clob", nullable: false})
    frente!: string;

    @Column ({ type: "clob", nullable: false})
    verso!: string;

    @Column ({ type: "decimal", precision: 5, scale: 2, default: 0})
    desempenho!: number;

    @ManyToOne(() => Baralho, (baralho) => baralho.id_baralho)
    @JoinColumn({ name: "id_baralho" })
    baralho!: Baralho;
}