import { pageTitle } from 'ember-page-title';
import { cached, tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import Component from '@glimmer/component';
import type Store from '#app/services/store.ts';
import { getRequestState, Request } from '@warp-drive/ember';
import { getLibraries, getVisits } from '#app/data/api';
import LibraryMap from '#app/components/library/map.gts';
import { ResponsiveImage } from '@responsive-image/ember';
import { netlify } from '@responsive-image/cdn';
import { concat } from '@ember/helper';
import LibraryTabber from '#app/components/library/tabber.gts';
import type { Library } from '#app/data/library.ts';

const METRO = 'chicago';

export default class MyVisitsComponent extends Component {
  @service declare store: Store;

  // DATA

  @cached
  get librariesRequest() {
    return this.store.request(getLibraries(METRO));
  }

  get libraries() {
    return getRequestState(this.librariesRequest).value?.data || [];
  }

  @cached
  get visitsRequest() {
    return this.store.request(getVisits());
  }

  get visits() {
    return getRequestState(this.visitsRequest).value?.data || [];
  }

  // SELECTION AND HIGHLIGHTING

  @tracked selectedId?: string;
  selectLibrary = (id: string) => {
    this.selectedId = id;
  };

  @tracked highlightedId: string | null = null;
  highlightLibrary = (id: string | null) => {
    this.highlightedId = id;
  };

  get selectedLibrary() {
    if (!this.selectedId) {
      return null;
    }
    return this.libraries.find((lib) => lib.id === this.selectedId) || null;
  }

  get highlightedLibrary() {
    if (!this.highlightedId) {
      return null;
    }
    return this.libraries.find((lib) => lib.id === this.highlightedId) || null;
  }

  // VISIT MANAGEMENT

  hasVisited = (library: Library) => {
    return this.visits.some((visit) => visit.library.id === library.id);
  };

  <template>
    {{pageTitle "Libraries"}}

    <Request @request={{this.visitsRequest}}>
      <:content as |response|>
        {{! eslint-disable-next-line ember/template-no-log }}
        {{log "loaded visits" response.data}}
      </:content>

      <:error as |e|>
        <h2>There was an error loading your visits</h2>
        <p>
          {{e.message}}
        </p>
        {{! eslint-disable-next-line ember/template-no-log }}
        {{log "visits loading error" e}}
      </:error>
    </Request>

    <Request @request={{this.librariesRequest}}>
      <:content as |response|>

        <div class="flex gap-2">

          <div class="w-1/3">
            <LibraryTabber
              @libraries={{response.data}}
              @selectedId={{this.selectedId}}
              @onSelect={{this.selectLibrary}}
              @sort="lon"
              class="text-xl font-semibold"
            />
            <hr />
            <LibraryMap
              @metroId={{METRO}}
              @selectedId={{this.selectedId}}
              @onSelect={{this.selectLibrary}}
              @highlightedId={{this.highlightedId}}
              @onHighlight={{this.highlightLibrary}}
              class="w-full"
            />
          </div>

          <div class="w-1/3">
            {{#if this.selectedLibrary}}
              <h3
                class="font-black text-3xl text-balance"
              >{{this.selectedLibrary.name}}</h3>
              <address>
                {{this.selectedLibrary.address}}
                <br />
                {{this.selectedLibrary.city}},
                {{this.selectedLibrary.state}}
                {{this.selectedLibrary.zip}}
              </address>
              <div>
                <ResponsiveImage
                  alt={{this.selectedLibrary.name}}
                  @src={{netlify
                    (concat "/images/" this.selectedLibrary.img)
                    aspectRatio=1.5
                  }}
                />
              </div>
              <div>
                {{#if (this.hasVisited this.selectedLibrary)}}
                  Visited? YES
                {{else}}
                  Visited? NO
                {{/if}}
              </div>
            {{/if}}
          </div>

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
