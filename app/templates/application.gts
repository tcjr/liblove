import { LinkTo } from '@ember/routing';
import { pageTitle } from 'ember-page-title';
import Component from '@glimmer/component';
import type AuthService from '#app/services/auth.ts';
import { service } from '@ember/service';
import ChicagoFlag from '#app/components/chicago-flag.gts';

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
        {{#if this.auth.isAuthenticated}}
          |
          <LinkTo @route="my-visits">My Visits</LinkTo>
        {{/if}}
      </div>
    </nav>

    <main class="min-h-screen">
      {{outlet}}
    </main>
    <footer
      class="footer footer-horizontal footer-center bg-primary text-primary-content p-10 mt-4"
    >
      <aside>
        <ChicagoFlag class="w-12 h-12" />
        <p class="font-thinner">
          Made with ♥ at libraries in Chicago, 2026
        </p>
        <p>tcjr</p>
      </aside>
    </footer>
  </template>
}
