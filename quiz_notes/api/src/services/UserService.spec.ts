import { UserService } from './UserService';
import { Usuario } from '../model/Usuario';
import { Repository } from 'typeorm';
import { AppDataSource } from '../config/data-source';

jest.mock('../config/data-source', () => ({
    AppDataSource: {
        getRepository: jest.fn()
    }
}));

describe('UserService', () => {
    let userService: UserService;
    let userRepositoryMock: jest.Mocked<Repository<Usuario>>;

    beforeEach(() => {
        userRepositoryMock = {
            create: jest.fn(),
            save: jest.fn(),
            findOneBy: jest.fn(),
            find: jest.fn(),
        } as unknown as jest.Mocked<Repository<Usuario>>;

        (AppDataSource.getRepository as jest.Mock).mockReturnValue(userRepositoryMock);

        userService = new UserService();
    });

    it('should create a new user successfully', async () => {
        const userData = { nome: 'Test User', email: 'test@example.com', senha: 'password123' };
        const savedUser = { id_usuario: '123-uuid', ...userData, criado_em: new Date() } as Usuario;

        userRepositoryMock.create.mockReturnValue(savedUser);
        userRepositoryMock.save.mockResolvedValue(savedUser);

        const result = await userService.createUser(userData);

        expect(userRepositoryMock.create).toHaveBeenCalledWith(userData);
        expect(userRepositoryMock.save).toHaveBeenCalledWith(savedUser);
        expect(result).toEqual(savedUser);
    });

    it('should throw an error if email is missing', async () => {
        const userData = { nome: 'Test User', email: '', senha: 'password123' };

        await expect(userService.createUser(userData)).rejects.toThrow('Nome, email e senha são obrigatórios');
    });

    it('should fetch a user by id', async () => {
        const user = { id_usuario: '123-uuid', nome: 'Test', email: 'test@example.com', senha: '123', criado_em: new Date() } as Usuario;
        userRepositoryMock.findOneBy.mockResolvedValue(user);

        const result = await userService.getUserById('123-uuid');

        expect(userRepositoryMock.findOneBy).toHaveBeenCalledWith({ id_usuario: '123-uuid' });
        expect(result).toEqual(user);
    });

    it('should throw NotFoundError if user not found', async () => {
        userRepositoryMock.findOneBy.mockResolvedValue(null);

        await expect(userService.getUserById('invalid-uuid')).rejects.toThrow('Usuário não encontrado');
    });
});
