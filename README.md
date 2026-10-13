# flutter_auth_template

A Flutter starter with email and password authentication against
[Supabase](https://supabase.com), using its REST API directly with Dio and
Retrofit instead of the Supabase SDK. It comes with sign up, sign in, sign out
and automatic session refresh, plus a posts tab and a profile tab as examples
of authenticated requests.

It is the starting point for new apps, with authentication, session refresh,
networking, error handling and dependency injection already set up.

## Setup

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

## Architecture

The app uses
[Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html),
adapted for this template. It is inspired a lot by Reso Coder's
[Flutter TDD Clean Architecture course](https://resocoder.com/flutter-clean-architecture-tdd/).
Each feature has a data, a domain and a presentation folder, with the
repository interfaces and use cases in the domain. This is what it does
differently from the course:

- **`Result` instead of `Either`.** Repositories return a small hand-written
  sealed `Result<T>`, as in the
  [Flutter architecture guide](https://docs.flutter.dev/app-architecture/design-patterns/result),
  rather than dartz's `Either<Failure, T>`.
- **Failures only.** There are no separate exception classes. A data source
  throws a `Failure` that carries its `cause`, and the repository returns it.
- **Cubits with `AsyncValue`.** Each feature has one cubit instead of a bloc
  with events. Its state is a single class holding one `AsyncValue` per
  operation, modelled on Riverpod's, rather than a sealed family of states.
- **injectable.** The get_it registrations are generated instead of written by
  hand in an `injection_container.dart`.
- **Models are separate from entities.** A model is mapped with `toEntity()`
  and does not extend its entity.
- **Plain use cases.** A use case is a callable class with no `UseCase` base
  class or `Params` object.
- **Dio and Retrofit** instead of the `http` package.
