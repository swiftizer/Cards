import React, { FC } from 'react';

import './BoolButton.css';

interface Props {
    falseText: string;
    trueText: string;
    value: boolean;
    onValueChange: (newValue: boolean) => void;
}

const BoolButton: FC<Props> = ({ falseText, trueText, value, onValueChange }) => {
    return (
        <button className={'bool-button ' + (value ? 'positive' : 'negative')} onClick={() => onValueChange(!value)}>
            { value ? trueText : falseText }
        </button>
    );
};

export default BoolButton;
