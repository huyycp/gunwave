# English and Vietnamese localization design

## Goal

Localize Gunwave's shipped application UI in English and Vietnamese. Let users select **Device language**, **English**, or **Tiếng Việt**. When Device language is selected, use Vietnamese when the device locale is Vietnamese and fall back to English for unsupported locales.

## Scope

- Localize static, user-facing text in the shipped app: screen titles and controls, forms, dialogs, empty/error states, and snackbars.
- Keep database-provided content, including room names, quiz text, character names, and player names, as authored. This change does not add translated database fields.
- Exclude developer-only standalone tooling such as the gesture recognizer test screen.
- Do not change authentication, backend schemas, or gameplay behavior.

## Localization resources

- Use Flutter's generated localization support with `flutter_localizations`, the existing `intl` dependency, and `gen-l10n`.
- Store English and Vietnamese strings in `lib/l10n/app_en.arb` and `lib/l10n/app_vi.arb`, with English as the template and fallback.
- Add `l10n.yaml` and enable Flutter localization code generation in `pubspec.yaml`.
- Replace app-owned hard-coded UI strings with generated, typed localization accessors. Keep dynamic values and formatting as parameters rather than concatenating translated fragments.

## Language preference and app integration

- Add a three-state preference: system/device locale, English, or Vietnamese.
- Persist the selected mode with `shared_preferences` so it works before authentication and is not tied to a Supabase account.
- Expose the active locale from the app's existing Riverpod root, and pass it to `MaterialApp.router` with the generated delegates and supported locales.
- In device mode, let Flutter resolve among English and Vietnamese; put English first and configure an English fallback for unsupported device locales.
- Add a compact language selector to the home screen. It must remain available while the sign-in form is shown, so the language can be changed before login. Its three options are Device language, English, and Tiếng Việt.
- A selection should update the UI immediately and persist for the next launch.

## Verification

- Generate localization code with Flutter's localization generator.
- Run `dart analyze lib`.
- Manually check English and Vietnamese in device mode, both explicit language modes, and an unsupported device locale fallback. Check that changing language works before sign-in and after navigation.

## Risks and constraints

- The app uses many hard-coded strings across screens and shared widgets; missing even one leaves mixed-language UI. Review app-owned literals across the routed application before calling the work complete.
- User-authored database content will remain in its original language until the backend model and content workflow support translations.
- Device locale preference and explicit language overrides must remain distinct when persisted; selecting Device language must clear or replace any explicit override.
