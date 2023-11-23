import React from 'react';
import NavigationButton from "../../components/NavigationButton/NavigationButton";
import { PageTitle } from "../../components/PageTitle/PageTitle";
import BoolButton from "../../components/BoolButton/BoolButton";
import { cardApiService } from '../../api-config';
import { useCardFormModel } from '../../models/cards/card-form-model';
import { useCreateCardModel } from '../../models/cards/create-card-model';
import { useNavigate, useParams } from 'react-router';

interface RouteParams {
    cardSetId: string;
    [key: string]: string;
}

const CreateCardPage = () => {
    const { cardSetId } = useParams<RouteParams>();
    const navigate = useNavigate();

    const creationModel = useCreateCardModel(cardApiService, {
        cardSetId: cardSetId,
        onSuccess: () => navigate(-1),
    });

    const formModel = useCardFormModel({ onSubmit: creationModel.createCard });

    return (
        <div className="card-set-creation-page">
            <PageTitle>Card Creation Page</PageTitle>
            <NavigationButton icon="arrowLeft" goBack={true} />
            <h2 className="text-bold">Question</h2>
            <textarea
                placeholder="Type here"
                className={"text-field large" + (formModel.isCardQuestionInvalid ? " invalid" : "")}
                value={formModel.cardQuestion}
                onChange={event => formModel.setCardQuestion(event.target.value)}
             />

            <h2 className="text-bold">Answer</h2>
            <textarea
                placeholder="Type here"
                className={"text-field large" + (formModel.isCardAnswerInvalid ? " invalid" : "")}
                value={formModel.cardAnswer}
                onChange={event => formModel.setCardAnswer(event.target.value)}
            />

            <div className="card-set-creation-page">
                <BoolButton falseText="not learned" trueText="learned" value={formModel.isCardLearned} onValueChange={formModel.setIsCardLearned} />
                <button className="primary-button" onClick={formModel.submit}>ADD</button>
            </div>
        </div>
    );
};

export default CreateCardPage;
