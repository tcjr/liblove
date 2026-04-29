import Component from '@glimmer/component';

export interface StatsBoxSignature {
  Args: { count: number };
  Element: HTMLDivElement;
}

export default class StatsBox extends Component<StatsBoxSignature> {
  <template>
    <div ...attributes>
      Count is
      {{@count}}.
    </div>
  </template>
}
