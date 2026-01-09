---
name: project-structure
description: Project organization conventions for files, modules, and directory structure
---

# Project Structure Skill

Use this skill when organizing a new project, refactoring structure, or evaluating project layout.

## General Principles

- **Discoverability**: New developers should find things where they expect them.
- **Cohesion**: Related code lives together.
- **Separation of concerns**: Different responsibilities in different modules.
- **Flat over nested**: Avoid deep directory hierarchies when possible.
- **Consistency**: Follow the same patterns throughout the project.

## Common Directory Patterns

### Source Code
```
src/           # Application source code
lib/           # Library/utility code
pkg/           # Go packages (Go convention)
internal/      # Private packages (Go convention)
```

### Tests
```
tests/         # Test files (separate from source)
__tests__/     # Jest/Vitest convention
*_test.go      # Go convention (alongside source)
*_test.py      # pytest can discover anywhere
test_*.py      # pytest prefix convention
```

### Configuration
```
config/        # Configuration files
.env           # Environment variables (git-ignored)
.env.example   # Example environment template (committed)
```

### Documentation
```
docs/          # Documentation
README.md      # Project overview
CONTRIBUTING.md # Contribution guidelines
CHANGELOG.md   # Version history
```

### Build/Output
```
build/         # Build output (git-ignored)
dist/          # Distribution files (git-ignored)
out/           # Output directory (git-ignored)
bin/           # Compiled binaries (git-ignored)
```

## Language-Specific Layouts

### Python
```
project/
├── src/
│   └── package_name/
│       ├── __init__.py
│       ├── main.py
│       ├── models/
│       ├── services/
│       └── api/
├── tests/
│   ├── conftest.py
│   ├── test_main.py
│   └── ...
├── pyproject.toml
├── requirements.txt (or requirements-dev.txt)
└── README.md
```

### TypeScript/React
```
project/
├── src/
│   ├── components/
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   ├── Button.test.tsx
│   │   │   └── index.ts
│   │   └── ...
│   ├── hooks/
│   ├── services/
│   ├── types/
│   ├── utils/
│   └── App.tsx
├── public/
├── tests/
├── package.json
├── tsconfig.json
└── README.md
```

### Go
```
project/
├── cmd/
│   └── appname/
│       └── main.go
├── internal/
│   ├── handler/
│   ├── service/
│   ├── repository/
│   └── model/
├── pkg/            # Public packages (if library)
├── api/            # API definitions (OpenAPI, protobuf)
├── go.mod
├── go.sum
└── README.md
```

## Module Organization

### By Feature (Recommended for Applications)
```
src/
├── users/
│   ├── handler.py
│   ├── service.py
│   ├── repository.py
│   └── models.py
├── orders/
│   ├── handler.py
│   ├── service.py
│   ├── repository.py
│   └── models.py
└── ...
```

### By Layer (Common but Less Scalable)
```
src/
├── handlers/
│   ├── users.py
│   └── orders.py
├── services/
│   ├── users.py
│   └── orders.py
├── repositories/
│   ├── users.py
│   └── orders.py
└── models/
    ├── user.py
    └── order.py
```

Feature-based organization scales better as the codebase grows.

## File Naming Conventions

### General
- Use lowercase with separators: `user_service.py`, `user-service.ts`
- Be descriptive: `email_validator.py` not `validator.py`
- Match the primary export: `UserService` class in `user_service.py`

### Language-Specific
- **Python**: `snake_case.py`
- **TypeScript**: `kebab-case.ts` or `PascalCase.tsx` for components
- **Go**: `lowercase.go` (no separators)

### Test Files
- **Python**: `test_*.py` or `*_test.py`
- **TypeScript**: `*.test.ts`, `*.spec.ts`
- **Go**: `*_test.go`

## Configuration Management

### Environment Variables
- Use `.env` for local development (git-ignored)
- Provide `.env.example` with dummy values (committed)
- Load with appropriate library (python-dotenv, dotenv)
- Validate required variables at startup

### Configuration Files
- Keep configuration separate from code
- Use typed configuration objects
- Validate configuration on load
- Support environment-specific overrides

## Dependency Management

### Lockfiles
Always commit lockfiles for reproducible builds:
- `package-lock.json` / `yarn.lock` / `bun.lockb`
- `poetry.lock` / `requirements.txt` (pinned)
- `go.sum`

### Virtual Environments
- Python: Use `venv` or `poetry`
- Node: Use `node_modules` (project-local by default)
- Go: Uses module cache (system-wide)

## Git Organization

### .gitignore Essentials
```gitignore
# Dependencies
node_modules/
venv/
.venv/

# Build output
build/
dist/
*.pyc
__pycache__/

# Environment
.env
.env.local

# IDE
.idea/
.vscode/
*.swp

# OS
.DS_Store
Thumbs.db
```

### Essential Root Files
```
README.md          # What is this project?
LICENSE            # How can others use it?
CONTRIBUTING.md    # How to contribute?
CHANGELOG.md       # What changed?
.gitignore         # What to exclude?
.editorconfig      # Editor settings
```
