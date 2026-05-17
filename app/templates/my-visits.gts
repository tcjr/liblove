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
import { asMonthDayYear } from '#app/utils/dates.ts';
import MakeNewVisit from '#app/components/make-new-visit.gts';
import type { Visit } from '#app/data/visit.ts';

const METRO = 'chicago';

/*
Warp-drive wants you to use derrived state for most data displayed on the page.
This page doesn't do that, however, because I couldn't figure out how to get
a "live" collection of visits from a request. By that I mean one that will show
all the visits, then upate when a new visit is added by a component not directly
on this page. So, instead I am doing the initial query to populate the store,
then using a `peekAll` to get me a live collection of data that will update
whenever we add a new visit to the store. This feels brittle and will break if
we ever add the ability to view visits from other users. The data model doesn't
support that right now, so I'm not gonna worrry about it. Also, I don't know
what will happen if we delete a visit.
*/

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
    return this.store.peekAll<Visit>('visit');
  }

  get visitIds() {
    return new Set(this.visits.map((visit) => visit.library.id));
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

  getVisit = (library: Library) => {
    return this.visits.find((visit) => visit.library.id === library.id);
  };

  hasVisited = (library: Library) => {
    return this.visitIds.has(library.id);
  };

  get percentageVisited() {
    if (this.libraries.length === 0) {
      return '0';
    }
    return ((this.visitIds.size / this.libraries.length) * 100).toFixed(1);
  }

  get latestVisit() {
    return this.visits.at(-1);
  }

  <template>
    {{pageTitle "Libraries"}}

    <Request @request={{this.visitsRequest}}>
      {{! 
        Note: We're not using the content. This component is here to kick off
        the request and have a place to show errors.
      }}
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
            <div class="divider"></div>
            <LibraryMap
              @metroId={{METRO}}
              @selectedId={{this.selectedId}}
              @onSelect={{this.selectLibrary}}
              @highlightedId={{this.highlightedId}}
              @onHighlight={{this.highlightLibrary}}
              @visitedIds={{this.visitIds}}
              class="w-full"
            />
          </div>

          <div class="w-1/3">
            <div class="stats">

              <div class="stat">
                <div class="stat-title">Visited</div>
                <div class="stat-value">
                  {{this.visitIds.size}}
                  <span class="text-sm">of</span>
                  {{this.libraries.length}}
                </div>
                <div class="stat-desc">{{this.percentageVisited}}% visited</div>
              </div>

              <div class="stat">
                <div class="stat-title">Latest Visit</div>
                <div class="stat-value">
                  {{asMonthDayYear this.latestVisit.visitedAt}}
                </div>
                <div class="stat-desc">{{this.latestVisit.library.name}}</div>
              </div>

            </div>
            <div class="divider"></div>
            {{#if this.selectedLibrary}}
              <div class="px-2 pt-2">
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
                    class="rounded-box"
                    alt={{this.selectedLibrary.name}}
                    @src={{netlify
                      (concat "/images/" this.selectedLibrary.img)
                      aspectRatio=1.5
                    }}
                  />
                  <p class="text-right text-base-content/25 text-xs">
                    library id
                    {{this.selectedLibrary.id}}
                  </p>
                </div>
                <div>
                  {{#let (this.getVisit this.selectedLibrary) as |visit|}}
                    {{#if visit}}
                      <p>
                        Visited on:
                        {{asMonthDayYear visit.visitedAt}}
                      </p>
                    {{else}}
                      <p>
                        Not yet visited.
                      </p>
                      <MakeNewVisit @library={{this.selectedLibrary}} />
                    {{/if}}
                  {{/let}}

                </div>
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
