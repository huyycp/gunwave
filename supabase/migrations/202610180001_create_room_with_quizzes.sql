create or replace function public.create_room_with_quizzes(
  room_data jsonb,
  quiz_data jsonb
)
returns text
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
  authenticated_user_id public.users.id%TYPE;
  selected_map_id public.maps.id%TYPE;
  created_room_id public.rooms.id%TYPE;
  created_quiz_id public.quizzes.id%TYPE;
  quiz jsonb;
begin
  select id into authenticated_user_id
  from public.users
  where id::text = room_data ->> 'user_id'
    and auth_id::text = auth.uid()::text;
  if authenticated_user_id is null then
    raise exception 'Room creator must be the authenticated user';
  end if;

  select id into selected_map_id
  from public.maps
  where id::text = room_data ->> 'map_id';
  if selected_map_id is null then
    raise exception 'Selected map does not exist';
  end if;
  if jsonb_typeof(quiz_data) is distinct from 'array' then
    raise exception 'Quiz data must be an array';
  end if;
  if jsonb_array_length(quiz_data) = 0 then
    raise exception 'At least one quiz is required';
  end if;

  insert into public.rooms (map_id, user_id, name, private)
  values (
    selected_map_id,
    authenticated_user_id,
    room_data ->> 'name',
    coalesce((room_data ->> 'private')::boolean, false)
  )
  returning id into created_room_id;

  for quiz in select value from jsonb_array_elements(quiz_data)
  loop
    insert into public.quizzes (question, result_a, result_b, result_c, result_d, answer)
    values (
      quiz ->> 'question',
      quiz ->> 'result_a',
      quiz ->> 'result_b',
      quiz ->> 'result_c',
      quiz ->> 'result_d',
      quiz ->> 'answer'
    )
    returning id into created_quiz_id;

    insert into public.rooms_quizzes (room_id, quiz_id)
    values (created_room_id, created_quiz_id);
  end loop;

  return created_room_id::text;
end;
$$;

revoke all on function public.create_room_with_quizzes(jsonb, jsonb) from public, anon;
grant execute on function public.create_room_with_quizzes(jsonb, jsonb) to authenticated;
