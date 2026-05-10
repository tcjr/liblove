import type { Library } from '#app/data/library.ts';
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

  <template>
    <ul
      class="flex flex-wrap gap-1 justify-center"
      ...attributes
      {{on "mouseleave" (fn this.highlightLibrary null)}}
    >
      {{#each @libraries as |lib|}}
        <li data-library-id={{lib.id}}>
          <button
            type="button"
            {{on "click" (fn this.chooseLibrary lib)}}
            {{on "mouseenter" (fn this.highlightLibrary lib)}}
            class="text-sm inline-block border border-primary px-2 rounded cursor-pointer
              {{if
                (this.isHighlighted lib)
                'highlighted bg-secondary text-secondary-content'
              }}
              {{if
                (this.isSelected lib)
                'selected bg-accent text-accent-content'
              }}"
          >
            {{lib.name}}
          </button>
        </li>
      {{/each}}
    </ul>
  </template>
}
