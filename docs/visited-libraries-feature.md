# Implementation Plan: Visited Libraries Feature

## Objective

Implement a feature allowing authenticated users to track which Chicago Public Libraries they have visited. This plan shifts from a custom frontend service approach to fully integrating with EmberData/Warp Drive, requiring the creation of a new `Visit` data model.

## Background & Motivation

The user wants to track visited libraries. While a lightweight service was initially proposed, the user correctly identified that treating "Visits" as formal EmberData models (`app/data/visit.ts`) allows for easier future expansion (e.g., adding notes, dates, or photos to a visit). This decision requires making the backend API compliant with JSON:API (the default format expected by Warp Drive).

## Scope & Impact

- **Backend:** Modifying the recently created `/api/visits` endpoint to return and accept JSON:API formatted payloads.
- **Frontend (Data):** Creating a new `Visit` model and schema, registering it with the store, and adding API builder functions.
- **Frontend (UI):** Updating components to fetch, observe, and mutate visit records.

---

## Implementation Steps

### Phase 1: Backend Refactor (JSON:API Compliance)

1.  **Refactor `netlify/functions/visits/visits.mts`:**
    - **GET:** Update the response payload to match JSON:API. Instead of returning `[1, 2, 3]`, map the Drizzle rows to objects with `type: 'visit'`, an `id` (the visit record ID, not the library ID), and `attributes` (containing `libraryId`).
    - **POST:** Update the request parsing to expect JSON:API format (`{ data: { type: 'visit', attributes: { libraryId: '...' } } }`). Update the response to return the newly created record in JSON:API format (status 201).
    - **DELETE:** Instead of passing the `libraryId` in the body, standard JSON:API deletes use the URL parameter (e.g., `DELETE /api/visits/:visitId`). We will need to update the routing/parsing to handle this.

### Phase 2: Frontend Data Modeling

1.  **Create `app/data/visit.ts`:**
    - Define the `Visit` interface (extending `libraryId` as a string/number).
    - Define and export `VisitSchema` using `@warp-drive/core/reactive` `withDefaults`.
2.  **Update `app/services/store.ts`:**
    - Import `VisitSchema`.
    - Add it to the `schemas` array configuration for `useLegacyStore`.
3.  **Update `app/data/api.ts`:**
    - Create request builders for visits: `getVisits()`, `createVisit(libraryId)`, and `deleteVisit(visitId)`. These will use `withResponseType`.

### Phase 3: Component Integration (Deferred)

_Note: The user specifically asked to focus on the data/backend setup before implementing the UI. This phase is noted for completeness but will not be executed in the immediate next steps._

1.  Update the application or map route/component to request the visits upon initialization (if logged in) or upon the login event.
2.  Update `CellMap` and library list components to derive their "visited" state by observing the store's visit records.

## Verification & Testing

- Ensure `pnpm lint` and `pnpm test` pass.
- Manually test the `/api/visits` endpoint via Postman or the browser console to verify JSON:API compliance and JWT authorization.
- Verify in the browser network tab that Warp Drive correctly appends the Authorization header when making requests to `/api/visits`.

## Migration & Rollback

- **Migration:** No new database migrations are required, as the schema changes were completed in the previous step.
- **Rollback:** Revert changes to `visits.mts` and delete the new `app/data/visit.ts` files if the JSON:API approach proves overly complex.
