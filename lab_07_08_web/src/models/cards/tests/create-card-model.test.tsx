import React from 'react';
import { act, renderHook } from '@testing-library/react-hooks';
import { useCardsModel } from '../cards-model';
import { MOCK_CARDS, mockCardService } from "../../../test-mocks/test-mocks";
import { useCreateCardModel } from '../create-card-model';
import { CardFormData } from '../card-form-model';

const mockData: CardFormData = {
    answer_text: "1",
    is_learned: true,
    question_text: "2",
};

describe('create card model', () => {

    it('create card', async () => {
        const spy = jest.spyOn(mockCardService, 'createCard');

        const { result } = renderHook(() => useCreateCardModel(mockCardService, { 
            cardSetId: "id"
         }));

        await act(async () => {
            await result.current.createCard(mockData)
        });

        expect(spy).toBeCalled();
    });

    it('create card with success', async () => {
        const spy = jest.spyOn(mockCardService, 'createCard');
        const onSuccess = jest.fn();

        const { result } = renderHook(() => useCreateCardModel(mockCardService, { 
            cardSetId: "id",
            onSuccess: onSuccess,
         }));

        await act(async () => {
            await result.current.createCard(mockData)
        });

        expect(spy).toBeCalled();
        expect(onSuccess).toBeCalled();
    });

    it('create card with NOT success', async () => {
        const spy = jest.spyOn(mockCardService, 'createCard');
        const onSuccess = jest.fn();

        const { result } = renderHook(() => useCreateCardModel({ 
            createCard: jest.fn(() => Promise.reject())
        } as any, 
        { 
            cardSetId: "id",
            onSuccess: onSuccess,
         }));

        await act(async () => {
            await result.current.createCard(mockData)
        });

        expect(spy).not.toBeCalled();
        expect(onSuccess).not.toBeCalled();
    });

})
