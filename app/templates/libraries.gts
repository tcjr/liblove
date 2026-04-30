import { pageTitle } from 'ember-page-title';
import Component from '@glimmer/component';
import { Request } from '@warp-drive/ember';
import { getLibraries } from '#app/data/api';
import { ResponsiveImage } from '@responsive-image/ember';
import { netlify } from '@responsive-image/cdn';
import type { Library } from '#app/data/library.ts';

function netlifyImage(library: Library) {
  return netlify(`/images/${library.img}`, {
    quality: 20,
    aspectRatio: 1.5,
  });
}

export default class LibrariesComponent extends Component {
  <template>
    {{pageTitle "Libraries"}}

    <Request @query={{(getLibraries)}}>
      <:content as |response|>
        {{!log ":content response" response}}
        <h2>Libraries ({{response.data.length}})</h2>
        <ul>
          {{#each response.data as |lib|}}
            <li class="flex flex-row gap-2" data-library-id={{lib.id}}>
              <div class="w-1/4">
                <ResponsiveImage @src={{netlifyImage lib}} />
              </div>
              <div>
                <div class="font-black text-lg">{{lib.name}}</div>
                <address>
                  {{lib.address}}<br />
                  {{lib.city}},
                  {{lib.state}}
                  {{lib.zip}}
                </address>
              </div>
            </li>
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
