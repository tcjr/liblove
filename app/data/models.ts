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

export interface MetroLibraryMap {
  id: string;
  metro: Metro;
  svg: Svg;
  libraryCells: Cell[];
}

export interface Visit {
  id: string;
  library: Library;
  visitedAt: Date;
}
