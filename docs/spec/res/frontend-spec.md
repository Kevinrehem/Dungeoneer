# Frontend Specification

> Extracted from [SPEC.md](../SPEC.md) Sections 5.4 — Lazy-loaded by agents working on the Next.js frontend.

---

## Tech Stack

- Next.js 16 (App Router)
- React 19
- TypeScript 5
- TailwindCSS 4
- shadcn/ui + Radix UI primitives
- TanStack Query (React Query) for data fetching
- Lucide React (icons)
- next-themes (dark/light mode)

---

## Pages (Phase 1)

| Route | Description |
|-------|-------------|
| `/` | Landing page (existing) |
| `/characters` | Character list (grid/table view) |
| `/characters/new` | Character creation wizard (multi-step) |
| `/characters/[id]` | Character sheet dashboard (card-based) |
| `/characters/[id]/edit` | Edit character details |
| `/characters/[id]/level-up` | Level-up flow |
| `/spells` | Spell search & filter page |

---

## Design Language

### Theme: Dark Fantasy RPG

| Token | Value | Usage |
|-------|-------|-------|
| Background (base) | `#0f0f1a` range | Page backgrounds |
| Background (card) | Parchment-toned with subtle texture | Card surfaces |
| Accent (primary) | Warm gold/amber `hsl(40, 90%, 55%)` range | Buttons, links, highlights |
| Accent (danger) | Crimson | HP loss, delete actions |
| Accent (success) | Emerald | HP gain, level-up confirmations |

### Typography

| Role | Font | Weight |
|------|------|--------|
| Headings (h1-h3) | Cinzel | 700 (bold) |
| Body text | Inter | 400 (regular), 500 (medium) |
| Monospace / stats | JetBrains Mono | 400 |

### Micro-Animations

- **Dice roll**: 3D tumbling animation on click (client-side, CSS + JS)
- **Card hover**: Subtle lift + border glow
- **HP bar**: Smooth transition on value change
- **Level-up**: Celebratory particle burst
- **Page transitions**: Fade-in with slight upward slide

---

## Character Creation Wizard

Multi-step stepper flow:

| Step | Title | Content |
|------|-------|---------|
| 1 | **Name & Ruleset** | Character name input, ruleset selector (5e 2014 / 2024) |
| 2 | **Lineage** | Lineage/Race picker (filtered by ruleset), preview granted feats |
| 3 | **Class** | Class picker, hit dice preview, spellcasting type indicator |
| 4 | **Background** | Background picker (filtered by ruleset), preview skills/feats |
| 5 | **Ability Scores** | Method selector (Standard Array / Point Buy / Roll). Score assignment UI with modifier preview |
| 6 | **Review & Create** | Full character summary, confirm and create |

### Ability Score Generation Methods

| Method | UI |
|--------|----|
| Standard Array | Drag-and-drop 15, 14, 13, 12, 10, 8 to ability slots |
| Point Buy | +/- buttons per ability, running point budget counter (27 max) |
| Rolled | Server-validated 4d6-drop-lowest. "Roll" button generates 6 values, user assigns them |

---

## Character Sheet Dashboard

Card-based layout with a responsive grid (3 columns desktop, 2 tablet, 1 mobile).

### Cards

| Card | Content | Interactive? |
|------|---------|-------------|
| **Core Stats** | Name, level, class(es), lineage, HP bar (current/max/temp), AC, initiative, proficiency bonus, speed | Click HP to adjust, toggle conditions |
| **Ability Scores** | 6 stats in 2×3 grid. Score + modifier + saving throw proficiency dot | Click to roll ability check |
| **Actions & Attacks** | Weapon attacks and cantrips. To-hit bonus, damage formula | Click to roll attack/damage |
| **Spellcasting** | Spell slot tracker (pip-style), spell list by level, prepared/known filter | Click slots to use/recover, click spell to roll |
| **Inventory** | Item list, weight tracker, attunement slots (3 max) | Equip/unequip, add/remove items |
| **Features & Feats** | Active feats grouped by source (class, lineage, background, item) | Collapsible sections |
| **Skills** | All 18 skills, proficiency/expertise dots, total modifier | Click to roll skill check |
| **Notes** | Free-form text: backstory, personality traits, ideals, bonds, flaws | Editable text areas |

### Card Behavior

- Cards are **collapsible/expandable** (persist state in localStorage)
- Cards are potentially **reorderable** via drag-and-drop (future enhancement)
- A martial character might collapse Spellcasting; a wizard might collapse Attacks

---

## Data Fetching

- **TanStack Query** for all server state (characters, spells, reference data)
- Query keys namespaced: `['characters']`, `['characters', id]`, `['spells', filters]`
- Optimistic updates for HP changes, spell slot usage
- Stale time: 5 minutes for reference data, 30 seconds for character data
- Error handling: Toast notifications via shadcn/ui `Sonner` or similar

---

## Responsive Breakpoints

| Breakpoint | Layout |
|-----------|--------|
| `≥1280px` (xl) | 3-column card grid, full sidebar |
| `≥768px` (md) | 2-column card grid, collapsed sidebar |
| `<768px` (sm) | Single-column stack, bottom nav |
