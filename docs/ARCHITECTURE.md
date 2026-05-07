## 🗂️ Estrutura de Diretórios (Clean Architecture)
[← README.md](../README.md)  
O backend do Dungeoneer foi estruturado para proteger as regras complexas do D&D, isolando o domínio de dependências externas (como o Spring Boot ou o PostgreSQL). A divisão de pacotes segue os princípios da Clean Architecture:

```text
└───dungeoneer
    │   BackendApplication.java
    │
    ├───campaign
    ├───core
    │   ├───config
    │   │       DatabaseConfig.java
    │   │       SecurityConfig.java
    │   │
    │   └───exception
    └───playerCharacter
        ├───adapter
        │   ├───in
        │   │   └───web
        │   │       ├───controller
        │   │       │       PlayerCharacterController.java
        │   │       │
        │   │       └───mapper
        │   │               PlayerCharacterWebMapper.java
        │   │
        │   └───out
        │       ├───config
        │       │       PlayerCharacterUseCaseConfig.java
        │       │
        │       └───persistence
        │           ├───adapter
        │           │       PlayerCharacterRepositoryImpl.java
        │           │
        │           ├───entity
        │           │       PlayerCharacterJpaEntity.java
        │           │
        │           └───springdata
        │                   SpringDataPlayerCharacterRepo.java
        │
        ├───application
        │   ├───dto
        │   │       CreatePlayerCharacterDTO.java
        │   │
        │   ├───port
        │   │   ├───in
        │   │   │       CreatePlayerCharacterUseCase.java
        │   │   │
        │   │   └───out
        │   │           CharacterRepositoryPort.java
        │   │
        │   └───service
        │           CreatePlayerCharacterService.java
        │
        └───domain
            └───model
                    AbilityScores.java
                    Archetype.java
                    Background.java
                    ClassProgression.java
                    Feat.java
                    Lineage.java
                    PlayerCharacter.java
                    Spell.java
                    SpellcastingStrategy.java
                    Subclass.java
