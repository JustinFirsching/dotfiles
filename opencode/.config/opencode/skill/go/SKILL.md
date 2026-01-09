---
name: go
description: Go idioms, error handling, and API patterns
---

# Go Skill

Use this skill when working with Go code.

## Core Principles

Go emphasizes simplicity, readability, and explicit error handling. Follow these idioms:

- **Explicit over implicit**: No hidden control flow or magic.
- **Accept interfaces, return structs**: Flexible inputs, concrete outputs.
- **Errors are values**: Handle them explicitly, don't panic.
- **Small interfaces**: Prefer single-method interfaces.
- **Package by feature**: Not by layer.

## Error Handling

### Always Handle Errors
```go
// Bad - ignoring errors
data, _ := json.Marshal(user)
file, _ := os.Open(path)

// Good - handle or propagate
data, err := json.Marshal(user)
if err != nil {
    return fmt.Errorf("marshaling user: %w", err)
}
```

### Wrap Errors with Context
```go
// Bad - loses context
if err != nil {
    return err
}

// Good - adds context with %w for unwrapping
if err != nil {
    return fmt.Errorf("fetching user %d: %w", userID, err)
}
```

### Error Types
```go
// Define sentinel errors for expected cases
var (
    ErrNotFound     = errors.New("not found")
    ErrUnauthorized = errors.New("unauthorized")
    ErrValidation   = errors.New("validation failed")
)

// Check with errors.Is
if errors.Is(err, ErrNotFound) {
    return http.StatusNotFound
}

// Custom error types for rich errors
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("%s: %s", e.Field, e.Message)
}

// Check with errors.As
var validationErr *ValidationError
if errors.As(err, &validationErr) {
    log.Printf("validation failed on field %s", validationErr.Field)
}
```

### Don't Panic
```go
// Bad - panics for expected errors
func MustGetUser(id int) User {
    user, err := GetUser(id)
    if err != nil {
        panic(err)
    }
    return user
}

// Good - return errors
func GetUser(id int) (User, error) {
    ...
}

// Panic is acceptable only for:
// - Programmer errors (nil pointer that should never be nil)
// - Initialization failures in main/init
// - Truly unrecoverable situations
```

## Interface Design

### Small Interfaces
```go
// Good - single method interfaces
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

// Compose when needed
type ReadWriter interface {
    Reader
    Writer
}
```

### Accept Interfaces, Return Structs
```go
// Good - accepts interface for flexibility
func ProcessData(r io.Reader) error {
    data, err := io.ReadAll(r)
    ...
}

// Good - returns concrete type
func NewUserService(repo UserRepository) *UserService {
    return &UserService{repo: repo}
}
```

### Define Interfaces Where Used
```go
// Define interface in the package that uses it, not where it's implemented
// This allows consumers to define exactly what they need

// In user_handler.go
type UserGetter interface {
    GetUser(ctx context.Context, id int) (User, error)
}

type UserHandler struct {
    users UserGetter  // Only needs GetUser, not full UserService
}
```

## Struct Patterns

### Constructor Functions
```go
type Server struct {
    addr    string
    timeout time.Duration
    logger  *log.Logger
}

// Simple constructor
func NewServer(addr string) *Server {
    return &Server{
        addr:    addr,
        timeout: 30 * time.Second,
        logger:  log.Default(),
    }
}

// Functional options for complex configuration
type ServerOption func(*Server)

func WithTimeout(d time.Duration) ServerOption {
    return func(s *Server) {
        s.timeout = d
    }
}

func WithLogger(l *log.Logger) ServerOption {
    return func(s *Server) {
        s.logger = l
    }
}

func NewServer(addr string, opts ...ServerOption) *Server {
    s := &Server{
        addr:    addr,
        timeout: 30 * time.Second,
        logger:  log.Default(),
    }
    for _, opt := range opts {
        opt(s)
    }
    return s
}

// Usage
server := NewServer(":8080", WithTimeout(60*time.Second), WithLogger(myLogger))
```

### Zero Values
Design structs so zero values are useful:
```go
// Good - zero value is valid
type Buffer struct {
    data []byte
}

func (b *Buffer) Write(p []byte) {
    b.data = append(b.data, p...)  // Works with nil slice
}

// Usage - no constructor needed
var buf Buffer
buf.Write([]byte("hello"))
```

## Context Usage

### Always Pass Context First
```go
// Good
func GetUser(ctx context.Context, id int) (User, error)
func (s *Service) CreateOrder(ctx context.Context, order Order) error

// Bad
func GetUser(id int, ctx context.Context) (User, error)
```

### Respect Cancellation
```go
func ProcessItems(ctx context.Context, items []Item) error {
    for _, item := range items {
        select {
        case <-ctx.Done():
            return ctx.Err()
        default:
        }
        
        if err := process(ctx, item); err != nil {
            return err
        }
    }
    return nil
}
```

### Don't Store Context
```go
// Bad - storing context in struct
type Service struct {
    ctx context.Context
}

// Good - pass context to methods
type Service struct {}

func (s *Service) DoWork(ctx context.Context) error {
    ...
}
```

## HTTP API Patterns

### Handler Structure
```go
type UserHandler struct {
    users  UserService
    logger *slog.Logger
}

func NewUserHandler(users UserService, logger *slog.Logger) *UserHandler {
    return &UserHandler{
        users:  users,
        logger: logger,
    }
}

func (h *UserHandler) GetUser(w http.ResponseWriter, r *http.Request) {
    ctx := r.Context()
    
    idStr := r.PathValue("id")  // Go 1.22+
    id, err := strconv.Atoi(idStr)
    if err != nil {
        h.respondError(w, http.StatusBadRequest, "invalid user ID")
        return
    }
    
    user, err := h.users.GetUser(ctx, id)
    if errors.Is(err, ErrNotFound) {
        h.respondError(w, http.StatusNotFound, "user not found")
        return
    }
    if err != nil {
        h.logger.Error("failed to get user", "error", err, "id", id)
        h.respondError(w, http.StatusInternalServerError, "internal error")
        return
    }
    
    h.respondJSON(w, http.StatusOK, user)
}

func (h *UserHandler) respondJSON(w http.ResponseWriter, status int, data any) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)
    json.NewEncoder(w).Encode(data)
}

func (h *UserHandler) respondError(w http.ResponseWriter, status int, message string) {
    h.respondJSON(w, status, map[string]string{"error": message})
}
```

### Middleware
```go
func LoggingMiddleware(logger *slog.Logger) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            start := time.Now()
            
            next.ServeHTTP(w, r)
            
            logger.Info("request",
                "method", r.Method,
                "path", r.URL.Path,
                "duration", time.Since(start),
            )
        })
    }
}

// Usage
mux := http.NewServeMux()
handler := LoggingMiddleware(logger)(mux)
```

## Package Organization

```
project/
├── cmd/
│   └── server/
│       └── main.go         # Entry point
├── internal/
│   ├── user/               # User domain
│   │   ├── handler.go
│   │   ├── service.go
│   │   ├── repository.go
│   │   └── user.go         # Types
│   ├── order/              # Order domain
│   │   └── ...
│   └── platform/           # Shared infrastructure
│       ├── database/
│       └── httputil/
├── go.mod
└── go.sum
```

### Package Naming
- Short, lowercase, no underscores: `user`, `order`, `httputil`
- Avoid stutter: `user.User` not `user.UserModel`
- Avoid generic names: `util`, `common`, `misc`

## Testing

```go
func TestGetUser(t *testing.T) {
    t.Run("returns user for valid ID", func(t *testing.T) {
        repo := &mockUserRepo{
            users: map[int]User{1: {ID: 1, Name: "Alice"}},
        }
        svc := NewUserService(repo)
        
        user, err := svc.GetUser(context.Background(), 1)
        
        if err != nil {
            t.Fatalf("unexpected error: %v", err)
        }
        if user.Name != "Alice" {
            t.Errorf("got name %q, want %q", user.Name, "Alice")
        }
    })
    
    t.Run("returns error for unknown ID", func(t *testing.T) {
        repo := &mockUserRepo{users: map[int]User{}}
        svc := NewUserService(repo)
        
        _, err := svc.GetUser(context.Background(), 999)
        
        if !errors.Is(err, ErrNotFound) {
            t.Errorf("got error %v, want ErrNotFound", err)
        }
    })
}
```

## Style Reference

For additional Go conventions, refer to:
- Effective Go: https://go.dev/doc/effective_go
- Google Go Style Guide: https://google.github.io/styleguide/go/
- Go Code Review Comments: https://github.com/golang/go/wiki/CodeReviewComments

## Graceful Shutdown

Always implement graceful shutdown for HTTP servers:

```go
func main() {
    logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
    
    srv := &http.Server{
        Addr:         ":8080",
        Handler:      setupRoutes(),
        ReadTimeout:  5 * time.Second,
        WriteTimeout: 10 * time.Second,
        IdleTimeout:  120 * time.Second,
    }

    // Start server in goroutine
    go func() {
        logger.Info("server starting", "addr", srv.Addr)
        if err := srv.ListenAndServe(); err != http.ErrServerClosed {
            logger.Error("server error", "error", err)
            os.Exit(1)
        }
    }()

    // Wait for interrupt signal
    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit

    logger.Info("shutting down server")

    // Give active connections time to finish
    ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()

    if err := srv.Shutdown(ctx); err != nil {
        logger.Error("forced shutdown", "error", err)
        os.Exit(1)
    }

    logger.Info("server stopped")
}
```

## Concurrent Operations with errgroup

Use `errgroup` for parallel operations with error handling:

```go
import "golang.org/x/sync/errgroup"

func FetchAllUsers(ctx context.Context, ids []int) ([]User, error) {
    g, ctx := errgroup.WithContext(ctx)
    users := make([]User, len(ids))

    for i, id := range ids {
        i, id := i, id  // Capture for goroutine (not needed in Go 1.22+)
        g.Go(func() error {
            user, err := FetchUser(ctx, id)
            if err != nil {
                return fmt.Errorf("fetching user %d: %w", id, err)
            }
            users[i] = user
            return nil
        })
    }

    if err := g.Wait(); err != nil {
        return nil, err  // Returns first error, cancels other goroutines
    }
    return users, nil
}

// With concurrency limit
func FetchAllUsersLimited(ctx context.Context, ids []int) ([]User, error) {
    g, ctx := errgroup.WithContext(ctx)
    g.SetLimit(10)  // Max 10 concurrent requests
    
    // ... same as above
}
```

## Table-Driven Tests

Use table-driven tests for comprehensive coverage:

```go
func TestValidateEmail(t *testing.T) {
    tests := []struct {
        name    string
        email   string
        wantErr bool
    }{
        {"valid email", "user@example.com", false},
        {"valid with subdomain", "user@mail.example.com", false},
        {"missing @", "userexample.com", true},
        {"missing domain", "user@", true},
        {"empty string", "", true},
        {"spaces", "user @example.com", true},
        {"unicode local", "用户@example.com", false},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := ValidateEmail(tt.email)
            if (err != nil) != tt.wantErr {
                t.Errorf("ValidateEmail(%q) error = %v, wantErr %v", 
                    tt.email, err, tt.wantErr)
            }
        })
    }
}
```

## Structured Logging with slog

Use the standard library's structured logger (Go 1.21+):

```go
import "log/slog"

func main() {
    // JSON handler for production
    logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
        Level: slog.LevelInfo,
    }))
    
    // Add default attributes
    logger = logger.With("service", "user-api", "version", "1.0.0")
    
    slog.SetDefault(logger)
}

func (h *UserHandler) GetUser(w http.ResponseWriter, r *http.Request) {
    ctx := r.Context()
    requestID := r.Header.Get("X-Request-Id")
    
    // Create request-scoped logger
    logger := slog.With("request_id", requestID)
    
    user, err := h.users.GetUser(ctx, id)
    if err != nil {
        logger.Error("failed to get user",
            "error", err,
            "user_id", id,
        )
        // ...
    }
    
    logger.Info("user retrieved",
        "user_id", id,
        "duration_ms", time.Since(start).Milliseconds(),
    )
}
```

## Generics (Go 1.18+)

Use generics for type-safe utilities:

```go
// Generic slice operations
func Map[T, U any](items []T, fn func(T) U) []U {
    result := make([]U, len(items))
    for i, item := range items {
        result[i] = fn(item)
    }
    return result
}

func Filter[T any](items []T, predicate func(T) bool) []T {
    result := make([]T, 0)
    for _, item := range items {
        if predicate(item) {
            result = append(result, item)
        }
    }
    return result
}

// Usage
names := Map(users, func(u User) string { return u.Name })
adults := Filter(users, func(u User) bool { return u.Age >= 18 })

// Generic with constraints
type Number interface {
    int | int64 | float64
}

func Sum[T Number](nums []T) T {
    var sum T
    for _, n := range nums {
        sum += n
    }
    return sum
}

// Generic Result type
type Result[T any] struct {
    Value T
    Err   error
}

func (r Result[T]) Unwrap() (T, error) {
    return r.Value, r.Err
}
```

## Database Patterns

### Connection and Query Patterns
```go
import "github.com/jmoiron/sqlx"

type UserRepo struct {
    db *sqlx.DB
}

func NewUserRepo(db *sqlx.DB) *UserRepo {
    return &UserRepo{db: db}
}

func (r *UserRepo) GetByID(ctx context.Context, id int) (User, error) {
    var user User
    err := r.db.GetContext(ctx, &user, 
        "SELECT id, name, email FROM users WHERE id = $1", id)
    if errors.Is(err, sql.ErrNoRows) {
        return User{}, ErrNotFound
    }
    return user, err
}

// Transactions
func (r *UserRepo) CreateWithProfile(ctx context.Context, user User, profile Profile) error {
    tx, err := r.db.BeginTxx(ctx, nil)
    if err != nil {
        return fmt.Errorf("begin tx: %w", err)
    }
    defer tx.Rollback()  // No-op if committed

    _, err = tx.ExecContext(ctx,
        "INSERT INTO users (name, email) VALUES ($1, $2)",
        user.Name, user.Email)
    if err != nil {
        return fmt.Errorf("insert user: %w", err)
    }

    _, err = tx.ExecContext(ctx,
        "INSERT INTO profiles (user_id, bio) VALUES ($1, $2)",
        user.ID, profile.Bio)
    if err != nil {
        return fmt.Errorf("insert profile: %w", err)
    }

    return tx.Commit()
}
```
