import { withDefaults } from '@warp-drive/core/reactive';
import type { Type } from '@warp-drive/core/types/symbols';

export interface Library {
  id: string;
  name: string;
  address: string;
  city: string;
  state: string;
  zip: string;
  phone: string;
  img: string;
  $type: 'library';
  [Type]: 'library';
}

export const LibrarySchema = withDefaults({
  type: 'library',
  fields: [
    { name: 'name', kind: 'field' },
    { name: 'address', kind: 'field' },
    { name: 'city', kind: 'field' },
    { name: 'state', kind: 'field' },
    { name: 'zip', kind: 'field' },
    { name: 'phone', kind: 'field' },
    { name: 'img', kind: 'field' },
  ],
});
