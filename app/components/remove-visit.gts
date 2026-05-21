import type { Library, Visit } from '#app/data/models.ts';
import { asMonthDayYear } from '#app/utils/dates.ts';
// import { service } from '@ember/service';
import Component from '@glimmer/component';
import ConfirmButton from './confirm-button.gts';

export interface RemoveVisitSignature {
  Args: {
    visit: Visit;
    library: Library;
    onRemove?: () => void;
  };
}

export default class RemoveVisit extends Component<RemoveVisitSignature> {
  deleteVisit = async () => {
    try {
      const response = await fetch(`/api/visits/${this.args.visit.id}`, {
        method: 'DELETE',
      });

      if (response.ok) {
        this.args.onRemove?.();
      } else {
        console.error('Failed to remove visit:', response.statusText);
      }
    } catch (e) {
      console.error(e);
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
