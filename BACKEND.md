# 🚀 BACKEND DEVELOPMENT GUIDELINES (SUPABASE + EDGE FUNCTIONS)

## 🎯 PURPOSE

This document defines strict backend architecture, security, API, and database rules for building a scalable, secure, and production-ready system.

All developers and AI agents MUST follow these rules.

---

# 🧱 1. BACKEND ARCHITECTURE

## Stack (STRICT)

* Supabase (PostgreSQL + Auth + Storage)
* Supabase Edge Functions (TypeScript)
* AI APIs (via Edge Functions ONLY)

---

## Architecture Flow

Client (Flutter App)
↓
Provider Layer
↓
Service Layer
↓
Supabase Edge Function (API Layer)
↓
Database (PostgreSQL)

---

## RULES:

* ❌ No direct DB access from frontend
* ❌ No AI calls from frontend
* ✅ All logic goes through Edge Functions

---

# 🗄️ 2. DATABASE DESIGN RULES

## 2.1 General Rules

* Use PostgreSQL (Supabase default)
* Use UUID for all primary keys
* Use `created_at`, `updated_at` timestamps in ALL tables

---

## 2.2 Required Tables

### users

* id (UUID, PK)
* email
* name
* created_at

---

### messages

* id (UUID)
* user_id (FK)
* content (text)
* context (text)
* created_at

---

### rewrites

* id
* message_id (FK)
* response (jsonb)
* created_at

---

### tone_analysis

* id
* message_id (FK)
* empathy_score
* clarity_score
* assertiveness_score
* warmth_score

---

### sessions (role-play)

* id
* user_id
* messages (jsonb)
* created_at

---

### insights

* id
* user_id
* summary (text)
* created_at

---

## 2.3 Indexing

* Index all foreign keys
* Index frequently queried fields (user_id, created_at)

---

# 🔐 3. SECURITY RULES (VERY STRICT)

## 3.1 Authentication

* Use Supabase Auth ONLY
* Support:

  * Google
  * Apple

---

## 3.2 Authorization (RLS)

## MUST ENABLE:

* Row Level Security (RLS) on ALL tables

### Example Policy:

* Users can only access their own data

---

## 3.3 API Security

* Validate all inputs
* Sanitize data
* Prevent injection attacks

---

## 3.4 Secrets Handling

* Store API keys in:

  * Supabase environment variables
* ❌ NEVER expose keys to frontend

---

# ⚙️ 4. EDGE FUNCTIONS (API LAYER)

## Rules:

* Written in TypeScript
* Stateless functions
* Small and focused

---

## Structure:

functions/
├── rewrite-message/
├── analyze-tone/
├── roleplay/
└── insights/

---

## Standard Flow:

1. Validate request
2. Authenticate user
3. Process logic
4. Call AI (if needed)
5. Store in DB
6. Return response

---

# 🤖 5. AI INTEGRATION RULES

## STRICT:

* All AI calls go through Edge Functions

---

## Flow:

User Input → Edge Function → AI API → Response → DB → Client

---

## Prompt Rules:

* Use structured prompts
* Return JSON format ONLY

---

## Error Handling:

* Timeout handling
* Retry logic (max 2 attempts)

---

# 🔌 6. API DESIGN RULES

## Format:

* REST-like endpoints via Edge Functions

---

## Response Structure:

{
"success": true,
"data": {},
"error": null
}

---

## Error Example:

{
"success": false,
"data": null,
"error": "Invalid input"
}

---

# 🧪 7. VALIDATION

## MUST:

* Validate all inputs using schema (Zod recommended)

---

## Example:

* message length
* required fields
* valid context values

---

# ⚡ 8. PERFORMANCE RULES

* Use pagination for large data
* Avoid heavy joins
* Use caching if needed
* Optimize queries

---

# 🧼 9. CODE QUALITY

## DO:

* Modular functions
* Clear naming
* Small functions

## DON’T:

* Monolithic logic
* Duplicate code

---

# 📊 10. LOGGING & MONITORING

* Log errors only (no sensitive data)
* Use Supabase logs
* Add basic request logging

---

# 🔁 11. DATA FLOW RULE

## STRICT FLOW:

Frontend → Edge Function → DB / AI → Response

---

# 📦 12. DEPLOYMENT RULES

* Use Supabase CLI
* Version control all functions
* Test before deploy

---

# 🔄 13. ERROR HANDLING

## MUST HANDLE:

* Invalid input
* Unauthorized access
* AI failure
* DB failure

---

# 🧠 14. INSIGHTS ENGINE RULES

* Run weekly aggregation
* Analyze last 7 days
* Generate summary via AI

---

# 🔒 15. RATE LIMITING

* Prevent abuse
* Limit AI calls per user

---

# 🧾 16. AUDIT RULES

* Track important actions:

  * message creation
  * AI usage
  * session activity

---

# 🚀 17. FINAL CHECKLIST

Before completing any backend feature:

✅ RLS enabled
✅ Input validated
✅ Errors handled
✅ Secure API
✅ DB optimized
✅ AI call structured
✅ Logs added

---

# ❗ STRICT RULE

Any backend code that violates these standards MUST be rejected or refactored.

---

END OF DOCUMENT
