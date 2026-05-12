import type { Context } from '@netlify/functions';

// This should get called whenever a user logs in.

export default async (req: Request, context: Context) => {
  const { event, user } = await req.json();

  console.log('SERVER SIDE IDENTITY EVENT (login)', event);
  console.log('user', JSON.stringify(user, null, 2));

  if (user.email === 'fakeuser@tcjr.org') {
    console.log('DISALLOWING LOGIN FOR FAKE USER, returning a 403');
    return new Response(
      'This fake user is not allowed to log in. Sorry, pal.',
      { status: 403 },
    );
  }

  console.log('ALLOWING LOGIN FOR USER, returning JSON with a 200');
  return Response.json({});
};
