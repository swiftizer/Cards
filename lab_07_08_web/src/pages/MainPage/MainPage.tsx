import React, { useEffect } from 'react';
import CardSetItem from "./components/CardSetItem/CardSetItem";

import './MainPage.css';
import { Link } from "react-router-dom";
import NavigationButton from "../../components/NavigationButton/NavigationButton";
import { PageTitle } from "../../components/PageTitle/PageTitle";

import plus from '../../assets/plus.svg';
import { cardSetApiService } from '../../api-config';
import { useCardSetsModel } from '../../models/card-sets/card-set-model';

const MainPage = () => {
    const model = useCardSetsModel(cardSetApiService);

    useEffect(() => {
        model.requestCardSets().catch();
    }, []);

    return (
        <div className="main-page">
            <PageTitle>Main Page</PageTitle>
            <NavigationButton link='/settings' icon="gear" />
            <Link className="create-button" to='/create-card-set'><img src={plus} alt="plus"/></Link>
            { model.cardSets.map(cardSet => <CardSetItem key={cardSet.card_set_id} cardSet={cardSet} onDelete={model.deleteCardSet} />) }
        </div>
    );
};

export default MainPage;
