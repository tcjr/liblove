import type AuthService from '#app/services/auth.ts';
import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class ApplicationRoute extends Route {
  @service declare auth: AuthService;

  async beforeModel() {
    await this.auth.initialize();
  }
}
