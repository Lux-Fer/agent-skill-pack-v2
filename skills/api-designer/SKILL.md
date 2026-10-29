---
name: api-designer
title: API Designer
version: 1.0.0
description: AI agent skill for designing RESTful APIs — from endpoint planning to OpenAPI 3.0 spec generation, authentication, error handling, pagination, and versioning.
author: Agent Skill Pack v2
tags: [api-design, rest, openapi, backend, architecture]
os: [linux, macos, windows]
tools: [python, curl, yq, openapi-generator]
---

# API Designer Skill

## Overview

This skill provides agents with structured methodologies for designing, documenting, and validating RESTful APIs. It covers RESTful principles, OpenAPI 3.0 specification generation, endpoint naming conventions, error handling, pagination, authentication, rate limiting, and versioning strategies.

---

## 1. RESTful Design Principles

### 1.1 Resource-Oriented Architecture
APIs should be organized around **resources** (nouns), not actions (verbs).

| Principle | Description |
|---|---|
| Resources are nouns | `/users`, `/orders`, `/products` |
| Actions are HTTP methods | `GET`, `POST`, `PUT`, `PATCH`, `DELETE` |
| Stateless interactions | Each request contains all needed context |
| Consistent naming | Plural nouns, kebab-case for multi-word |
| HATEOAS (optional) | Responses include related resource links |

### 1.2 HTTP Method Mapping
| Method | Action | Idempotent | Safe | Response |
|---|---|---|---|---|
| GET | Retrieve resource(s) | Yes | Yes | 200 OK |
| POST | Create resource | No | No | 201 Created |
| PUT | Full replace | Yes | No | 200/204 |
| PATCH | Partial update | No* | No | 200/204 |
| DELETE | Remove resource | Yes | No | 204 No Content |

### 1.3 URL Naming Conventions
```
# Good
GET    /api/v1/users                    # List users
GET    /api/v1/users/{id}               # Get user by ID
POST   /api/v1/users                    # Create user
PUT    /api/v1/users/{id}               # Replace user
PATCH  /api/v1/users/{id}               # Partial update user
DELETE /api/v1/users/{id}               # Delete user
GET    /api/v1/users/{id}/orders        # List user's orders

# Bad — actions in URLs
GET    /api/v1/getUser                  # Use GET /users/{id}
POST   /api/v1/createUser               # Use POST /users
POST   /api/v1/deleteUser               # Use DELETE /users/{id}
GET    /api/v1/getUserOrders            # Use GET /users/{id}/orders
```

### 1.4 Status Code Usage
```
2xx Success
  200 OK           — Successful GET, PUT, PATCH
  201 Created      — Successful POST (include Location header)
  204 No Content   — Successful DELETE or PUT with no body
  202 Accepted     — Async operation accepted for processing

3xx Redirection
  301 Moved Permanently
  302 Found
  307 Temporary Redirect
  308 Permanent Redirect

4xx Client Error
  400 Bad Request        — Malformed syntax, invalid params
  401 Unauthorized       — Missing or invalid authentication
  403 Forbidden          — Authenticated but not authorized
  404 Not Found          — Resource doesn't exist
  405 Method Not Allowed — Wrong HTTP method used
  409 Conflict           — Resource state conflict (e.g., duplicate)
  422 Unprocessable Entity — Semantic validation failure
  429 Too Many Requests   — Rate limit exceeded

5xx Server Error
  500 Internal Server Error  — Unhandled server exception
  502 Bad Gateway             — Upstream service failed
  503 Service Unavailable     — Server temporarily overloaded
  504 Gateway Timeout         — Upstream timeout
```

---

## 2. OpenAPI 3.0 Specification Generation

### 2.1 Minimal OpenAPI Structure
```yaml
openapi: "3.0.3"
info:
  title: "My API"
  description: "API description"
  version: "1.0.0"
  contact:
    name: "API Support"
    email: "support@example.com"
servers:
  - url: "https://api.example.com/v1"
    description: "Production"
  - url: "https://staging-api.example.com/v1"
    description: "Staging"
paths:
  /users:
    get:
      summary: "List users"
      operationId: listUsers
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: per_page
          in: query
          schema:
            type: integer
            default: 20
      responses:
        "200":
          description: "User list"
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/UserList"
  /users/{id}:
    get:
      summary: "Get user by ID"
      operationId: getUser
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: integer
      responses:
        "200":
          description: "User object"
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/User"
        "404":
          $ref: "#/components/responses/NotFound"
components:
  schemas:
    User:
      type: object
      required: [id, email, name]
      properties:
        id:
          type: integer
          readOnly: true
        email:
          type: string
          format: email
        name:
          type: string
        created_at:
          type: string
          format: date-time
          readOnly: true
        updated_at:
          type: string
          format: date-time
          readOnly: true
    UserList:
      type: object
      properties:
        data:
          type: array
          items:
            $ref: "#/components/schemas/User"
        meta:
          $ref: "#/components/schemas/PaginationMeta"
    PaginationMeta:
      type: object
      properties:
        current_page:
          type: integer
        per_page:
          type: integer
        total:
          type: integer
        total_pages:
          type: integer
    ErrorResponse:
      type: object
      properties:
        error:
          type: object
          properties:
            code:
              type: string
            message:
              type: string
            details:
              type: object
  responses:
    NotFound:
      description: "Resource not found"
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/ErrorResponse"
    ValidationError:
      description: "Validation error"
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/ErrorResponse"
```

### 2.2 OpenAPI Generation Workflow
```
1. Define data models (entities, DTOs, enums)
2. Define endpoints (path, method, summary, params)
3. Define request bodies (content type, schema)
4. Define responses (status codes, schemas per status)
5. Define security schemes (bearer, OAuth2, API key)
6. Generate server/client stubs (openapi-generator)
7. Validate spec (openapi-spec-validator, spectral linting)
8. Publish spec (developer portal, Swagger UI, Redoc)
```

---

## 3. Error Handling Patterns

### 3.1 Consistent Error Response Format
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The request body contains invalid fields.",
    "details": {
      "fields": [
        {
          "field": "email",
          "reason": "must be a valid email address",
          "value": "not-an-email"
        },
        {
          "field": "age",
          "reason": "must be at least 18",
          "value": 15
        }
      ]
    },
    "request_id": "req_abc123",
    "timestamp": "2026-04-30T01:10:00Z"
  }
}
```

### 3.2 Problem Details (RFC 9457)
```json
{
  "type": "https://api.example.com/errors/insufficient-funds",
  "title": "Insufficient Funds",
  "status": 422,
  "detail": "Account balance 5.00 is less than required amount 20.00",
  "instance": "/api/v1/transactions/withdraw",
  "balance": 5.00,
  "required": 20.00
}
```

### 3.3 Error Catalog Template
```yaml
errors:
  VALIDATION_ERROR:
    status: 422
    message: "Request validation failed"
    description: "One or more fields failed validation"
    resolution: "Check the details for field-specific errors and correct them"

  NOT_FOUND:
    status: 404
    message: "Resource not found"
    description: "The requested resource does not exist"
    resolution: "Verify the resource ID and ensure it exists"

  UNAUTHORIZED:
    status: 401
    message: "Authentication required"
    description: "No valid authentication credentials provided"
    resolution: "Include a valid Authorization header"

  FORBIDDEN:
    status: 403
    message: "Insufficient permissions"
    description: "You do not have access to this resource"
    resolution: "Request the necessary permissions from an administrator"

  RATE_LIMITED:
    status: 429
    message: "Too many requests"
    description: "Rate limit exceeded"
    resolution: "Retry after the time specified in the Retry-After header"

  INTERNAL_ERROR:
    status: 500
    message: "Internal server error"
    description: "An unexpected error occurred"
    resolution: "Retry the request; contact support if the issue persists"
```

---

## 4. Pagination Strategies

| Strategy | Description | Pros | Cons | When to Use |
|---|---|---|---|---|
| **Offset/Limit** | `?page=2&per_page=20` | Simple, familiar | Inconsistent if data changes, slow on large offsets | Small datasets, admin UIs |
| **Cursor-based** | `?cursor=eyJpZCI6MTAwfQ==&limit=20` | Consistent, fast, handles real-time data | More complex, no random page access | Real-time feeds, large datasets |
| **Keyset** | `?after_id=100&limit=20` | Fast with indexed columns | Requires sortable unique key | Time-series data |
| **Page tokens** | `?page_token=xyz` | Opaque, server-controlled | Client can't construct URLs | Google-style APIs |

### Cursor-Based Pagination Response
```json
{
  "data": [...],
  "meta": {
    "next_cursor": "eyJpZCI6MTAwfQ==",
    "prev_cursor": "eyJpZCI6MX0=",
    "has_more": true
  }
}
```

### Pagination Headers (RFC 8288)
```
Link: <https://api.example.com/users?cursor=xyz>; rel="next",
      <https://api.example.com/users?cursor=abc>; rel="prev"
X-Total-Count: 500
```

---

## 5. Authentication Methods

| Method | Description | Security Level | Complexity |
|---|---|---|---|
| **API Keys** | Static key in header/query | Low | Low |
| **Bearer Token (JWT)** | Signed token in Authorization header | Medium | Medium |
| **OAuth 2.0** | Authorization framework with grants | High | High |
| **Basic Auth** | Base64-encoded username:password | Low | Low |
| **Mutual TLS** | Certificate-based client auth | Very High | High |
| **HMAC Signatures** | Request signing with shared secret | High | Medium |

### OpenAPI Security Schemes
```yaml
components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: "JWT token obtained from /auth/login"
    ApiKeyAuth:
      type: apiKey
      in: header
      name: X-API-Key
    OAuth2:
      type: oauth2
      flows:
        authorizationCode:
          authorizationUrl: https://auth.example.com/authorize
          tokenUrl: https://auth.example.com/token
          scopes:
            read:users: "Read user data"
            write:users: "Modify user data"
security:
  - BearerAuth: []
```

---

## 6. Rate Limiting

### Strategy Comparison
| Strategy | Algorithm | Behavior |
|---|---|---|
| Token Bucket | Fixed capacity refills over time | Allows bursts up to capacity |
| Leaky Bucket | Fixed processing rate | Smooths traffic |
| Fixed Window | Reset counter per time window | Simple but allows bursts at boundaries |
| Sliding Window Log | Timestamp-based rolling window | Precise but memory-intensive |
| Sliding Window Counter | Combines fixed window + sliding | Good balance of precision and efficiency |

### Rate Limit Headers (Standard)
```
X-RateLimit-Limit: 100           # Max requests per window
X-RateLimit-Remaining: 42        # Remaining in current window
X-RateLimit-Reset: 1619798400    # Window reset timestamp (Unix)
Retry-After: 35                  # Seconds to wait (RFC 7231)
```

---

## 7. API Versioning

### Strategy Pros/Cons
| Strategy | Example | Pros | Cons |
|---|---|---|---|
| URL path | `/api/v1/users` | Explicit, easy to route | URL pollution, hard to maintain |
| Header | `Accept: application/vnd.myapp.v1+json` | Clean URLs | Harder to discover, client complexity |
| Query param | `?version=1` | Simple | Pollutes query params, caching issues |

### Version Lifecycle
```
v1 (GA)     — Current stable, full support
v1.1        — Backward-compatible additions, no breaking changes
v2-beta     — Pre-release, may change
v2 (GA)     — New stable when ready
v1-deprecated — Still works but warned via Sunset header
v1-sunset   — Scheduled for removal
```

### Sunset Header (RFC 8594)
```
Sunset: Sat, 31 Dec 2026 23:59:59 GMT
Deprecation: true
Link: <https://api.example.com/v2/users>; rel="successor-version"
```

---

## 8. Endpoint Templates

### List Resources (GET)
```yaml
get:
  summary: "List {resources}"
  operationId: list{Resources}
  parameters:
    - name: page
      in: query
      schema: { type: integer, default: 1 }
    - name: per_page
      in: query
      schema: { type: integer, default: 20, maximum: 100 }
    - name: sort
      in: query
      schema: { type: string, example: "-created_at" }
    - name: filter
      in: query
      description: "JSON-encoded filter object"
      schema: { type: string }
  responses:
    "200":
      description: "{Resource} list"
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/{Resource}List"
```

### Create Resource (POST)
```yaml
post:
  summary: "Create {resource}"
  operationId: create{Resource}
  requestBody:
    required: true
    content:
      application/json:
        schema:
          $ref: "#/components/schemas/Create{Resource}Request"
  responses:
    "201":
      description: "Created {resource}"
      headers:
        Location:
          schema: { type: string }
          description: "URL of created resource"
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/{Resource}"
    "422":
      $ref: "#/components/responses/ValidationError"
```

### Get Resource (GET by ID)
```yaml
get:
  summary: "Get {resource} by ID"
  operationId: get{Resource}
  parameters:
    - name: id
      in: path
      required: true
      schema: { type: integer }
  responses:
    "200":
      description: "{Resource} object"
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/{Resource}"
    "404":
      $ref: "#/components/responses/NotFound"
```

### Update Resource (PATCH)
```yaml
patch:
  summary: "Update {resource}"
  operationId: update{Resource}
  parameters:
    - name: id
      in: path
      required: true
      schema: { type: integer }
  requestBody:
    required: true
    content:
      application/json:
        schema:
          $ref: "#/components/schemas/Update{Resource}Request"
  responses:
    "200":
      description: "Updated {resource}"
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/{Resource}"
    "404":
      $ref: "#/components/responses/NotFound"
    "422":
      $ref: "#/components/responses/ValidationError"
```

### Delete Resource (DELETE)
```yaml
delete:
  summary: "Delete {resource}"
  operationId: delete{Resource}
  parameters:
    - name: id
      in: path
      required: true
      schema: { type: integer }
  responses:
    "204":
      description: "{resource} deleted"
    "404":
      $ref: "#/components/responses/NotFound"
    "409":
      description: "Cannot delete due to existing references"
```

---

## 9. API Design Checklist

- [ ] Resources named as plural nouns (kebab-case)
- [ ] Consistent HTTP method usage (GET=read, POST=create, etc.)
- [ ] Proper status codes for each response
- [ ] Standardized error response format across all endpoints
- [ ] Pagination implemented with sensible defaults
- [ ] Authentication defined in OpenAPI security schemes
- [ ] Rate limiting documented with headers
- [ ] Versioning strategy chosen and documented
- [ ] OpenAPI spec validated with spectral
- [ ] Request validation (400 vs 422 vs 403)
- [ ] CORS configured for browser clients
- [ ] Content negotiation via Accept header
- [ ] Idempotency support for POST (Idempotency-Key header)
- [ ] Field selection (sparse fieldsets) or expand support
- [ ] API changelog maintained
- [ ] Deprecation policy documented
