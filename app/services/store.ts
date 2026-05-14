import { LibrarySchema } from '#app/data/library';
import { MetroLibraryMapSchema } from '#app/data/metro-library-map';
import { VisitSchema } from '#app/data/visit.ts';
import { useLegacyStore } from '@warp-drive/legacy';
import { JSONAPICache } from '@warp-drive/json-api';

const Store = useLegacyStore({
  linksMode: true,
  cache: JSONAPICache,
  handlers: [],
  schemas: [LibrarySchema, MetroLibraryMapSchema, VisitSchema],
});

type Store = InstanceType<typeof Store>;

export default Store;
