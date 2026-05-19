import { Request, Response, NextFunction } from 'express';
import { ReviewService } from '../services/ReviewService';

export class ReviewController {
    private reviewService: ReviewService;

    constructor() {
        this.reviewService = new ReviewService();
    }

    public getCardsForReview = async (req: Request, res: Response, next: NextFunction) => {
        try {
            const deckId = req.params['deckId'] as string;
            const cards = await this.reviewService.getCardsForReview(deckId);
            res.status(200).json(cards);
        } catch (error) {
            next(error);
        }
    };

    public submitReview = async (req: Request, res: Response, next: NextFunction) => {
        try {
            const cardId = req.params['cardId'] as string;
            const { qualidade } = req.body;
            const card = await this.reviewService.submitReview(cardId, qualidade);
            res.status(200).json(card);
        } catch (error) {
            next(error);
        }
    };
}
