import { neon } from '@netlify/neon';
import type { Context, Config } from '@netlify/functions';

export const config: Config = {
  path: '/api/libraries',
};

const sql = neon();

// Table looks like this:
//     CREATE TABLE IF NOT EXISTS libraries (
//       id      SERIAL PRIMARY KEY,
//       name    TEXT NOT NULL,
//       address TEXT NOT NULL,
//       city    TEXT NOT NULL,
//       state   TEXT NOT NULL,
//       zip     TEXT NOT NULL,
//       phone   TEXT NOT NULL,
//       img     TEXT NOT NULL
//     )

export default async (req: Request, _context: Context) => {
  if (req.method === 'GET') {
    // get all libraries
    const rows = await sql('SELECT * FROM libraries ORDER BY name ASC');
    return new Response(JSON.stringify(rows), {
      headers: { 'Content-Type': 'application/json' },
    });
  } else {
    return new Response('Method not allowed', { status: 405 });
  }
};
