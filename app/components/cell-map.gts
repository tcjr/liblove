import Component from '@glimmer/component';
import './cell-map.css';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';

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
    /** The ids of the cells that have been visited. */
    visited?: string[];
    /** Called when a cell is selected/clicked. */
    onSelect?: (id: string) => void;
    /**
     * Called when a cell is hovered over. It is called with `null` when the
     * mouse leaves the map.
     */
    onHighlight?: (id: string) => void;
  };
  Element: SVGElement;
}

export default class CellMap extends Component<CellMapSignature> {
  hasVisited = (id: string) => {
    return Boolean(this.args.visited?.includes(id));
  };

  selectCell = (id: string) => {
    console.log('[CellMap] select cell ', id);
    this.args.onSelect?.(id);
  };

  highlightCell = (id: string) => {
    console.log('[CellMap] highlight cell ', id);
    this.args.onHighlight?.(id);
  };

  <template>
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox={{@viewBox}}
      class="cell-map"
      ...attributes
    >
      {{! voronoi cells }}
      <g {{on "mouseout" (fn this.highlightCell null)}}>
        {{#each @cells as |cell|}}
          <path
            class="voronoi-cell {{if (this.hasVisited cell.id) 'visited'}}"
            data-item-id={{cell.id}}
            fill="gray"
            stroke="black"
            stroke-width="1"
            d={{cell.outlinePath}}
            {{on "click" (fn this.selectCell cell.id)}}
            {{on "mouseover" (fn this.highlightCell cell.id)}}
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
