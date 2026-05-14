import { db } from '../../db/index';
import { users } from '../../db/schema';
import type { Handler, HandlerEvent, HandlerContext } from '@netlify/functions';

/**
 * Netlify Identity Event Function: identity-signup
 * Triggered when a user signs up via Netlify Identity.
 * Synchronizes the Netlify user ID and email to our local database.
 *
 * NOTE: Identity event functions must use the legacy named handler export.
 */
const handler: Handler = async (
  event: HandlerEvent,
  _context: HandlerContext,
) => {
  if (event.httpMethod !== 'POST') {
    return { statusCode: 405, body: 'Method Not Allowed' };
  }

  let user;
  try {
    const body = JSON.parse(event.body || '{}');
    user = body.user;
  } catch (e) {
    return { statusCode: 400, body: 'Invalid JSON' };
  }

  if (!user || !user.id || !user.email) {
    console.error('[identity-signup] Invalid payload:', event.body);
    return { statusCode: 400, body: 'Invalid payload' };
  }

  console.log(`[identity-signup] Syncing new user to database: ${user.email}`);

  try {
    await db
      .insert(users)
      .values({
        netlifyId: user.id,
        email: user.email,
      })
      .onConflictDoNothing();

    console.log(`[identity-signup] Successfully synced user: ${user.id}`);

    return {
      statusCode: 200,
      body: JSON.stringify({}), // Return empty object to signal success with no metadata changes
    };
  } catch (error) {
    console.error(`[identity-signup] Error syncing user:`, error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Failed to sync user to database' }),
    };
  }
};

export { handler };
