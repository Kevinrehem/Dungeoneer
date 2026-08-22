---
name: NextJS UI/UX
description: UI/UX development guidelines using Next.js 16, React 19, TailwindCSS 4, and shadcn/ui.
---

# NextJS UI/UX Rules

When working on the frontend (`dungeoneer-frontend`), you **MUST** follow these core guidelines.

## 1. Design & Aesthetics

- **Premium Feel**: Always prioritize rich aesthetics, dark fantasy themes, and high-quality UI design.
- **Dynamic Interactions**: Implement subtle micro-animations (e.g., hover states, transitions) to make the interface feel responsive and alive. Do not settle for basic or generic styles.
- **Component Library**: Use `shadcn/ui` components extensively and style them using TailwindCSS.

## 2. State & Data Fetching

- **Server State**: Strictly mandate the use of **TanStack Query** for all server state and data fetching. Do not use plain `useEffect` with `fetch` for data fetching.

*See `res/state-management.md` for implementation patterns.*

## 3. Form Validation

- **Client-Side Validation**: Strictly mandate the combination of **Zod** for schema definition and **React Hook Form** for form state management.
- **Integration**: Seamlessly integrate these forms with `shadcn/ui` Form components to provide accessible error handling and validation feedback.

*See `res/form-validation.md` for reusable patterns.*

## 4. SEO & Accessibility

- **SEO Best Practices**: Ensure proper metadata, descriptive titles, and semantic HTML (e.g., `<h1>` hierarchy) are implemented across all pages.
- **Accessibility**: Ensure unique IDs and ARIA labels on interactive elements.

---

## Associated Resources

The following resources are available in the `/res/` subdirectory. Lazy-load them when you are actively working on their specific domain.

| Resource Name | Path | Description |
| --- | --- | --- |
| State Management | `res/state-management.md` | Implementation patterns for TanStack Query (queries, mutations, invalidation). |
| Form Validation | `res/form-validation.md` | Patterns for connecting Zod schemas to React Hook Form in shadcn/ui components. |
