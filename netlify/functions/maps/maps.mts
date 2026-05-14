import type { Context, Config } from '@netlify/functions';
import chicagoData from '../static-data/chicago-library-map-data.json';

export const config: Config = {
  path: '/api/maps/:metroId',
};

export default (req: Request, context: Context) => {
  if (req.method === 'GET') {
    if (context.params) {
      // GET /api/maps/abc
      const metroId = context.params.metroId;
      if (metroId !== 'chicago') {
        return new Response('Not found', { status: 404 });
      } else {
        const jsonApi = {
          data: {
            type: 'metro-library-map',
            id: 'chicago',
            attributes: chicagoData,
          },
        };
        return new Response(JSON.stringify(jsonApi), {
          headers: { 'Content-Type': 'application/json' },
        });
      }
    } else {
      // GET /api/maps
      // Invalid
      return new Response('Not found', { status: 404 });
    }
  } else {
    return new Response('Method not allowed', { status: 405 });
  }
};
