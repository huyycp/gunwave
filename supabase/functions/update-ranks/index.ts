import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'

Deno.serve(async (req) => {
  try {
    // Get the authorization header
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Authorization header required' }),
        { 
          headers: { "Content-Type": "application/json" },
          status: 401
        }
      )
    }

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: authHeader },
        },
      }
    )

    // Get auth user
    const { data: { user }, error: userError } = await supabaseClient.auth.getUser()
    console.log('User:', user)
    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: 'Invalid or expired token' }),
        { 
          headers: { "Content-Type": "application/json" },
          status: 401
        }
      )
    }

    // Get app user
    const { data: userData, error: userDataError } = await supabaseClient
      .from('users')
      .select('id')
      .eq('auth_id', user.id)
      .single()

    if (userDataError || !userData) {
      return new Response(
        JSON.stringify({ 
          error: 'User not found in users table',
          auth_id: user.id 
        }),
        { 
          headers: { "Content-Type": "application/json" },
          status: 404
        }
      )
    }

    const appUserId = userData.id

    const gameData = await req.json()
    
    const roomId = gameData.room_id
    const characterId = gameData.character_id
    const timeLeft = gameData.time_left || 0
    const timeLimit = gameData.time_limit || 0
    const monsters = gameData.monsters || []
    const quizzes = gameData.quizzes || []
    
    let totalScore = 0
    
    const percentTimeLeft = timeLimit > 0 ? timeLeft / timeLimit : 0
    totalScore += Math.floor(percentTimeLeft * 100)
    
    monsters.forEach((monster: any) => {
      const monsterScore = monster.score || 0
      totalScore += monster.percent_hp_left * monsterScore
    })
    
    quizzes.forEach((quiz: any) => {
      if (quiz.is_correct) {
        const failAttempts = quiz.fail_attempts || 0
        let quizScore = Math.max(0, 100 - failAttempts * 10)
        totalScore += quizScore
      }
    })
            
    const { data: rankData, error: insertError } = await supabaseClient
      .from('ranks')
      .insert({
        user_id: appUserId,
        room_id: roomId,
        character_id: characterId,
        duration: timeLeft,
        score: totalScore,
      })
      .select()
      .single()
    
    if (insertError) {
      return new Response(
        JSON.stringify({ 
          error: 'Failed to save rank data',
          details: insertError.message 
        }),
        { 
          headers: { "Content-Type": "application/json" },
          status: 500
        }
      )
    }
    
    const response = {
      id: rankData.id,
      user_id: appUserId,
      room_id: roomId,
      character_id: characterId,
      duration: timeLeft,
      score: totalScore,
      created_at: rankData.created_at,
    }

    return new Response(
      JSON.stringify(response),
      { 
        headers: { "Content-Type": "application/json" },
        status: 200
      }
    )
    
  } catch (error) {    
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: "Failed to process game data",
        message: error.message 
      }),
      { 
        headers: { "Content-Type": "application/json" },
        status: 400
      }
    )
  }
})