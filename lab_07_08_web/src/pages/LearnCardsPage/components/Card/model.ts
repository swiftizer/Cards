import { useState } from "react";

export const useCardModel = () => {
    const [isFlipped, setIsFlipped] = useState(false);

    const flipCard = () => {
        setIsFlipped(prev => !prev);
    };

    const showQuestion = () => {
        setIsFlipped(false);
    };

    return {
        isFlipped,
        flipCard,
        showQuestion,
    };
};
