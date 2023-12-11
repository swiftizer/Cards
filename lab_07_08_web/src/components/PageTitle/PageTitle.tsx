import { FC } from "react";

interface Props {
    children: string;
}

export const PageTitle: FC<Props> = ({ children }) => {

    document.title = children;

    return null;
};
