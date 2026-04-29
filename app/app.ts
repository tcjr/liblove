import Application from 'ember-strict-application-resolver';
import PageTitleService from 'ember-page-title/services/page-title';
import '@warp-drive/ember/install';
import './styles/app.css';

export default class App extends Application {
  modules = {
    ...import.meta.glob('./router.*', { eager: true }),
    ...import.meta.glob('./templates/**/*', { eager: true }),
    ...import.meta.glob('./services/**/*', { eager: true }),
    './services/page-title': PageTitleService,
  };
}
