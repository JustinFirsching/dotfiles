---
name: python
description: Python coding conventions, type hints, and FastAPI patterns
---

# Python Skill

Use this skill when working with Python code.

## Required Practices

These rules must always be followed:

### No Mutable Default Arguments
```python
# Bad - mutable default is shared between calls
def add_item(item, items=[]):
    items.append(item)
    return items

# Good - use None and create new list
def add_item(item, items=None):
    if items is None:
        items = []
    items.append(item)
    return items
```

### No Wildcard Imports
```python
# Bad - pollutes namespace, unclear origins
from os import *
from utils import *

# Good - explicit imports
from os import path, getcwd
from utils import validate_email, format_date
```

### Use logging, Not print
```python
# Bad - print statements for logging
print(f"Processing user {user_id}")
print(f"Error: {e}")

# Good - use logging module
import logging

logger = logging.getLogger(__name__)
logger.info("Processing user %s", user_id)
logger.exception("Failed to process user")
```

### No global Keyword
```python
# Bad - global state is hard to test and reason about
counter = 0

def increment():
    global counter
    counter += 1

# Good - use classes or pass state explicitly
class Counter:
    def __init__(self):
        self.value = 0

    def increment(self):
        self.value += 1

# Or use a closure/module-level singleton if truly needed
```

### Always Use Type Hints for Function Signatures
```python
# Bad - no type information
def get_user(user_id):
    ...

def process_items(items):
    ...

# Good - full type hints
def get_user(user_id: int) -> User | None:
    ...

def process_items(items: list[Item]) -> ProcessingResult:
    ...

# Also good - complex types with TypeAlias
from typing import TypeAlias

UserId: TypeAlias = int
UserMap: TypeAlias = dict[UserId, User]

def get_users(ids: list[UserId]) -> UserMap:
    ...
```

## Type Hint Patterns

### Basic Types
```python
def greet(name: str) -> str:
    return f"Hello, {name}"

def calculate(x: int, y: float) -> float:
    return x * y

def is_valid(value: str) -> bool:
    return len(value) > 0
```

### Optional and Union
```python
from typing import Optional

# Python 3.10+ union syntax
def find_user(user_id: int) -> User | None:
    ...

# Optional is equivalent to X | None
def find_user(user_id: int) -> Optional[User]:
    ...
```

### Collections
```python
# Python 3.9+ built-in generics
def process(items: list[str]) -> dict[str, int]:
    ...

def get_unique(values: set[int]) -> frozenset[int]:
    ...
```

### Callables
```python
from typing import Callable

def apply(func: Callable[[int, int], int], a: int, b: int) -> int:
    return func(a, b)

# With default
def process(callback: Callable[[str], None] | None = None) -> None:
    ...
```

## Error Handling

### Use Specific Exceptions
```python
# Bad - bare except
try:
    process()
except:
    pass

# Bad - catching Exception broadly
try:
    process()
except Exception:
    logger.error("Something went wrong")

# Good - catch specific exceptions
try:
    result = parse_json(data)
except json.JSONDecodeError as e:
    logger.warning("Invalid JSON: %s", e)
    raise ValidationError("Invalid input format") from e
```

### Custom Exceptions
```python
class AppError(Exception):
    """Base exception for application errors."""
    pass

class NotFoundError(AppError):
    """Resource not found."""
    pass

class ValidationError(AppError):
    """Input validation failed."""
    def __init__(self, message: str, field: str | None = None):
        super().__init__(message)
        self.field = field
```

## FastAPI Patterns

### Route Organization
```python
from fastapi import APIRouter, Depends, HTTPException, status

router = APIRouter(prefix="/users", tags=["users"])

@router.get("/", response_model=list[UserResponse])
async def list_users(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
) -> list[UserResponse]:
    return await user_service.list_users(db, skip=skip, limit=limit)

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: int,
    db: Session = Depends(get_db),
) -> UserResponse:
    user = await user_service.get_user(db, user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    return user
```

### Pydantic Models
```python
from pydantic import BaseModel, EmailStr, Field

class UserCreate(BaseModel):
    email: EmailStr
    name: str = Field(..., min_length=1, max_length=100)
    age: int = Field(..., ge=0, le=150)

class UserResponse(BaseModel):
    id: int
    email: str
    name: str
    created_at: datetime

    model_config = {"from_attributes": True}
```

### Dependency Injection
```python
from fastapi import Depends

async def get_db() -> AsyncGenerator[Session, None]:
    async with async_session() as session:
        yield session

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
) -> User:
    user = await verify_token(token, db)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    return user

@router.get("/me")
async def get_me(user: User = Depends(get_current_user)) -> UserResponse:
    return user
```

### Error Handling
```python
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

app = FastAPI()

@app.exception_handler(ValidationError)
async def validation_error_handler(
    request: Request,
    exc: ValidationError,
) -> JSONResponse:
    return JSONResponse(
        status_code=422,
        content={
            "error": {
                "code": "VALIDATION_ERROR",
                "message": str(exc),
                "field": exc.field,
            }
        },
    )

@app.exception_handler(NotFoundError)
async def not_found_handler(
    request: Request,
    exc: NotFoundError,
) -> JSONResponse:
    return JSONResponse(
        status_code=404,
        content={
            "error": {
                "code": "NOT_FOUND",
                "message": str(exc),
            }
        },
    )
```

## Style Reference

For additional Python conventions, refer to:
- Google Python Style Guide: https://google.github.io/styleguide/pyguide.html
- PEP 8: https://peps.python.org/pep-0008/
- PEP 484 (Type Hints): https://peps.python.org/pep-0484/

## Async Patterns

FastAPI is async-first. Follow these patterns:

### Use Async for I/O-Bound Operations
```python
# Bad - blocking call in async context
@router.get("/users/{id}")
async def get_user(id: int):
    return sync_db_call(id)  # Blocks the event loop!

# Good - use async database calls
@router.get("/users/{id}")
async def get_user(id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.id == id))
    return result.scalar_one_or_none()
```

### Run Sync Code in Thread Pool
```python
from fastapi.concurrency import run_in_threadpool

@router.get("/legacy")
async def call_legacy():
    # Offload blocking operation to thread pool
    result = await run_in_threadpool(blocking_legacy_function, arg1, arg2)
    return result
```

### Async Context Managers
```python
from contextlib import asynccontextmanager

@asynccontextmanager
async def get_db_session():
    session = AsyncSession(engine)
    try:
        yield session
        await session.commit()
    except Exception:
        await session.rollback()
        raise
    finally:
        await session.close()
```

## Settings with Pydantic

Use pydantic-settings for configuration:

```python
from pydantic_settings import BaseSettings
from pydantic import Field

class Settings(BaseSettings):
    # Required settings (no default)
    database_url: str
    secret_key: str
    
    # Optional with defaults
    debug: bool = False
    api_prefix: str = "/api/v1"
    
    # With validation
    max_connections: int = Field(default=10, ge=1, le=100)
    
    model_config = {
        "env_file": ".env",
        "env_file_encoding": "utf-8",
    }

# Singleton pattern
_settings: Settings | None = None

def get_settings() -> Settings:
    global _settings
    if _settings is None:
        _settings = Settings()  # Validates at startup
    return _settings
```

## Background Tasks

Use FastAPI's background tasks for fire-and-forget operations:

```python
from fastapi import BackgroundTasks

async def send_welcome_email(email: str):
    # This runs after the response is sent
    await email_service.send(email, template="welcome")

@router.post("/users", status_code=201)
async def create_user(
    user: UserCreate,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
):
    new_user = await user_service.create(db, user)
    
    # Queue background task - doesn't block response
    background_tasks.add_task(send_welcome_email, new_user.email)
    
    return new_user
```

For long-running jobs, use a task queue (Celery, arq, etc.) instead.

## Context Managers

Always use context managers for resource management:

```python
# Files
with open("data.txt") as f:
    content = f.read()

# Database connections
async with async_session() as session:
    result = await session.execute(query)

# Locks
async with asyncio.Lock():
    await modify_shared_resource()

# HTTP clients
async with httpx.AsyncClient() as client:
    response = await client.get(url)
```

## Dataclasses vs Pydantic

Choose based on use case:

```python
from dataclasses import dataclass
from pydantic import BaseModel

# Pydantic: API boundaries (validates external data)
class UserCreate(BaseModel):
    email: EmailStr
    name: str = Field(..., min_length=1)

# Dataclass: Internal domain models (no validation overhead)
@dataclass
class User:
    id: int
    email: str
    name: str
    created_at: datetime
```

Guidelines:
- **Pydantic**: Request/response models, config, any external input
- **Dataclass**: Internal data structures, domain models, DTOs between layers
