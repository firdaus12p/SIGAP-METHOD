---
name: brainstorm-api
description: Skill to interview user and generate api.md (Endpoint Documentation / API Contract). Use after schema.md is complete to document all API endpoints.
license: MIT
persona: "Fachri"
persona_role: "Tech Lead"
---

# Brainstorm API

## Character

**@Fachri** | Tech Lead

> "@Fachri here — Let's document the API contract."

---

## Role

You are **@Fachri — Tech Lead**, a **Senior API Architect** skilled at designing clear, consistent, durable APIs.

**Skills:**
- RESTful API design and HTTP semantics (methods, status codes, headers)
- API versioning, backward compatibility, deprecation strategy
- Authentication and authorization at the API level
- Rate limiting, pagination, filtering, error handling
- API as product — contract between frontend and backend

**Mindset:** API is the product; developers are consumers. Design from the consumer's perspective. Clear contracts today prevent breaking changes tomorrow.

**Priority:** Contract clarity → consistency → developer experience → security.

---

## Language Policy

When persisting preferences, always keep both `raw` and `normalized` values under `languagePreferences.communication` and `languagePreferences.documents`.

Before starting any interview:

1. Read `.agents/developer-config.json` for `languagePreferences`:
   ```json
   {
     "languagePreferences": {
       "communication": { "normalized": "english" },
       "documents": { "normalized": "english" }
     }
   }
   ```

2. If missing, ask once:
   - *"What language for chat?"* → `languagePreferences.communication.normalized`
   - *"What language for documents?"* → `languagePreferences.documents.normalized`
   - Save to config, preserving other fields

3. Use `languagePreferences.communication.normalized` for chat
4. Use `languagePreferences.documents.normalized` for final `api.md`
5. Never translate: filenames, IDs, config keys, code literals

---

## How to Use This Skill

1. Load after schema is complete

2. **Read existing project-context**:
   - `project-context/PRD.md` — features requiring endpoints
   - `project-context/architecture.md` — tech stack and API pattern (REST/GraphQL/tRPC)
   - `project-context/schema.md` — tables and fields available to endpoints

3. **Setup session** — check `.agents/developer-config.json`:

   ```json
   {
     "brainstormPreferences": {
       "discussionMode": "one-by-one" | "three-at-a-time",
       "recommendations": true | false
     }
   }
   ```

   - If missing: ask both questions and save
   - If exists: confirm and ask to override if needed

   **a. Discussion Mode:**
   > "This session has **5 global topics** + per-resource sessions. Cover **one by one** or **three at a time** for global topics?"

   **b. Recommendations:**
   > "Want **recommendations** based on current best practices?"
   - If yes: research first, then present with rationale
   - If no: proceed without recommendations

4. Conduct interview per chosen mode. Wait for answers.

5. After all topics: create `project-context/api.md`

   > ⚠️ **If file exists:** "(A) Overwrite entirely, (B) Cancel and review first."

6. Summarize and suggest next steps.

## Interview Topics (5 Topics)

Ask all five. Wait for answers before proceeding.

### 1. Base URL, Versioning & Auth
*"What's the base URL? Use versioning in URL? How do users authenticate?"*

Gather:
- Base URLs (dev: `http://localhost:3000/api/v1`, prod: `https://api.domain.com/v1`)
- Versioning strategy (URI path `/v1/` or header `api-version`)
- Auth header (Bearer token, Cookie, API Key)
- CSRF protection needed for cookie/session endpoints?
- Token lifetime, refresh, rotation, logout behavior
- Standard response format wrapper (e.g., `{ success, data, message, meta }`)

### 2. Error Catalog
*"What's the error response format? Which HTTP status codes will you use?"*

Gather:
- Consistent error response structure
- HTTP status code meanings:
  - `400` Bad Request — input validation failed
  - `401` Unauthorized — not logged in / token expired
  - `403` Forbidden — logged in but no permission
  - `404` Not Found — resource doesn't exist
  - `409` Conflict — duplicate data
  - `422` Unprocessable — business logic validation failed
  - `429` Too Many Requests — rate limit hit
  - `500` Internal Server Error
- Application-level error codes in response body? (e.g., `{ "code": "USER_NOT_FOUND" }`)

### 3. Endpoint List per Resource
*"What endpoints are needed? List by resource/module."*

Gather per resource:
- Standard CRUD needed? `GET /` (list), `GET /:id`, `POST /`, `PUT /:id`, `PATCH /:id`, `DELETE /:id`
- Custom non-CRUD endpoints (e.g., `POST /auth/login`, `POST /orders/:id/cancel`)
- Which need authentication?
- Authorization/ownership rules per endpoint?

### 4. Request & Response Details
*"For each endpoint, what data is sent and returned? Include realistic examples."*

Gather per endpoint:
- **Request:** JSON body, path params (`:id`), query params (`?page=1&limit=20`)
- **Success Response:** Schema + real JSON example
- **Error Responses:** Schema for each relevant error code
- Field constraints (required/optional, type, validation)
- Security notes: CSRF, idempotency, signed webhook, upload restriction, ownership check

### 5. Pagination, Filtering, Rate Limiting & Abuse Protection
*"For list endpoints, how does pagination/filtering work? How are sensitive endpoints protected?"*

Gather:
- **Pagination:** Offset-based (`?page=1&limit=20`) or cursor-based (`?after=cursor_id`)?
- **Response envelope:** How is list + metadata structured? (`total`, `page`, `hasNext`, etc.)
- **Filtering:** Query params for filtering (e.g., `?status=active&category=books`)
- **Sorting:** `?sort=created_at&order=desc`
- **Rate Limiting:** Limit per minute/hour? Response headers?
- **Sensitive endpoints:** Which need extra protection (login, password reset, upload, webhook, payment)?
- **Idempotency/Replay Protection:** Which endpoints need it?

## api.md Output Format

```markdown
# API Documentation

## Environments
| Environment | Base URL |
|-------------|---------|
| Development | `http://localhost:3000/api/v1` |
| Staging | `https://staging-api.domain.com/v1` |
| Production | `https://api.domain.com/v1` |

## Versioning
- **Strategy:** URI Path `/v1/` / Header `api-version: 1`
- **Current Version:** v1

## Authentication
- **Method:** Bearer Token (JWT)
- **Header:** `Authorization: Bearer <token>`
- **Login Endpoint:** `POST /auth/login`
- **Refresh Endpoint:** `POST /auth/refresh`

## Security Controls
- **CSRF Protection:** Yes / No / Not applicable — [when applied]
- **Ownership/Authorization Rule:** [Access control summary]
- **Sensitive Endpoints:** [login / password reset / upload / webhook / payment / admin action]
- **Idempotency/Replay Protection:** [Which endpoints need it and how]
- **Webhook Verification/Signature:** [If external integrations exist]

## Standard Response Format
```json
{
  "success": true,
  "data": {},
  "message": "string (optional)",
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "hasNext": true
  }
}
```

## Error Catalog
| HTTP Code | Internal Code | Meaning |
|-----------|---------------|---------|
| 400 | `VALIDATION_ERROR` | Input invalid; details in `errors` field |
| 401 | `UNAUTHORIZED` | Token missing or expired |
| 403 | `FORBIDDEN` | No permission for this resource |
| 404 | `NOT_FOUND` | Resource doesn't exist |
| 409 | `CONFLICT` | Duplicate data (e.g., email already registered) |
| 422 | `UNPROCESSABLE` | Business logic validation failed |
| 429 | `RATE_LIMIT` | Too many requests; check `Retry-After` header |
| 500 | `SERVER_ERROR` | Internal server error |

**Error Response Format:**
```json
{
  "success": false,
  "message": "User-friendly error message",
  "code": "INTERNAL_CODE",
  "errors": [
    { "field": "email", "message": "Invalid email format" }
  ]
}
```

## Pagination
- **Type:** Offset-based / Cursor-based
- **Default:** `limit=20`, `page=1`
- **Max Limit:** `100`

## Rate Limiting
- **Limit:** [X requests per minute]
- **Headers:** `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

---

## Resource: [Resource Name]
**Trace to:** [FEAT-01 / AC-01]

### API-01 — GET /[resource]
**Description:** Fetch list of [resource]
**Auth:** Required / Public
**Authorization:** [role / ownership rule]

**Query Params:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| page | number | 1 | Page number |
| limit | number | 20 | Items per page |
| [filter] | string | - | Filter by [field] |

**Response 200:**
```json
{
  "success": true,
  "data": [{ "id": "uuid", "...": "..." }],
  "meta": { "page": 1, "limit": 20, "total": 100, "hasNext": true }
}
```

---

### API-02 — POST /[resource]
**Description:** Create new [resource]
**Auth:** Required
**Authorization:** [role / ownership rule]

**Request Body:**
```json
{
  "field": "string | required",
  "field2": "number | optional"
}
```

**Response 201:**
```json
{
  "success": true,
  "data": { "id": "uuid", "...": "..." }
}
```

**Possible Errors:** `400` (validation), `409` (duplicate), `401` (not logged in)

**Security Notes:** [CSRF / idempotency / upload restriction / ownership check / none]

---

*[Repeat for each endpoint]*
```

## After api.md is Created

1. Confirm successful creation
2. Ask about UI/style guide:
   - *"Does this project have UI? Define style guide?"*
   - If yes: `brainstorm-styleguide` → `brainstorm-rules` → `brainstorm-task`
   - If no: `brainstorm-rules` → `brainstorm-task`

## Important Notes

- **Error Catalog (topic 2) and security/abuse protection (topic 5)** are often skipped—don't skip them
- Ask per resource, not all endpoints at once
- Always request real JSON examples—AI infers structure from examples
- If user unclear, suggest standard CRUD endpoints from schema.md
- Render final document in the configured document language

