import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import type { Library } from '#app/data/models.ts';
import ConfirmButton from './confirm-button.gts';
import { service } from '@ember/service';
import type VisitsService from '#app/services/visits.ts';

function getTodayString() {
  const today = new Date();
  const yyyy = today.getFullYear();
  const mm = String(today.getMonth() + 1).padStart(2, '0');
  const dd = String(today.getDate()).padStart(2, '0');
  return `${yyyy}-${mm}-${dd}`;
}

export interface MakeNewVisitSignature {
  Args: {
    library: Library;
    onSave?: () => void;
  };
}

export default class MakeNewVisit extends Component<MakeNewVisitSignature> {
  @service declare visits: VisitsService;
  @tracked selectedDateStr = getTodayString();

  updateDate = (event: Event) => {
    const target = event.target as HTMLInputElement;
    this.selectedDateStr = target.value;
  };

  makeVisit = () => {
    const dateToUse = this.selectedDateStr
      ? new Date(`${this.selectedDateStr}T12:00:00`)
      : new Date();

    try {
      this.visits.addVisit(this.args.library.id, dateToUse);
      this.args.onSave?.();
    } catch (e) {
      console.error('Failed to add visit:', e);
    }
  };

  <template>
    <ConfirmButton
      @title="New Visit"
      @confirmText="Yes, add visit"
      @buttonText="Add Library Visit"
      @onConfirm={{this.makeVisit}}
      class="btn btn-warning"
    >
      <div class="space-y-3">
        <p>
          This will add a visit to
          <strong>{{@library.name}}</strong>.
        </p>
        <div class="form-control w-full max-w-xs">
          <label class="label" for="visit-date-picker">
            <span class="label-text">Date of visit</span>
          </label>
          <input
            id="visit-date-picker"
            type="date"
            class="input input-bordered w-full max-w-xs"
            value={{this.selectedDateStr}}
            {{on "change" this.updateDate}}
          />
        </div>
        <p>Are you sure?</p>
      </div>
    </ConfirmButton>
  </template>
}
