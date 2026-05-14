import { db } from '../../../db/index';
import { visits, users } from '../../../db/schema';
import { and, eq } from 'drizzle-orm';
import type { Context, Config } from '@netlify/functions';

export const config: Config = {
  path: '/api/visits',
};

export default async (req: Request, context: Context) => {
  const netlifyUser = context.user;

  if (!netlifyUser) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  // Get the internal user record
  const userRecord = await db.query.users.findFirst({
    where: eq(users.netlifyId, netlifyUser.sub),
  });

  if (!userRecord) {
    return new Response(JSON.stringify({ error: 'User record not found' }), {
      status: 404,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  const userId = userRecord.id;

  if (req.method === 'GET') {
    const userVisits = await db.query.visits.findMany({
      where: eq(visits.userId, userId),
    });

    return new Response(JSON.stringify({ data: userVisits.map(v => v.libraryId) }), {
      headers: { 'Content-Type': 'application/json' },
    });
  }

  if (req.method === 'POST') {
    const { libraryId } = await req.json();

    if (!libraryId) {
      return new Response(JSON.stringify({ error: 'Missing libraryId' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    try {
      await db.insert(visits).values({
        userId,
        libraryId: parseInt(libraryId, 10),
      }).onConflictDoNothing();

      return new Response(JSON.stringify({ message: 'Visit recorded' }), {
        status: 201,
        headers: { 'Content-Type': 'application/json' },
      });
    } catch (error) {
      return new Response(JSON.stringify({ error: 'Failed to record visit' }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      });
    }
  }

  if (req.method === 'DELETE') {
    const { libraryId } = await req.json();

    if (!libraryId) {
      return new Response(JSON.stringify({ error: 'Missing libraryId' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    await db.delete(visits).where(
      and(
        eq(visits.userId, userId),
        eq(visits.libraryId, parseInt(libraryId, 10))
      )
    );

    return new Response(null, { status: 204 });
  }

  return new Response('Method not allowed', { status: 405 });
};
