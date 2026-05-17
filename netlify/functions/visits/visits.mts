import { db } from '../../../db/index';
import { visits, users } from '../../../db/schema';
import { and, eq } from 'drizzle-orm';
import type { Context, Config } from '@netlify/functions';
import { getUser as originalGetUser } from '@netlify/identity';

export const config: Config = {
  path: ['/api/visits', '/api/visits/:id'],
};

interface VisitPayload {
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

  console.log('in visits function, netlifyUser is', netlifyUser);

  if (!netlifyUser) {
    console.log('.... returning 401 since there is no netlifyUser');
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

  console.log('....  userRecord is', userRecord);

  if (!userRecord) {
    console.log(
      '....  there is no user record for this netlifyUser, so returning 404',
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

  console.log('....  we passed all the pre-checks, now on to the actual query');

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
          attributes: {},
        })),
      }),
      {
        headers: { 'Content-Type': 'application/vnd.api+json' },
      },
    );
  }

  if (req.method === 'POST') {
    // console.log('.... req:', req);
    console.log('.... this is a POST request; req.body:', req.body);

    const parsed = (await req.json()) as VisitPayload;
    console.log('.... parsed:', parsed);

    // TODO: validate both of these
    const libraryId = parsed['libraryId'];
    const visitedAt = parsed['visitedAt'];
    console.log('.... libraryId:', libraryId);
    console.log('.... visitedAt:', visitedAt);

    if (!libraryId || !visitedAt) {
      return errorResponse('Bad Request', 'Missing required fields', 400);
    }

    type Visit = typeof visits.$inferSelect;

    try {
      const newVisits = await db
        .insert(visits)
        .values({
          userId,
          libraryId: parseInt(libraryId, 10),
          visitedAt: new Date(visitedAt),
        })
        .onConflictDoNothing()
        .returning();

      const newVisit = newVisits[0] as Visit;

      console.log('.... newVisit is', newVisit);

      // return errorResponse('Almost home', 'not yet', 500);

      return new Response(
        JSON.stringify({
          data: {
            type: 'visit',
            id: String(newVisit.id),
            attributes: {
              visitedAt: newVisit.visitedAt,
            },
            relationships: {
              library: {
                links: {
                  related: `/api/libraries/${newVisit.libraryId}`,
                },
                data: {
                  type: 'library',
                  id: String(newVisit.libraryId),
                },
              },
            },
          },
          included: [{ type: 'library', id: String(newVisit.libraryId) }],
        }),
        {
          status: 201,
          headers: { 'Content-Type': 'application/vnd.api+json' },
        },
      );
    } catch (error) {
      console.error(error);
      return errorResponse('Failed to record visit', 'insert failed', 500);
    }
  }

  if (req.method === 'DELETE') {
    const visitId = context.params.id;

    if (!visitId) {
      return errorResponse('Bad Request', 'Missing visit ID in URL', 400);
    }

    try {
      console.log('.... making db call, visitId is', visitId);
      await db
        .delete(visits)
        .where(
          and(eq(visits.userId, userId), eq(visits.id, parseInt(visitId, 10))),
        );

      console.log('.... returning 204');
      return new Response(
        // The payload seems to be required so it is properly deleted from the client-side cache
        JSON.stringify({
          data: null,
        }),
        {
          status: 200,
          headers: { 'Content-Type': 'application/vnd.api+json' },
        },
      );
    } catch (error) {
      console.error(error);
      return errorResponse('Failed to delete visit', 'delete failed', 500);
    }
  }

  return new Response('Method not allowed', { status: 405 });
};
