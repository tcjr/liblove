import type { Library } from '#app/data/models.ts';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import Component from '@glimmer/component';

export interface LibraryListSignature {
  Args: {
    libraries: Library[];
    selectedId?: string;
    onSelect?: (id: string) => void;

    highlightedId?: string | null;
    onHighlight?: (id: string | null) => void;
  };
  Element: HTMLUListElement;
}

export default class LibraryList extends Component<LibraryListSignature> {
  chooseLibrary = (lib: Library) => {
    this.args.onSelect?.(lib.id);
  };

  isSelected = (lib: Library) => {
    return lib.id === this.args.selectedId;
  };

  highlightLibrary = (lib: Library | null) => {
    const idOrNull = lib?.id ?? null;
    this.args.onHighlight?.(idOrNull);
  };

  isHighlighted = (lib: Library) => {
    return lib.id === this.args.highlightedId;
  };

  buttonClasses = (lib: Library) => {
    if (this.isSelected(lib) && this.isHighlighted(lib)) {
      return 'bg-(--chicago-blue) text-white border-(--chicago-blue)';
    } else if (this.isSelected(lib)) {
      return 'bg-(--chicago-blue) text-white border-(--chicago-blue)';
    } else if (this.isHighlighted(lib)) {
      return 'bg-(--chicago-blue) text-white border-(--chicago-blue)';
    } else {
      return 'bg-white text-(--chicago-blue-darker) border-(--chicago-blue)';
    }
  };

  <template>
    <ul
      class="flex flex-wrap gap-1 justify-center content-start"
      ...attributes
      {{on "mouseleave" (fn this.highlightLibrary null)}}
    >
      {{#each @libraries as |lib|}}
        <li data-library-id={{lib.id}}>
          <button
            type="button"
            class="text-sm inline-block px-2 rounded cursor-pointer border-2
              {{this.buttonClasses lib}}"
            {{on "click" (fn this.chooseLibrary lib)}}
            {{on "mouseenter" (fn this.highlightLibrary lib)}}
          >
            {{lib.name}}
          </button>
        </li>
      {{/each}}
    </ul>
  </template>
}
