import tailwindcss from '@tailwindcss/vite';
import { defineConfig } from 'vite';
import { extensions, ember } from '@embroider/vite';
import { babel } from '@rollup/plugin-babel';
import { preview } from '@vitest/browser-preview';
import { playwright } from '@vitest/browser-playwright';
import svgJar from '@svg-jar/plugin/vite';

const isCI = process.env.CI === 'true';

export default defineConfig({
  optimizeDeps: {
    include: [
      // I'm not sure why I need to do this, but without it, I was getting test
      // failures preceeded by this:
      //    [vitest] Vite unexpectedly reloaded a test. This may cause tests to
      //    fail, lead to flaky behaviour or duplicated test runs.
      'ember-source/@ember/service/index.js',
      '@embroider/router',
      'ember-page-title',
      'ember-source/@ember/routing/index.js',
      'ember-source/@ember/reactive/collections.js',
      'ember-source/@glimmer/tracking/index.js',
      '@responsive-image/ember',
      '@responsive-image/cdn',
      '@netlify/identity',
      'ember-source/@ember/routing/route.js',
    ],
  },
  test: {
    include: ['tests/**/*.test.{gjs,gts,js,ts}'],
    maxConcurrency: 1,
    browser: {
      provider: isCI ? playwright() : preview(),
      enabled: true,
      headless: isCI,
      instances: [{ browser: 'chromium' }],
      screenshotFailures: false,
    },
  },
  plugins: [
    ember(),
    babel({
      babelHelpers: 'runtime',
      extensions,
    }),
    tailwindcss(),
    svgJar({ target: 'ember' }),
  ],
});
