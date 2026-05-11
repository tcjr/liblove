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

    /**
     * The ids of the cells that have been visited.
     */
    visited?: Set<string>;

    /**
     * The id of the cell that is currently selected.
     */
    selected?: string;

    /**
     * Called when a cell is selected/clicked. The caller is responsible for
     * updating `@selected` if desired. This component does not own any state.
     */
    onSelect?: (id: string) => void;

    /**
     * The id of the cell that is currently highlighted.
     */
    highlighted?: string | null;

    /**
     * Called when a cell is hovered over. It is called with `null` when the
     * mouse leaves the map.
     */
    onHighlight?: (id: string | null) => void;
  };
  Element: SVGElement;
}

/**
 * Display an SVG of points on a map and regions (or "cells") representing the
 * voronoi areas around those points.
 *
 * The cells are identified by `id` and the id is used in the event interface.
 * Currently, it supports marking cells as `visited` (multiple) and `selected`
 * (single). This component will add add the corresponding css class and/or
 * data-* attributes, but it does not maintain any state outside the DOM. The
 * caller is responsible for the data down.
 */
export default class CellMap extends Component<CellMapSignature> {
  hasVisited = (id: string) => {
    return Boolean(this.args.visited?.has(id));
  };

  isSelected = (id: string) => {
    return Boolean(this.args.selected === id);
  };

  selectCell = (id: string) => {
    console.log('[CellMap] select cell ', id);
    this.args.onSelect?.(id);
  };

  isHighlighted = (id: string) => {
    return Boolean(this.args.highlighted === id);
  };

  highlightCell = (id: string) => {
    console.log('[CellMap] highlight cell ', id);
    this.args.onHighlight?.(id);
  };

  unhighlight = () => {
    console.log('[CellMap] unhighlight ');
    this.args.onHighlight?.(null);
  };

  <template>
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox={{@viewBox}}
      class="cell-map"
      ...attributes
    >
      {{! voronoi cells }}
      <g {{on "mouseleave" this.unhighlight}}>
        {{#each @cells as |cell|}}
          {{! eslint-disable-next-line ember/template-no-invalid-interactive }}
          <path
            class="voronoi-cell cursor-pointer
              {{if (this.hasVisited cell.id) 'visited'}}
              {{if (this.isSelected cell.id) 'selected'}}
              {{if (this.isHighlighted cell.id) 'highlighted'}}
              fill-base-300 stroke-base-100 stroke-1"
            data-item-id={{cell.id}}
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
            class="item-marker
              {{if (this.hasVisited cell.id) 'visited'}}
              {{if (this.isSelected cell.id) 'selected'}}
              {{if (this.isHighlighted cell.id) 'highlighted'}}
              pointer-events-none fill-current stroke-current"
            cx={{cell.markerX}}
            cy={{cell.markerY}}
            r="3"
          />
        {{/each}}
      </g>

      {{#if @outlinePath}}
        <path
          id="city-outline"
          class="city-outline stroke-current fill-none stroke-2 pointer-events-none"
          vector-effect="non-scaling-stroke"
          d={{@outlinePath}}
        />
      {{/if}}

    </svg>
  </template>
}
