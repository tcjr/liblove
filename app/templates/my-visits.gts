import { getVisits } from '#app/data/api.ts';
import type AuthService from '#app/services/auth.ts';
import type Store from '#app/services/store.ts';
import Component from '@ember/component';
import { service } from '@ember/service';
import { cached } from '@glimmer/tracking';
import { getRequestState, Request } from '@warp-drive/ember';

export default class MyVisitsComponent extends Component {
  @service declare store: Store;
  @service declare auth: AuthService;

  @cached
  get visitsRequest() {
    return this.store.request(getVisits());
  }

  get visitIds() {
    const visits = getRequestState(this.visitsRequest).value?.data;
    if (!visits) {
      return [];
    }
    return visits.map((visit) => visit.id);
  }

  <template>
    Hello.
    {{#if this.auth.isAuthenticated}}
      <p>
        Ok, logged in.
      </p>
      <p>
        Just the ids:
        <pre>{{JSON.stringify this.visitIds}}</pre>
      </p>
      <hr />
      <div>
        <Request @request={{this.visitsRequest}}>
          <:content as |response|>
            <pre>{{JSON.stringify response null 2}}</pre>
          </:content>
          <:loading>
            <p>Loading visits...</p>
          </:loading>

          <:error as |e|>
            <h2>Error loading visits</h2>
            <p>
              {{e.message}}
            </p>
            {{! eslint-disable-next-line ember/template-no-log }}
            {{log "error" e}}
          </:error>
        </Request>

      </div>

    {{else}}
      <p>
        This page is intended for logged-in users. Login then try it again.
      </p>
    {{/if}}
  </template>
}
