import type { Library } from '#app/data/library.ts';
import { on } from '@ember/modifier';
import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';

export interface LibraryTabberSignature {
  Args: {
    /** The list of libraries to display and navigate between. */
    libraries: Library[];
    /** The ID of the currently selected library. */
    selectedId?: string;
    /** Configures the paging order of the libraries. */
    sort?: 'name' | 'geo';
    /** Callback triggered when a new library is selected via the Next/Prev buttons. */
    onSelect?: (id: string) => void;
  };
  /** The root element of the component. */
  Element: HTMLDivElement;
}

/**
 * A component that allows navigating through a list of libraries
 * using previous and next buttons. It wraps around when reaching
 * the start or end of the list.
 */
export default class LibraryTabber extends Component<LibraryTabberSignature> {
  @cached
  get sortedLibraries() {
    const { libraries, sort } = this.args;
    if (!libraries || libraries.length === 0) {
      return [];
    }

    if (sort === 'name') {
      return [...libraries].sort((a, b) => a.name.localeCompare(b.name));
    }

    if (sort === 'geo') {
      const libs = [...libraries];
      let startIdx = 0;
      let maxTopLeft = -Infinity;

      // Find top-left-most library (maximize lat - lon)
      // Note: Typically in US, lon is negative. Max lat is north, min lon is west.
      // So maximize latitude - longitude
      for (let i = 0; i < libs.length; i++) {
        const lib = libs[i];
        if (!lib) continue;
        const val = lib.lat - lib.lon;
        if (val > maxTopLeft) {
          maxTopLeft = val;
          startIdx = i;
        }
      }

      const sorted: Library[] = [];
      let current = libs.splice(startIdx, 1)[0] as Library;
      sorted.push(current);

      while (libs.length > 0) {
        let nearestIdx = 0;
        let minDistanceSq = Infinity;

        for (let i = 0; i < libs.length; i++) {
          const lib = libs[i];
          if (!lib) continue;
          const distanceSq =
            Math.pow(lib.lat - current.lat, 2) +
            Math.pow(lib.lon - current.lon, 2);
          if (distanceSq < minDistanceSq) {
            minDistanceSq = distanceSq;
            nearestIdx = i;
          }
        }

        current = libs.splice(nearestIdx, 1)[0] as Library;
        sorted.push(current);
      }

      return sorted;
    }

    return libraries;
  }

  /** Checks if a given library is currently selected. */
  isSelected = (lib: Library) => {
    return lib.id === this.args.selectedId;
  };

  /** Selects the previous library in the list, wrapping to the end if necessary. */
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
      newIndex = this.sortedLibraries.length - 1;
    } else {
      newIndex = currentIndex - 1;
    }

    const newLibrary = this.sortedLibraries[newIndex] as Library;
    this.args.onSelect(newLibrary.id);
  };

  /** Selects the next library in the list, wrapping to the start if necessary. */
  chooseNext = () => {
    if (!this.args.onSelect) {
      return;
    }
    if (!this.args.selectedId) {
      return;
    }

    const currentIndex = this.selectedIndex;
    let newIndex = 0;
    if (currentIndex === this.sortedLibraries.length - 1) {
      newIndex = 0;
    } else {
      newIndex = currentIndex + 1;
    }

    const newLibrary = this.sortedLibraries[newIndex] as Library;
    this.args.onSelect(newLibrary.id);
  };

  /**
   * Gets the index of the currently selected library.
   * Defaults to 0 if no library is selected.
   */
  @cached
  get selectedIndex() {
    if (!this.args.selectedId) {
      return 0;
    }
    const index = this.sortedLibraries.findIndex(
      (lib) => lib.id === this.args.selectedId
    );
    return index === -1 ? 0 : index;
  }

  /**
   * Gets the currently selected library object based on `selectedId`.
   * Returns null if no library is selected.
   */
  get selectedLibrary() {
    // Don't consider the index if there is no library selected
    if (!this.args.selectedId) {
      return null;
    }

    // return this.args.libraries.find((lib) => this.args.selectedId === lib.id);
    return this.sortedLibraries[this.selectedIndex];
  }

  <template>
    <div class="flex flex-row justify-between" ...attributes>
      <button type="button" {{on "click" this.choosePrev}} class="btn">
        PREV
      </button>
      {{#let this.selectedLibrary as |lib|}}
        <div data-library-id={{lib.id}} class="text-center text-balance">
          {{lib.name}}
        </div>
      {{/let}}
      <button type="button" {{on "click" this.chooseNext}} class="btn">
        NEXT
      </button>
    </div>
  </template>
}
