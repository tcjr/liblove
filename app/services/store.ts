import { LibrarySchema } from '#app/data/library';
import { CityLibraryMapSchema } from '#app/data/city-library-map';
import { useLegacyStore } from '@warp-drive/legacy';
import { JSONAPICache } from '@warp-drive/json-api';

const Store = useLegacyStore({
  linksMode: true,
  cache: JSONAPICache,
  handlers: [],
  schemas: [LibrarySchema, CityLibraryMapSchema],
});

type Store = InstanceType<typeof Store>;

export default Store;
