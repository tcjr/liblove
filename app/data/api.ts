import { withResponseType } from '@warp-drive/core/request';
import type { Library } from '#app/data/library';
import type { ReactiveDataDocument } from '@warp-drive/core/reactive';

/** Builds a request to fetch all libraries. */
export function getLibraries() {
  return withResponseType<ReactiveDataDocument<Library[]>>({
    url: `/api/libraries`,
    method: 'GET',
  });
}
