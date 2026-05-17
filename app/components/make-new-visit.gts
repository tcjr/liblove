import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import type { Library } from '#app/data/library.ts';
import { service } from '@ember/service';
import type Store from '#app/services/store.ts';
import { createVisit } from '#app/data/api.ts';
import ConfirmButton from './confirm-button.gts';

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
  };
  Blocks: {
    default: [];
  };
  Element: null;
}

export default class MakeNewVisit extends Component<MakeNewVisitSignature> {
  @service declare store: Store;

  @tracked selectedDateStr = getTodayString();

  updateDate = (event: Event) => {
    const target = event.target as HTMLInputElement;
    this.selectedDateStr = target.value;
  };

  makeVisit = async () => {
    console.log('calling createVisit to get the builder...');
    const dateToUse = new Date(`${this.selectedDateStr}T12:00:00`);
    const b = createVisit(this.args.library, dateToUse);
    console.log('b', b);

    console.log('calling store.request...');
    const req = this.store.request(b);
    console.log('req', req);
    const awaitedReq = await req;
    console.log('awaitedReq', awaitedReq);
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
