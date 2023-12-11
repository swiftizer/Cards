import { useState } from "react";
import { CardSet, CardSetService } from "../../api";

export const useCardSetsModel = (cardSetApiService: CardSetService) => {
    const [cardSets, setCardSets] = useState<CardSet[]>([]);

    const requestCardSets = async () => {
        try {
            const data = await cardSetApiService.getCardSets({ limit: 20 });            

            setCardSets(data);
        } catch (error) {
            console.log('Ошибка во время получения кардсетов');
        }
    };

    const deleteCardSet = async (id: string) => {
        const confirmed = window.confirm('Delete?');

        if (confirmed) {
            try {
                await cardSetApiService.deleteCardSetById({ cardSetId: id });

                await requestCardSets();
            } catch (error) {
                console.log('Ошибка во время удаления');
            }
        }
    };

    return {
        cardSets,
        requestCardSets,
        deleteCardSet
    };

};
