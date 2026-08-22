# Mapping Guidelines

To preserve Clean Architecture, we strictly use manual mapping for conversions between JPA Entities, Domain Entities, and DTOs. Do **not** use MapStruct.

## 1. Domain to JPA Entity (Persistence Adapter)

Create static factory methods (`fromDomain`) on the JPA Entity, or use a dedicated Mapper class in the `adapter/out/persistence` package.

```java
// adapter/out/persistence/CharacterJpaEntity.java
@Entity
@Table(name = "characters")
public class CharacterJpaEntity {
    @Id
    private UUID id;
    private String name;
    
    // ... JPA mappings

    public static CharacterJpaEntity fromDomain(Character character) {
        CharacterJpaEntity entity = new CharacterJpaEntity();
        entity.setId(character.getId());
        entity.setName(character.getName());
        return entity;
    }

    public Character toDomain() {
        return new Character(this.id, this.name);
    }
}
```

## 2. Domain to DTO (Web Adapter)

Similarly, keep the conversion logic in the `adapter/in/web` or `application/dto` packages. The `domain` package must know nothing about DTOs.

```java
// application/dto/CharacterResponseDto.java
public record CharacterResponseDto(UUID id, String name) {
    public static CharacterResponseDto fromDomain(Character character) {
        return new CharacterResponseDto(character.getId(), character.getName());
    }
}
```

## 3. Command to Domain (Use Cases)

When receiving data (e.g., creating a character), pass a Command object to the Use Case, which then constructs the Domain entity.

```java
// application/port/in/CreateCharacterCommand.java
public record CreateCharacterCommand(String name) {
    public Character toDomain() {
        return new Character(UUID.randomUUID(), this.name);
    }
}
```
