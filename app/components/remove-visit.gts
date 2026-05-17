import { deleteVisit as apiDeleteVisit } from '#app/data/api.ts';
import type { Visit } from '#app/data/visit.ts';
import type Store from '#app/services/store.ts';
import { on } from '@ember/modifier';
import { service } from '@ember/service';
import Component from '@glimmer/component';

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

    // Once the API has completed, we can update the store
    console.log('calling store.unloadRecord...');
    this.store.unloadRecord(this.args.visit);
    // console.log('calling store.deleteRecord...');
    // this.store.deleteRecord(this.args.visit);
  };

  <template>
    <button {{on "click" this.deleteVisit}} class="btn">
      Click here to remove the Visit for this library
    </button>
  </template>
}
