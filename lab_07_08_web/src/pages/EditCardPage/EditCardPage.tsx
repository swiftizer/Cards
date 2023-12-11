import { FC, useEffect } from "react";
import { PageTitle } from "../../components/PageTitle/PageTitle";
import NavigationButton from "../../components/NavigationButton/NavigationButton";
import { useCardFormModel } from "../../models/cards/card-form-model";
import BoolButton from "../../components/BoolButton/BoolButton";
import { useUpdateCardModel } from "../../models/cards/update-card-model";
import { cardApiService } from "../../api-config";
import { useNavigate, useParams } from "react-router";

interface RouteParams {
    cardId: string;
    [key: string]: string;
}

const EditCardPage: FC = () => {
    const navigate = useNavigate();
    const { cardId } = useParams<RouteParams>();

    const updateModel = useUpdateCardModel(cardApiService, {
        onSuccess: () => navigate(-1),
        cardId: cardId,
    });
    const formModel = useCardFormModel({ onSubmit: updateModel.updateCard });

    useEffect(() => {
        if (updateModel.currentCard) {
            formModel.setCardValues({
                ...updateModel.currentCard,
            });
        }
    }, [updateModel.currentCard]);

    return (
        <div className="card-set-creation-page">
            <PageTitle>Edit Card Page</PageTitle>
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
                <button className="primary-button" onClick={formModel.submit}>UPDATE</button>
            </div>
        </div>
    );
};

export default EditCardPage;