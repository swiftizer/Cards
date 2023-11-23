import * as uuid from 'uuid';
import { CardFormData } from "./card-form-model";
import { CardService } from '../../api';

interface Args {
    onSuccess?: () => void;
    cardSetId?: string;
}

export const useCreateCardModel = (apiService: CardService, { cardSetId, onSuccess }: Args) => {
    const createCard = async (card: CardFormData) => {
        try {
            if (!cardSetId) {
                throw new Error("Не передан CardSetId"); 
            }

            await apiService.createCard({
                body: {
                    card_id: uuid.v4(),
                    card_set_id: cardSetId,
                    ...card,
                }
            });

            onSuccess?.();
        } catch (err) {
            console.log("Ошибка при создании набора карточек");
        }
    };

    return {
        createCard
    };
};
