import { db } from '../../../db/index';
import { visits, users } from '../../../db/schema';
import { and, eq } from 'drizzle-orm';
import type { Context, Config } from '@netlify/functions';
import { getUser } from '@netlify/identity';

export const config: Config = {
  path: ['/api/visits', '/api/visits/:id'],
};

interface VisitPayload {
  data?: {
    attributes?: {
      libraryId?: string;
    };
  };
}

export default async (req: Request, context: Context) => {
  const netlifyUser = await getUser();

  console.log('in visits function, netlifyUser is', netlifyUser);

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

  // Get the internal user record
  const [userRecord] = await db
    .select()
    .from(users)
    .where(eq(users.netlifyId, netlifyUser.id))
    .limit(1);

  console.log('in visits function, userRecord is', userRecord);

  if (!userRecord) {
    console.log(
      'in visits function, there is no user record for this netlifyUser, so returning 404',
    );
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

  console.log(
    'in visits function, we passed all the pre-checks, now on to the actual query',
  );

  const userId = userRecord.id;

  if (req.method === 'GET') {
    const userVisits = await db
      .select()
      .from(visits)
      .where(eq(visits.userId, userId));

    return new Response(
      JSON.stringify({
        data: userVisits.map((v) => ({
          type: 'visit',
          id: String(v.id),
          attributes: {
            visitedAt: v.visitedAt,
          },
          relationships: {
            library: {
              links: {
                related: `/api/libraries/${v.libraryId}`,
              },
              data: {
                type: 'library',
                id: String(v.libraryId),
              },
            },
          },
        })),
        included: userVisits.map((v) => ({
          type: 'library',
          id: String(v.libraryId),
          // NOTE: we could add attributes here, but we don't need to since
          // we only care about the ids. This causes a warning in the console.
        })),
      }),
      {
        headers: { 'Content-Type': 'application/vnd.api+json' },
      },
    );
  }

  if (req.method === 'POST') {
    // The JSONAPI format is in flux, so wait to implment this
    return new Response(
      JSON.stringify({
        errors: [
          {
            status: '400',
            title: 'Not Implemented',
            detail: 'POST is not implemented yet',
          },
        ],
      }),
    );
  }

  if (req.method === 'DELETE') {
    const visitId = context.params.id;

    if (!visitId) {
      return new Response(
        JSON.stringify({
          errors: [
            {
              status: '400',
              title: 'Bad Request',
              detail: 'Missing visit ID in URL',
            },
          ],
        }),
        {
          status: 400,
          headers: { 'Content-Type': 'application/vnd.api+json' },
        },
      );
    }

    await db
      .delete(visits)
      .where(
        and(eq(visits.userId, userId), eq(visits.id, parseInt(visitId, 10))),
      );

    return new Response(null, { status: 204 });
  }

  return new Response('Method not allowed', { status: 405 });
};
