import type { Library, Visit } from '#app/data/models.ts';
import { asMonthDayYear } from '#app/utils/dates.ts';
import { service } from '@ember/service';
import Component from '@glimmer/component';
import ConfirmButton from './confirm-button.gts';
import type VisitsService from '#app/services/visits.ts';

export interface RemoveVisitSignature {
  Args: {
    visit: Visit;
    library: Library;
    onRemove?: () => void;
  };
}

export default class RemoveVisit extends Component<RemoveVisitSignature> {
  @service declare visits: VisitsService;

  deleteVisit = () => {
    try {
      this.visits.removeLibraryVisit(this.args.visit.id);
      this.args.onRemove?.();
    } catch (e) {
      console.error('Failed to remove visit:', e);
    }
  };

  <template>
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
          <strong>{{@library.name}}</strong>
          on
          <strong>{{asMonthDayYear @visit.visitedAt}}</strong>.
        </p>
        <p>Are you sure?</p>
      </div>
    </ConfirmButton>
  </template>
}
