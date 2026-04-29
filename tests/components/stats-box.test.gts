import { describe, test, expect } from 'vitest';
import { setupRenderingContext } from 'ember-vitest';
import App from '#app/app';
import StatsBox from '#app/components/stats-box';

describe('StatsBox', () => {
  test('renders the count', async () => {
    await using ctx = await setupRenderingContext(App);
    await ctx.render(<template><StatsBox @count={{99}} /></template>);

    expect(ctx.element.textContent).toContain('Count is');
    expect(ctx.element.textContent).toContain('99');
  });
});
