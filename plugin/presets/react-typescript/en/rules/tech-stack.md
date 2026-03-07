> **Purpose**: Single Source of Truth for tech stack versions

# Frontend Tech Stack

## Core Dependencies

| Technology | Version |
|-----------|---------|
| React | 19+ |
| TypeScript | 5+ |
| Vite | 5+ |
| TailwindCSS | 4+ |
| TanStack Query | 5+ |
| Zustand | 4+ |
| React Hook Form | 7+ |
| Zod | 3+ |

## Testing Tools

| Technology | Version |
|-----------|---------|
| Vitest | 1+ |
| Testing Library | 14+ |
| MSW | 2+ |
| Playwright | 1+ |

## Development Tools

pnpm | ESLint | Prettier

## Optional (Add as Needed)

react-window | web-vitals | rollup-plugin-visualizer

## Prohibited

| Prohibited | Replacement |
|-----------|-------------|
| Redux, MobX | Zustand |
| lodash (full bundle) | lodash-es |

## Upgrade Strategy

- **Major versions** (React, TS, Vite): Team review required
- **Minor/Patch versions**: Self-service upgrade + testing
