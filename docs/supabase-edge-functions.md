# Deploying the Supabase Edge Function

This project currently has one Edge Function: `update-ranks`. Deploy it from the repository root after changing files under `supabase/functions/update-ranks/`.

## 1. Check the CLI

```sh
supabase --version
```

If the CLI is not installed, follow the [Supabase CLI installation guide](https://supabase.com/docs/guides/cli/getting-started).

## 2. Sign in

```sh
supabase login
```

Complete the browser or token prompt. The CLI needs an access token to inspect projects and deploy functions.

## 3. Find and confirm the cloud project

```sh
supabase projects list
```

Copy the project reference for the intended Gunwave project. Do not use `project_id = "gunwave"` from `supabase/config.toml` as the cloud project reference; that value identifies the local CLI project.

Link this repository to the intended cloud project:

```sh
supabase link --project-ref <project-ref>
supabase status
```

Confirm the linked project before continuing. If the repository is already linked to the correct project, linking again is unnecessary.

## 4. Check the current cloud functions

```sh
supabase functions list
```

Confirm that `update-ranks` is listed for the intended project.

## 5. Deploy only `update-ranks`

```sh
supabase functions deploy update-ranks --use-api
```

The `--use-api` option uses API-based deployment and does not require Docker. This deploys the function source and its project configuration; it does not apply database migrations.

## 6. Verify the deployment

```sh
supabase functions list
```

Check the `update-ranks` entry and its updated deployment timestamp/version. You can also inspect the function in the Supabase Dashboard under **Edge Functions**.

`update-ranks` requires a valid signed-in user's JWT and a valid room/character submission, so an arbitrary unauthenticated `curl` request is not a successful health check. Verify it through the app with an authenticated user and a valid game submission, or use the Dashboard's function logs to inspect an invocation.

## Notes

- Run these commands from the repository root.
- `supabase db push` is for database migrations and is not needed to deploy this function.
- Do not put a service-role key in the Flutter app or commit Supabase access tokens.
