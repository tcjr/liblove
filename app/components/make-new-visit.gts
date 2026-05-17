import Component from '@glimmer/component';
import type { Library } from '#app/data/library.ts';
import { service } from '@ember/service';
import type Store from '#app/services/store.ts';
import { createVisit } from '#app/data/api.ts';
import ConfirmButton from './confirm-button.gts';

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

  makeVisit = async () => {
    console.log('calling createVisit to get the builder...');
    // TODO: add a date picker and use that date here
    const b = createVisit(this.args.library, new Date());
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
          {{! TODO: add a date picker to choose a date }}
        </p>
        <p>Are you sure?</p>
      </div>
    </ConfirmButton>
  </template>
}
