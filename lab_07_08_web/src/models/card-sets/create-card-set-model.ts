import { useEffect, useState } from "react";
import { CardSetService } from "../../api";
import * as uuid from "uuid";

interface Args {
    onSuccess?: () => void;
}

export const useCreateCardSetModel = (cardSetApiService: CardSetService, { onSuccess }: Args) => {
    const [cardSetName, setCardSetName] = useState("");
    const [isInvalid, setIsInvalid] = useState(false);

    const createCardSet = async () => {
        if (cardSetName === "") {
            setIsInvalid(true);
            return;
        }

        try {
            await cardSetApiService.createCardSet({
                body: {
                    card_set_id: uuid.v4().toUpperCase(),
                    title: cardSetName,
                    color: 0,
                    all_cards_count: 0,
                    learned_cards_count: 0
                }
            });

            setCardSetName("");
            onSuccess?.();
        } catch (err) {
            console.log("");
        }
    };

    useEffect(() => {
        setIsInvalid(false);
    }, [cardSetName]);

    return {
        cardSetName,
        setCardSetName,
        isInvalid,
        createCardSet,
    };
};

 
