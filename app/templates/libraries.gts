import { pageTitle } from 'ember-page-title';
import Component from '@glimmer/component';
import { use } from 'ember-resources';
import { RemoteData } from 'reactiveweb/remote-data';

type Library = {
  id: string;
  name: string;
  address: string;
  city: string;
  state: string;
  zip: string;
  phone: string;
  img: string;
};

export default class ApplicationComponent extends Component {
  @use loadingLibraries = RemoteData<Library[]>('/api/libraries');

  <template>
    {{pageTitle "Libraries"}}

    {{#if this.loadingLibraries.isResolved}}
      <h2>Libraries ({{this.loadingLibraries.value.length}})</h2>
      <ul>
        {{#each this.loadingLibraries.value as |lib|}}
          <li>{{lib.name}} ({{lib.id}})</li>
        {{/each}}
      </ul>
    {{/if}}

    {{#if this.loadingLibraries.isError}}
      <h2>Error loading libraries</h2>
      {{log "loadingLibraries" this.loadingLibraries}}
    {{/if}}
  </template>
}
