import { Request, Response, NextFunction } from 'express';
import { CardService } from '../services/CardService';

export class CardController {
    private cardService: CardService;

    constructor() {
        this.cardService = new CardService();
    }

    public createCard = async (req: Request, res: Response, next: NextFunction) => {
        try {
            const deckId = req.params['deckId'] as string;
            const { frente, verso } = req.body;
            const card = await this.cardService.createCard(deckId, frente, verso);
            res.status(201).json(card);
        } catch (error) {
            next(error);
        }
    };
}
