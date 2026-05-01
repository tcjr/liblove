import { getUser, admin } from '@netlify/identity';
import type { Context, Config } from '@netlify/functions';

export const config: Config = {
  path: '/api/admin-users',
};

export default async (req: Request, context: Context) => {
  console.log('INSIDE admin-users function');
  const user = await getUser();
  if (!user) {
    return new Response('Unauthorized', { status: 401 });
  }

  if (!user.roles?.includes('admin')) {
    return new Response('Forbidden', { status: 403 });
  }

  // Only admins reach this point
  const users = await admin.listUsers();
  return Response.json({ users });
};
