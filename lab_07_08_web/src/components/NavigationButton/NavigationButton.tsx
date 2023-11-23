import React, { FC } from 'react';

import arrowLeft from '../../assets/arrow_left.svg';
import house from '../../assets/house.svg';
import gear from '../../assets/gear.svg';

import './NavigationButton.css';
import { useNavigate } from "react-router";

const iconsMap = {
    arrowLeft: arrowLeft,
    house: house,
    gear: gear,
};

interface Props {
    icon: keyof typeof iconsMap;
    link?: string;
    goBack?: boolean;
}

const NavigationButton: FC<Props> = ({ link, icon, goBack }) => {
    const navigate = useNavigate();

    const onClick = () => {
        if (goBack) {
            navigate(-1);
            return;
        }

        if (link) {
            navigate(link);
        }
    };


    return (
        <div className="navigation-button" onClick={onClick}>
            <img src={iconsMap[icon]} alt="icon" />
        </div>
    );
};

export default NavigationButton;
