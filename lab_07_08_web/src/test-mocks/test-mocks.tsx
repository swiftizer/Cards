import { Card, CardService } from "../api";

export const MOCK_CARDS: Card[] = [
    {card_set_id: '1', card_id: '1', is_learned: false, answer_text: "answer 1", question_text: "question 1"},
    {card_set_id: '2', card_id: '2', is_learned: false, answer_text: "answer 2", question_text: "question 2"},
    {card_set_id: '3', card_id: '3', is_learned: false, answer_text: "answer 3", question_text: "question 3"},
    {card_set_id: '4', card_id: '4', is_learned: false, answer_text: "answer 4", question_text: "question 4"},
    {card_set_id: '5', card_id: '5', is_learned: false, answer_text: "answer 5", question_text: "question 5"},
];

export const mockCardService: CardService = {
    changeCardById: () => Promise.resolve(),
    createCard: () => Promise.resolve(),
    getCardById: () => Promise.resolve(MOCK_CARDS[0]),
    getCards: () => Promise.resolve(MOCK_CARDS),
    deleteCardById: () => Promise.resolve(),
} as any;
