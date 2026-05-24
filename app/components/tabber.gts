import { on } from '@ember/modifier';
import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import './tabber.css';

interface TabbableItem {
  id: string;
  name: string;
  lat: number;
  lon: number;
}

export interface TabberSignature {
  Args: {
    /** The list of items to display and navigate between. */
    items: TabbableItem[];
    /** The ID of the currently selected item. */
    selectedId?: string;
    /**
     * Configures the paging order of the items.
     * - `name`: Alphabetical by name.
     * - `geo`: Geographic proximity (nearest neighbor, starting top-left).
     * - `lat`: Latitude, north to south.
     * - `lon`: Longitude, west to east.
     * - undefined: No sorting; original array order is preserved.
     */
    sort?: 'name' | 'geo' | 'lat' | 'lon';
    /** Callback triggered when a new item is selected via the Next/Prev buttons. */
    onSelect?: (id: string) => void;
  };
  /** The root element of the component. */
  Element: HTMLDivElement;
}

/**
 * A component that allows navigating through a list of items
 * using previous and next buttons. It wraps around when reaching
 * the start or end of the list.
 */
export default class Tabber extends Component<TabberSignature> {
  @cached
  get sortedItems() {
    const { items, sort } = this.args;
    if (!items || items.length === 0) {
      return [];
    }

    if (sort === 'name') {
      return [...items].sort((a, b) => a.name.localeCompare(b.name));
    }

    if (sort === 'lat') {
      return [...items].sort((a, b) => b.lat - a.lat);
    }

    if (sort === 'lon') {
      return [...items].sort((a, b) => a.lon - b.lon);
    }

    if (sort === 'geo') {
      const its = [...items];
      let startIdx = 0;
      let maxTopLeft = -Infinity;

      // Find top-left-most item (maximize lat - lon)
      // Note: Typically in US, lon is negative. Max lat is north, min lon is west.
      // So maximize latitude - longitude
      for (let i = 0; i < its.length; i++) {
        const itm = its[i];
        if (!itm) continue;
        const val = itm.lat - itm.lon;
        if (val > maxTopLeft) {
          maxTopLeft = val;
          startIdx = i;
        }
      }

      const sorted: TabbableItem[] = [];
      let current = its.splice(startIdx, 1)[0] as TabbableItem;
      sorted.push(current);

      while (its.length > 0) {
        let nearestIdx = 0;
        let minDistanceSq = Infinity;

        for (let i = 0; i < its.length; i++) {
          const itm = its[i];
          if (!itm) continue;
          const distanceSq =
            Math.pow(itm.lat - current.lat, 2) +
            Math.pow(itm.lon - current.lon, 2);
          if (distanceSq < minDistanceSq) {
            minDistanceSq = distanceSq;
            nearestIdx = i;
          }
        }

        current = its.splice(nearestIdx, 1)[0] as TabbableItem;
        sorted.push(current);
      }

      return sorted;
    }

    return items;
  }

  /** Checks if a given item is currently selected. */
  isSelected = (item: TabbableItem) => {
    return item.id === this.args.selectedId;
  };

  /** Selects the previous item in the list, wrapping to the end if necessary. */
  choosePrev = () => {
    if (!this.args.onSelect) {
      return;
    }
    if (!this.args.selectedId) {
      return;
    }

    const currentIndex = this.selectedIndex;
    let newIndex = 0;
    if (currentIndex === 0) {
      newIndex = this.sortedItems.length - 1;
    } else {
      newIndex = currentIndex - 1;
    }

    const newItem = this.sortedItems[newIndex] as TabbableItem;
    if (!newItem) {
      return;
    }

    const onSelect = this.args.onSelect;

    if (document.startViewTransition) {
      document.documentElement.classList.add('transition-prev');
      const transition = document.startViewTransition(() => {
        onSelect(newItem.id);
      });
      void transition.finished.finally(() => {
        document.documentElement.classList.remove('transition-prev');
      });
    } else {
      onSelect(newItem.id);
    }
  };

  /** Selects the next item in the list, wrapping to the start if necessary. */
  chooseNext = () => {
    if (!this.args.onSelect) {
      return;
    }
    if (!this.args.selectedId) {
      return;
    }

    const currentIndex = this.selectedIndex;
    let newIndex = 0;
    if (currentIndex === this.sortedItems.length - 1) {
      newIndex = 0;
    } else {
      newIndex = currentIndex + 1;
    }

    const newItem = this.sortedItems[newIndex] as TabbableItem;
    if (!newItem) {
      return;
    }

    const onSelect = this.args.onSelect;

    if (document.startViewTransition) {
      document.documentElement.classList.add('transition-next');
      const transition = document.startViewTransition(() => {
        onSelect(newItem.id);
      });
      void transition.finished.finally(() => {
        document.documentElement.classList.remove('transition-next');
      });
    } else {
      onSelect(newItem.id);
    }
  };

  /**
   * Gets the index of the currently selected item.
   * Defaults to 0 if no item is selected.
   */
  @cached
  get selectedIndex() {
    if (!this.args.selectedId) {
      return 0;
    }
    const index = this.sortedItems.findIndex(
      (item) => item.id === this.args.selectedId
    );
    return index === -1 ? 0 : index;
  }

  /**
   * Gets the currently selected item object based on `selectedId`.
   * Returns null if no item is selected.
   */
  get selectedItem() {
    // Don't consider the index if there is no item selected or no items.
    if (!this.args.selectedId || !this.args.items) {
      return null;
    }

    return this.sortedItems[this.selectedIndex];
  }

  <template>
    <div
      class="flex flex-row justify-between"
      ...attributes
      data-component="tabber"
    >
      <button type="button" {{on "click" this.choosePrev}} class="btn">
        &larr;
      </button>
      {{#let this.selectedItem as |item|}}
        <div
          data-tabber-item-id={{item.id}}
          class="flex-1 self-center px-4 text-center text-balance tabber-item-name-transition"
        >
          {{item.name}}
        </div>
      {{/let}}
      <button type="button" {{on "click" this.chooseNext}} class="btn">
        &rarr;
      </button>
    </div>
  </template>
}
