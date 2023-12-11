import React from 'react';
import { renderHook, act } from '@testing-library/react-hooks';
import { useCardSetsModel } from '../card-set-model';
import { CardSet, CardSetService } from '../../../api';

const mockCardSet: CardSet = {
    card_set_id: '1',
    learned_cards_count: 1,
    title: 'title',
}

const mockCardSetApiService: CardSetService = {
 getCardSets: jest.fn(),   
 deleteCardSetById: jest.fn()
} as any;


describe('card sets model', () => {

    it('default state', () => {
        const { result } = renderHook(useCardSetsModel, { initialProps: mockCardSetApiService });

        expect(result.current.cardSets).toEqual([]);
    });

    it('request card sets', async () => {
        const { result } = renderHook(useCardSetsModel, { initialProps: mockCardSetApiService });

        expect(result.current.cardSets).toHaveLength(0);

        await act(async () => {
            await result.current.requestCardSets()
        })

        expect(mockCardSetApiService.getCardSets).toBeCalled();
    });

    it('delete card set confirmed', async () => {
        const { result } = renderHook(useCardSetsModel, { initialProps: mockCardSetApiService });

        window.confirm = jest.fn(() => true);

        await act(async () => {
            await result.current.deleteCardSet("id");
        })

        expect(mockCardSetApiService.deleteCardSetById).toBeCalledWith({ cardSetId: "id" });
    });

    it('delete card set NOT confirmed', async () => {
        const { result } = renderHook(useCardSetsModel, { initialProps: mockCardSetApiService });

        window.confirm = jest.fn(() => false);

        await act(async () => {
            await result.current.deleteCardSet("id");
        })

        expect(mockCardSetApiService.deleteCardSetById).toBeCalledTimes(0);
    });
})