import { withResponseType } from '@warp-drive/core/request';
import type { Library } from '#app/data/library';
import type { CityLibraryMap } from '#app/data/city-library-map';
import type { ReactiveDataDocument } from '@warp-drive/core/reactive';

/** Builds a request to fetch all libraries. */
export function getLibraries() {
  return withResponseType<ReactiveDataDocument<Library[]>>({
    url: `/api/libraries`,
    method: 'GET',
  });
}

export function getCityLibraryMap(cityId: string) {
  return withResponseType<ReactiveDataDocument<CityLibraryMap>>({
    url: `/api/maps/${cityId}`,
    method: 'GET',
  });
}
