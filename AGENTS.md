# Agent Guidelines for liblove

## Build/Test/Lint Commands

- **Test**: `pnpm test`
- **Lint**: `pnpm lint` (check all)
- **Type check**: `pnpm lint:types` (uses Glint/ember-tsc)

## Code Style & Conventions

- **Language**: TypeScript with Ember.js (Octane edition), Glimmer components
- **Templates**: Use `.gts` files for components
- **Imports**: Use subpaths (`#app/services/clerk`) not relative paths
- **Formatting**: Prettier with single quotes for JS/TS, double quotes for templates
- **Services**: Inject with `@service declare serviceName: ServiceType;`
- **Tracking**: Use `@tracked` for reactive properties
- **Styling**: TailwindCSS + DaisyUI components
- **Naming**: PascalCase for components/classes, camelCase for methods/properties
- **Error handling**: Throw descriptive errors with proper validation
- **Comments**: Minimal - add for clarity
