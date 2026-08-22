# Testing Boundaries

To ensure fast feedback loops and true isolation, adhere to these testing setups based on the architectural layer. Remember the **TDD method**: Write failing test, pass it, then refactor, with manual commits in between.

## 1. Domain & Application Layers (NO Spring Context)

Tests for domain entities and application services (Use Cases) must run instantaneously. Do NOT use `@SpringBootTest` or any Spring-related annotations. Use plain JUnit 5 and Mockito.

```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
class CharacterServiceTest {

    @Mock
    private SaveCharacterPort saveCharacterPort;

    @InjectMocks
    private CharacterService characterService;

    @Test
    void shouldCreateCharacterSuccessfully() {
        // ... Given, When, Then
    }
}
```

## 2. Persistence Adapters (Sliced Context)

When testing JPA repositories and mappers, only load the persistence slice. Do NOT load the full application context.

```java
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;

@DataJpaTest // Only loads JPA components
class CharacterRepositoryAdapterTest {

    @Autowired
    private SpringDataCharacterRepository repository;

    @Test
    void shouldSaveAndFindCharacter() {
        // ... Given, When, Then
    }
}
```

## 3. Web Adapters (Sliced Context)

When testing REST controllers, use `@WebMvcTest` to only load the web layer, mocking the Use Case interfaces.

```java
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(CharacterController.class)
class CharacterControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private CreateCharacterUseCase createCharacterUseCase;

    @Test
    void shouldReturn201OnCreation() throws Exception {
        // ... Given, When, Then
    }
}
```
