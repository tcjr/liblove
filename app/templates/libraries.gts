import LibraryList from '#app/components/library/list.gts';
import LibraryMap from '#app/components/library/map.gts';
import LibraryTabber from '#app/components/library/tabber.gts';
import type { Library, MetroLibraryMap } from '#app/data/models.ts';
import { concat } from '@ember/helper';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { netlify } from '@responsive-image/cdn';
import { ResponsiveImage } from '@responsive-image/ember';

interface LibsSignature {
  Args: {
    model: { libraries: Library[]; map: MetroLibraryMap };
  };
  Element: HTMLDivElement;
}

export default class LibrariesComponent extends Component<LibsSignature> {
  get libraries() {
    return this.args.model.libraries;
  }

  @tracked selectedId?: string;
  selectLibrary = (id: string) => {
    this.selectedId = id;
  };

  @tracked highlightedId: string | null = null;
  highlightLibrary = (id: string | null) => {
    this.highlightedId = id;
  };

  get selectedLibrary() {
    if (!this.selectedId) {
      return null;
    }
    return this.libraries.find((lib) => lib.id === this.selectedId) || null;
  }

  get highlightedLibrary() {
    if (!this.highlightedId) {
      return null;
    }

    return this.libraries.find((lib) => lib.id === this.highlightedId) || null;
  }

  <template>
    <div>
      {{@model.libraries.length}}
      libraries loaded
    </div>
    <div>
      {{@model.map.libraryCells.length}}
      map cells loaded for
      {{@model.map.metro.id}}
    </div>

    <LibraryList
      @libraries={{this.libraries}}
      @selectedId={{this.selectedId}}
      @onSelect={{this.selectLibrary}}
      @highlightedId={{this.highlightedId}}
      @onHighlight={{this.highlightLibrary}}
      class="text-center"
    />

    <LibraryTabber
      @libraries={{this.libraries}}
      @selectedId={{this.selectedId}}
      @onSelect={{this.selectLibrary}}
      @sort="name"
    />

    <LibraryMap
      @map={{@model.map}}
      @selectedId={{this.selectedId}}
      @onSelect={{this.selectLibrary}}
      @highlightedId={{this.highlightedId}}
      @onHighlight={{this.highlightLibrary}}
      class="w-full"
    />

    <div>
      {{#if this.selectedLibrary}}
        <h3
          class="font-black text-3xl text-balance"
        >{{this.selectedLibrary.name}}</h3>
        <address>
          {{this.selectedLibrary.address}}
          <br />
          {{this.selectedLibrary.city}},
          {{this.selectedLibrary.state}}
          {{this.selectedLibrary.zip}}
        </address>
        <div>
          <ResponsiveImage
            alt={{this.selectedLibrary.name}}
            @src={{netlify
              (concat "/images/" this.selectedLibrary.img)
              aspectRatio=1.5
            }}
          />
        </div>
      {{/if}}
    </div>
  </template>
}
