import { describe, test, expect } from 'vitest';
import { setupRenderingContext } from 'ember-vitest';
import App from '#app/app';
import CellMap from '#app/components/cell-map.gts';

describe('CellMap', () => {
  test('renders an svg', async () => {
    const testCells = [
      {
        id: '1',
        name: 'One',
        outlinePath: '',
        markerX: 50,
        markerY: 50,
      },
    ];
    await using ctx = await setupRenderingContext(App);
    await ctx.render(
      <template>
        <CellMap @viewBox="0 0 100 100" @cells={{testCells}} />
      </template>
    );

    const svg = ctx.element.querySelector('svg')!;
    expect(svg).not.toBeNull();
    expect(svg.getAttribute('viewBox')).toBe('0 0 100 100');

    expect(svg.querySelectorAll('path.voronoi-cell').length).toBe(1);
    const cell = svg.querySelectorAll('.voronoi-cell')[0];
    expect(cell).not.toBeNull();
    expect(cell.getAttribute('d')).toBe('');
    expect(cell.getAttribute('data-item-id')).toBe('1');

    expect(svg.querySelectorAll('circle.item-marker').length).toBe(1);
    const circle = svg.querySelectorAll('circle')[0];
    expect(circle.getAttribute('cx')).toBe('50');
    expect(circle.getAttribute('cy')).toBe('50');
    expect(circle.getAttribute('r')).toBe('3');
  });
});
