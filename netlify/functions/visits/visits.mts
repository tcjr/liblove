import type { Context, Config } from '@netlify/functions';
import { getUser as originalGetUser } from '@netlify/identity';

export const config: Config = {
  path: ['/api/visits', '/api/visits/:id'],
};

interface VisitPayload {
  libraryId: string;
  visitedAt: string;
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

  // ===============
  // GET
  // ===============

  if (req.method === 'GET') {
    // Look up the REAL visits
    const userVisits: VisitPayload[] = [
      {
        libraryId: 'altgeld',
        visitedAt: '2026-02-01',
      },
      {
        libraryId: 'harold-washington',
        visitedAt: '2026-03-04',
      },
    ];

    return new Response(JSON.stringify(userVisits), {
      headers: { 'Content-Type': 'application/vnd.api+json' },
    });
  }

  if (req.method === 'POST') {
    const parsed = (await req.json()) as VisitPayload;

    // TODO: validate both of these
    const libraryId = parsed['libraryId'];
    const visitedAt = parsed['visitedAt'];

    if (!libraryId || !visitedAt) {
      return errorResponse('Bad Request', 'Missing required fields', 400);
    }

    // TODO: save the visit

    return new Response(JSON.stringify({ message: 'saved (not really)' }), {
      status: 201,
      headers: { 'Content-Type': 'application/vnd.api+json' },
    });
  }

  if (req.method === 'DELETE') {
    const visitId = context.params.id;

    if (!visitId) {
      return errorResponse('Bad Request', 'Missing visit ID in URL', 400);
    }

    // TODO: delete the visit

    return new Response(JSON.stringify({ message: 'removed (not really)' }), {
      status: 200,
      headers: { 'Content-Type': 'application/vnd.api+json' },
    });
  }

  return new Response('Method not allowed', { status: 405 });
};
