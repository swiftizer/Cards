import React, { FC, useEffect } from 'react';
import { Card as ICard } from "../../../../api";

import './Card.css';
import { useCardModel } from "./model";

interface Props {
    card: ICard;
}

const Card: FC<Props> = ({card}) => {
    const model = useCardModel();

    useEffect(() => {
        model.showQuestion();
    }, [card]);

    return (
        <div onClick={model.flipCard} className={"flip-card" + (model.isFlipped ? " flipped" : "")}>
            <div className="flip-card-inner">
                <div className="flip-card-front">
                    {card.question_text}
                </div>
                <div className="flip-card-back">
                    {card.answer_text}
                </div>
            </div>
        </div>
    );
};

export default Card;
