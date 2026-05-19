import { AppDataSource } from '../config/data-source';
import { Usuario } from '../model/Usuario';
import { BadRequestError } from '../errors/BadRequestError';
import { NotFoundError } from '../errors/NotFoundError';

export class UserService {
    private get userRepository() {
        return AppDataSource.getRepository(Usuario);
    }

    async createUser(data: Partial<Usuario>): Promise<Usuario> {
        if (!data.nome || !data.email || !data.senha) {
            throw new BadRequestError('Nome, email e senha são obrigatórios');
        }

        const newUser = this.userRepository.create(data);
        return await this.userRepository.save(newUser);
    }

    async getUserById(id: string): Promise<Usuario> {
        const user = await this.userRepository.findOneBy({ id_usuario: id });
        if (!user) {
            throw new NotFoundError('Usuário não encontrado');
        }
        return user;
    }
}
