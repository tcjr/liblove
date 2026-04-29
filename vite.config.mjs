import tailwindcss from '@tailwindcss/vite';
import { defineConfig } from 'vite';
import { extensions, ember } from '@embroider/vite';
import { babel } from '@rollup/plugin-babel';
import { preview } from '@vitest/browser-preview';
import { playwright } from '@vitest/browser-playwright';

const isCI = process.env.CI === 'true';

export default defineConfig({
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
