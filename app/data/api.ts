import { withResponseType } from '@warp-drive/core/request';
import type { Library } from '#app/data/library';
import type { MetroLibraryMap } from '#app/data/metro-library-map';
import type { Visit } from '#app/data/visit';
import type { ReactiveDataDocument } from '@warp-drive/core/reactive';

/** Builds a request to fetch all libraries. */
export function getLibraries(metroId: string) {
  return withResponseType<ReactiveDataDocument<Library[]>>({
    url: `/api/libraries/${metroId}`,
    method: 'GET',
  });
}

export function getMetroLibraryMap(metroId: string) {
  return withResponseType<ReactiveDataDocument<MetroLibraryMap>>({
    url: `/api/maps/${metroId}`,
    method: 'GET',
  });
}

/** Builds a request to fetch all the visits for the current user. */
export function getVisits() {
  return withResponseType<ReactiveDataDocument<Visit[]>>({
    url: '/api/visits',
    method: 'GET',
  });
}

/** Builds a request to create a new Visit. */
export function createVisit(library: Library, date: Date) {
  return withResponseType<ReactiveDataDocument<Visit>>({
    method: 'POST',
    url: '/api/visits',
    body: JSON.stringify({
      libraryId: library.id,
      visitedAt: date,
    }),
    op: 'createRecord',
  });
}

/** Builds a request to delete a Visit. */
export function deleteVisit(visit: Visit) {
  return withResponseType<ReactiveDataDocument<Visit>>({
    method: 'DELETE',
    url: `/api/visits/${visit.id}`,
    op: 'deleteRecord',
  });
}
