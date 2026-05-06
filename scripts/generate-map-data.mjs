import fs from 'fs';
import path from 'path';
import { Delaunay } from 'd3-delaunay';
import polygonClipping from 'polygon-clipping';
import simplify from 'simplify-js';

// Configuration based on existing scripts and map-svg-spec.md
const WIDTH = 800;
const LNG_MIN = -87.95;
const LNG_MAX = -87.5;
const LAT_MIN = 41.63;
const LAT_MAX = 42.05;

// Dynamic height calculation to match geographic aspect ratio at 41.8° N
const ASPECT_RATIO =
  (LAT_MAX - LAT_MIN) /
  ((LNG_MAX - LNG_MIN) * Math.cos((41.8 * Math.PI) / 180));
const HEIGHT = Math.round(WIDTH * ASPECT_RATIO);

// Douglas-Peucker simplification tolerance.
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

async function generateData() {
  console.log('Loading input files...');
  const libsData = JSON.parse(fs.readFileSync('scripts/libs-geo.json', 'utf8'));
  const boundaryData = JSON.parse(
    fs.readFileSync('data/chicago-boundary.geojson', 'utf8'),
  );

  // 1. Extract and simplify city boundary
  console.log('Simplifying city boundary...');
  let cityPolygons = [];
  boundaryData.features.forEach((feature) => {
    if (feature.geometry.type === 'Polygon') {
      cityPolygons.push(
        feature.geometry.coordinates.map((ring) =>
          ring.map((coord) => [projectX(coord[0]), projectY(coord[1])]),
        ),
      );
    } else if (feature.geometry.type === 'MultiPolygon') {
      feature.geometry.coordinates.forEach((poly) => {
        cityPolygons.push(
          poly.map((ring) =>
            ring.map((coord) => [projectX(coord[0]), projectY(coord[1])]),
          ),
        );
      });
    }
  });

  // Simplify boundary
  cityPolygons = cityPolygons.map((poly) => {
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
  console.log('Generating Voronoi cells data...');
  const libraryCells = [];

  libsData.forEach((lib, i) => {
    const cellPolygon = voronoi.cellPolygon(i);
    if (!cellPolygon) {
      console.warn(`No cell polygon for ${lib.name}`);
      return;
    }

    // Intersect Voronoi cell with city boundary
    try {
      const clipped = polygonClipping.intersection([cellPolygon], cityPolygons);

      if (clipped.length > 0) {
        // combine all rings into a single path string
        let outlinePath = '';
        clipped.forEach((poly) => {
          poly.forEach((ring) => {
            outlinePath +=
              ring
                .map((p, j) =>
                  j === 0 ? `M${p[0]},${p[1]}` : `L${p[0]},${p[1]}`,
                )
                .join(' ') + ' Z ';
          });
        });

        libraryCells.push({
          id: lib.id,
          name: lib.name,
          outlinePath: outlinePath.trim(),
          markerX: projectX(lib.lon),
          markerY: projectY(lib.lat),
        });
      }
    } catch (e) {
      console.error(`Error clipping cell for ${lib.name}:`, e.message);
    }
  });

  // 4. Generate city outline path
  console.log('Generating city outline path...');
  const cityOutlinePath = cityPolygons
    .map((poly) => {
      const outerRing = poly[0];
      return (
        outerRing
          .map((p, j) => (j === 0 ? `M${p[0]},${p[1]}` : `L${p[0]},${p[1]}`))
          .join(' ') + ' Z'
      );
    })
    .join(' ');

  // 5. Assemble final JSON object
  console.log('Assembling final JSON...');
  const result = {
    svg: {
      width: WIDTH,
      height: HEIGHT,
    },
    city: {
      name: 'Chicago',
      state: 'IL',
      outlinePath: cityOutlinePath,
    },
    libraryCells: libraryCells,
  };

  const outputDir = path.join(process.cwd(), 'public');
  const filename = path.join(outputDir, 'library-map-data.json');

  fs.writeFileSync(filename, JSON.stringify(result, null, 2));
  console.log(`Successfully generated ${filename}`);
}

generateData().catch(console.error);
