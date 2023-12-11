import React from 'react';
import { act, renderHook } from '@testing-library/react-hooks';
import { useCreateCardSetModel } from '../create-card-set-model';
import { CardSetService } from '../../../api';

const mockCardSetApiService: CardSetService = {
    createCardSet: jest.fn(() => Promise.resolve())
} as any;

const mockCardSetApiServiceWithError: CardSetService = {
    createCardSet: () => Promise.reject(),
} as any;

describe('create card set model', () => {

    it('create card set', async () => {
        const spy = jest.spyOn(mockCardSetApiService, 'createCardSet');

        const { result } = renderHook(() => useCreateCardSetModel(mockCardSetApiService, {}));

        act(() => {
            result.current.setCardSetName("name");
        });

        await act(async () => {
            await result.current.createCardSet();
        });

        expect(spy).toBeCalled();
    });

    it('create card set invalid input', async () => {
        const spy = jest.spyOn(mockCardSetApiService, 'createCardSet');

        const { result } = renderHook(() => useCreateCardSetModel(mockCardSetApiService, {}));

        act(() => {
            result.current.setCardSetName("");
        });

        await act(async () => {
            await result.current.createCardSet();
        });

        expect(spy).not.toBeCalled();
    });

    it('create card set success', async () => {
        const spy = jest.spyOn(mockCardSetApiService, 'createCardSet');
        const onSuccess = jest.fn();

        const { result } = renderHook(() => useCreateCardSetModel(mockCardSetApiService, { onSuccess: onSuccess }));

        act(() => {
            result.current.setCardSetName("name");
        });

        await act(async () => {
            await result.current.createCardSet();
        });

        expect(spy).toBeCalled();
        expect(onSuccess).toBeCalled();
    });

    it('create card set NOT success', async () => {
        const spy = jest.spyOn(mockCardSetApiServiceWithError, 'createCardSet');
        const onSuccess = jest.fn();

        const { result } = renderHook(() => useCreateCardSetModel(mockCardSetApiServiceWithError, { onSuccess: onSuccess }));

        act(() => {
            result.current.setCardSetName("name");
        });

        await act(async () => {
            await result.current.createCardSet();
        });

        expect(spy).toBeCalled();
        expect(onSuccess).not.toBeCalled();
    });
})
