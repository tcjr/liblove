import Component from '@glimmer/component';
import type { Library } from '#app/data/library.ts';
import type { Visit } from '#app/data/visit.ts';
import { service } from '@ember/service';
import type Store from '#app/services/store.ts';
import { on } from '@ember/modifier';
import { createRecord } from '@warp-drive/utilities/json-api';
import { createVisit, differentCreateVisit } from '#app/data/api.ts';

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
    // console.log('calling store.createRecord...');
    // const visit = this.store.createRecord<Visit>('visit', {
    //   visitedAt: new Date(),
    // });
    // console.log('visit', visit);
    // console.log('calling createRecord...');
    // const newVisitRequest = createRecord(visit);
    // console.log('newVisitRequest', newVisitRequest);

    console.log('calling createVisit to get the builder...');
    //const b = createVisit(this.args.library, new Date());
    const b = differentCreateVisit(this.args.library, new Date());
    // const b = createVisit({
    //   library: this.args.library,
    //   visitedAt: new Date(),
    // });
    console.log('b', b);

    console.log('calling store.request...');
    const req = this.store.request(b);
    console.log('req', req);
    const awaitedReq = await req;
    console.log('awaitedReq', awaitedReq);

    // console.log('creating record...');
    // const rec = this.store.createRecord<Visit>('visit', {
    //   visitedAt: new Date(),
    // });
    // console.log('rec', rec);

    // const newVisitData = {
    //   type: 'visit',
    //   attributes: {
    //     visitedAt: new Date(),
    //   },
    //   relationships: {
    //     library: {
    //       data: {
    //         type: 'library',
    //         id: this.args.library.id,
    //       },
    //     },
    //   },
    // };
    // console.log('newVisitData', newVisitData);

    // const headers = new Headers();
    // headers.append('Content-Type', 'application/vnd.api+json');

    // console.log('calling store.request...');
    // const req = this.store.request({
    //   method: 'POST',
    //   url: '/api/visits',
    //   data: newVisitData,
    //   headers,
    // });

    // console.log('req', req);
    // const awaitedReq = await req;
    // console.log('awaitedReq', awaitedReq);
  };

  <template>
    <button {{on "click" this.makeVisit}} class="btn">
      Click here to make new Visit for this library
    </button>
  </template>
}
