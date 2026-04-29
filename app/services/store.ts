import { LibrarySchema } from '#app/data/library';
import { useLegacyStore } from '@warp-drive/legacy';
import { JSONAPICache } from '@warp-drive/json-api';

const Store = useLegacyStore({
  linksMode: true,
  cache: JSONAPICache,
  handlers: [],
  schemas: [LibrarySchema],
});

type Store = InstanceType<typeof Store>;

export default Store;
