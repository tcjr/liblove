import { deleteVisit as apiDeleteVisit } from '#app/data/api.ts';
import type { Visit } from '#app/data/visit.ts';
import type Store from '#app/services/store.ts';
import { asMonthDayYear } from '#app/utils/dates.ts';
import { service } from '@ember/service';
import Component from '@glimmer/component';
import ConfirmButton from './confirm-button.gts';

export interface RemoveVisitSignature {
  Args: {
    visit: Visit;
  };
  Element: null;
}

export default class RemoveVisit extends Component<RemoveVisitSignature> {
  @service declare store: Store;

  deleteVisit = async () => {
    console.log('calling deleteVisit to get the builder...');
    const b = apiDeleteVisit(this.args.visit);
    console.log('b', b);
    console.log('calling store.request...');
    const req = this.store.request(b);
    console.log('req', req);
    const awaitedReq = await req;
    console.log('awaitedReq', awaitedReq);

    // Once the API call has completed, we can update the store
    console.log('calling store.unloadRecord...');
    this.store.unloadRecord(this.args.visit);
  };

  <template>
    {{!-- <button {{on "click" this.deleteVisit}} class="btn">
      Click here to remove the Visit for this library
    </button> --}}

    <ConfirmButton
      @title="Delete Visit"
      @confirmText="Yes, remove visit"
      @buttonText="Remove Library Visit"
      @onConfirm={{this.deleteVisit}}
      class="btn btn-warning"
    >
      <div class="space-y-3">
        <p>
          This will remove the visit to
          <strong>{{@visit.library.name}}</strong>
          on
          <strong>{{asMonthDayYear @visit.visitedAt}}</strong>.
        </p>
        <p>Are you sure?</p>
      </div>
    </ConfirmButton>
  </template>
}
