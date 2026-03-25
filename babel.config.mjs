import { dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildMacros } from '@embroider/macros/babel';
import { setConfig } from '@warp-drive/core/build-config';

const macros = buildMacros({
  configure: (config) => {
    setConfig(config, {
      compatWith: '5.6',
    });
  },
});

export default {
  plugins: [
    [
      '@babel/plugin-transform-typescript',
      {
        allExtensions: true,
        onlyRemoveTypeImports: true,
        allowDeclareFields: true,
      },
    ],
    [
      'babel-plugin-ember-template-compilation',
      {
        transforms: [...macros.templateMacros],
      },
    ],
    [
      'module:decorator-transforms',
      {
        runtime: {
          import: import.meta.resolve('decorator-transforms/runtime-esm'),
        },
      },
    ],
    [
      '@babel/plugin-transform-runtime',
      {
        absoluteRuntime: dirname(fileURLToPath(import.meta.url)),
        useESModules: true,
        regenerator: false,
      },
    ],
    ...macros.babelMacros,
    // 'ember-concurrency/async-arrow-task-transform',
  ],

  generatorOpts: {
    compact: false,
  },
};
