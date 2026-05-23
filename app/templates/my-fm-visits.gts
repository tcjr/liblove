import { pageTitle } from 'ember-page-title';
import { cached, tracked } from '@glimmer/tracking';
import Component from '@glimmer/component';
import type Owner from '@ember/owner';
import FmMap from '#app/components/fm/map.gts';
// import FmTabber from '#app/components/fm/tabber.gts';
import type { FarmersMarket, MetroCellMap } from '#app/data/models.ts';

interface MyFmVisitsSignature {
  Args: {
    model: { markets: FarmersMarket[]; map: MetroCellMap };
  };
  Element: HTMLDivElement;
}

export default class MyVisitsComponent extends Component<MyFmVisitsSignature> {
  constructor(owner: Owner, args: MyFmVisitsSignature['Args']) {
    super(owner, args);
    this.chooseDefaultMarket();
  }

  get markets() {
    return this.args.model.markets;
  }

  getMarket = (id: string) => {
    return this.markets.find((market) => market.id === id);
  };

  get map() {
    return this.args.model.map;
  }

  // SELECTION AND HIGHLIGHTING

  @tracked selectedId?: string;
  selectMarket = (id: string) => {
    this.selectedId = id;
  };

  @tracked highlightedId: string | null = null;
  highlightMarket = (id: string | null) => {
    this.highlightedId = id;
  };

  get selectedMarket() {
    if (!this.selectedId) {
      return null;
    }
    return this.markets.find((market) => market.id === this.selectedId) || null;
  }

  get highlightedMarket() {
    if (!this.highlightedId) {
      return null;
    }
    return (
      this.markets.find((market) => market.id === this.highlightedId) || null
    );
  }

  // PAGE CONCERNS

  chooseDefaultMarket = () => {
    // Pick a random market and select it
    const randomIndex = Math.floor(Math.random() * this.markets.length);
    const marketId = this.markets?.[randomIndex]?.id;
    if (marketId) {
      this.selectMarket(marketId);
    }
  };

  <template>
    {{pageTitle "My Farmers Market Visits"}}

    <div class="flex gap-2">

      <div class="w-1/3">
        {{!-- <FmTabber
          @markets={{this.markets}}
          @selectedId={{this.selectedId}}
          @onSelect={{this.selectMarket}}
          @sort="lon"
          class="text-xl font-semibold"
        />
        <div class="divider"></div> --}}
        <FmMap
          @map={{this.map}}
          @selectedId={{this.selectedId}}
          @onSelect={{this.selectMarket}}
          @highlightedId={{this.highlightedId}}
          @onHighlight={{this.highlightMarket}}
          class="w-full"
        />
      </div>

      <div class="w-1/3">
        <div class="divider"></div>
        {{#if this.selectedMarket}}
          <div class="px-2 pt-2" data-test-selected-market>
            <h3
              class="font-black text-3xl text-balance"
            >{{this.selectedMarket.name}}</h3>
            <address>
              {{this.selectedMarket.address}}
              <br />
              {{this.selectedMarket.city}},
              {{this.selectedMarket.state}}
              {{this.selectedMarket.zip}}
            </address>
            <div>

              <p class="text-right text-base-content/25 text-xs">
                market id
                {{this.selectedMarket.id}}
              </p>
            </div>

          </div>
        {{/if}}
      </div>

    </div>
  </template>
}
