# flutter_auth_template

A Flutter starter with email and password authentication against
[Supabase](https://supabase.com), using its REST API directly with Dio and
Retrofit instead of the Supabase SDK. It comes with sign up, sign in, sign out
and automatic session refresh, plus a posts tab and a profile tab as examples
of authenticated requests, and a settings tab for the theme and signing out.

It is the starting point for new apps, with authentication, session refresh,
networking, error handling, localization and dependency injection already set
up.

## Setup

The code uses primary constructors and dot shorthands, so it needs Dart 3.13.5
or later.

1. Run [`supabase.sql`](supabase.sql) once in the Supabase SQL Editor.
2. Copy `env/example.json` to `env/dev.json` and fill in your project URL and
   publishable key.
3. Generate the code, which is not committed:

   ```sh
   flutter pub get
   dart run build_runner build
   ```

4. Run the app:

   ```sh
   flutter run --dart-define-from-file=env/dev.json
   ```

Supabase asks new users to confirm their email by default. To skip that while
developing, turn off **Confirm email** in the Email provider settings.

## Linting

The lints come from
[very_good_analysis](https://pub.dev/packages/very_good_analysis). Like Very
Good Ventures' own app template, the project turns off
`public_member_api_docs`, which is meant for packages, so only code that needs
explaining has doc comments.

```sh
flutter analyze
dart format lib
```

## Architecture

The app uses
[Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html),
adapted for this template. It is inspired a lot by Reso Coder's
[Flutter TDD Clean Architecture course](https://resocoder.com/flutter-clean-architecture-tdd/).
Each feature has a data, a domain and a presentation folder, with the
repository interfaces and use cases in the domain. Settings has nothing to
load, so it only has a presentation folder. This is what it does
differently from the course:

- **`Result` instead of `Either`.** Repositories return a small hand-written
  sealed `Result<T>`, as in the
  [Flutter architecture guide](https://docs.flutter.dev/app-architecture/design-patterns/result),
  rather than dartz's `Either<Failure, T>`.
- **Failures only.** There are no separate exception classes. A data source
  throws a `Failure` that carries its `cause`, and the repository returns it.
  Any other error becomes a `GenericFailure`.
- **Cubits with `AsyncValue`.** Each feature has one cubit instead of a bloc
  with events. Its state is a single class holding one `AsyncValue` per
  operation, modelled on Riverpod's, rather than a sealed family of states.
- **Models and Entities** use mappers and do not extend the entity.
- **Plain use cases.** A use case is a callable class with no `UseCase` base
  class or `Params` object.
- **Dio and Retrofit** instead of the `http` package.

## Project structure

```text
lib/
  core/
    app/          session, app state and the root screens, layered like a feature
    error/        Result, AsyncValue and the base failures
    l10n/         translations (app_en.arb) and context.l10n
    network/      the Dio client
    widgets/      the shared LoadingView and FailureView
  features/
    auth/         sign up, sign in, sign out and the token interceptor
    posts/        listing and creating posts
    profile/      the signed-in user's profile
    settings/     theme and sign out
  injection_container.dart   get_it registrations
  main.dart
```
