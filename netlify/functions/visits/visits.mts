import type { Context, Config } from '@netlify/functions';
import { getUser as originalGetUser } from '@netlify/identity';
import { getStore } from '@netlify/blobs';

export const config: Config = {
  path: ['/api/visits', '/api/visits/:id'],
};

interface VisitRecord {
  id: string;
  libraryId: string;
  visitedAt: string;
}

interface RawVisitRecord {
  id?: string;
  libraryId?: string;
  visitedAt?: string;
}

/**
 * Standard helper to build JSON:API-compliant HTTP responses.
 */
function jsonResponse(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/vnd.api+json' },
  });
}

/**
 * Helper to build JSON:API-formatted error responses.
 */
function errorResponse(title: string, detail: string, status: number) {
  return jsonResponse(
    {
      errors: [
        {
          status: String(status),
          title,
          detail,
        },
      ],
    },
    status,
  );
}

/**
 * Safely parses the request body as JSON, returning null if malformed or empty.
 */
async function safeParseJson<T>(req: Request): Promise<T | null> {
  try {
    return (await req.json()) as T;
  } catch {
    return null;
  }
}

export default async (req: Request, context: Context) => {
  try {
    // Authenticate the user session using Netlify Identity.
    const netlifyUser = await originalGetUser();

    // If no valid session is found, return a 401 Unauthorized response in JSON:API format.
    if (!netlifyUser) {
      return errorResponse('Unauthorized', 'Authentication required', 401);
    }

    // Currently using the Netlify Identity ID directly.
    const userId = netlifyUser.id;

    const store = getStore('library-visits');

    // ===============
    // GET: Fetch all visits for the authenticated user
    // ===============

    if (req.method === 'GET') {
      // Retrieve the user's visits list from the Netlify Blobs 'library-visits' store.
      const rawVisits =
        ((await store.get(userId, {
          type: 'json',
        })) as RawVisitRecord[]) || [];

      // Map raw blob data to the standard VisitRecord structure, supplying fallbacks for missing fields.
      const userVisits: VisitRecord[] = rawVisits.map((v) => ({
        id: v.id || v.libraryId || '',
        libraryId: v.libraryId || '',
        visitedAt: v.visitedAt || '',
      }));

      // Return the visits array.
      return jsonResponse(userVisits);
    }

    // ===============
    // POST: Record or update a library visit
    // ===============

    if (req.method === 'POST') {
      // Parse request body for library details and visit timestamp.
      const parsed = await safeParseJson<{
        libraryId: string;
        visitedAt: string;
      }>(req);

      if (!parsed) {
        return errorResponse(
          'Bad Request',
          'Malformed or empty JSON payload',
          400,
        );
      }

      const libraryId = parsed['libraryId'];
      const visitedAt = parsed['visitedAt'];

      // Ensure all required fields are present in the request payload.
      if (!libraryId || !visitedAt) {
        return errorResponse('Bad Request', 'Missing required fields', 400);
      }

      // Load existing visits from Blobs.
      const rawVisits =
        ((await store.get(userId, { type: 'json' })) as RawVisitRecord[]) || [];
      const visits: VisitRecord[] = rawVisits.map((v) => ({
        id: v.id || v.libraryId || '',
        libraryId: v.libraryId || '',
        visitedAt: v.visitedAt || '',
      }));

      // Check if the user has already recorded a visit for this library.
      const existingIndex = visits.findIndex((v) => v.libraryId === libraryId);
      const newVisit: VisitRecord = {
        id: crypto.randomUUID(),
        libraryId,
        visitedAt,
      };

      if (existingIndex > -1) {
        // Overwrite/update the existing visit for this library (only one record per library).
        visits[existingIndex] = newVisit;
      } else {
        // Append the new visit.
        visits.push(newVisit);
      }

      console.log(
        `setting visits for user '${userId}' to '${JSON.stringify(visits)}'`,
      );
      // Persist the updated visits array back to Blobs.
      await store.set(userId, JSON.stringify(visits));

      return jsonResponse({ message: 'saved', visit: newVisit }, 201);
    }

    // ===============
    // DELETE: Remove a specific library visit by its ID
    // ===============

    if (req.method === 'DELETE') {
      // Extract the specific visit ID from the route parameter context.id.
      const visitId = context.params.id;

      if (!visitId) {
        return errorResponse('Bad Request', 'Missing visit ID in URL', 400);
      }

      // Retrieve existing visits list.
      const rawVisits =
        ((await store.get(userId, { type: 'json' })) as RawVisitRecord[]) || [];
      const visits: VisitRecord[] = rawVisits.map((v) => ({
        id: v.id || v.libraryId || '',
        libraryId: v.libraryId || '',
        visitedAt: v.visitedAt || '',
      }));

      // Filter out the visit record matching the provided ID.
      const updatedVisits = visits.filter((v) => v.id !== visitId);

      console.log(
        `setting visits for user '${userId}' after delete to '${JSON.stringify(updatedVisits)}'`,
      );
      // Save the filtered list back to Blobs.
      await store.set(userId, JSON.stringify(updatedVisits));

      return jsonResponse({ message: 'removed' });
    }

    return errorResponse(
      'Method Not Allowed',
      `Method ${req.method} is not supported`,
      405,
    );
  } catch (error) {
    console.error('Unhandled exception in visits function:', error);
    return errorResponse(
      'Internal Server Error',
      error instanceof Error ? error.message : 'An unexpected error occurred',
      500,
    );
  }
};
