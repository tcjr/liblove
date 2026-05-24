import { pageTitle } from 'ember-page-title';
import { cached, tracked } from '@glimmer/tracking';
import Component from '@glimmer/component';
import type Owner from '@ember/owner';
import LibraryMap from '#app/components/library/map.gts';
import { ResponsiveImage } from '@responsive-image/ember';
import { netlify } from '@responsive-image/cdn';
import { concat } from '@ember/helper';
import Tabber from '#app/components/tabber.gts';
import { asMonthDayYear } from '#app/utils/dates.ts';
import type { Library, MetroCellMap } from '#app/data/models.ts';
import MakeNewVisit from '#app/components/make-new-visit.gts';
import RemoveVisit from '#app/components/remove-visit.gts';
import { service } from '@ember/service';
import type VisitsService from '#app/services/visits.ts';

interface MyVisitsSignature {
  Args: {
    model: { libraries: Library[]; map: MetroCellMap };
  };
  Element: HTMLDivElement;
}

export default class MyVisitsComponent extends Component<MyVisitsSignature> {
  @service('visits') declare visitsService: VisitsService;

  constructor(owner: Owner, args: MyVisitsSignature['Args']) {
    super(owner, args);
    this.chooseDefaultLibrary();
  }

  @cached
  get visits() {
    return [...this.visitsService.libraryVisits].sort((a, b) => {
      return a.visitedAt.getTime() - b.visitedAt.getTime();
    });
  }

  get libraries() {
    return this.args.model.libraries;
  }

  getLibrary = (id: string) => {
    return this.libraries.find((lib) => lib.id === id);
  };

  get map() {
    return this.args.model.map;
  }

  updateVisits = () => {
    // Local storage is reactive and automatically updates the template.
    // TODO: add toast or other visual feedback
  };

  get visitIds() {
    return new Set(this.visits.map((visit) => visit.libraryId));
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
    return this.visits.find((visit) => visit.libraryId === library.id);
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

  // PAGE CONCERNS

  chooseDefaultLibrary = () => {
    // Pick a random library and select it
    const randomIndex = Math.floor(Math.random() * this.libraries.length);
    const libId = this.libraries?.[randomIndex]?.id;
    if (libId) {
      this.selectLibrary(libId);
    }
  };

  <template>
    {{pageTitle "My Library Visits"}}

    <div class="flex gap-2">

      <div class="w-1/3">
        <Tabber
          @items={{this.libraries}}
          @selectedId={{this.selectedId}}
          @onSelect={{this.selectLibrary}}
          @sort="lon"
          class="text-xl font-semibold"
        />
        <div class="divider"></div>
        <LibraryMap
          @map={{this.map}}
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
            <div class="stat-title">Progress</div>
            <div class="stat-value">
              {{this.visitIds.size}}
              <span class="text-sm">of</span>
              {{this.libraries.length}}
            </div>
            <div class="stat-desc">{{this.percentageVisited}}% visited</div>
          </div>

          {{#if this.latestVisit}}
            <div class="stat">
              <div class="stat-title">Latest Visit</div>
              <div class="stat-value">
                {{asMonthDayYear this.latestVisit.visitedAt}}
              </div>
              <div class="stat-desc">
                {{#let (this.getLibrary this.latestVisit.libraryId) as |lib|}}
                  {{lib.name}}
                {{/let}}
              </div>
            </div>
          {{/if}}

        </div>
        <div class="divider"></div>
        {{#if this.selectedLibrary}}
          <div class="px-2 pt-2" data-test-selected-library>
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
                  <RemoveVisit
                    @visit={{visit}}
                    @library={{this.selectedLibrary}}
                    @onRemove={{this.updateVisits}}
                  />
                {{else}}
                  <p>
                    Not yet visited.
                  </p>
                  <MakeNewVisit
                    @library={{this.selectedLibrary}}
                    @onSave={{this.updateVisits}}
                  />
                {{/if}}
              {{/let}}

            </div>
          </div>
        {{/if}}
      </div>

    </div>
  </template>
}
