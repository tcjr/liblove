import { defineConfig } from 'cypress';

export default defineConfig({
  allowCypressEnv: false,

  e2e: {
    // baseUrl: 'http://localhost:8888',
    baseUrl: 'https://liblove.netlify.app',

    // setupNodeEvents(/*_on, _config*/) {
    //   // implement node event listeners here
    // },
  },
});
