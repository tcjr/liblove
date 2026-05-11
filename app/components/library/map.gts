import Component from '@glimmer/component';
import { getMetroLibraryMap } from '#app/data/api';
import { Request } from '@warp-drive/ember';
import CellMap from '#app/components/cell-map.gts';

export interface LibraryMapSignature {
  Args: {
    metroId: string;
    selectedId?: string;
    onSelect?: (id: string) => void;

    highlightedId?: string | null;
    onHighlight?: (id: string | null) => void;
  };

  Element: HTMLDivElement;
}

export default class LibraryMap extends Component<LibraryMapSignature> {
  query = getMetroLibraryMap(this.args.metroId);

  <template>
    <div ...attributes>

      <Request @query={{this.query}}>
        <:content as |response|>
          <CellMap
            @viewBox="0 0 {{response.data.svg.width}} {{response.data.svg.height}}"
            @cells={{response.data.libraryCells}}
            @outlinePath={{response.data.metro.outlinePath}}
            @selected={{@selectedId}}
            @onSelect={{@onSelect}}
            @highlighted={{@highlightedId}}
            @onHighlight={{@onHighlight}}
          />
        </:content>
        <:loading>
          <p>Loading ...</p>
        </:loading>
        <:error as |e|>
          <h2>Error loading data</h2>
          <p>
            {{e.message}}
          </p>
          {{! eslint-disable-next-line ember/template-no-log }}
          {{log "error" e}}
        </:error>
      </Request>

    </div>
  </template>
}
