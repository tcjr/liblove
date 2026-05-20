import type { Visit } from '#app/data/models.ts';
import { asMonthDayYear } from '#app/utils/dates.ts';
// import { service } from '@ember/service';
import Component from '@glimmer/component';
import ConfirmButton from './confirm-button.gts';

export interface RemoveVisitSignature {
  Args: {
    visit: Visit;
  };
  Element: null;
}

export default class RemoveVisit extends Component<RemoveVisitSignature> {
  deleteVisit = async () => {
    // TODO: actually delete visit...
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
