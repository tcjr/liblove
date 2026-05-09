import { withResponseType } from '@warp-drive/core/request';
import type { Library } from '#app/data/library';
import type { MetroLibraryMap } from '#app/data/metro-library-map';
import type { ReactiveDataDocument } from '@warp-drive/core/reactive';

/** Builds a request to fetch all libraries. */
export function getLibraries() {
  return withResponseType<ReactiveDataDocument<Library[]>>({
    url: `/api/libraries`,
    method: 'GET',
  });
}

export function getMetroLibraryMap(metroId: string) {
  return withResponseType<ReactiveDataDocument<MetroLibraryMap>>({
    url: `/api/maps/${metroId}`,
    method: 'GET',
  });
}
