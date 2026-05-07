## 🗂️ Estrutura de Diretórios (Clean Architecture)
[← README.md](../README.md)  
O backend do Dungeoneer foi estruturado para proteger as regras complexas do D&D, isolando o domínio de dependências externas (como o Spring Boot ou o PostgreSQL). A divisão de pacotes segue os princípios da Clean Architecture:

```text
dungeoneer/
├── backend/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── com/
│   │   │   │       └── dungeoneer/
│   │   │   │           ├── domain/                 # 🛡️ Núcleo: Entidades puras, Enums e Interfaces (Sem Spring)
│   │   │   │           ├── application/            # ⚙️ Casos de Uso: Orquestração e DTOs
│   │   │   │           ├── presentation/           # 🌐 API Web: Controllers REST, Mappers e Error Handling
│   │   │   │           ├── infrastructure/         # 🔌 Detalhes: Spring Security, Configs, Entidades JPA e DB
│   │   │   │           └── BackendApplication.java # Entrypoint do Spring Boot
│   │   │   └── resources/
│   │   │       ├── db/
│   │   │       │   └── migration/                  # Scripts de versionamento de banco (Flyway)
│   │   │       └── application.yml                 # Propriedades do sistema (DB, JWT, Server)
│   │   └── test/
│   │       └── java/
│   │           └── com/
│   │               └── dungeoneer/                 # 🧪 Suíte de testes (Unitários puros e Integração com Testcontainers)
│   └── pom.xml                                     # Dependências do Maven
│
├── docs/
│   ├── ARCHITECTURE.md                             # Detalhamento de decisões técnicas e design de software
│   └── USE-CASES.md                                # Descrição dos Atores, Fluxos e Diagramas de Uso
│
└── README.md                                       # Visão geral, Stack Tecnológica e Setup de Ambiente