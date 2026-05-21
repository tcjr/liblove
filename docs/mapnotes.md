To achieve a stylized, "blocky" look similar to your desired output while maintaining the integrity of the Voronoi
cells, you can follow a process of geometric abstraction.

Since the Voronoi cells are clipped against the city boundary, the level of detail in the map is entirely dictated
by the complexity of that boundary polygon. Here is how you could approach simplifying it:

1. Increase Simplification Tolerance
   The script currently uses the Douglas-Peucker algorithm (via simplify-js) with a tolerance of 1.5.

- The Process: By significantly increasing this tolerance value (e.g., to 15 or 20), the algorithm will ignore
  larger "wiggles" in the boundary and only keep points that represent major shifts in direction.
- The Result: This would prune the current thousands of points down to perhaps 40–50, resulting in longer,
  straighter lines that still roughly follow the city's path but lose the "natural" detail.

2. Grid Snapping (Quantization)
   To get the architectural, "pixel-art" feel seen in your image, you can snap the coordinates to a fixed grid.

- The Process: Before passing the boundary coordinates to the clipping function, you would round every X and Y
  coordinate to the nearest multiple of a "grid unit" (e.g., 10 or 20 pixels).
- The Result: This forces the boundary edges to align to a common grid. If a segment is nearly horizontal,
  snapping will make it perfectly horizontal. This creates the "blocky" aesthetic where angles are restricted.

3. Manual "Key Point" Selection
   If you want the map to look exactly like the stylized image, the most effective method is to replace the
   11,000-point official GeoJSON with a hand-curated list of ~20 "Anchor Points."

- The Process: You would identify the critical geographic corners of Chicago:
  1.  The four corners of the O'Hare "arm."
  2.  The "notch" at the top of the city.
  3.  The straight vertical line of the Lakefront.
  4.  The diagonal southern border.
- The Result: By defining the cityPolygon as this simple array of 20 coordinates, the Voronoi cells will
  automatically expand to fill these new "straight" edges during the clipping phase, creating the clean, low-poly
  look of the reference image.

4. Manually Squaring the Lakefront
   The reference image treats the Lakefront (the east side of the city) as a perfectly straight vertical line, whereas
   the official data has hundreds of small inlets and piers.

- The Process: You could identify the easternmost longitude of the city and force all points on the eastern edge
  to that exact X-coordinate.
- The Result: This creates the iconic "wall" effect on the right side of the map, which looks much cleaner in a
  stylized SVG than a jagged coastline.

Summary of Workflow
If you were to implement this, you would essentially reduce the vertex count of the cityPolygon variable in the
script. Because the Voronoi computation is "unbounded" (the cells want to go to infinity), they will always
perfectly "stretch" to meet whatever boundary you provide. Simple boundary = simple cells.
