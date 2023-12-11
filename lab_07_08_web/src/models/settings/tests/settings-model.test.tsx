import React from 'react';
import { renderHook, act } from '@testing-library/react-hooks';
import { useSettingsModel } from '../settings-model';
import { SettingsService } from '../../../api';

const getSettings = async () => {
    return { 
    is_mixed: false,
    mixing_in_power: 0,
  };
}

const mockSettingsApiService: SettingsService = {
 changeSettings: jest.fn(),   
 getSettings,
}


describe('settings page useSettingsModel', () => {

    it('get settings', () => {
        const spy = jest.spyOn(mockSettingsApiService, 'getSettings')
        
        renderHook(() => useSettingsModel(mockSettingsApiService));

        expect(spy).toBeCalled();
    });

    it('change is mixing', async () => {
        const { result } = renderHook(() => useSettingsModel(mockSettingsApiService));

        expect(result.current.isMixing).toEqual(false);
        expect(result.current.mixingPowerSliderState).toEqual(0);

        await act(async () => {
            await result.current.toggleIsMixing()
        })

        expect(result.current.isMixing).toEqual(true);
        expect(result.current.mixingPowerSliderState).toEqual(0);

        expect(mockSettingsApiService.changeSettings).toBeCalledWith({
            body: {
                is_mixed: true,
                mixing_in_power: 0,
            }
        })
    });

    it('change MixingPowerSliderState', async () => {
        const { result, rerender } = renderHook(() => useSettingsModel(mockSettingsApiService));

        expect(result.current.isMixing).toEqual(false);
        expect(result.current.mixingPowerSliderState).toEqual(0);

        await act(async () => {
            await result.current.changeMixingPowerSliderState(20)
        })

        rerender();

        jest.useFakeTimers();
        jest.advanceTimersByTime(1000)

        expect(result.current.isMixing).toEqual(false);
        expect(result.current.mixingPowerSliderState).toEqual(20);
    });

    it('change is mixing and MixingPowerSliderState', async () => {
        const { result } = renderHook(() => useSettingsModel(mockSettingsApiService));

        expect(result.current.isMixing).toEqual(false);
        expect(result.current.mixingPowerSliderState).toEqual(0);

        await act(async () => {
            await result.current.toggleIsMixing();
            result.current.changeMixingPowerSliderState(20);
        })

        expect(result.current.isMixing).toEqual(true);
        expect(result.current.mixingPowerSliderState).toEqual(20);
    });

    it('change MixingPowerSliderState wrong value', async () => {
        const { result } = renderHook(() => useSettingsModel(mockSettingsApiService));

        expect(result.current.isMixing).toEqual(false);
        expect(result.current.mixingPowerSliderState).toEqual(0);

        await act(async () => {
            await result.current.toggleIsMixing();
            result.current.changeMixingPowerSliderState(200);
        })

        expect(result.current.isMixing).toEqual(true);
        expect(result.current.mixingPowerSliderState).toEqual(100);
    });
})