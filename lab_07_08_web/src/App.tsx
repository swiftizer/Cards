import React from 'react';
import { BrowserRouter, Route, Routes } from 'react-router-dom';
import MainPage from "./pages/MainPage/MainPage";
import SettingsPage from "./pages/SettingsPage/SettingsPage";
import LearnCardsPage from "./pages/LearnCardsPage/LearnCardsPage";
import CreateCardSetPage from "./pages/CreateCardSetPage/CreateCardSetPage";
import CardSetPage from "./pages/CardSetPage/CardSetPage";
import CreateCardPage from "./pages/CreateCardPage/CreateCardPage";
import EditCardPage from './pages/EditCardPage/EditCardPage';


function App() {
    return (
        <BrowserRouter>
            <Routes>
                <Route path='/' element={<MainPage/>}/>
                <Route path='/settings' element={<SettingsPage/>}/>
                <Route path='/card-set/:id' element={<LearnCardsPage/>}/>
                <Route path='/create-card-set' element={<CreateCardSetPage/>}/>
                <Route path='/edit-card-set/:currentCardSetId' element={<CardSetPage/>}/>
                <Route path='/create-card/:cardSetId' element={<CreateCardPage />}/>
                <Route path='/edit-card/:cardId' element={<EditCardPage />}/> 
            </Routes>
        </BrowserRouter>
    );
}

export default App;
