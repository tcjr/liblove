import { db } from '../../db/index';
import { users } from '../../db/schema';
import type { Handler, HandlerEvent, HandlerContext } from '@netlify/functions';

const handler: Handler = async (
  event: HandlerEvent,
  _context: HandlerContext,
) => {
  const { user } = JSON.parse(event.body || '{}');

  if (!user || !user.id || !user.email) {
    return { statusCode: 400, body: 'Invalid identity user data' };
  }

  try {
    await db
      .insert(users)
      .values({
        netlifyId: user.id,
        email: user.email,
      })
      .onConflictDoNothing();

    return {
      statusCode: 200,
      body: JSON.stringify({
        app_metadata: {
          ...user.app_metadata,
          roles: user.app_metadata?.roles || ['member'],
        },
      }),
    };
  } catch (error) {
    console.error('Error syncing user to database:', error);
    return { statusCode: 500, body: 'Internal Server Error' };
  }
};

export { handler };
