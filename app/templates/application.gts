import { LinkTo } from '@ember/routing';
import { pageTitle } from 'ember-page-title';
import { service } from '@ember/service';
import type AuthService from '#app/services/auth';
import Component from '@glimmer/component';
import { on } from '@ember/modifier';

export default class ApplicationComponent extends Component {
  @service declare auth: AuthService;

  <template>
    {{pageTitle "Lib Love"}}

    <nav>
      <LinkTo @route="index">Home</LinkTo>
      |
      <LinkTo @route="libraries">Libraries</LinkTo>
    </nav>

    {{#if this.auth.isAuthenticated}}
      <div role="alert" class="alert alert-info">
        <div></div>
        <span>You are logged in.</span>
        <div>
          <button class="btn btn-sm" {{on "click" this.auth.logout}}>
            Logout
          </button>
        </div>
      </div>
    {{else}}
      <div role="alert" class="alert alert-warning">
        <div></div>
        <span>You are not logged in.</span>
        <div>
          <LinkTo @route="login" class="btn btn-sm">
            Login
          </LinkTo>
        </div>
      </div>
    {{/if}}

    {{outlet}}
  </template>
}
