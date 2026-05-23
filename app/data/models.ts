export interface Library {
  id: string;
  name: string;
  address: string;
  city: string;
  state: string;
  zip: string;
  phone: string;
  img: string;
  lat: number;
  lon: number;
}

export interface FarmersMarket {
  id: string;
  name: string;
  address: string;
  city: string;
  state: string;
  zip: string;
  lat: number;
  lon: number;
}

interface Metro {
  id: string;
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

export interface MetroCellMap {
  id: string;
  metro: Metro;
  svg: Svg;
  cells: Cell[];
}

export interface Visit {
  id: string;
  libraryId: string;
  visitedAt: Date;
}
