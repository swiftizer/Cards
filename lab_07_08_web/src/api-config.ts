import { CardService, CardSetService, serviceOptions, SettingsService } from './api';
import axios from "axios";

serviceOptions.axios = axios.create({
    baseURL: `http://127.0.0.1:8078`,
});

export const cardApiService = new CardService();
export const cardSetApiService = new CardSetService();
export const settingsApiService = new SettingsService();
