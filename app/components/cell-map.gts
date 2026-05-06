import Component from '@glimmer/component';
import './cell-map.css';

// This is the data required for rendering the cell on the map.
export interface MappableCell {
  id: string;
  name: string;
  outlinePath: string;
  markerX: number;
  markerY: number;
}

export interface CellMapSignature {
  Args: {
    cells: MappableCell[];
    viewBox: string;
    outlinePath?: string;
  };
  Element: SVGElement;
}

export default class CellMap extends Component<CellMapSignature> {
  <template>
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox={{@viewBox}}
      class="cell-map"
      ...attributes
    >
      {{! voronoi cells }}
      <g>
        {{#each @cells as |cell|}}
          <path
            class="voronoi-cell"
            data-item-id={{cell.id}}
            fill="gray"
            stroke="black"
            stroke-width="1"
            d={{cell.outlinePath}}
          >
            <title>{{cell.name}}</title>
          </path>
        {{/each}}

      </g>

      {{! item markers }}
      <g>
        {{#each @cells as |cell|}}
          <circle
            class="item-marker"
            cx={{cell.markerX}}
            cy={{cell.markerY}}
            r="3"
          />
        {{/each}}
      </g>

      {{#if @outlinePath}}
        <path
          id="city-outline"
          class="city-outline"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          vector-effect="non-scaling-stroke"
          d={{@outlinePath}}
        />
      {{/if}}

    </svg>
  </template>
}
