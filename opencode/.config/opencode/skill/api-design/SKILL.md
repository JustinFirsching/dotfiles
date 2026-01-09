---
name: api-design
description: REST API design patterns for endpoints, responses, errors, and conventions
---

# API Design Skill

Use this skill when designing, implementing, or reviewing REST APIs.

## URL Structure

### Resources
- Use nouns, not verbs: `/users` not `/getUsers`
- Use plural names: `/users`, `/orders`, `/items`
- Use lowercase with hyphens: `/order-items` not `/orderItems`
- Nest for relationships: `/users/{id}/orders`

### Examples
```
GET    /users              # List users
POST   /users              # Create user
GET    /users/{id}         # Get user
PUT    /users/{id}         # Replace user
PATCH  /users/{id}         # Update user fields
DELETE /users/{id}         # Delete user

GET    /users/{id}/orders  # List user's orders
POST   /users/{id}/orders  # Create order for user
```

### Anti-patterns
```
# Bad
GET  /getUser?id=123
POST /createUser
GET  /users/delete/123
POST /users/123/updateEmail

# Good
GET    /users/123
POST   /users
DELETE /users/123
PATCH  /users/123
```

## HTTP Methods

| Method | Purpose | Idempotent | Safe |
|--------|---------|------------|------|
| GET | Retrieve resource(s) | Yes | Yes |
| POST | Create resource | No | No |
| PUT | Replace resource entirely | Yes | No |
| PATCH | Partial update | Yes | No |
| DELETE | Remove resource | Yes | No |

### Idempotency
Idempotent operations produce the same result when called multiple times.
- PUT with same data = same result
- DELETE on deleted resource = still deleted (or 404)
- POST creates new resource each time (not idempotent)

## Status Codes

### Success (2xx)
| Code | Meaning | Use Case |
|------|---------|----------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST (include Location header) |
| 204 | No Content | Successful DELETE, or PUT with no response body |

### Client Errors (4xx)
| Code | Meaning | Use Case |
|------|---------|----------|
| 400 | Bad Request | Invalid syntax, validation errors |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Authenticated but not authorized |
| 404 | Not Found | Resource doesn't exist |
| 405 | Method Not Allowed | Wrong HTTP method |
| 409 | Conflict | State conflict (duplicate, version mismatch) |
| 422 | Unprocessable Entity | Semantic errors (valid syntax, invalid data) |
| 429 | Too Many Requests | Rate limit exceeded |

### Server Errors (5xx)
| Code | Meaning | Use Case |
|------|---------|----------|
| 500 | Internal Server Error | Unexpected server error |
| 502 | Bad Gateway | Upstream service error |
| 503 | Service Unavailable | Temporarily unavailable |
| 504 | Gateway Timeout | Upstream timeout |

## Error Responses

Use a consistent error format across all endpoints.

### Standard Format
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The request contains invalid fields.",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      },
      {
        "field": "age",
        "message": "Must be a positive integer"
      }
    ]
  }
}
```

### Principles
- Human-readable `message` for display
- Machine-readable `code` for programmatic handling
- `details` array for field-level errors
- Never expose stack traces or internal details in production
- Log detailed errors server-side with correlation ID

## Request/Response Design

### Field Naming
Choose one convention and be consistent:
- **snake_case**: Python/Ruby convention, common in REST
- **camelCase**: JavaScript convention

```json
// Consistent snake_case
{
  "user_id": 123,
  "created_at": "2024-01-15T10:30:00Z",
  "email_verified": true
}
```

### Timestamps
Use ISO 8601 format with timezone:
```json
{
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T14:22:33Z"
}
```

### Null vs Absent
- Absent field = not requested or not applicable
- Null = explicitly no value
- Document which fields can be null

### IDs
- Use strings for IDs in JSON (avoids JavaScript integer limits)
- Keep internal ID format consistent (UUID, auto-increment, etc.)

## Pagination

### Offset-based (Simple)
```
GET /users?limit=20&offset=40
```

Response:
```json
{
  "data": [...],
  "pagination": {
    "total": 150,
    "limit": 20,
    "offset": 40
  }
}
```

### Cursor-based (Scalable)
```
GET /users?limit=20&cursor=eyJpZCI6MTIzfQ
```

Response:
```json
{
  "data": [...],
  "pagination": {
    "next_cursor": "eyJpZCI6MTQzfQ",
    "has_more": true
  }
}
```

Cursor-based is better for large datasets and real-time data.

## Filtering & Sorting

### Filtering
```
GET /users?status=active&role=admin
GET /orders?created_after=2024-01-01&status=pending
```

### Sorting
```
GET /users?sort=created_at        # Ascending
GET /users?sort=-created_at       # Descending (prefix with -)
GET /users?sort=last_name,first_name  # Multiple fields
```

## Versioning

**Always use URL path versioning.**

```
GET /v1/users
GET /v2/users
```

Benefits:
- Simple and explicit
- Easy to route and test
- Visible in logs and debugging
- No header parsing required
- Works with all HTTP clients

Do NOT use header-based versioning (`Accept: application/vnd.api+json; version=2`) - it's harder to test, debug, and maintain.

## Authentication

### Bearer Token
```
Authorization: Bearer <token>
```

### API Key
```
X-API-Key: <key>
# or
Authorization: ApiKey <key>
```

### Response to Auth Failures
- 401 for missing/invalid credentials
- 403 for valid credentials but insufficient permissions

## Rate Limiting

Include headers in responses:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1705312800
```

When exceeded, return 429:
```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Please retry after 60 seconds.",
    "retry_after": 60
  }
}
```

## Health Check Endpoints

Implement health checks for monitoring and orchestration:

```
GET /health          # Basic liveness check
GET /health/ready    # Readiness (can accept traffic?)
GET /health/live     # Liveness (is the process healthy?)
```

### Response Format
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "checks": {
    "database": { "status": "healthy", "latency_ms": 5 },
    "cache": { "status": "healthy", "latency_ms": 1 },
    "external_api": { "status": "degraded", "latency_ms": 500 }
  }
}
```

### Status Values
- `healthy` - All systems operational
- `degraded` - Operating with reduced functionality
- `unhealthy` - Critical failure, should not receive traffic

## Request Tracing

Include request IDs for debugging and correlation:

### Headers
```
X-Request-Id: 550e8400-e29b-41d4-a716-446655440000
```

### Implementation
- Generate UUID if client doesn't provide one
- Include in all log entries for this request
- Return in response headers
- Pass to downstream services
- Include in error responses

```json
{
  "error": {
    "code": "INTERNAL_ERROR",
    "message": "An unexpected error occurred.",
    "request_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

## Long-Running Operations

For operations that take more than a few seconds, use async patterns:

### Request
```
POST /v1/reports
{
  "type": "annual_summary",
  "year": 2024
}
```

### Response (202 Accepted)
```json
{
  "job_id": "abc123",
  "status": "pending",
  "status_url": "/v1/jobs/abc123",
  "estimated_completion": "2024-01-15T10:35:00Z"
}
```

### Polling Status
```
GET /v1/jobs/abc123
```

```json
{
  "job_id": "abc123",
  "status": "completed",
  "result_url": "/v1/reports/xyz789",
  "completed_at": "2024-01-15T10:33:00Z"
}
```

## Bulk Operations

For operations on multiple resources:

```
POST   /v1/users/bulk      # Create multiple
PATCH  /v1/users/bulk      # Update multiple
DELETE /v1/users/bulk      # Delete multiple
```

### Request Format
```json
{
  "operations": [
    { "method": "create", "data": { "name": "Alice" } },
    { "method": "update", "id": "123", "data": { "name": "Bob" } },
    { "method": "delete", "id": "456" }
  ]
}
```

### Response Format
```json
{
  "results": [
    { "status": "success", "id": "789" },
    { "status": "success", "id": "123" },
    { "status": "error", "id": "456", "error": { "code": "NOT_FOUND" } }
  ],
  "summary": { "succeeded": 2, "failed": 1 }
}
```

## API Design Checklist

- [ ] Resources use nouns, not verbs
- [ ] HTTP methods match semantics (GET for read, POST for create, etc.)
- [ ] Status codes are correct and consistent
- [ ] Error format is consistent across all endpoints
- [ ] Pagination is implemented for list endpoints
- [ ] Authentication is documented and enforced
- [ ] Rate limiting is in place for public endpoints
- [ ] API is versioned (URL path: /v1/)
- [ ] Request/response examples are documented
- [ ] Breaking changes are avoided or versioned
- [ ] Health check endpoints are implemented
- [ ] Request tracing is in place
