import Component from '@glimmer/component';
import CellMap from '#app/components/cell-map.gts';
import type { MetroCellMap } from '#app/data/models.ts';

export interface FmMapSignature {
  Args: {
    map: MetroCellMap;

    selectedId?: string;
    onSelect?: (id: string) => void;

    highlightedId?: string | null;
    onHighlight?: (id: string | null) => void;

    visitedIds?: Set<string>;
  };

  Element: HTMLDivElement;
}

export default class FmMap extends Component<FmMapSignature> {
  get visitedIds() {
    return this.args.visitedIds || new Set();
  }

  onSelect = (id: string) => {
    const selFn = this.args.onSelect;
    if (!selFn) {
      return;
    }

    if (document.startViewTransition) {
      document.startViewTransition(() => {
        selFn(id);
      });
    } else {
      selFn(id);
    }
  };

  <template>
    <div ...attributes>

      <CellMap
        @viewBox="0 0 {{@map.svg.width}} {{@map.svg.height}}"
        @cells={{@map.cells}}
        @outlinePath={{@map.metro.outlinePath}}
        @selected={{@selectedId}}
        @onSelect={{this.onSelect}}
        @highlighted={{@highlightedId}}
        @onHighlight={{@onHighlight}}
        @visited={{this.visitedIds}}
      />

    </div>
  </template>
}
