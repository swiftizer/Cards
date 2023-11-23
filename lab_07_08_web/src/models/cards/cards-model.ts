import { Card, CardService } from "../../api";
import { useState } from "react";


export const useCardsModel = (cardsApiService: CardService, currentCardSetId?: string) => {
    const [cards, setCards] = useState<Card[]>([]);

    const requestCards = async (cardSetId: string) => {
        try {
            const cards = await cardsApiService.getCards({cardSetId: cardSetId, limit: 100 });

            setCards(cards);
        } catch (err) {
            console.log("Ошибка получения карточек");
        }
    };

    const deleteCard = async (cardId: string) => {
        const confirmed = window.confirm('Точно удалить карточку?');

        if (confirmed && currentCardSetId) {
            try {
                await cardsApiService.deleteCardById({ cardId: cardId });

                await requestCards(currentCardSetId);
            } catch (err) {
                console.log('Ошибка удаления карточки');
            }
        }
    };

    return {
        requestCards,
        deleteCard,
        cards,
    };
};
