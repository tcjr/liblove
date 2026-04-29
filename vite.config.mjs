import tailwindcss from '@tailwindcss/vite';
import { defineConfig } from 'vite';
import { extensions, ember } from '@embroider/vite';
import { babel } from '@rollup/plugin-babel';
import { preview } from '@vitest/browser-preview';
import { playwright } from '@vitest/browser-playwright';

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
      '@warp-drive/legacy',
      '@warp-drive/json-api',
      'ember-page-title',
      '@warp-drive/ember',
      'ember-source/@ember/routing/index.js',
      '@warp-drive/core/reactive',
      '@warp-drive/core/request',
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
  ],
});
