import { pageTitle } from 'ember-page-title';
import Component from '@glimmer/component';
import CellMap from '#app/components/cell-map.gts';
import { trackedSet } from '@ember/reactive/collections';
import { tracked } from '@glimmer/tracking';

import { getMetroLibraryMap } from '#app/data/api';
import { Request } from '@warp-drive/ember';

const PREFILL_VISITED = [
  '31',
  '8',
  '56',
  '50',
  '10',
  '37',
  '17',
  '9',
  '2',
  '12',
  '21',
  '64',
  '79',
  '19',
  '52',
  '42',
  '30',
  '15',
  '28',
  '41',
  '80',
  '54',
  '45',
  '35',
  '16',
  '69',
  '18',
  '33',
  '11',
  '40',
  '1',
  '6',
  '34',
  '77',
  '38',
  '74',
  '44',
  '43',
  '67',
];

export default class MapComponent extends Component {
  visited = trackedSet(PREFILL_VISITED);
  @tracked highlightedId: string | null = null;
  @tracked selectedId?: string;

  selectLibrary = (id: string) => {
    // deselect if it is selected
    if (this.selectedId === id) {
      this.selectedId = undefined;
    } else {
      this.selectedId = id;
    }
  };

  highlightLibrary = (id: string | null) => {
    this.highlightedId = id;
  };

  query = getMetroLibraryMap('chicago');

  <template>
    {{pageTitle "Map"}}

    <Request @query={{this.query}}>
      <:content as |response state|>
        {{!JSON.stringify state}}
        {{!JSON.stringify response}}
        <div class="flex flex-row">
          <div class="w-1/2 px-10">
            <CellMap
              @viewBox="0 0 {{response.data.svg.width}} {{response.data.svg.height}}"
              @cells={{response.data.libraryCells}}
              @outlinePath={{response.data.metro.outlinePath}}
              @visited={{this.visited}}
              @selected={{this.selectedId}}
              @onSelect={{this.selectLibrary}}
              @onHighlight={{this.highlightLibrary}}
            />
          </div>
          <div>
            <div class="text-5xl font-black">
              {{if this.highlightedId this.highlightedId "--"}}
            </div>
            <div>
              {{#if this.selectedId}}
                (Details for library
                {{this.selectedId}}
                here)
              {{/if}}
            </div>
          </div>
        </div>
        <hr />
        <div>
          Selected:
          {{JSON.stringify this.selectedId}}
        </div>
        <div>
          Visited:
          {{JSON.stringify (Array.from this.visited)}}
        </div>

      </:content>
      <:loading>
        <p>Loading ...</p>
      </:loading>
      <:error as |e state|>
        <h2>Error loading data</h2>
        <p>
          {{e.message}}
        </p>
        {{!JSON.stringify state}}
        {{log "state" state}}
        {{! eslint-disable-next-line ember/template-no-log }}
        {{log "error" e}}
      </:error>
    </Request>
  </template>
}
