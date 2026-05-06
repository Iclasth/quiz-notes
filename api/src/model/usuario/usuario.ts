import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from "typeorm";

@Entity("Usuario")
export class Usuario{

    @PrimaryGeneratedColumn()
    id_usuario!: number;

    @Column ({ type: "varchar2", length: "100", nullable: false})
    nome!: string;

    @Column ({ type: "varchar2", length: 100, unique: true, nullable: false})
    email!: string;

    @Column ({ type: "varchar2", length: 255, nullable: false})
    senha!: string;

    @OneToMany(() => Usuario, (usuario) => usuario.id_usuario)
    usuario!: Usuario[];
}