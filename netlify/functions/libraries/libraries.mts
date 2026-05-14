import { db } from '../../../db/index';
import { libraries } from '../../../db/schema';
import { asc, eq } from 'drizzle-orm';
import type { Context, Config } from '@netlify/functions';

export const config: Config = {
  path: '/api/libraries/:metroId',
};

export default async (req: Request, context: Context) => {
  if (req.method === 'GET') {
    if (context.params) {
      const metroId = context.params.metroId;

      if (!metroId) {
        return new Response('Not found', { status: 404 });
      }

      // get all libraries for metro
      const rows = await db
        .select()
        .from(libraries)
        .where(eq(libraries.metro, metroId))
        .orderBy(asc(libraries.name));

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
          lat: row.lat,
          lon: row.lon,
          metro: row.metro,
        },
      }));

      const data = {
        data: libObjs,
      };

      return new Response(JSON.stringify(data), {
        headers: { 'Content-Type': 'application/json' },
      });
    } else {
      // GET /api/libraries
      // Not allowed to get all libraries across metros
      return new Response('Not found', { status: 404 });
    }
  } else {
    return new Response('Method not allowed', { status: 405 });
  }
};
