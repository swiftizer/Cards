import React from 'react';
import { useNavigate } from "react-router";

import './CreateCardSetPage.css';
import NavigationButton from "../../components/NavigationButton/NavigationButton";
import { PageTitle } from "../../components/PageTitle/PageTitle";
import { cardSetApiService } from '../../api-config';
import { useCreateCardSetModel } from '../../models/card-sets/create-card-set-model';

const CreateCardSetPage = () => {
    const navigate = useNavigate();

    const model = useCreateCardSetModel(cardSetApiService, {
        onSuccess: () => navigate(-1),
    });

    return (
        <div className="card-set-creation-page">
            <PageTitle>Card Set Creation Page</PageTitle>
            <NavigationButton goBack={true} icon="arrowLeft" />
            <h2 className="text-bold">Enter new card set title:</h2>
            <input
                type="text"
                placeholder="Type here"
                className={"text-field" + (model.isInvalid ? " invalid" : "")}
                value={model.cardSetName}
                onChange={event => model.setCardSetName(event.target.value)}/>
            <button className="primary-button" onClick={model.createCardSet}>ADD</button>
            <button className="primary-button" onClick={() => navigate('/')}>cancel</button>
        </div>
    );
};

export default CreateCardSetPage;
