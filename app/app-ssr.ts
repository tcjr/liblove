import EmberApp from 'ember-strict-application-resolver';
import config from './config.ts';
import Router from './router.ts';
import PageTitleService from 'ember-page-title/services/page-title';
import '@warp-drive/ember/install';
import './styles/app.css';

// Re-exporting `settled` lets the renderer await Ember's run loop, pending
// timers, and any registered test-waiters before capturing the DOM. See
// the Concepts section below for details.
export { settled } from '@ember/test-helpers';

class App extends EmberApp {
  modules = {
    './router': Router,
    ...import.meta.glob('./templates/**/*', { eager: true }),
    ...import.meta.glob('./services/**/*', { eager: true }),
    ...import.meta.glob('./routes/**/*', { eager: true }),
    './services/page-title': PageTitleService,
  };
}

export function createSsrApp() {
  return App.create({ ...config.APP, autoboot: false });
}
