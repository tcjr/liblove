/**
 * Debugging:
 *   https://eslint.org/docs/latest/use/configure/debug
 *  ----------------------------------------------------
 *
 *   Print a file's calculated configuration
 *
 *     npx eslint --print-config path/to/file.js
 *
 *   Inspecting the config
 *
 *     npx eslint --inspect-config
 *
 */
import globals from 'globals';
import js from '@eslint/js';
import { defineConfig, globalIgnores } from 'eslint/config';
import ts from 'typescript-eslint';
import ember from 'eslint-plugin-ember/recommended';
import templateConfig from 'eslint-plugin-ember/configs/template-lint-migration';
import eslintConfigPrettier from 'eslint-config-prettier';
import vitest from '@vitest/eslint-plugin';
import n from 'eslint-plugin-n';
import babelParser from '@babel/eslint-parser/experimental-worker';
import css from '@eslint/css';

const parserOptions = {
  esm: {
    js: {
      ecmaFeatures: { modules: true },
      ecmaVersion: 'latest',
    },
    ts: {
      projectService: true,
      tsconfigRootDir: import.meta.dirname,
    },
  },
};

export default defineConfig([
  globalIgnores(['dist/', 'coverage/', '.netlify/*', '!**/.*']),
  js.configs.recommended,
  ember.configs.base,
  ember.configs.gjs,
  ember.configs.gts,
  eslintConfigPrettier,
  /**
   * https://eslint.org/docs/latest/use/configure/configuration-files#configuring-linter-options
   */
  {
    linterOptions: {
      reportUnusedDisableDirectives: 'error',
    },
  },
  {
    files: ['**/*.js'],
    languageOptions: {
      parser: babelParser,
    },
  },
  {
    files: ['**/*.{js,gjs}'],
    languageOptions: {
      parserOptions: parserOptions.esm.js,
      globals: {
        ...globals.browser,
      },
    },
  },
  {
    files: ['**/*.{ts,gts}'],
    languageOptions: {
      parser: ember.parser,
      parserOptions: parserOptions.esm.ts,
      globals: {
        ...globals.browser,
      },
    },
    extends: [...ts.configs.recommendedTypeChecked, ember.configs.gts],
    rules: {
      'ember/no-empty-glimmer-component-classes': 'off',
    },
  },

  // GJS/GTS template part
  ...templateConfig,

  // TESTING (vitest)
  {
    files: ['tests/**/*.test.{js,gjs,ts,gts}'],
    plugins: { vitest },
    rules: {
      ...vitest.configs.recommended.rules,
      // When using testing-library-ember, the types for the event triggers are
      // not correctly typed; the calls are wrapped in promises, but the types
      // do not reflect this. So we turn this rule off to allow us to await
      // the trigger calls.
      '@typescript-eslint/await-thenable': 'off',

      // ember-vitest adds applicationTest() and renderingTest() alternatives to
      // the default test() function. This registers these functions, so this
      // rule won't flag the usage of `expect`.
      'vitest/no-standalone-expect': [
        'error',
        {
          additionalTestBlockFunctions: ['renderingTest'],
        },
      ],

      // ember-vitest's recommended way to provide the app container is with
      // code like this:
      //   renderingTest.scoped({ app: ({}, use) => use(App) });
      // Relaxing the no-empty-pattern rule allows this code.
      'no-empty-pattern': ['error', { allowObjectPatternsAsParameters: true }],
    },
  },

  /**
   * CJS node files
   */
  {
    files: ['**/*.cjs', 'config/**/*.js', 'ember-cli-build.js'],
    plugins: {
      n,
    },

    languageOptions: {
      sourceType: 'script',
      ecmaVersion: 'latest',
      globals: {
        ...globals.node,
      },
    },
  },
  /**
   * ESM node files
   */
  {
    files: ['**/*.mjs'],
    plugins: {
      n,
    },

    languageOptions: {
      sourceType: 'module',
      ecmaVersion: 'latest',
      parserOptions: parserOptions.esm.js,
      globals: {
        ...globals.node,
      },
    },
  },

  // lint CSS files
  {
    files: ['**/*.css'],
    language: 'css/css',
    plugins: { css },
    extends: ['css/recommended'],
    rules: {
      'no-irregular-whitespace': 'off',
    },
  },
]);
