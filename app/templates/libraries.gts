import { pageTitle } from 'ember-page-title';
import Component from '@glimmer/component';
import { getRequestState, Request } from '@warp-drive/ember';
import { getLibraries } from '#app/data/api';
import LibraryList from '#app/components/library/list.gts';
import { cached, tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import type Store from '#app/services/store.ts';
import LibraryMap from '#app/components/library/map.gts';

export default class LibrariesComponent extends Component {
  @service declare store: Store;

  // query = getLibraries('chicago');
  @cached
  get librariesRequest() {
    return this.store.request(getLibraries('chicago'));
  }

  @tracked selectedId?: string;
  selectLibrary = (id: string) => {
    console.log('selectLibrary', id);
    this.selectedId = id;
  };

  @tracked highlightedId: string | null = null;
  highlightLibrary = (id: string | null) => {
    console.log('highlightLibrary', id);
    this.highlightedId = id;
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

  get highlightedLibrary() {
    if (!this.highlightedId) {
      return null;
    }
    const libraries = getRequestState(this.librariesRequest).value?.data;
    if (!libraries) {
      return null;
    }
    return libraries.find((lib) => lib.id === this.highlightedId);
  }

  <template>
    {{pageTitle "Libraries"}}

    <Request @request={{this.librariesRequest}}>
      <:content as |response|>

        <div class="flex gap-2">
          <LibraryList
            @libraries={{response.data}}
            @selectedId={{this.selectedId}}
            @onSelect={{this.selectLibrary}}
            @highlightedId={{this.highlightedId}}
            @onHighlight={{this.highlightLibrary}}
            class="text-center w-1/3"
          />

          <LibraryMap
            @metroId="chicago"
            @selectedId={{this.selectedId}}
            @onSelect={{this.selectLibrary}}
            @highlightedId={{this.highlightedId}}
            @onHighlight={{this.highlightLibrary}}
            class="w-1/3"
          />

          <div class="w-1/3 flex-1">
            {{#if this.selectedLibrary}}
              <h3 class="font-bold text-3x">{{this.selectedLibrary.name}}</h3>
              <address>
                {{this.selectedLibrary.address}}
                <br />
                {{this.selectedLibrary.city}},
                {{this.selectedLibrary.state}}
                {{this.selectedLibrary.zip}}
              </address>
              <img
                class="w-48"
                alt={{this.selectedLibrary.name}}
                src="/images/{{this.selectedLibrary.img}}"
              />
              {{! eslint-disable-next-line ember/template-no-log }}
              {{log "selected" (JSON.stringify this.selectedLibrary)}}
            {{/if}}
          </div>

        </div>

        <div>
          {{#if this.highlightedId}}
            <h3 class="font-bold text-3x">{{this.highlightedLibrary.name}}</h3>
            <img
              class="w-14"
              alt={{this.highlightedLibrary.name}}
              src="/images/{{this.highlightedLibrary.img}}"
            />
          {{/if}}
        </div>

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
