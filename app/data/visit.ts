import { withDefaults } from '@warp-drive/core/reactive';
import type { Type } from '@warp-drive/core/types/symbols';
import type { Library } from './library';

export interface Visit {
  id: string;
  library: Library;
  visitedAt: Date;
  $type: 'visit';
  [Type]: 'visit';
}

export const VisitSchema = withDefaults({
  type: 'visit',
  fields: [
    {
      name: 'library',
      kind: 'belongsTo',
      type: 'library',
      options: { async: false, inverse: null, linksMode: true },
    },
    { name: 'visitedAt', kind: 'field' },
  ],
});
