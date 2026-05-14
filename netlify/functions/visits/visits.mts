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
            libraryId: v.libraryId,
            visitedAt: v.visitedAt,
          },
        })),
      }),
      {
        headers: { 'Content-Type': 'application/vnd.api+json' },
      },
    );
  }

  if (req.method === 'POST') {
    let payload: VisitPayload | undefined;
    try {
      payload = (await req.json()) as VisitPayload;
    } catch {
      return new Response(
        JSON.stringify({
          errors: [
            {
              status: '400',
              title: 'Bad Request',
              detail: 'Invalid JSON payload',
            },
          ],
        }),
        {
          status: 400,
          headers: { 'Content-Type': 'application/vnd.api+json' },
        },
      );
    }

    const libraryId = payload?.data?.attributes?.libraryId;

    if (!libraryId) {
      return new Response(
        JSON.stringify({
          errors: [
            {
              status: '400',
              title: 'Bad Request',
              detail: 'Missing libraryId in attributes',
            },
          ],
        }),
        {
          status: 400,
          headers: { 'Content-Type': 'application/vnd.api+json' },
        },
      );
    }

    try {
      // Upsert pattern using onConflictDoNothing + fetch
      let [visit] = await db
        .insert(visits)
        .values({
          userId,
          libraryId: parseInt(libraryId, 10),
        })
        .onConflictDoNothing()
        .returning();

      if (!visit) {
        [visit] = await db
          .select()
          .from(visits)
          .where(
            and(
              eq(visits.userId, userId),
              eq(visits.libraryId, parseInt(libraryId, 10)),
            ),
          )
          .limit(1);
      }

      if (!visit) {
        throw new Error('Failed to retrieve or create visit');
      }

      return new Response(
        JSON.stringify({
          data: {
            type: 'visit',
            id: String(visit.id),
            attributes: {
              libraryId: visit.libraryId,
              visitedAt: visit.visitedAt,
            },
          },
        }),
        {
          status: 201,
          headers: { 'Content-Type': 'application/vnd.api+json' },
        },
      );
    } catch (error) {
      console.error('[visits] Error recording visit:', error);
      return new Response(
        JSON.stringify({
          errors: [
            {
              status: '500',
              title: 'Internal Server Error',
              detail: 'Failed to record visit',
            },
          ],
        }),
        {
          status: 500,
          headers: { 'Content-Type': 'application/vnd.api+json' },
        },
      );
    }
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
