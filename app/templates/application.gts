import { LinkTo } from '@ember/routing';
import { pageTitle } from 'ember-page-title';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import type AuthService from '#app/services/auth';
import Component from '@glimmer/component';

export default class ApplicationComponent extends Component {
  @service declare auth: AuthService;

  <template>
    {{pageTitle "Lib Love"}}

    <div class="min-h-screen bg-base-200">
      <header class="navbar bg-base-100 shadow-sm px-4">
        <div class="flex-1 gap-4">
          <LinkTo @route="index" class="btn btn-ghost text-xl">Lib Love</LinkTo>
          <nav class="flex gap-2">
            <LinkTo
              @route="libraries"
              class="btn btn-ghost btn-sm"
            >Libraries</LinkTo>
          </nav>
        </div>
        <div class="flex-none gap-4">
          {{#if this.auth.loading}}
            <span class="loading loading-spinner loading-sm"></span>
          {{else if this.auth.isAuthenticated}}
            <span class="text-sm opacity-70">Hello,
              {{this.auth.user.email}}</span>
            <button
              class="btn btn-outline btn-sm"
              type="button"
              {{on "click" this.auth.logout}}
            >Logout</button>
          {{else}}
            <LinkTo @route="login" class="btn btn-primary btn-sm">Login</LinkTo>
            <LinkTo @route="signup" class="btn btn-outline btn-sm">Sign Up</LinkTo>
          {{/if}}
        </div>
      </header>

      <main class="p-8">
        {{outlet}}
      </main>
    </div>
  </template>
}
