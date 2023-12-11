import React, { FC } from 'react';
import { Card } from "../../../../api";
import arrowRight from '../../../../assets/arrow_right.svg';

import './CardItem.css';
import { useNavigate } from 'react-router';

interface Props {
    card: Card;
    onDelete: (id: string) => void;
}

const CardItem: FC<Props> = ({card, onDelete}) => {
    const navigate = useNavigate();

    return (
        <div className="card-item-wrapper">
            <div className="card-item" onClick={() => navigate(`/edit-card/${card.card_id}`)}>
                <div className="card-mark-wrapper">
                    <div className={"card-mark" + (card.is_learned ? " learned" : " not-learned")}></div>
                </div>

                <div className="card-body">
                    <h5 className="text-bold">{card.question_text}</h5>
                    <p className="text-small">{card.answer_text}</p>
                </div>

                <img src={arrowRight} alt="arrowRight" className="card-set-item-arrow" />
            </div>
            <button className="card-delete-button" onClick={() => onDelete(card.card_id)}>Delete</button>
        </div>
    );
};

export default CardItem;
