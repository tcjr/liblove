import { LinkTo } from '@ember/routing';
import { pageTitle } from 'ember-page-title';

<template>
  {{pageTitle "Lib Love"}}

  <nav>
    <LinkTo @route="index">Home</LinkTo>
    |
    <LinkTo @route="libraries">Libraries</LinkTo>
  </nav>

  {{outlet}}
</template>
