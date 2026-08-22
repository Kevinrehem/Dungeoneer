# Data Models (PostgreSQL)

> Extracted from [SPEC.md](../SPEC.md) Section 6 — Lazy-loaded by agents working on database schema and Flyway migrations.

---

## `player_character` Schema — Core Tables

### `characters`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | `UUID` | PK, DEFAULT gen_random_uuid() | |
| `name` | `VARCHAR(100)` | NOT NULL | |
| `level` | `INT` | NOT NULL, DEFAULT 1, CHECK (1-20) | Total character level |
| `hit_points_current` | `INT` | NOT NULL | |
| `hit_points_max` | `INT` | NOT NULL | |
| `hit_points_temp` | `INT` | NOT NULL, DEFAULT 0 | |
| `armor_class` | `INT` | NOT NULL, DEFAULT 10 | |
| `initiative_bonus` | `INT` | NOT NULL, DEFAULT 0 | |
| `speed` | `INT` | NOT NULL, DEFAULT 30 | In feet |
| `proficiency_bonus` | `INT` | NOT NULL, DEFAULT 2 | |
| `ruleset` | `VARCHAR(10)` | NOT NULL, CHECK IN ('SRD_2014', 'SRD_2024') | |
| `ability_score_method` | `VARCHAR(20)` | NOT NULL | STANDARD_ARRAY, POINT_BUY, ROLLED |
| `lineage_id` | `UUID` | FK → lineages.id, NOT NULL | |
| `background_id` | `UUID` | FK → backgrounds.id, NOT NULL | |
| `user_id` | `UUID` | FK → users.id, NULLABLE | Placeholder for future auth |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT NOW() | |
| `updated_at` | `TIMESTAMPTZ` | NOT NULL, DEFAULT NOW() | |

### `ability_scores`

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | `UUID` | PK |
| `character_id` | `UUID` | FK → characters.id, UNIQUE, NOT NULL |
| `strength` | `INT` | NOT NULL, CHECK (1-30) |
| `dexterity` | `INT` | NOT NULL, CHECK (1-30) |
| `constitution` | `INT` | NOT NULL, CHECK (1-30) |
| `intelligence` | `INT` | NOT NULL, CHECK (1-30) |
| `wisdom` | `INT` | NOT NULL, CHECK (1-30) |
| `charisma` | `INT` | NOT NULL, CHECK (1-30) |

### `class_progressions`

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | `UUID` | PK |
| `character_id` | `UUID` | FK → characters.id, NOT NULL |
| `archetype_id` | `UUID` | FK → archetypes.id, NOT NULL |
| `subclass_id` | `UUID` | FK → subclasses.id, NULLABLE |
| `class_level` | `INT` | NOT NULL, CHECK (1-20) |
| UNIQUE | | (`character_id`, `archetype_id`) |

### `character_spells`

| Column | Type | Constraints |
|--------|------|-------------|
| `character_id` | `UUID` | FK → characters.id |
| `spell_id` | `UUID` | FK → spells.id |
| `is_prepared` | `BOOLEAN` | NOT NULL, DEFAULT false |
| PK | | (`character_id`, `spell_id`) |

### `character_items`

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | `UUID` | PK |
| `character_id` | `UUID` | FK → characters.id, NOT NULL |
| `item_id` | `UUID` | FK → items.id, NOT NULL |
| `quantity` | `INT` | NOT NULL, DEFAULT 1 |
| `is_equipped` | `BOOLEAN` | NOT NULL, DEFAULT false |
| `is_attuned` | `BOOLEAN` | NOT NULL, DEFAULT false |

### `character_feats`

| Column | Type | Constraints |
|--------|------|-------------|
| `character_id` | `UUID` | FK → characters.id |
| `feat_id` | `UUID` | FK → feats.id |
| `source` | `VARCHAR(20)` | NOT NULL (CLASS, LINEAGE, BACKGROUND, ITEM, LEVEL_UP) |
| PK | | (`character_id`, `feat_id`) |

### `character_conditions`

| Column | Type | Constraints |
|--------|------|-------------|
| `character_id` | `UUID` | FK → characters.id |
| `condition_name` | `VARCHAR(50)` | NOT NULL |
| `is_active` | `BOOLEAN` | NOT NULL, DEFAULT true |
| PK | | (`character_id`, `condition_name`) |

---

## `player_character` Schema — Reference Data Tables

### `archetypes` (Classes)

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | `UUID` | PK |
| `name` | `VARCHAR(50)` | NOT NULL, UNIQUE |
| `hit_dice` | `VARCHAR(3)` | NOT NULL (D6, D8, D10, D12) |
| `primary_ability` | `VARCHAR(15)` | NOT NULL |
| `saving_throw_proficiencies` | `VARCHAR[]` | NOT NULL |
| `armor_proficiencies` | `VARCHAR[]` | |
| `weapon_proficiencies` | `VARCHAR[]` | |
| `spellcasting_type` | `VARCHAR(15)` | FULL, HALF, THIRD, PACT, NONE |
| `spellcasting_ability` | `VARCHAR(15)` | NULLABLE |
| `ruleset` | `VARCHAR(10)` | NOT NULL |
| `source` | `VARCHAR(10)` | NOT NULL, DEFAULT 'SRD' |
| `owner_id` | `UUID` | NULLABLE (for homebrew) |

### `subclasses`

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | `UUID` | PK |
| `name` | `VARCHAR(100)` | NOT NULL |
| `description` | `TEXT` | |
| `archetype_id` | `UUID` | FK → archetypes.id, NOT NULL |
| `subclass_level` | `INT` | NOT NULL (level when subclass is chosen) |
| `spellcasting_type` | `VARCHAR(15)` | NULLABLE (overrides archetype if set) |
| `ruleset` | `VARCHAR(10)` | NOT NULL |
| `source` | `VARCHAR(10)` | NOT NULL, DEFAULT 'SRD' |
| `owner_id` | `UUID` | NULLABLE |

### `spells`

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | `UUID` | PK |
| `name` | `VARCHAR(100)` | NOT NULL |
| `level` | `INT` | NOT NULL, CHECK (0-9) |
| `school` | `VARCHAR(20)` | NOT NULL |
| `casting_time` | `VARCHAR(50)` | NOT NULL |
| `range` | `VARCHAR(50)` | NOT NULL |
| `duration` | `VARCHAR(50)` | NOT NULL |
| `components` | `VARCHAR[]` | NOT NULL (V, S, M) |
| `material_description` | `TEXT` | NULLABLE |
| `description` | `TEXT` | NOT NULL |
| `higher_levels` | `TEXT` | NULLABLE |
| `is_ritual` | `BOOLEAN` | NOT NULL, DEFAULT false |
| `is_concentration` | `BOOLEAN` | NOT NULL, DEFAULT false |
| `ruleset` | `VARCHAR(10)` | NOT NULL |
| `source` | `VARCHAR(10)` | NOT NULL, DEFAULT 'SRD' |
| `owner_id` | `UUID` | NULLABLE |

### `spell_classes` (many-to-many: which classes can learn which spells)

| Column | Type | Constraints |
|--------|------|-------------|
| `spell_id` | `UUID` | FK → spells.id |
| `archetype_id` | `UUID` | FK → archetypes.id |
| PK | | (`spell_id`, `archetype_id`) |

### `feats`

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | `UUID` | PK |
| `name` | `VARCHAR(100)` | NOT NULL |
| `description` | `TEXT` | NOT NULL |
| `prerequisite` | `TEXT` | NULLABLE |
| `ruleset` | `VARCHAR(10)` | NOT NULL |
| `source` | `VARCHAR(10)` | NOT NULL, DEFAULT 'SRD' |
| `owner_id` | `UUID` | NULLABLE |

### `lineages`

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | `UUID` | PK |
| `name` | `VARCHAR(50)` | NOT NULL |
| `description` | `TEXT` | |
| `speed` | `INT` | NOT NULL, DEFAULT 30 |
| `size` | `VARCHAR(10)` | NOT NULL |
| `ruleset` | `VARCHAR(10)` | NOT NULL |
| `source` | `VARCHAR(10)` | NOT NULL, DEFAULT 'SRD' |
| `owner_id` | `UUID` | NULLABLE |

### `lineage_feats`

| Column | Type | Constraints |
|--------|------|-------------|
| `lineage_id` | `UUID` | FK → lineages.id |
| `feat_id` | `UUID` | FK → feats.id |
| PK | | (`lineage_id`, `feat_id`) |

### `backgrounds`

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | `UUID` | PK |
| `name` | `VARCHAR(50)` | NOT NULL |
| `description` | `TEXT` | |
| `skill_proficiencies` | `VARCHAR[]` | NOT NULL |
| `tool_proficiencies` | `VARCHAR[]` | |
| `languages` | `VARCHAR[]` | |
| `ruleset` | `VARCHAR(10)` | NOT NULL |
| `source` | `VARCHAR(10)` | NOT NULL, DEFAULT 'SRD' |
| `owner_id` | `UUID` | NULLABLE |

### `items`

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | `UUID` | PK |
| `name` | `VARCHAR(100)` | NOT NULL |
| `description` | `TEXT` | |
| `weight` | `DECIMAL(6,2)` | NOT NULL, DEFAULT 0 |
| `item_type` | `VARCHAR(20)` | NOT NULL (WEAPON, ARMOR, POTION, WONDROUS, etc.) |
| `rarity` | `VARCHAR(15)` | COMMON, UNCOMMON, RARE, VERY_RARE, LEGENDARY |
| `requires_attunement` | `BOOLEAN` | NOT NULL, DEFAULT false |
| `ruleset` | `VARCHAR(10)` | NOT NULL |
| `source` | `VARCHAR(10)` | NOT NULL, DEFAULT 'SRD' |
| `owner_id` | `UUID` | NULLABLE |
