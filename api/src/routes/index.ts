import { Router } from 'express';
import { UserController } from '../controllers/UserController';
import { DeckController } from '../controllers/DeckController';
import { CardController } from '../controllers/CardController';
import { ReviewController } from '../controllers/ReviewController';

const router = Router();

const userController = new UserController();
const deckController = new DeckController();
const cardController = new CardController();
const reviewController = new ReviewController();

// Usuários
router.post('/users', userController.createUser);
router.post('/login', userController.login);
router.get('/users/:id', userController.getUserById);

// Baralhos
router.post('/users/:userId/decks', deckController.createDeck);
router.get('/users/:userId/decks', deckController.getUserDecks);

// Cards
router.post('/decks/:deckId/cards', cardController.createCard);
router.get('/decks/:deckId/cards', cardController.getDeckCards);

// Revisões
router.get('/decks/:deckId/revisao', reviewController.getCardsForReview);
router.post('/cards/:cardId/revisao', reviewController.submitReview);

export { router };
