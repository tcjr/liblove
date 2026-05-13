import type { Library } from '#app/data/library.ts';
import { on } from '@ember/modifier';
import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';

export interface LibraryTabberSignature {
  Args: {
    libraries: Library[];
    selectedId?: string;
    onSelect?: (id: string) => void;
  };
  Element: HTMLUListElement;
}

export default class LibraryTabber extends Component<LibraryTabberSignature> {
  isSelected = (lib: Library) => {
    return lib.id === this.args.selectedId;
  };

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

  @cached
  get selectedIndex() {
    if (!this.args.selectedId) {
      return 0;
    }
    return this.args.libraries.findIndex(
      (lib) => lib.id === this.args.selectedId
    );
  }

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
      <button
        type="button"
        {{on "click" this.choosePrev}}
        class="btn"
      >PREV</button>
      {{#let this.selectedLibrary as |lib|}}
        <div data-library-id={{lib.id}} class="text-center text-balance">
          {{lib.name}}
        </div>
      {{/let}}
      <button
        type="button"
        {{on "click" this.chooseNext}}
        class="btn"
      >NEXT</button>
    </div>
  </template>
}
