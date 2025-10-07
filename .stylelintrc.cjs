'use strict';

module.exports = {
  extends: ['stylelint-config-standard'],
  rules: {
    // Allow @plugin and @theme
    'at-rule-no-unknown': [
      true,
      {
        ignoreAtRules: ['plugin', 'theme'],
      },
    ],
    // We want to allow: `@import('tailwindcss');`, so we disable the url() rule
    'import-notation': null,

    // #ffffff is ok, instead of #fff
    'color-hex-length': null,
  },
};
