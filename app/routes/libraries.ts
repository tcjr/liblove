import Route from '@ember/routing/route';

export default class LibsRoute extends Route {
  async model() {
    const [libsModule, mapModule] = await Promise.all([
      import('../../data/chicago-libs.json'),
      import('../../data/chicago-library-map-data.json'),
    ]);
    return { libraries: libsModule.default, map: mapModule.default };
  }
}
