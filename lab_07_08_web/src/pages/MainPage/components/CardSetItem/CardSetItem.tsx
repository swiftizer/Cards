import React, { FC } from 'react';
import { CardSet } from '../../../../api';
import './CardSetItem.css';
import { useNavigate } from "react-router";

import arrowRight from '../../../../assets/arrow_right.svg';

interface Props {
    cardSet: CardSet;
    onDelete: (id: string) => void;
}

const CardSetItem: FC<Props> = ({ cardSet, onDelete }) => {
    const navigate = useNavigate();

    const color = `#${(cardSet.color?.toString(16))?.padStart(6, "0")}` ?? "#000";

    return (
        <div className="card-set-item-wrapper">
            <div className="card-set-item" onClick={() => navigate(`/card-set/${cardSet.card_set_id}`)}>
                <div className="card-set-mark-wrapper">
                    <div className="card-set-mark" style={{ background: color }}></div>
                </div>

                <div className="card-set-body">
                    <h5 className="text-bold card-set-title">{ cardSet.title }</h5>
                    <p className="text-small">{ cardSet.learned_cards_count } / { cardSet.all_cards_count }</p>
                </div>

                <img src={arrowRight} alt="arrowRight" className="card-set-item-arrow" />
            </div>
            <button className="delete-button" onClick={() => onDelete(cardSet.card_set_id)}>Delete</button>
        </div>
    );
};

export default CardSetItem;