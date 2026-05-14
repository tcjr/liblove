import { LinkTo } from '@ember/routing';
import { pageTitle } from 'ember-page-title';
import Component from '@glimmer/component';
import type AuthService from '#app/services/auth.ts';
import { service } from '@ember/service';

export default class ApplicationComponent extends Component {
  @service declare auth: AuthService;

  <template>
    {{pageTitle "Lib Love"}}

    <nav class="flex flex-row gap-2 items-center">
      <LinkTo
        @route="about"
        aria-label="status"
        class="status status-xl
          {{if this.auth.isAuthenticated 'status-success' 'status-warning'}}"
      />

      <div>
        <LinkTo @route="index">Home</LinkTo>
        |
        <LinkTo @route="libraries">Libraries</LinkTo>
        |
        <LinkTo @route="my-visits">My Visits</LinkTo>
      </div>
    </nav>

    {{outlet}}
  </template>
}
