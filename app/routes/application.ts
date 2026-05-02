import Route from '@ember/routing/route';
import type AuthService from '#app/services/auth';
import { service } from '@ember/service';

export default class ApplicationRoute extends Route {
  @service declare auth: AuthService;

  async beforeModel() {
    //console.log('[route/application] beforeModel()');
    //await this.auth.initialize();
  }
}
