import fs from 'fs';
import path from 'path';
import { Delaunay } from 'd3-delaunay';
import polygonClipping from 'polygon-clipping';
import simplify from 'simplify-js';

// Configuration based on map-svg-spec.md
const WIDTH = 800;
const LNG_MIN = -87.95;
const LNG_MAX = -87.5;
const LAT_MIN = 41.63;
const LAT_MAX = 42.05;

// Dynamic height calculation to match geographic aspect ratio at 41.8° N
// 1 degree latitude is approx 111.1 km
// 1 degree longitude at 41.8° N is approx 111.1 * cos(41.8°) ≈ 82.8 km
const ASPECT_RATIO =
  (LAT_MAX - LAT_MIN) /
  ((LNG_MAX - LNG_MIN) * Math.cos((41.8 * Math.PI) / 180));
const HEIGHT = Math.round(WIDTH * ASPECT_RATIO);

// Douglas-Peucker simplification tolerance. Higher numbers make the map smoother.
// const SIMPLIFICATION_TOLERANCE = 1.5;
const SIMPLIFICATION_TOLERANCE = 10;

console.log(
  `Canvas: ${WIDTH}x${HEIGHT} (Aspect Ratio: ${ASPECT_RATIO.toFixed(3)})`,
);

// Coordinate projection functions
function projectX(lng) {
  return ((lng - LNG_MIN) / (LNG_MAX - LNG_MIN)) * WIDTH;
}

function projectY(lat) {
  // Invert Y for SVG space
  return HEIGHT - ((lat - LAT_MIN) / (LAT_MAX - LAT_MIN)) * HEIGHT;
}

// 20-color categorical palette
const PALETTE = [
  '#1f77b4',
  '#aec7e8',
  '#ff7f0e',
  '#ffbb78',
  '#2ca02c',
  '#98df8a',
  '#d62728',
  '#ff9896',
  '#9467bd',
  '#c5b0d5',
  '#8c564b',
  '#c49c94',
  '#e377c2',
  '#f7b6d2',
  '#7f7f7f',
  '#c7c7c7',
  '#bcbd22',
  '#dbdb8d',
  '#17becf',
  '#9edae5',
];

async function generateMap() {
  const libsData = JSON.parse(fs.readFileSync('scripts/libs-geo.json', 'utf8'));
  const boundaryData = JSON.parse(
    fs.readFileSync('data/chicago-boundary.geojson', 'utf8'),
  );

  // 1. Extract and simplify city boundary
  // Structure: MultiPolygon = [Polygon, Polygon, ...]
  // Polygon = [OuterRing, Hole, Hole, ...]
  // Ring = [[x,y], [x,y], ...]
  console.log('Simplifying city boundry...');
  let cityPolygon = [];
  boundaryData.features.forEach((feature) => {
    if (feature.geometry.type === 'Polygon') {
      cityPolygon.push(
        feature.geometry.coordinates.map((ring) =>
          ring.map((coord) => [projectX(coord[0]), projectY(coord[1])]),
        ),
      );
    } else if (feature.geometry.type === 'MultiPolygon') {
      feature.geometry.coordinates.forEach((poly) => {
        cityPolygon.push(
          poly.map((ring) =>
            ring.map((coord) => [projectX(coord[0]), projectY(coord[1])]),
          ),
        );
      });
    }
  });

  // Simplify boundary for performance and "stylized" look
  cityPolygon = cityPolygon.map((poly) => {
    return poly.map((ring) => {
      const points = ring.map((p) => ({ x: p[0], y: p[1] }));
      const simplified = simplify(points, SIMPLIFICATION_TOLERANCE, true);
      return simplified.map((p) => [p.x, p.y]);
    });
  });

  // 2. Prepare library points for Voronoi
  console.log('Generating Voronoi points...');
  const points = libsData.map((lib) => [projectX(lib.lon), projectY(lib.lat)]);
  const delaunay = Delaunay.from(points);
  const voronoi = delaunay.voronoi([0, 0, WIDTH, HEIGHT]);

  // 3. Generate clipped Voronoi cells
  console.log('Generating Voronoi cells...');
  let cellsHtml = '';

  libsData.forEach((lib, i) => {
    const cellPolygon = voronoi.cellPolygon(i);
    if (!cellPolygon) {
      console.warn(`No cell polygon for ${lib.name}`);
      return;
    }

    // Intersect Voronoi cell with city boundary
    try {
      // polygonClipping.intersection expects [MultiPolygon, MultiPolygon]
      // voronoi.cellPolygon returns [[x,y], [x,y]...] which is a single Polygon ring
      const clipped = polygonClipping.intersection([cellPolygon], cityPolygon);

      if (clipped.length > 0) {
        // clipped is a MultiPolygon: [Polygon, Polygon, ...]
        // where each Polygon is [Ring, Ring, ...]
        clipped.forEach((poly) => {
          poly.forEach((ring) => {
            const pathData =
              ring
                .map((p, j) =>
                  j === 0 ? `M${p[0]},${p[1]}` : `L${p[0]},${p[1]}`,
                )
                .join(' ') + ' Z';
            const color = PALETTE[i % PALETTE.length];

            cellsHtml += `    <path 
      class="voronoi-cell" 
      data-name="${lib.name}" 
      fill="${color}" 
      fill-opacity="0.5" 
      stroke="white" 
      stroke-width="1" 
      d="${pathData}">
      <title>${lib.name}</title>
    </path>\n`;
          });
        });
      }
    } catch (e) {
      console.error(`Error clipping cell for ${lib.name}:`, e.message);
    }
  });

  // 4. Generate library markers
  console.log('Generating library points...');
  let markersHtml = '';
  libsData.forEach((lib) => {
    markersHtml += `    <circle class="lib-marker" cx="${projectX(lib.lon)}" cy="${projectY(lib.lat)}" r="3" fill="red" />\n`;
  });

  // 5. Generate city outline path
  // We only draw the outer ring (index 0) of each polygon in the MultiPolygon
  console.log('Generating city outline...');
  const outlinePathData = cityPolygon
    .map((poly) => {
      const outerRing = poly[0];
      return (
        outerRing
          .map((p, j) => (j === 0 ? `M${p[0]},${p[1]}` : `L${p[0]},${p[1]}`))
          .join(' ') + ' Z'
      );
    })
    .join(' ');

  // 6. Assemble final SVG
  console.log('Assembling SVG...');
  const svg = `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${WIDTH} ${HEIGHT}">
  <style>
    .voronoi-cell { cursor: pointer; transition: fill-opacity 0.2s; }
    .voronoi-cell:hover { fill-opacity: 0.9; stroke: #000; stroke-width: 1.5; }
    .lib-marker { pointer-events: none; }
    .city-outline { pointer-events: none; }
  </style>
  <g id="voronoi-cells">
${cellsHtml}  </g>
  <g id="library-points">
${markersHtml}  </g>
  <path id="city-outline" class="city-outline" fill="none" stroke="black" stroke-width="2" vector-effect="non-scaling-stroke" d="${outlinePathData}" />
</svg>`;

  const outputDir = path.join(process.cwd(), 'public');
  const filename = path.join(
    outputDir,
    `library-map-${SIMPLIFICATION_TOLERANCE}.svg`,
  );

  fs.writeFileSync(filename, svg);
  console.log(`Successfully generated ${filename}`);
}

generateMap().catch(console.error);
