import React from 'react';
import { act, renderHook } from '@testing-library/react-hooks';
import { useCardsModel } from '../cards-model';
import { MOCK_CARDS, mockCardService } from "../../../test-mocks/test-mocks";
import { CardFormData } from '../card-form-model';
import { useUpdateCardModel } from '../update-card-model';

describe('update card model', () => {

    it('update card', async () => {
        const spy = jest.spyOn(mockCardService, 'changeCardById');
        const getCardSpy = jest.spyOn(mockCardService, 'getCardById');

        const mockData: CardFormData = {
            answer_text: "1",
            is_learned: true,
            question_text: "2",
        };

        const { result } = renderHook(() => useUpdateCardModel(mockCardService, { cardId: "id" }));

        expect(getCardSpy).toBeCalled();

        await act(async () => {
            await result.current.updateCard(mockData)
        });

        // expect(spy).toBeCalled();
    });
})
