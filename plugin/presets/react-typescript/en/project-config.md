> **Purpose**: Project-specific configuration - Feature modules, routes, API endpoints, environment variables (SSoT for business configuration)

# Project Configuration - {{PROJECT_NAME}} Frontend

> **Principle**: Common standards go in `rules/`, project-specific information goes here.
> See [rules/architecture.md](rules/architecture.md) for architecture standards.

---

## Project Information

| Configuration | Value |
|---------------|-------|
| **Project Name** | {{PROJECT_NAME}} |
| **Project Description** | {{PROJECT_DESCRIPTION}} |
| **Architecture Pattern** | Feature-Sliced Design (FSD) |
| **Node Version** | >=18.0.0 |
| **Source Root** | `src` |

---

## Tech Stack Version Requirements

> **Tech Stack Versions**: See [rules/tech-stack.md](rules/tech-stack.md) (Single Source of Truth)
>
> For project-specific version constraints, define them in `package.json` under `engines` or `peerDependencies`.

---

## Feature Modules

> **Maintenance Note**: Update this table and the `src/features/` directory when adding new features.

| Feature | Responsibility | Core Components |
|---------|---------------|----------------|
| `auth` | User authentication and authorization | `LoginForm`, `RegisterForm`, `AuthProvider` |
| `shared` | Shared components and utilities | `Button`, `Modal`, `useApi` |
<!-- TODO: Add feature modules based on project requirements, e.g.:
| `dashboard` | Dashboard and data visualization | `DashboardLayout`, `MetricsCard` |
| `settings` | System settings | `SettingsForm`, `ProfileEditor` |
-->

---

## Route Configuration

> **Design Principle**: Route structure reflects business domains; use nested routes to organize related pages.

| Path | Page | Feature Module | Permission |
|------|------|---------------|------------|
| `/` | Home/Dashboard | `dashboard` | Login required |
| `/login` | Login page | `auth` | Public |
| `/register` | Registration page | `auth` | Public |
| `/settings` | Settings page | `settings` | Login required |
<!-- TODO: Add routes based on project requirements -->

---

## API Endpoint Configuration

> **Convention**: All API calls go under `src/shared/api/`.

| Endpoint | Purpose | Backend Module |
|----------|---------|---------------|
| `/api/v1/auth/*` | Authentication related | `auth` |
| `/api/v1/users/*` | User management | `auth` |
<!-- TODO: Add API endpoints based on project requirements -->

### API Client Configuration

```typescript
// src/shared/api/client.ts
import axios from 'axios';

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});
```

---

## Environment Variable Configuration

> **Location**: `.env.example` template, `.env.local` local configuration

| Variable Name | Description | Example Value |
|---------------|-------------|---------------|
| `VITE_API_BASE_URL` | Backend API base URL | `http://localhost:8000` |
| `VITE_APP_TITLE` | Application title | `{{PROJECT_NAME}}` |
<!-- TODO: Add environment variables based on project requirements -->
