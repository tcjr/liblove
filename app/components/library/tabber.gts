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
      newIndex = this.args.libraries.length - 1;
    } else {
      newIndex = currentIndex - 1;
    }

    const newLibrary = this.args.libraries[newIndex] as Library;
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
    if (currentIndex === this.args.libraries.length - 1) {
      newIndex = 0;
    } else {
      newIndex = currentIndex + 1;
    }

    const newLibrary = this.args.libraries[newIndex] as Library;
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
    return this.args.libraries.findIndex(
      (lib) => lib.id === this.args.selectedId
    );
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
    return this.args.libraries[this.selectedIndex];
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
