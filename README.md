# Dungeoneer 🐉
#### DnD Campaign and Character Sheet Manager

O Dungeoneer é uma aplicação unificada para gerenciamento de campanhas, NPCs e fichas de personagens de Dungeons & Dragons. Este projeto foi concebido utilizando os princípios da Clean Architecture, priorizando um design de software que seja flexível, coeso e fácil de manter a longo prazo.

## 🛠️ Tecnologias Utilizadas
A stack tecnológica foi escolhida para garantir robustez no backend e uma interface moderna e tipada no frontend:
- **Backend**: Java com Spring Boot.
- **Frontend**: Next.js com TypeScript e componentes shadcn/ui.
- **Banco de Dados**: PostgreSQL.
- **Comunicação**: API REST (HTTP) para tráfego de dados isolados e padronizados entre o cliente e o servidor.
- **Infraestrutura**: Docker para conteinerização de todos os serviços, garantindo que o ambiente de desenvolvimento seja idêntico ao de produção.

## 🏛️ Decisões Arquiteturais

### 1. Monolito Modular Preparado para o Futuro  

Atualmente, o sistema foi desenhado como um Monolito. No entanto, devido à forte separação de conceitos da Clean Architecture, as fronteiras entre os módulos do sistema (como a gestão de usuários, fichas de personagens e rolagem de dados) são bem definidas. Uma boa arquitetura permite que um sistema nasça como um monolito, mas cresça até se tornar um conjunto de microsserviços independentes quando a necessidade de escalabilidade surgir

### 2. Design Orientado a Objetos e Padrões de Projeto  

O núcleo do sistema (as Entidades do D&D) foi modelado para proteger as regras de negócio:

1. **Composição sobre Herança**: Em vez de criar uma hierarquia rígida de classes para representar capacidades dos personagens (Feats), utilizamos o Padrão Strategy através de uma interface genérica Feat. Isso permite atribuir habilidades de raças, classes e antecedentes dinamicamente, mantendo o sistema extensível e alinhado aos princípios de design de software.

2. **Padrão Builder**: A entidade Spell (Magia) 
possui dezenas de atributos opcionais (como tipos de dano, condições, componentes verbais/somáticos). O padrão Builder foi adotado para simplificar a instanciação desses objetos complexos sem poluir a classe com construtores gigantes.

3. **Segregação de Interfaces (ISP)**: A lógica de uso de magias foi extraída para uma interface SpellcastingStrategy (FullCaster, HalfCaster, NonCaster). Isso garante que personagens puramente marciais não herdem código inútil de pontos de magia, mantendo as classes coesas.

4. **Inversão de Dependências (DIP)**: Para lidar com magias de área e alvo único de forma limpa, extraímos o conceito de alvo para uma interface Target (AreaTarget, SingleTarget), permitindo que a magia afete o jogo sem precisar saber como o alvo é calculado.

---
## 📊 Diagramas
### Diagrama Entidade-Relacionamento (Conceitual)

Visão de alto nível sobre como os dados se relacionam no banco de dados:
```mermaid
erDiagram
    %% cada note pertence a apenas uma campanha (||), campanha pode ter n notes (o{)
    CAMPAIGN ||--o{ NOTES : "contém" 
    
    %% 1 Npc em 0 ou N campanhas (}o), campanhas podem ter 0 ou n npcs (o{)
    CAMPAIGN }o--o{ NPC : "contém" 
    
    %% 1 PLAYER_CHARACTER em 0 ou N campanhas (}o), campanhas podem ter 0 ou n PLAYER_CHARACTERs (o{)
    CAMPAIGN }o--o{ PLAYER_CHARACTER : "contém" 
    
    %% 0 OU N ITENS EM 0 OU N PERSONAGENS
    PLAYER_CHARACTER }o--o{ ITEM : "possui" 
    
    %% 1 BACKGROUND POR PERSONAGEM (||), um background pode pertencer a 0 ou N personagens (}o)
    PLAYER_CHARACTER }o--|| BACKGROUND : "tem" 
    
    %% 1 OU N ARQUETIPOS POR PERSONAGEM (|{), 1 arquetipo pode ser seguido por 0 ou N personagens (}o)
    PLAYER_CHARACTER }o--|{ ARCHETYPE : "segue" 
    
    %% 0 OU N POR PERSONAGEM (Assumindo que o ataque instanciado pertence só a ele)
    PLAYER_CHARACTER ||--o{ ATTACKS : "possui" 
    
    %% 0 OU N 
    PLAYER_CHARACTER ||--o{ CONDITIONS : "sofre" 
    
    %% 0 OU N
    NPC ||--o{ ATTACKS : "possui" 
    
    %% 0 OU N
    NPC ||--o{ CONDITIONS : "sofre" 
    
    %% Nem todo arquetipo tem spell (o{), todo spell tem um ou mais arquetipos ao qual pertence (}|)
    ARCHETYPE }|--o{ SPELL : "tem acesso" 
    
    %% Todo arquetipo precisa de pelo menos uma feat (|{), nem toda feat será de um arquétipo (}o)
    ARCHETYPE }o--|{ FEAT : "habilita" 
    
    %% CADA ARQUETIPO TEM 1 OU N SUBCLASSES (|{), TODA SUBCLASSE É DE APENAS UM ARQUETIPO (||)
    ARCHETYPE ||--|{ SUBCLASS : "especializa em" 
    
    %% 1 PERSONAGEM PODE TER 0 OU N SPELLS (o{), UM SPELL PODE SER CONHECIDO POR 0 OU N PERSONAGENS (}o)
    SPELL }o--o{ PLAYER_CHARACTER : "conhece" 
    
    %% 1 lineage pode ser de vários PLAYER_CHARACTERs (o{), 1 PLAYER_CHARACTER tem exatamente 1 lineage (||)
    LINEAGE ||--o{ PLAYER_CHARACTER : "define"

    %% TODA LINEAGE TEM FEAT (|{), NEM TODA FEAT É DE LINEAGE (}o)
    LINEAGE }o--|{ FEAT : "concede"
```

### Diagrama de Classes (Core Domain)

Estrutura das Entidades focada nas regras de negócio e na progressão da Ficha do Jogador (PlayerCharacter):

```mermaid
classDiagram
    class PlayerCharacter {
        -String name
        -int level
        -int hitPoints
        -Map~String, int~ abilityScores
        -Set~ClassProgression~ progressions
        -List~Item~ inventory
        -Background background
        -Lineage lineage
        -List~Condition~ conditions
        -List~Feat~ activeFeats
    }

    class ClassProgression {
        -Archetype archetype
        -Subclass subclass
        -int level
    }

    class Archetype {
        -String name
        -HitDiceEnum hitDice
        -List~Feat~ classFeats
        -List~Subclass~ availableSubclasses
        -SpellcastingStrategy castingStrategy
    }

    class Subclass {
        -String name
        -String description
        -List~Feat~ subclassFeats
        -SpellcastingStrategy castingStrategy
    }

    class HitDiceEnum {
        <<enumeration>>
        D6
        D8
        D10
        D12
    }

    class Feat {
        <<interface>>
        +getName() String
        +getDescription() String
        +apply(PlayerCharacter pc) void
    }

    class Item {
        <<interface>>
        +getName() String
        +getWeight() float
        +use(PlayerCharacter pc) void
    }

    class Spell {
        <<interface>>
        +getName() String
        +getLevel() int
        +getComponents() List~String~
        +getDamageDice() String
        +getDamageType() String
        +getConditionsCaused() List~Condition~
        +cast(PlayerCharacter caster, Target target) void
    }

    class Target {
        <<interface>>
        +applyEffect(Spell spell) void
    }

    class SingleTarget {
        -PlayerCharacter target
        +applyEffect(Spell spell) void
    }

    class AreaTarget {
        -String shape
        -int size
        -List~PlayerCharacter~ affectedTargets
        +applyEffect(Spell spell) void
    }

    class SpellBuilder {
        -String name
        -int level
        -List~String~ components
        -String damageDice
        -String damageType
        -List~Condition~ conditionsCaused
        +setName(String name) SpellBuilder
        +setDamage(String dice, String type) SpellBuilder
        +addCondition(Condition cond) SpellBuilder
        +build() Spell
    }

    class SpellcastingStrategy {
        <<interface>>
        +getSpellSlots(int level) int
        +getSpellsKnown() List~Spell~
        +learnSpell(Spell spell) void
    }

    class FullCaster {
        -List~Spell~ spellsKnown
        -Map~int, int~ spellSlots
    }

    class HalfCaster {
        -List~Spell~ spellsKnown
        -Map~int, int~ spellSlots
    }

    class NonCaster {
    }

    class Lineage {
        -String name
        -String description
        -int baseSpeed
        -List~Feat~ grantedFeats
    }

    class Background {
        -String name
        -String description
        -List~Feat~ backgroundFeats
    }

    class Condition {
        -String name
        -String description
        -boolean isActive
    }

    %% Spellcasting Strategy Relationships
    SpellcastingStrategy <|.. FullCaster : implements
    SpellcastingStrategy <|.. HalfCaster : implements
    SpellcastingStrategy <|.. NonCaster : implements
    Archetype "1" o-- "1" SpellcastingStrategy : castingStrategy
    Subclass "1" o-- "0..1" SpellcastingStrategy : castingStrategy

    %% Spell, Builder, and Target Relationships
    SpellBuilder ..> Spell : creates
    Spell ..> Target : affects
    Target <|.. SingleTarget : implements
    Target <|.. AreaTarget : implements
    FullCaster "1" o-- "*" Spell : spellsKnown
    HalfCaster "1" o-- "*" Spell : spellsKnown

    %% Relacionamentos Principais
    PlayerCharacter "1" *-- "*" ClassProgression : progressions
    ClassProgression "1" --> "1" Archetype : archetype
    ClassProgression "1" --> "0..1" Subclass : subclass
    Archetype "1" *-- "*" Subclass : availableSubclasses
    Archetype ..> HitDiceEnum : uses

    %% Composições com o PlayerCharacter
    PlayerCharacter "1" o-- "*" Item : inventory
    PlayerCharacter "1" o-- "1" Background : background
    PlayerCharacter "1" o-- "1" Lineage : lineage
    PlayerCharacter "1" o-- "*" Condition : conditions
    PlayerCharacter "1" o-- "*" Feat : activeFeats

    %% Fornecimento de Feats
    Lineage "1" o-- "*" Feat : grantedFeats
    Background "1" o-- "*" Feat : backgroundFeats
    Archetype "1" o-- "*" Feat : classFeats
    Subclass "1" o-- "*" Feat : subclassFeats
```
