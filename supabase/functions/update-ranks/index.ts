import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'
import {
  calculateRank,
  RankValidationError,
  type RankSubmission,
} from './score.ts'

Deno.serve(async (req) => {
  try {
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) return json({ error: 'Authorization header required' }, 401)

    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY')
    if (!supabaseUrl || !supabaseAnonKey) {
      console.error('Rank service Supabase configuration is missing')
      return json({ error: 'Rank service is not configured' }, 500)
    }

    const supabaseClient = createClient(
      supabaseUrl,
      supabaseAnonKey,
      { global: { headers: { Authorization: authHeader } } },
    )
    const { data: { user }, error: userError } = await supabaseClient.auth.getUser()
    if (userError || !user) return json({ error: 'Invalid or expired token' }, 401)

    const { data: userData, error: userDataError } = await supabaseClient
      .from('users')
      .select('id')
      .eq('auth_id', user.id)
      .maybeSingle()
    if (userDataError) {
      console.error('Failed to load application user', userDataError)
      return json({ error: 'Failed to load user profile' }, 500)
    }
    if (!userData) return json({ error: 'User not found' }, 404)

    const body: unknown = await req.json()
    if (!isRecord(body) || !isIdentifier(body.room_id) || !isIdentifier(body.character_id)) {
      return json({ error: 'room_id and character_id are required' }, 400)
    }

    const { data: room, error: roomError } = await supabaseClient
      .from('rooms')
      .select('id, maps(time_limit, monsters(id, score)), quizzes(id, answer, result_a, result_b, result_c, result_d)')
      .eq('id', body.room_id)
      .maybeSingle()
    if (roomError) {
      console.error('Failed to load room for rank submission', roomError)
      return json({ error: 'Failed to load room' }, 500)
    }
    if (!room) return json({ error: 'Room not found' }, 404)
    const map = room.maps
    if (!map || !Number.isInteger(map.time_limit) || map.time_limit <= 0) {
      console.error('Room has invalid map configuration', room.id)
      return json({ error: 'Room map configuration is invalid' }, 500)
    }

    const { data: ownedCharacter, error: characterError } = await supabaseClient
      .from('users_characters')
      .select('character_id')
      .eq('user_id', userData.id)
      .eq('character_id', body.character_id)
      .maybeSingle()
    if (characterError) {
      console.error('Failed to validate character ownership', characterError)
      return json({ error: 'Failed to validate character ownership' }, 500)
    }
    if (!ownedCharacter) return json({ error: 'Character is not owned by this user' }, 403)

    const roomScoreData = {
      timeLimit: map.time_limit as number,
      monsters: map.monsters ?? [],
      quizzes: room.quizzes ?? [],
    }
    const { duration, score } = calculateRank(body as RankSubmission, roomScoreData)
    const { data: rankData, error: insertError } = await supabaseClient
      .from('ranks')
      .insert({
        user_id: userData.id,
        room_id: room.id,
        character_id: body.character_id,
        duration,
        score,
      })
      .select()
      .single()
    if (insertError) {
      console.error('Failed to save rank data', insertError)
      return json({ error: 'Failed to save rank data' }, 500)
    }

    return json({
      id: rankData.id,
      user_id: userData.id,
      room_id: room.id,
      character_id: body.character_id,
      duration,
      score,
      created_at: rankData.created_at,
    }, 200)
  } catch (error) {
    if (error instanceof RankValidationError || error instanceof SyntaxError) {
      return json({ error: error.message }, 400)
    }
    console.error('Rank service failed unexpectedly', error)
    return json({ error: 'Rank service failed unexpectedly' }, 500)
  }
})

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value)
}


function isIdentifier(value: unknown): value is string {
  return typeof value === 'string' && value.length > 0 && value.length <= 128
}

function json(body: Record<string, unknown>, status: number) {
  return new Response(JSON.stringify(body), {
    headers: { 'Content-Type': 'application/json' },
    status,
  })
}
