import { useCallback, useEffect, useState } from "react";
import { SettingsService } from "../../api";
import { debounce } from "../../utils/debounce";

export const useSettingsModel = (settingsApiService: SettingsService) => {
    const [isMixing, setIsMixing] = useState(false);

    const [mixingPowerSliderState, setMixingPowerSliderState] = useState(0);

    const getSettings = async () => {
        try {
            const settings = await settingsApiService.getSettings();

            if (settings.is_mixed) {
                setIsMixing(settings.is_mixed);
            }

            if (settings.mixing_in_power) {
                setMixingPowerSliderState(settings.mixing_in_power);
            }
        } catch (err) {
            // console.log('Ошибка получения настроек');
        }
    };

    useEffect(() => {
        getSettings();
    }, []);

    const toggleIsMixing = async () => {
        try {
            await settingsApiService.changeSettings({
                body: {
                    is_mixed: !isMixing,
                    mixing_in_power: mixingPowerSliderState,
                }
            });

            setIsMixing(prev => !prev);

        } catch (err) {
            console.log('Ошибка смены настроек');
        }
    };

    const changeMixingPowerSliderState = (value: number) => {
        let realValue = value;
        if (value < 0) {
            realValue = 0;
        }

        if (value > 100) {
            realValue = 100;
        }

        setMixingPowerSliderState(realValue);
    };

    const updateMixingPowerSettings = useCallback(debounce(async (value: number) => {
        try {
            await settingsApiService.changeSettings({
                body: {
                    mixing_in_power: value,
                    is_mixed: isMixing,
                }
            });
        } catch (err) {
            console.log('Ошибка смены силы замешивания');
        }
    }, 500), []);

    useEffect(() => {
        updateMixingPowerSettings(mixingPowerSliderState);
    }, [mixingPowerSliderState, updateMixingPowerSettings]);

    return {
        isMixing,
        toggleIsMixing,
        mixingPowerSliderState,
        changeMixingPowerSliderState,
    };

};
