### **SVG Architecture Specification: Chicago Library Voronoi Map**

**1. Canvas & ViewBox Setup**

- **Root Element:** `<svg>`
- **Namespaces:** Standard `xmlns="http://www.w3.org/2000/svg"`
- **ViewBox:** `0 0 800 {calculated_height}`. The height (approximately `1012`) must be dynamically calculated to match the geographic aspect ratio of Chicago at 41.8° N latitude, preventing spatial distortion.
- **Scaling Map:** Longitude (-87.95 to -87.50) maps to the X-axis (`0` to `800`). Latitude (41.63 to 42.05) maps to the Y-axis (`height` to `0`, inverted for SVG coordinate space).

**2. Embedded CSS (`<style>`)**
The SVG contains an embedded stylesheet with the following interactive rules:

- `.voronoi-cell`: `cursor: pointer; transition: fill-opacity 0.2s;`
- `.voronoi-cell:hover`: `fill-opacity: 0.9; stroke: #000; stroke-width: 1.5;`
- `.lib-marker`: `pointer-events: none;` (ensures hovering over a dot doesn't interrupt the hover state of the cell beneath it).
- `.city-outline`: `pointer-events: none;`

**3. DOM Layering Strategy (Z-Index)**
The document relies on SVG's natural render order (bottom-to-top) to establish z-index. The DOM must be ordered exactly as follows:

1.  **Bottom Layer:** `<g id="voronoi-cells">` (The colored polygons).
2.  **Middle Layer:** `<g id="library-points">` (The red coordinate dots).
3.  **Top Layer:** `<path id="city-outline">` (The bold boundary stroke).

**4. Element-Level Specifications**

- **Voronoi Cells (The Polygons)**
  - **Container:** `<g id="voronoi-cells">`
  - **Elements:** 81 individual `<path>` nodes.
  - **Geometry (`d` attribute):** Each path must represent a mathematically strict Voronoi cell generated from the library coordinates, intersected (clipped) against the exact polygon of the Chicago city boundary.
  - **Attributes:**
    - `class="voronoi-cell"`
    - `data-name="[Exact Library Name]"`
    - `fill="[Hex Color]"` (iterated from a distinct categorical palette of ~20 colors).
    - `fill-opacity="0.5"`
    - `stroke="white"`
    - `stroke-width="1"`
  - **Children:** Each `<path>` contains a native `<title>[Exact Library Name]</title>` tag to leverage built-in browser tooltips on hover.

- **Library Markers (The Coordinates)**
  - **Container:** `<g id="library-points">`
  - **Elements:** 81 individual `<circle>` nodes.
  - **Geometry:** `cx` and `cy` mapped to the exact scaled X/Y coordinates of each respective library.
  - **Attributes:**
    - `class="lib-marker"`
    - `r="3"`
    - `fill="red"`

- **City Outline (The Boundary Mask)**
  - **Element:** A single `<path>` node.
  - **Geometry (`d` attribute):** A continuous line connecting the simplified bounding coordinates of the City of Chicago.
  - **Attributes:**
    - `id="city-outline"`
    - `class="city-outline"`
    - `fill="none"`
    - `stroke="black"`
    - `stroke-width="2"`
