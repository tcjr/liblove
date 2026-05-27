import App from './app.ts';
import config from './config.ts';

export { settled } from '@ember/test-helpers';

export function createSsrApp() {
  return App.create({ ...config.APP, autoboot: false });
}
