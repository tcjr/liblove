import { pageTitle } from 'ember-page-title';
import Component from '@glimmer/component';
import CellMap from '#app/components/cell-map.gts';
import MAP_DATA from '#app/data/library-map-data.json';

export default class MapComponent extends Component {
  data = MAP_DATA;

  <template>
    {{pageTitle "Map"}}

    <div class="w-1/2 px-10">
      <CellMap
        @viewBox="0 0 {{this.data.svg.width}} {{this.data.svg.height}}"
        @cells={{this.data.libraryCells}}
        @outlinePath={{this.data.city.outlinePath}}
      />
    </div>
  </template>
}
