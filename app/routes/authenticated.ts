import Route from '@ember/routing/route';
import { service } from '@ember/service';
import type AuthService from '#app/services/auth';
import type RouterService from '@ember/routing/router-service';

export default class AuthenticatedRoute extends Route {
  @service auth!: AuthService;
  @service router!: RouterService;

  async beforeModel() {
    // Wait for auth to initialize if it's still loading
    if (this.auth.loading) {
      await new Promise((resolve) => {
        const check = () => {
          if (!this.auth.loading) {
            resolve(null);
          } else {
            console.log(
              '[routes/authenticated] Waiting for auth to initialize...'
            );
            setTimeout(check, 50);
          }
        };
        check();
      });
    }

    if (!this.auth.isAuthenticated) {
      console.log(
        '[routes/authenticated] this.auth.isAuthenticated is false,Redirecting to login'
      );
      this.router.transitionTo('login');
    }
  }
}
