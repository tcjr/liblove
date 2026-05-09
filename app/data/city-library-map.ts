import { withDefaults } from '@warp-drive/core/reactive';
import type { Type } from '@warp-drive/core/types/symbols';

interface City {
  name: string;
  state: string;
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

export interface CityLibraryMap {
  id: string;
  city: City;
  svg: Svg;
  libraryCells: Cell[];

  $type: 'city-library-map';
  [Type]: 'city-library-map';
}

export const CityLibraryMapSchema = withDefaults({
  type: 'city-library-map',
  fields: [
    { name: 'city', kind: 'field' },
    { name: 'svg', kind: 'field' },
    { name: 'libraryCells', kind: 'field' },
  ],
});
