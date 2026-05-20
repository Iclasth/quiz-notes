import { AppDataSource } from '../config/data-source';
import { Usuario } from '../model/Usuario';
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
}
