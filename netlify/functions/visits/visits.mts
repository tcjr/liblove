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

function errorResponse(title: string, detail: string, status: number) {
  return new Response(
    JSON.stringify({
      errors: [
        {
          status: String(status),
          title,
          detail,
        },
      ],
    }),
    {
      status,
      headers: { 'Content-Type': 'application/vnd.api+json' },
    },
  );
}

export default async (req: Request, context: Context) => {
  const netlifyUser = await originalGetUser();

  if (!netlifyUser) {
    return new Response(
      JSON.stringify({
        errors: [
          {
            status: '401',
            title: 'Unauthorized',
            detail: 'Authentication required',
          },
        ],
      }),
      {
        status: 401,
        headers: { 'Content-Type': 'application/vnd.api+json' },
      },
    );
  }

  // Get the internal user data (blob?). For now, just use the netlify id.
  const userRecord = { id: netlifyUser.id };

  if (!userRecord) {
    return new Response(
      JSON.stringify({
        errors: [
          {
            status: '404',
            title: 'User Not Found',
            detail: 'User record not found in database',
          },
        ],
      }),
      {
        status: 404,
        headers: { 'Content-Type': 'application/vnd.api+json' },
      },
    );
  }
  // console.log('....  we passed all the pre-checks, now on to the actual query');

  const userId = userRecord.id;

  const store = getStore('library-visits');

  // ===============
  // GET
  // ===============

  if (req.method === 'GET') {
    const rawVisits =
      ((await store.get(userId, {
        type: 'json',
      })) as RawVisitRecord[]) || [];

    // Ensure all visits returned have an ID (fallback to libraryId for legacy data)
    const userVisits: VisitRecord[] = rawVisits.map((v) => ({
      id: v.id || v.libraryId || '',
      libraryId: v.libraryId || '',
      visitedAt: v.visitedAt || '',
    }));

    console.log(`STORE:`, store);
    console.log(`STORE list:`, await store.list());
    console.log(`LOADED userVisits for user '${userId}':`, userVisits);

    return new Response(JSON.stringify(userVisits), {
      headers: { 'Content-Type': 'application/vnd.api+json' },
    });
  }

  // ===============
  // POST
  // ===============

  if (req.method === 'POST') {
    const parsed = (await req.json()) as {
      libraryId: string;
      visitedAt: string;
    };

    const libraryId = parsed['libraryId'];
    const visitedAt = parsed['visitedAt'];

    if (!libraryId || !visitedAt) {
      return errorResponse('Bad Request', 'Missing required fields', 400);
    }

    // get visits, map/normalize legacy data, check for duplicates and append/overwrite
    const rawVisits =
      ((await store.get(userId, { type: 'json' })) as RawVisitRecord[]) || [];
    const visits: VisitRecord[] = rawVisits.map((v) => ({
      id: v.id || v.libraryId || '',
      libraryId: v.libraryId || '',
      visitedAt: v.visitedAt || '',
    }));

    const existingIndex = visits.findIndex((v) => v.libraryId === libraryId);
    const newVisit: VisitRecord = {
      id: crypto.randomUUID(),
      libraryId,
      visitedAt,
    };

    if (existingIndex > -1) {
      visits[existingIndex] = newVisit; // overwrite / update duplicate
    } else {
      visits.push(newVisit);
    }

    console.log(
      `setting visits for user '${userId}' to '${JSON.stringify(visits)}'`,
    );
    await store.set(userId, JSON.stringify(visits));

    return new Response(JSON.stringify({ message: 'saved', visit: newVisit }), {
      status: 201,
      headers: { 'Content-Type': 'application/vnd.api+json' },
    });
  }

  // ===============
  // DELETE
  // ===============

  if (req.method === 'DELETE') {
    const visitId = context.params.id;

    if (!visitId) {
      return errorResponse('Bad Request', 'Missing visit ID in URL', 400);
    }

    const rawVisits =
      ((await store.get(userId, { type: 'json' })) as RawVisitRecord[]) || [];
    const visits: VisitRecord[] = rawVisits.map((v) => ({
      id: v.id || v.libraryId || '',
      libraryId: v.libraryId || '',
      visitedAt: v.visitedAt || '',
    }));

    const updatedVisits = visits.filter((v) => v.id !== visitId);

    console.log(
      `setting visits for user '${userId}' after delete to '${JSON.stringify(updatedVisits)}'`,
    );
    await store.set(userId, JSON.stringify(updatedVisits));

    return new Response(JSON.stringify({ message: 'removed' }), {
      status: 200,
      headers: { 'Content-Type': 'application/vnd.api+json' },
    });
  }

  return new Response('Method not allowed', { status: 405 });
};
