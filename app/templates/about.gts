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

      <div class="card bg-base-200 shadow-xl max-w-xl">
        <div class="card-body">
          <h2 class="card-title text-warning">Visit Data & Privacy</h2>
          <p>
            Your library visits are saved directly to your browser's
            <strong>Local Storage</strong>. No registration or login is
            required, ensuring your history is private and kept entirely on your
            device.
          </p>
          <div class="alert alert-info mt-4">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              class="stroke-current shrink-0 w-6 h-6"
            ><path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
              ></path></svg>
            <span>
              Since your data is stored locally, it will not sync across other
              browsers or devices. Clearing your browser's site data or cache
              will reset your visit history.
            </span>
          </div>
        </div>
      </div>
    </div>
  </template>
}
