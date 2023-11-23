/** Generate by swagger-axios-codegen */
// @ts-nocheck
/* eslint-disable */

/** Generate by swagger-axios-codegen */
/* eslint-disable */
// @ts-nocheck
import { AxiosInstance, AxiosRequestConfig } from 'axios';

export interface IRequestOptions extends AxiosRequestConfig {
  /** only in axios interceptor config*/
  loading?: boolean;
  showError?: boolean;
}

export interface IRequestConfig {
  method?: any;
  headers?: any;
  url?: any;
  data?: any;
  params?: any;
}

// Add options interface
export interface ServiceOptions {
  axios?: AxiosInstance;
  /** only in axios interceptor config*/
  loading: boolean;
  showError: boolean;
}

// Add default options
export const serviceOptions: ServiceOptions = {};

// Instance selector
export function axios(configs: IRequestConfig, resolve: (p: any) => void, reject: (p: any) => void): Promise<any> {
  if (serviceOptions.axios) {
    return serviceOptions.axios
      .request(configs)
      .then(res => {
        resolve(res.data);
      })
      .catch(err => {
        reject(err);
      });
  } else {
    throw new Error('please inject yourself instance like axios  ');
  }
}

export function getConfigs(method: string, contentType: string, url: string, options: any): IRequestConfig {
  const configs: IRequestConfig = {
    loading: serviceOptions.loading,
    showError: serviceOptions.showError,
    ...options,
    method,
    url
  };
  configs.headers = {
    ...options.headers,
    'Content-Type': contentType
  };
  return configs;
}

export const basePath = '';

export interface IList<T> extends Array<T> {}
export interface List<T> extends Array<T> {}
export interface IDictionary<TValue> {
  [key: string]: TValue;
}
export interface Dictionary<TValue> extends IDictionary<TValue> {}

export interface IListResult<T> {
  items?: T[];
}

export class ListResultDto<T> implements IListResult<T> {
  items?: T[];
}

export interface IPagedResult<T> extends IListResult<T> {
  totalCount?: number;
  items?: T[];
}

export class PagedResultDto<T = any> implements IPagedResult<T> {
  totalCount?: number;
  items?: T[];
}

// customer definition
// empty

export class CardService {
  /**
   * Получить список карточек.
   */
  public getCards(
    params: {
      /**  */
      limit: number;
      /**  */
      offset?: number;
      /**  */
      cardSetId?: string;
      /**  */
      isLearned?: boolean;
    } = {} as any,
    options: IRequestOptions = {}
  ): Promise<Cards> {
    return new Promise((resolve, reject) => {
      let url = basePath + '/cards';

      const configs: IRequestConfig = getConfigs('get', 'application/json', url, options);
      configs.params = {
        limit: params['limit'],
        offset: params['offset'],
        card_set_id: params['cardSetId'],
        is_learned: params['isLearned']
      };

      /** 适配ios13，get请求不允许带body */

      axios(configs, resolve, reject);
    });
  }
  /**
   * Создать карточку.
   */
  public createCard(
    params: {
      /** requestBody */
      body?: Card;
    } = {} as any,
    options: IRequestOptions = {}
  ): Promise<Card> {
    return new Promise((resolve, reject) => {
      let url = basePath + '/cards';

      const configs: IRequestConfig = getConfigs('post', 'application/json', url, options);

      let data = params.body;

      configs.data = data;

      axios(configs, resolve, reject);
    });
  }
  /**
   * Получить карточку.
   */
  public getCardById(
    params: {
      /** Идентификатор карточки. */
      cardId: string;
    } = {} as any,
    options: IRequestOptions = {}
  ): Promise<Card> {
    return new Promise((resolve, reject) => {
      let url = basePath + '/cards/{card_id}';
      url = url.replace('{card_id}', params['cardId'] + '');

      const configs: IRequestConfig = getConfigs('get', 'application/json', url, options);

      /** 适配ios13，get请求不允许带body */

      axios(configs, resolve, reject);
    });
  }
  /**
   * Изменить карточку.
   */
  public changeCardById(
    params: {
      /** Идентификатор карточки. */
      cardId: string;
      /** requestBody */
      body?: Card;
    } = {} as any,
    options: IRequestOptions = {}
  ): Promise<Card> {
    return new Promise((resolve, reject) => {
      let url = basePath + '/cards/{card_id}';
      url = url.replace('{card_id}', params['cardId'] + '');

      const configs: IRequestConfig = getConfigs('put', 'application/json', url, options);

      let data = params.body;

      configs.data = data;

      axios(configs, resolve, reject);
    });
  }
  /**
   * Удалить карточку.
   */
  public deleteCardById(
    params: {
      /** Идентификатор карточки. */
      cardId: string;
    } = {} as any,
    options: IRequestOptions = {}
  ): Promise<any> {
    return new Promise((resolve, reject) => {
      let url = basePath + '/cards/{card_id}';
      url = url.replace('{card_id}', params['cardId'] + '');

      const configs: IRequestConfig = getConfigs('delete', 'application/json', url, options);

      let data = null;

      configs.data = data;

      axios(configs, resolve, reject);
    });
  }
}

export class CardSetService {
  /**
   * Получить список наборов карточек.
   */
  public getCardSets(
    params: {
      /**  */
      limit: number;
      /**  */
      offset?: number;
    } = {} as any,
    options: IRequestOptions = {}
  ): Promise<CardSets> {
    return new Promise((resolve, reject) => {
      let url = basePath + '/card_sets';

      const configs: IRequestConfig = getConfigs('get', 'application/json', url, options);
      configs.params = { limit: params['limit'], offset: params['offset'] };

      /** 适配ios13，get请求不允许带body */

      axios(configs, resolve, reject);
    });
  }
  /**
   * Создать набор карточек.
   */
  public createCardSet(
    params: {
      /** requestBody */
      body?: CardSet;
    } = {} as any,
    options: IRequestOptions = {}
  ): Promise<CardSet> {
    return new Promise((resolve, reject) => {
      let url = basePath + '/card_sets';

      const configs: IRequestConfig = getConfigs('post', 'application/json', url, options);

      let data = params.body;

      configs.data = data;

      axios(configs, resolve, reject);
    });
  }
  /**
   * Получить информацию о наборе карточек.
   */
  public getCardSetById(
    params: {
      /** Идентификатор набора карточек. */
      cardSetId: string;
    } = {} as any,
    options: IRequestOptions = {}
  ): Promise<CardSet> {
    return new Promise((resolve, reject) => {
      let url = basePath + '/card_sets/{card_set_id}';
      url = url.replace('{card_set_id}', params['cardSetId'] + '');

      const configs: IRequestConfig = getConfigs('get', 'application/json', url, options);

      /** 适配ios13，get请求不允许带body */

      axios(configs, resolve, reject);
    });
  }
  /**
   * Изменить информацию о наборе карточек.
   */
  public changeCardSetById(
    params: {
      /** Идентификатор набора карточек. */
      cardSetId: string;
      /** requestBody */
      body?: CardSet;
    } = {} as any,
    options: IRequestOptions = {}
  ): Promise<CardSet> {
    return new Promise((resolve, reject) => {
      let url = basePath + '/card_sets/{card_set_id}';
      url = url.replace('{card_set_id}', params['cardSetId'] + '');

      const configs: IRequestConfig = getConfigs('put', 'application/json', url, options);

      let data = params.body;

      configs.data = data;

      axios(configs, resolve, reject);
    });
  }
  /**
   * Удалить набор карточек.
   */
  public deleteCardSetById(
    params: {
      /** Идентификатор набора карточек. */
      cardSetId: string;
    } = {} as any,
    options: IRequestOptions = {}
  ): Promise<any> {
    return new Promise((resolve, reject) => {
      let url = basePath + '/card_sets/{card_set_id}';
      url = url.replace('{card_set_id}', params['cardSetId'] + '');

      const configs: IRequestConfig = getConfigs('delete', 'application/json', url, options);

      let data = null;

      configs.data = data;

      axios(configs, resolve, reject);
    });
  }
}

export class SettingsService {
  /**
   * Получить настройки.
   */
  public getSettings(options: IRequestOptions = {}): Promise<Settings> {
    return new Promise((resolve, reject) => {
      let url = basePath + '/settings';

      const configs: IRequestConfig = getConfigs('get', 'application/json', url, options);

      /** 适配ios13，get请求不允许带body */

      axios(configs, resolve, reject);
    });
  }
  /**
   * Изменить настройки.
   */
  public changeSettings(
    params: {
      /** requestBody */
      body?: Settings;
    } = {} as any,
    options: IRequestOptions = {}
  ): Promise<Settings> {
    return new Promise((resolve, reject) => {
      let url = basePath + '/settings';

      const configs: IRequestConfig = getConfigs('patch', 'application/json', url, options);

      let data = params.body;

      configs.data = data;

      axios(configs, resolve, reject);
    });
  }
}

export interface Card {
  /** Id карточки. */
  card_id: string;

  /** Id набора карточек, к которому относится карточка. */
  card_set_id: string;

  /** Текст вопроса карточки. */
  question_text?: string;

  /** Путь к файлу картинки вопроса. */
  question_image?: string;

  /** Текст ответа карточки. */
  answer_text?: string;

  /** Путь к файлу картинки ответа. */
  answer_image?: string;

  /** Флаг, показывающий выучена карточка или нет. */
  is_learned?: boolean;
}

export interface CardSet {
  /** Id набора карточек. */
  card_set_id: string;

  /** Заголовок набора карточек. */
  title?: string;

  /** Общее количество карточек в наборе. */
  all_cards_count?: number;

  /** Количество выученных карточек в наборе. */
  learned_cards_count?: number;

  /** Цвет набора карточек. */
  color?: number;
}

export interface Settings {
  /** Флаг, определяющий подмешивать выученные карточки к невыученным или нет. */
  is_mixed?: boolean;

  /** Степень подмешивания (0...100)%. */
  mixing_in_power?: number;
}

export interface Error400 {}

export interface Error400GET {}

export interface Error400Delete {}
