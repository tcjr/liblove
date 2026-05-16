import {
  withReactiveResponse,
  withResponseType,
} from '@warp-drive/core/request';
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
// export function createVisit(library: Library, visitedAt: Date) {
//   return withResponseType<ReactiveDataDocument<Visit>>({
//     url: '/api/visits',
//     method: 'POST',
//     data: {
//       type: 'visit',
//       attributes: {
//         library,
//         visitedAt,
//         SOMETHING_HERE: 'HELP ME PLEASE',
//       },
//     },
//   });
// }

// export function createVisit(attributes) {
//   return withReactiveResponse<Visit>({
//     method: 'POST',
//     url: '/api/visits',
//     body: JSON.stringify({
//       data: {
//         type: 'visit',
//         attributes,
//       },
//     }),
//     op: 'createRecord',
//   });
// }

// This works, but is very complicated. I realize now that the format of the
// POST data is irrelevant to Warp Drive. I can use a much simpler format
// and work with that on the server.
// export function createVisit(library: Library, date: Date) {
//   return withReactiveResponse<Visit>({
//     method: 'POST',
//     url: '/api/visits',
//     body: JSON.stringify({
//       data: {
//         type: 'visit',
//         attributes: {
//           visitedAt: date,
//         },
//         relationships: {
//           library: {
//             data: {
//               type: 'library',
//               id: library.id,
//             },
//           },
//         },
//       },
//     }),
//     op: 'createRecord',
//   });
// }

export function createVisit(library: Library, date: Date) {
  return withReactiveResponse<Visit>({
    method: 'POST',
    url: '/api/visits',
    body: JSON.stringify({
      libraryId: library.id,
      visitedAt: date,
    }),
    op: 'createRecord',
  });
}

export function differentCreateVisit(library: Library, date: Date) {
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
