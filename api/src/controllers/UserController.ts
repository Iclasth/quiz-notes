import { Request, Response, NextFunction } from 'express';
import { UserService } from '../services/UserService';

export class UserController {
    private userService: UserService;

    constructor() {
        this.userService = new UserService();
    }

    public createUser = async (req: Request, res: Response, next: NextFunction) => {
        try {
            const user = await this.userService.createUser(req.body);
            res.status(201).json(user);
        } catch (error) {
            next(error);
        }
    };

    public login = async (req: Request, res: Response, next: NextFunction) => {
        try {
            const { email, senha } = req.body;
            const user = await this.userService.login(email, senha);
            res.status(200).json(user);
        } catch (error) {
            next(error);
        }
    };

    public getUserById = async (req: Request, res: Response, next: NextFunction) => {
        try {
            const user = await this.userService.getUserById(req.params['id'] as string);
            res.status(200).json(user);
        } catch (error) {
            next(error);
        }
    };

    public getUserStats = async (req: Request, res: Response, next: NextFunction) => {
        try {
            const userId = req.params['userId'] as string;
            const stats = await this.userService.getUserStats(userId);
            res.status(200).json(stats);
        } catch (error) {
            next(error);
        }
    };
}
