import fs from 'fs';
import path from 'path';
import { Delaunay } from 'd3-delaunay';
import polygonClipping from 'polygon-clipping';
import simplify from 'simplify-js';
import { Command } from 'commander';
import { intro, log, outro } from '@clack/prompts';

const program = new Command();

program.option('-m, --metro <name>', 'metro name', 'chicago');

program.parse();

const options = program.opts();

if (options.metro) {
  if (options.metro !== 'chicago') {
    console.error('Invalid metro name, only "chicago" is currently supported.');
    process.exit(1);
  }
}

intro(`Generating farmer's market map data for ${options.metro}`);

// Required input files must exist:
// - data/${options.metro}-farmers-markets.json
// - data/${options.metro}-boundary.geojson
// Output file:
// - data/${options.metro}-fm-map-data.json

// Configuration
const WIDTH = 800;
// NOTE: These are chicago-specific
const LNG_MIN = -87.95;
const LNG_MAX = -87.5;
const LAT_MIN = 41.63;
const LAT_MAX = 42.05;

// Dynamic height calculation to match geographic aspect ratio at 41.8° N
// NOTE: This is chicago-specific
const ASPECT_RATIO =
  (LAT_MAX - LAT_MIN) /
  ((LNG_MAX - LNG_MIN) * Math.cos((41.8 * Math.PI) / 180));
const HEIGHT = Math.round(WIDTH * ASPECT_RATIO);

// Douglas-Peucker simplification tolerance.
const SIMPLIFICATION_TOLERANCE = 10;

log.step(
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
  log.step('Loading input files...');
  const fmsData = JSON.parse(
    fs.readFileSync(`data/${options.metro}-farmers-markets.json`, 'utf8'),
  );
  const boundaryData = JSON.parse(
    fs.readFileSync(`data/${options.metro}-boundary.geojson`, 'utf8'),
  );

  // 1. Extract and simplify metro boundary
  log.step('Simplifying metro boundary...');
  let metroPolygons = [];
  boundaryData.features.forEach((feature) => {
    if (feature.geometry.type === 'Polygon') {
      metroPolygons.push(
        feature.geometry.coordinates.map((ring) =>
          ring.map((coord) => [projectX(coord[0]), projectY(coord[1])]),
        ),
      );
    } else if (feature.geometry.type === 'MultiPolygon') {
      feature.geometry.coordinates.forEach((poly) => {
        metroPolygons.push(
          poly.map((ring) =>
            ring.map((coord) => [projectX(coord[0]), projectY(coord[1])]),
          ),
        );
      });
    }
  });

  // Simplify boundary
  metroPolygons = metroPolygons.map((poly) => {
    return poly.map((ring) => {
      const points = ring.map((p) => ({ x: p[0], y: p[1] }));
      const simplified = simplify(points, SIMPLIFICATION_TOLERANCE, true);
      return simplified.map((p) => [p.x, p.y]);
    });
  });

  // 2. Prepare markets points for Voronoi
  log.step('Generating Voronoi points...');
  const points = fmsData.map((fm) => [projectX(fm.lon), projectY(fm.lat)]);
  const delaunay = Delaunay.from(points);
  const voronoi = delaunay.voronoi([0, 0, WIDTH, HEIGHT]);

  // 3. Generate clipped Voronoi cells
  log.step('Generating Voronoi cells data...');
  const cells = [];

  fmsData.forEach((fm, i) => {
    const cellPolygon = voronoi.cellPolygon(i);
    if (!cellPolygon) {
      console.warn(`No cell polygon for ${fm.name}`);
      return;
    }

    // Intersect Voronoi cell with metro boundary
    try {
      const clipped = polygonClipping.intersection(
        [cellPolygon],
        metroPolygons,
      );

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

        cells.push({
          id: fm.id,
          name: fm.name,
          outlinePath: outlinePath.trim(),
          markerX: projectX(fm.lon),
          markerY: projectY(fm.lat),
        });
      }
    } catch (e) {
      console.error(`Error clipping cell for ${fm.name}:`, e.message);
    }
  });

  // 4. Generate metro outline path
  log.step('Generating metro outline path...');
  const metroOutlinePath = metroPolygons
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
  log.step('Assembling final JSON...');
  const result = {
    _INFO: {
      note: 'GENERATED FILE - DO NOT EDIT',
      timestamp: new Date().toISOString(),
    },
    svg: {
      width: WIDTH,
      height: HEIGHT,
    },
    metro: {
      id: options.metro,
      outlinePath: metroOutlinePath,
    },
    cells,
  };

  const outputDir = path.join(process.cwd(), 'data');
  const filename = path.join(outputDir, `${options.metro}-fm-map-data.json`);

  fs.writeFileSync(filename, JSON.stringify(result, null, 2));
  log.step(`Successfully generated ${filename}`);
}

generateData().catch(console.error);

outro('All done');
