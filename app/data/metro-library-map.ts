import { withDefaults } from '@warp-drive/core/reactive';
import type { Type } from '@warp-drive/core/types/symbols';

interface Metro {
  name: string;
  outlinePath: string;
}

interface Cell {
  id: string;
  name: string;
  outlinePath: string;
  markerX: number;
  markerY: number;
}

interface Svg {
  width: number;
  height: number;
}

export interface MetroLibraryMap {
  id: string;
  metro: Metro;
  svg: Svg;
  libraryCells: Cell[];

  $type: 'metro-library-map';
  [Type]: 'metro-library-map';
}

export const MetroLibraryMapSchema = withDefaults({
  type: 'metro-library-map',
  fields: [
    { name: 'metro', kind: 'field' },
    { name: 'svg', kind: 'field' },
    { name: 'libraryCells', kind: 'field' },
  ],
});
