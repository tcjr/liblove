import Component from '@glimmer/component';
import { pageTitle } from 'ember-page-title';
import Star from '#app/images/flag-star.svg';

export default class About extends Component {
  <template>
    {{pageTitle "About"}}
    <div class="h-6 bg-(--chicago-blue)">
    </div>
    <div class="p-0 flex flex-row justify-between items-center">
      <div>
        <Star class="inline-block w-16 mx-2 fill-(--chicago-red)" />
        <Star class="inline-block w-16 mx-2 fill-(--chicago-red)" />
      </div>
      <div class="text-(--chicago-red) text-[56px] font-logo">
        Exploring Chicago
        {{! Farmer's Markets }}
        {{! Libraries }}
      </div>
      <div>
        <Star class="inline-block w-16 mx-2 fill-(--chicago-red)" />
        <Star class="inline-block w-16 mx-2 fill-(--chicago-red)" />
      </div>
    </div>
    <div class="h-14 bg-(--chicago-blue)">
    </div>

    <div class="p-6 space-y-6">
      <h1 class="font-bold text-3xl">About</h1>
      <p class="text-lg">
        This is an application for exploring Chicago's public spaces.
      </p>

      <p>
        Your library visits are saved directly to your browser's
        <strong>Local Storage</strong>. No registration or login is required.
      </p>
    </div>
  </template>
}
