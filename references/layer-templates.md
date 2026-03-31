# Architecture Layer Templates

Reference templates for common tech stacks. Adapt to the ACTUAL directory structure — discover via import patterns, don't force.

## Web Frontend (React / Vue / Svelte)

```
types/        → No app imports (pure definitions)
utils/        → No app imports (pure functions)
lib/          → types/ only (clients, configs)
services/     → lib/, types/ (business logic)
hooks/states/ → lib/, services/, types/ (state management)
components/   → hooks/, lib/, types/ (UI)
pages/routes/ → components/, hooks/, lib/, types/ (entry points)
```

## Backend API (Express / FastAPI / Rails)

```
types/models/ → No app imports (data definitions)
config/       → types/ only
db/repo/      → config/, types/ (data access)
services/     → db/, config/, types/ (business logic)
middleware/   → services/, config/, types/ (request processing)
routes/       → services/, middleware/, types/ (HTTP handlers)
```

## Full-Stack (Next.js / Nuxt / SvelteKit)

```
types/        → No app imports
lib/          → types/ only (shared utilities)
db/           → lib/, types/ (database)
services/     → db/, lib/, types/ (business logic)
components/   → lib/, types/ (UI primitives)
features/     → components/, services/, lib/, types/ (feature modules)
app/pages/    → features/, components/, lib/, types/ (routes)
```

## Monorepo (Turborepo / Nx)

```
packages/types/   → No internal imports
packages/config/  → types/
packages/db/      → config/, types/
packages/api/     → db/, config/, types/
packages/ui/      → types/ only
packages/web/     → ui/, api/, types/
```

## OpenAI Original Model

The canonical model from the harness engineering article:

```
Types → Config → Repo → Service → Runtime → UI
```

Each layer may only import from layers to its left.

**Providers** handle cross-cutting concerns (auth, connectors, telemetry, feature flags). Providers are the ONLY mechanism for injecting cross-cutting dependencies — direct imports across domains are disallowed. A Provider wraps an external service or shared capability and exposes it through a clean interface that any layer can consume without violating dependency direction.
