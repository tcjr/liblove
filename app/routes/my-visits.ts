import Route from '@ember/routing/route';

export default class MyVisitsRoute extends Route {
  async model() {
    // TODO: do not await these serially
    const libsModule = await import('../../data/chicago-libs.json');
    const mapModule = await import('../../data/chicago-library-map-data.json');
    return { libraries: libsModule.default, map: mapModule.default };
  }
}
