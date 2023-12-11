import React from 'react';
import NavigationButton from "../../components/NavigationButton/NavigationButton";
import { PageTitle } from "../../components/PageTitle/PageTitle";
import BoolButton from "../../components/BoolButton/BoolButton";

import './SettingsPage.css';
import { settingsApiService } from '../../api-config';
import { useSettingsModel } from '../../models/settings/settings-model';

const SettingsPage = () => {

    const model = useSettingsModel(settingsApiService);

    return (
        <div>
            <PageTitle>Settings</PageTitle>
            <NavigationButton link="/" icon="house"/>

            <div className="option-wrapper">
                <p className="option-title text-bold">Is mixing:</p>
                <div className="bool-button-wrapper">
                    <BoolButton falseText="NO" trueText="YES" value={model.isMixing} onValueChange={model.toggleIsMixing}/>
                </div>
            </div>

            <div className="option-wrapper">
                <p className="option-title text-bold">Mixing in power:</p>
                0
                <input
                    type="range"
                    min={0}
                    max={100}
                    value={model.mixingPowerSliderState}
                    onChange={event => model.changeMixingPowerSliderState(Number(event.target.value))}
                />
                100
                <p className="slider-value">({ model.mixingPowerSliderState }) </p>
            </div>

        </div>
    );
};

export default SettingsPage;
