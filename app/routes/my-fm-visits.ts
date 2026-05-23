import Route from '@ember/routing/route';

export default class MyFmVisitsRoute extends Route {
  async model() {
    const [fmModule, mapModule] = await Promise.all([
      import('../../data/farmers-markets.json'),
      import('../../data/chicago-fm-map-data.json'),
    ]);
    return { markets: fmModule.default, map: mapModule.default };
  }
}
