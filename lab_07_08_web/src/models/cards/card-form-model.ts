import { useEffect, useState } from "react";
import { Card } from "../../api";

export type CardFormData = Pick<Card, "is_learned" | "answer_text" | "question_text">

interface Args {
    onSubmit: (card: CardFormData) => void;
}

export const useCardFormModel = ({ onSubmit }: Args) => {
    const [cardQuestion, setCardQuestion] = useState("");
    const [isCardQuestionInvalid, setIsCardQuestionInvalid] = useState(false);
    const [isCardLearned, setIsCardLearned] = useState(false);

    const [cardAnswer, setCardAnswer] = useState("");
    const [isCardAnswerInvalid, setIsCardAnswerInvalid] = useState(false);

    const submit = async () => {
        if (cardQuestion === "") {
            setIsCardQuestionInvalid(true);
        }

        if (cardAnswer === "") {
            setIsCardAnswerInvalid(true);
        }

        if (cardQuestion === "" || cardAnswer === "") {
            return;
        }

        onSubmit({
            answer_text: cardAnswer,
            question_text: cardQuestion,
            is_learned: isCardLearned,
        });

        setCardQuestion("");
        setCardAnswer("");
        setIsCardLearned(false);
    };

    const setCardValues = (card: CardFormData) => {
        setCardAnswer(card.answer_text ?? "");
        setCardQuestion(card.question_text ?? "");
        setIsCardLearned(card.is_learned ?? false);
    };

    useEffect(() => {
        setIsCardQuestionInvalid(false);
    }, [cardQuestion]);

    useEffect(() => {
        setIsCardAnswerInvalid(false);
    }, [cardAnswer]);

    return {
        cardQuestion, setCardQuestion,
        cardAnswer, setCardAnswer,
        isCardLearned, setIsCardLearned,
        isCardQuestionInvalid, isCardAnswerInvalid,
        submit,
        setCardValues
    };

};