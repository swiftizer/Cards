import React, { useEffect } from 'react';
import { useCardsModel } from '../../models/cards/cards-model';
import CardItem from "./components/CardItem/CardItem";
import { useParams } from "react-router";
import { Link } from "react-router-dom";
import { PageTitle } from "../../components/PageTitle/PageTitle";

import plus from '../../assets/plus.svg';
import NavigationButton from "../../components/NavigationButton/NavigationButton";

import './CardSetPage.css';
import { cardApiService } from '../../api-config';

interface RouteParams {
    currentCardSetId: string;
    [key: string]: string;
}

const CardSetPage = () => {
    const { currentCardSetId } = useParams<RouteParams>();

    const model = useCardsModel(cardApiService, currentCardSetId);

    useEffect(() => {
        if (currentCardSetId) {
            model.requestCards(currentCardSetId);
        }
    }, []);

    return (
        <div className="card-set-page">
            <PageTitle>Cards</PageTitle>
            <NavigationButton icon="arrowLeft" goBack={true} />
            <Link className="create-button" to={`/create-card/${currentCardSetId}`}><img src={plus} alt="plus"/> </Link>
            {model.cards.map(card => <CardItem key={card.card_id} card={card} onDelete={model.deleteCard} />)}
        </div>
    );
};

export default CardSetPage;
