import React, { useEffect } from 'react';
import { useParams } from "react-router";
import Card from "./components/Card/Card";

import { Link } from "react-router-dom";
import NavigationButton from "../../components/NavigationButton/NavigationButton";
import { PageTitle } from "../../components/PageTitle/PageTitle";

import checkmark from '../../assets/checkmark.svg';
import xmark from '../../assets/xmark.svg';
import menu from '../../assets/menu.svg';

import { cardApiService } from '../../api-config';
import { useLearnCardsModel } from '../../models/cards/learn-cards-model';

import './LearnCardsPage.css';

const LearnCardsPage = () => {
    const params = useParams();
    const currenCardSetId = (params as any).id;

    const model = useLearnCardsModel(cardApiService);

    useEffect(() => {
        if (currenCardSetId) {
            model.requestCards(currenCardSetId);
        }
    }, []);

    let content: React.ReactNode;

    if (model.totalCount === 0) {
        content = (
            <>
                <h1 className='text-bold'>No card</h1>
            </>
        );
    } else if (model.isFinished) {
        content = (
            <button className="restore-cards-button"
                    onClick={() => model.restore(currenCardSetId)}
            >
                Reset
            </button>
        );
    } else if (!model.currentCard) {
        content = (
            <>
                <h1 className='text-bold'>All cards learned</h1>

                <button className="restore-cards-button" onClick={() => model.markAllCardsNotLearned(currenCardSetId)}>Restore all cards</button>
            </>
        );
    } else {
        content = (
            <>
                <p className="caption">{ model.caption }</p>

                <Card card={model.currentCard} />

                <div className="card-actions">
                    <button onClick={model.markCurrentCardNotLearned} className="not-learned-button"><img src={xmark} alt="xmark"/></button>
                    <button onClick={model.markCurrentCardLearned} className="learned-button"><img src={checkmark} alt="checkmark"/></button>
                </div></>
        );
    }

    return (
        <div className="card-page">
            <PageTitle>Card Page</PageTitle>
            <NavigationButton link="/" icon="house" />

            {content}

            <Link className="edit-card-set-button" to={`/edit-card-set/${currenCardSetId}`}>
                <img src={menu} alt="menu" />
            </Link>
        </div>
    );
};

export default LearnCardsPage;
