import Component from '@glimmer/component';
import { pageTitle } from 'ember-page-title';

export default class About extends Component {
  <template>
    {{pageTitle "About"}}
    <div class="p-6 space-y-6">
      <h1 class="font-bold text-3xl">About Lib Love</h1>
      <p class="text-lg">
        Lib Love is an application for exploring Chicago Public Library
        locations and tracking your visits.
      </p>

      <p>
        Your library visits are saved directly to your browser's
        <strong>Local Storage</strong>. No registration or login is required.
      </p>
    </div>
  </template>
}
