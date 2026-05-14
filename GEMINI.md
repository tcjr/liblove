# Gemini CLI Context: liblove

This project, **liblove**, is an Ember.js application for exploring Chicago Public Library locations. It features a unique Voronoi-based map visualization of library service areas.

## Project Overview

- **Frontend:** Ember.js (Octane/Polaris style) using `.gts` (Glimmer Template Syntax) files.
- **Build System:** Vite (via Embroider) for the frontend; Netlify CLI for the full-stack local environment.
- **Styling:** Tailwind CSS v4 with DaisyUI.
- **Backend:** Netlify Functions (TypeScript) for API endpoints.
- **Authentication:** Netlify Identity.
- **Database:** Netlify Database (Postgres) managed with Drizzle ORM.
- **Testing:** Vitest for component and unit testing.

## Key Directories

- `app/`: Frontend source code (Components, Routes, Services, Styles).
- `netlify/functions/`: Serverless backend functions.
- `db/`: Database schema (`schema.ts`) and Drizzle configuration.
- `scripts/`: Data processing scripts, specifically for generating the Voronoi map data from GeoJSON.
- `data/`: Raw geographic and library location data.
- `public/`: Static assets, including a large collection of Chicago library images.

## Architecture & Conventions

### Frontend (Ember)

- Uses modern "Polaris" patterns: `<template>` tags in `.gts` files for components.
- State management: `tracked` properties and `ember-resources`.
- Routing: Standard Ember router (`app/router.ts`).

### Backend (Netlify)

- Functions are located in `netlify/functions/`.
- `netlify.toml` handles redirects (e.g., `/api/misc` to static JSON) and configures the build/dev environment.

### Database (Drizzle)

- Schema is defined in `db/schema.ts`.
- Migrations are applied using `netlify database migrations apply` (aliased to `pnpm db:migrate`).

### Map Generation

- Custom logic in `scripts/generate-map-data.mjs` uses `d3-delaunay` to create Voronoi cells and `polygon-clipping` to fit them within the Chicago city boundary.
- The output is a static JSON file (`netlify/functions/static-data/chicago-library-map-data.json`) used by the frontend.

## Building and Running

### Development

- `pnpm start`: Starts the Netlify Dev environment, which runs both the Vite development server and Netlify Functions.
- `pnpm start:ember`: Starts only the Vite development server for the frontend.

### Testing & Linting

- `pnpm test`: Runs Vitest for the suite.
- `pnpm lint`: Runs ESLint, Prettier, and Template-lint.
- `pnpm lint:fix`: Automatically fixes linting and formatting issues.

### Database

- `pnpm db:generate`: Generates Drizzle migrations based on schema changes.
- `pnpm db:migrate`: Applies migrations to the Netlify Database.

### Map Data

- `pnpm generate:map-data`: Runs the script to re-generate the Voronoi map JSON file.

### Production Build

- `pnpm build`: Runs `vite build` to prepare the `dist` directory.
