import React from 'react';
import { act, renderHook } from '@testing-library/react-hooks';
import { useCardFormModel } from '../card-form-model';

const onSubmit = jest.fn();

describe('card form model', () => {

    it('invalid question', async () => {
        const { result } = renderHook(() => useCardFormModel({ onSubmit: onSubmit }));

        act(() => {
            result.current.setCardQuestion("");
            result.current.submit();
        })

        expect(result.current.isCardQuestionInvalid).toBeTruthy();
        expect(result.current.isCardAnswerInvalid).toBeTruthy();
        expect(onSubmit).not.toBeCalled();
    });

    it('invalid question', async () => {
        const { result } = renderHook(() => useCardFormModel({ onSubmit: onSubmit }));

        act(() => {
            result.current.setCardAnswer("");
            result.current.submit();
        })

        expect(result.current.isCardQuestionInvalid).toBeTruthy();
        expect(result.current.isCardAnswerInvalid).toBeTruthy();
        expect(onSubmit).not.toBeCalled();
    });

    it('valid card', async () => {
        const { result } = renderHook(() => useCardFormModel({ onSubmit }));

        act(() => {
            result.current.setCardAnswer("text");
            result.current.setCardQuestion("text");
        })

        act(() => {
            result.current.submit();
        })

        expect(result.current.isCardQuestionInvalid).toBeFalsy();
        expect(result.current.isCardAnswerInvalid).toBeFalsy();
        expect(onSubmit).toBeCalled();
    });
})
