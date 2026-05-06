import { pageTitle } from 'ember-page-title';
import Component from '@glimmer/component';
import CellMap from '#app/components/cell-map.gts';
import MAP_DATA from '#app/data/library-map-data.json';
import { trackedSet } from '@ember/reactive/collections';
import { tracked } from '@glimmer/tracking';
const PREFILL_VISITED = ['17', '8', '15', '34', '38', '31'];

export default class MapComponent extends Component {
  data = MAP_DATA;
  visited = trackedSet(PREFILL_VISITED);
  @tracked highlightedId: string | null = null;

  selectLibrary = (id: string) => {
    if (this.visited.has(id)) {
      this.visited.delete(id);
    } else {
      this.visited.add(id);
    }
  };

  highlightLibrary = (id: string | null) => {
    this.highlightedId = id;
  };

  <template>
    {{pageTitle "Map"}}
    <div class="flex flex-row">
      <div class="w-1/2 px-10">
        <CellMap
          @viewBox="0 0 {{this.data.svg.width}} {{this.data.svg.height}}"
          @cells={{this.data.libraryCells}}
          @outlinePath={{this.data.city.outlinePath}}
          @visited={{Array.from this.visited}}
          @onSelect={{this.selectLibrary}}
          @onHighlight={{this.highlightLibrary}}
        />
      </div>
      <div>
        <div class="text-5xl font-black">
          {{if this.highlightedId this.highlightedId "--"}}
        </div>
      </div>
    </div>
    <hr />
    <div>
      Visited:
      {{JSON.stringify (Array.from this.visited)}}
    </div>
  </template>
}
