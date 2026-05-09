import { pageTitle } from 'ember-page-title';
import Component from '@glimmer/component';
import { getRequestState, Request } from '@warp-drive/ember';
import { getLibraries } from '#app/data/api';
import LibraryList from '#app/components/library/list.gts';
import { cached, tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import { service } from '@ember/service';
import type Store from '#app/services/store.ts';
import LibraryMap from '#app/components/library/map.gts';

function eq<T>(a: T, b: T) {
  return a === b;
}

export default class LibrariesComponent extends Component {
  @service declare store: Store;

  // query = getLibraries('chicago');
  @cached
  get librariesRequest() {
    return this.store.request(getLibraries('chicago'));
  }

  @tracked display: 'list' | 'map' = 'list';
  setDisplay = (display: 'list' | 'map') => {
    this.display = display;
  };

  @tracked selectedId?: string;
  selectLibrary = (id: string) => {
    console.log('selectLibrary', id);
    this.selectedId = id;
  };

  get selectedLibrary() {
    if (!this.selectedId) {
      return null;
    }
    const libraries = getRequestState(this.librariesRequest).value?.data;
    if (!libraries) {
      return null;
    }
    return libraries.find((lib) => lib.id === this.selectedId);
  }

  <template>
    {{pageTitle "Libraries"}}

    <div class="flex gap-4">
      <div class="w-1/3 flex-none border border-primary">

        <Request @request={{this.librariesRequest}}>
          <:content as |response|>

            <div role="tablist" class="tabs tabs-border">
              {{! eslint-disable-next-line ember/template-link-href-attributes }}
              <a
                role="tab"
                class="tab {{if (eq this.display 'list') 'tab-active'}}"
                {{on "click" (fn this.setDisplay "list")}}
              >
                List
              </a>
              {{! eslint-disable-next-line ember/template-link-href-attributes }}
              <a
                role="tab"
                class="tab {{if (eq this.display 'map') 'tab-active'}}"
                {{on "click" (fn this.setDisplay "map")}}
              >
                Map
              </a>
            </div>

            {{#if (eq this.display "list")}}
              <LibraryList
                @libraries={{response.data}}
                @selectedId={{this.selectedId}}
                @onSelect={{this.selectLibrary}}
                class="text-center"
              />
            {{else}}
              <LibraryMap
                @metroId="chicago"
                @selectedId={{this.selectedId}}
                @onSelect={{this.selectLibrary}}
              />
            {{/if}}
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
      </div>
      <div class="w-2/3 flex-1">
        <div>Selected</div>
        <div>
          {{#if this.selectedLibrary}}
            <h3 class="font-bold text-3x">{{this.selectedLibrary.name}}</h3>
            <address>
              {{this.selectedLibrary.address}}
              <br />
              {{this.selectedLibrary.city}},
              {{this.selectedLibrary.state}}
              {{this.selectedLibrary.zip}}
            </address>
            {{! eslint-disable-next-line ember/template-no-log }}
            {{log "selected" (JSON.stringify this.selectedLibrary)}}
          {{/if}}
        </div>
      </div>
    </div>
  </template>
}
