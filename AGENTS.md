# Agent Context: liblove

This project, **liblove**, is an Ember.js application for exploring Chicago Public locations, currently public libraries and farmer's markets. It features a unique Voronoi-based map visualization of service areas.

## Project Overview

- **Frontend:** Ember.js (Octane/Polaris style) using `.gts` (Glimmer Template Syntax) files.
- **Build System:** Vite (via Embroider) for the frontend; Netlify CLI for the full-stack local environment.
- **Styling:** Tailwind CSS v4 with DaisyUI.
- **Backend:** Netlify Functions (TypeScript) for API endpoints.
- **Authentication:** Netlify Identity.
- **Database:** Netlify Blobs - structure TBD.
- **Testing:** Vitest for component and unit testing.

## Key Directories

- `app/`: Frontend source code (Components, Routes, Services, Styles).
- `netlify/functions/`: Serverless backend functions.
- `scripts/`: Data processing scripts, specifically for generating the Voronoi map data from GeoJSON.
- `data/`: Raw geographic and location data + generated map data.
- `public/`: Static assets, including a large collection of Chicago library images.

## Architecture & Conventions

### Frontend (Ember)

- Uses modern "Polaris" patterns: `<template>` tags in `.gts` files for components.
- State management: `tracked` properties and `ember-resources`.
- User-specific data is stored in local storage only.
- Routing: Standard Ember router (`app/router.ts`).

### Backend (Netlify)

- Functions are located in `netlify/functions/`. (CURRENTLY NOT USED.)
- `netlify.toml` handles redirects and configures the build/dev environment.

### Map Generation

- Custom logic in `scripts/generate-library-map-data.mjs` and `scripts/generate-fm-map-data.mjs` uses `d3-delaunay` to create Voronoi cells and `polygon-clipping` to fit them within the Chicago city boundary.
- The output are static JSON files (`data/chicago-library-map-data.json` and `data/chicago-fm-map-data.json`) that are used in the frontend.

## Building and Running

### Development

- `pnpm start`: Starts the Netlify Dev environment, which runs both the Vite development server and Netlify Functions.
- `pnpm start:ember`: Starts only the Vite development server for the frontend.

### Testing & Linting

- `pnpm test`: Runs Vitest for the suite.
- `pnpm lint`: Runs ESLint, Prettier, and Template-lint.
- `pnpm lint:fix`: Automatically fixes linting and formatting issues.

### Map Data

- `pnpm generate:map-data`: Runs the script to re-generate the Voronoi map JSON file.

### Production Build

- `pnpm build`: Runs `netlify build` which also runs`vite build` to prepare the `dist` directory.

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
