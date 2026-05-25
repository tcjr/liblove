import { LinkTo } from '@ember/routing';
import { pageTitle } from 'ember-page-title';
import Component from '@glimmer/component';
import ChicagoFlag from '#app/components/chicago-flag.gts';

export default class ApplicationComponent extends Component {
  <template>
    {{pageTitle "Exploring Chicago"}}

    <nav class="flex flex-row gap-2 items-center py-2 px-4">
      <div>
        <LinkTo @route="index">Home</LinkTo>
        |
        <LinkTo @route="my-visits">Libraries</LinkTo>
        |
        <LinkTo @route="farmers-markets">Farmer's Markets</LinkTo>
        |
        <LinkTo @route="about">About</LinkTo>
      </div>
    </nav>

    <main class="min-h-screen">
      {{outlet}}
    </main>
    <footer
      class="footer footer-horizontal footer-center bg-primary text-primary-content p-10"
    >
      <aside>
        <ChicagoFlag class="w-12 h-12" />
        <p class="font-thinner text-xs">
          Made with ♥ at libraries in Chicago, 2026
        </p>
        <p class="font-thinner text-xs">tcjr</p>
      </aside>
    </footer>
  </template>
}
