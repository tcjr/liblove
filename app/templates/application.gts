import { pageTitle } from 'ember-page-title';
import Component from '@glimmer/component';

export default class ApplicationComponent extends Component {
  <template>
    {{pageTitle "Lib Love"}}

    {{outlet}}
  </template>
}
