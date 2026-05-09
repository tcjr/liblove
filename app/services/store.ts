import { LibrarySchema } from '#app/data/library';
import { MetroLibraryMapSchema } from '#app/data/metro-library-map';
import { useLegacyStore } from '@warp-drive/legacy';
import { JSONAPICache } from '@warp-drive/json-api';

const Store = useLegacyStore({
  linksMode: true,
  cache: JSONAPICache,
  handlers: [],
  schemas: [LibrarySchema, MetroLibraryMapSchema],
});

type Store = InstanceType<typeof Store>;

export default Store;
