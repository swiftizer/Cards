import { useEffect, useState } from "react";
import { Card, CardService } from "../../api";
import { CardFormData } from "./card-form-model";

interface Args {
    onSuccess?: () => void;
    cardId?: string;
}

export const useUpdateCardModel = (cardApiService: CardService, { onSuccess, cardId }: Args) => {
    const [currentCard, setCurrentCard] = useState<Card | undefined>();

    const getCurrentCard = async (cardId: string) => {
        try {
            const card = await cardApiService.getCardById({
                cardId: cardId,
            });

            setCurrentCard(card);
        } catch (err) {
            console.log('Ошибка при обновлении');
        }
    };

    useEffect(() => {
        if (cardId) {
            getCurrentCard(cardId);
        }
    }, [cardId]);

    const updateCard = async (formData: CardFormData) => {
        if (!currentCard) {
            return;
        }
        
        try {
            await cardApiService.changeCardById({
                cardId: currentCard.card_id,
                body: {
                    ...currentCard,
                    ...formData,
                }
            });

            onSuccess?.();
        } catch (err) {
            console.log('Ошибка при обновлении');
        }
    };

    return {
        updateCard,
        currentCard,
    };
};