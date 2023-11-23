import { useState } from "react";
import { Card, CardService } from "../../api";

export const useLearnCardsModel = (cardApiService: CardService) => {

    const [currentCardIndex, setCurrentCardIndex] = useState(0);
    const [allCards, setAllCards] = useState<Card[]>([]);

    const [isFinished, setIsFinished] = useState(false);

    const [currentCard, setCurrentCard] = useState<Card | undefined>();

    const [caption, setCaption] = useState("");

    const [totalCount, setTotalCount] = useState(0);

    const requestCards = async (cardSetId: string) => {
        try {
            const cards: Card[] = await cardApiService.getCards({ cardSetId: cardSetId, limit: 100, isLearned: false });

            setAllCards(cards);
            setCurrentCardIndex(0);
            setCurrentCard(cards[0]);
            setTotalCount(cards.length);

            setCaption(`1 / ${cards.length}`);
        } catch (err) {
            console.log("Ошибка получения карточек");
        }
    };

    const goToNextCard = async () => {
        if (currentCardIndex + 1 < allCards.length) {
            setCaption(`${currentCardIndex + 2} / ${allCards.length}`);
            setCurrentCard(allCards[currentCardIndex + 1]);
            setCurrentCardIndex(currentCardIndex + 1);
        } else {
            setIsFinished(true);
        }
    };

    const updateCurrentCardCard = async ({ isLearned }: { isLearned: boolean }) => {
        try {
            if (!currentCard) {
                return;
            }

            await cardApiService.changeCardById({
                cardId: currentCard.card_id,
                body: {
                    ...currentCard,
                    is_learned: isLearned,
                }
            });
        } catch (err) {
            console.log('Ошибка обновления карточки');
        }
    };

    const markCurrentCardLearned = async () => {
        await updateCurrentCardCard({ isLearned: true });

        await goToNextCard();
    };

    const markCurrentCardNotLearned = async () => {
        await updateCurrentCardCard({ isLearned: false });

        await goToNextCard();
    };

    const markAllCardsNotLearned = async (cardSetId: string) => {
        try {
            const cards = await cardApiService.getCards({ cardSetId: cardSetId, limit: 100 });
            for (const card of cards) {
                await cardApiService.changeCardById({
                    cardId: card.card_id,
                    body: {
                        ...card,
                        is_learned: false,
                    }
                });
            }

            await requestCards(cardSetId);
        } catch (err) {
            console.log("Ошибка сброса карточек");
        }
    };

    const restore = async (cardSetId: string) => {
        const cards: Card[] = await cardApiService.getCards({ cardSetId: cardSetId, limit: 100 });

        const notLearnedCards = cards.filter(card => card.is_learned === false);

        setIsFinished(false);

        if (notLearnedCards.length > 0) {
            setAllCards(notLearnedCards);
            setCurrentCardIndex(0);
            setCurrentCard(notLearnedCards[0]);

            setCaption(`1 / ${notLearnedCards.length}`);
        } else {
            await markAllCardsNotLearned(cardSetId);
        }
    };

    return {
        requestCards,
        markCurrentCardLearned,
        markCurrentCardNotLearned,
        currentCard,
        caption,
        markAllCardsNotLearned,
        restore,
        isFinished,
        totalCount,
    };
};
