# Lumina Coach

Production-oriented Flutter app: **communication coaching** with BYOK Claude (Haiku), **Supabase** auth, and **Edge Functions** as the **only** path to PostgreSQL and AI (per `BACKEND.md`).

## Prerequisites

- Flutter SDK 3.24+ (`flutter doctor`)
- Supabase project
- (Optional) Firebase for Crashlytics

## Bootstrap

```bash
cd lumina_coach
flutter pub get
flutter create . --project-name lumina_coach   # if android/ios missing
```

## Configuration

1. **Supabase** — set via `--dart-define`:

   `SUPABASE_URL`, `SUPABASE_ANON_KEY` (see `lib/core/config/app_config.dart`).

2. **Database** — run `supabase/migrations/00001_initial.sql`.

3. **Edge Functions** (each returns `{ success, data, error }`):

   ```bash
   supabase functions deploy rewrite-message
   supabase functions deploy analyze-tone
   supabase functions deploy roleplay
   supabase functions deploy insights
   supabase functions deploy list-messages
   supabase functions deploy update-profile
   ```

4. **OAuth** — enable Google & Apple in Supabase; configure app deep links to match `login_page.dart` `redirectTo`.

5. **Firebase** (optional) — `flutterfire configure`, then use `DefaultFirebaseOptions` in `main.dart`.

## Architecture (see `FRONTEND.md` / `BACKEND.md`)

- **UI** → **Providers** (`lib/providers/`) → **Services** (`lib/services/`) → **Edge Functions** → **Postgres / Claude**
- No direct `supabase.from(...)` data access from Flutter (except **Auth** session helpers).
- BYOK: `x-anthropic-key` header on AI functions only; keys stay in **secure storage** on device.

## Security

- RLS on all tables.
- Do not log `x-anthropic-key` in Edge Functions.
- Rotate keys if leaked.
