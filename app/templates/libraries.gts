import { pageTitle } from 'ember-page-title';
import Component from '@glimmer/component';
import { Request } from '@warp-drive/ember';
import { getLibraries } from '#app/data/api';

export default class LibrariesComponent extends Component {
  <template>
    {{pageTitle "Libraries"}}

    <Request @query={{(getLibraries)}}>
      <:content as |response|>
        {{!log ":content response" response}}
        <h2>Libraries ({{response.data.length}})</h2>
        <ul>
          {{#each response.data as |lib|}}
            <li>{{lib.name}} ({{lib.id}})</li>
          {{/each}}
        </ul>
      </:content>

      <:loading>
        <p>Loading libraries...</p>

      </:loading>

      <:error as |e|>
        <h2>Error loading libraries</h2>
        <p>
          {{e.message}}
        </p>
        {{! eslint-disable-next-line ember/template-no-log }}
        {{log "error" e}}
      </:error>

    </Request>
  </template>
}
