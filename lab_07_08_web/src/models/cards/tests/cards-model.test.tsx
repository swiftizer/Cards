import React from 'react';
import { act, renderHook } from '@testing-library/react-hooks';
import { useCardsModel } from '../cards-model';
import { MOCK_CARDS, mockCardService } from "../../../test-mocks/test-mocks";

describe('cards model', () => {

    it('get cards', async () => {
        const spy = jest.spyOn(mockCardService, 'getCards');

        const { result } = renderHook(() => useCardsModel(mockCardService));

        await act(async () => {
            await result.current.requestCards("id");
        });

        expect(spy).toBeCalledWith( { cardSetId: "id", limit: 100 })
        expect(result.current.cards).toEqual(MOCK_CARDS);
    });

    it('delete card confirmed', async () => {
        const spy = jest.spyOn(mockCardService, 'deleteCardById');

        const { result } = renderHook(() => useCardsModel(mockCardService, "id"));

        window.confirm = jest.fn(() => true);

        await act(async () => {
            await result.current.deleteCard("id");
        })

        expect(spy).toBeCalledWith({ cardId: "id" });
    })

    it('delete card NOT confirmed', async () => {
        const spy = jest.spyOn(mockCardService, 'deleteCardById');

        const { result } = renderHook(() => useCardsModel(mockCardService));

        window.confirm = jest.fn(() => false);

        await act(async () => {
            await result.current.deleteCard("id");
        })

        expect(spy).not.toBeCalled()
    })

})
