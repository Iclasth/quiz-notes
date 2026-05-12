import { Request, Response, NextFunction } from 'express';
import { DeckService } from '../services/DeckService';

export class DeckController {
    private deckService: DeckService;

    constructor() {
        this.deckService = new DeckService();
    }

    public createDeck = async (req: Request, res: Response, next: NextFunction) => {
        try {
            const { userId } = req.params;
            const { nome } = req.body;
            const deck = await this.deckService.createDeck(userId, nome);
            res.status(201).json(deck);
        } catch (error) {
            next(error);
        }
    };

    public getUserDecks = async (req: Request, res: Response, next: NextFunction) => {
        try {
            const { userId } = req.params;
            const decks = await this.deckService.getUserDecks(userId);
            res.status(200).json(decks);
        } catch (error) {
            next(error);
        }
    };
}
