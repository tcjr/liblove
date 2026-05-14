import { db } from '../../db/index';
import { users } from '../../db/schema';
import type { Context } from '@netlify/functions';

export default async (req: Request, context: Context) => {
  const body = await req.json();
  const { user } = body;
  
  if (!user || !user.id || !user.email) {
    return new Response('Invalid payload', { status: 400 });
  }

  console.log(`[identity-signup] Syncing new user to database: ${user.email}`);

  try {
    await db.insert(users).values({
      netlifyId: user.id,
      email: user.email,
    });

    console.log(`[identity-signup] Successfully synced user: ${user.id}`);

    return new Response(JSON.stringify({ message: "User synced successfully" }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });

  } catch (error) {
    console.error(`[identity-signup] Error syncing user:`, error);
    return new Response(JSON.stringify({ error: "Failed to sync user to database" }), { 
      status: 500 
    });
  }
};
