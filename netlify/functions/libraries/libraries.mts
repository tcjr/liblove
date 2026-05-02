import { db } from '../../../db/index';
import { libraries } from '../../../db/schema';
import { asc } from 'drizzle-orm';
import type { Context, Config } from '@netlify/functions';

export const config: Config = {
  path: '/api/libraries',
};

export default async (req: Request, _context: Context) => {
  if (req.method === 'GET') {
    // get all libraries
    const rows = await db.select().from(libraries).orderBy(asc(libraries.name));

    // Convert the response to JSON:API spec with type and attributes.

    const libObjs = rows.map((row) => ({
      type: 'library',
      id: row.id.toString(),
      attributes: {
        name: row.name,
        address: row.address,
        city: row.city,
        state: row.state,
        zip: row.zip,
        phone: row.phone,
        img: row.img,
      },
    }));

    const data = {
      data: libObjs,
    };

    return new Response(JSON.stringify(data), {
      headers: { 'Content-Type': 'application/json' },
    });
  } else {
    return new Response('Method not allowed', { status: 405 });
  }
};
