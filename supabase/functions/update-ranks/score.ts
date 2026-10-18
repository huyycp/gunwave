export type RankRoom = {
  timeLimit: number
  monsters: Array<{ id: string; score: number }>
  quizzes: Array<{
    id: string
    answer: string
    result_a: string
    result_b: string
    result_c: string
    result_d: string
  }>
}

export type RankSubmission = {
  time_left: unknown
  monsters: unknown
  quizzes: unknown
}

export function calculateRank(submission: RankSubmission, room: RankRoom) {
  const timeLeft = integerInRange(submission.time_left, 0, room.timeLimit, 'time_left')
  if (!Array.isArray(submission.monsters) || !Array.isArray(submission.quizzes)) {
    throw new Error('monsters and quizzes must be arrays')
  }

  const monsterScores = new Map(room.monsters.map((monster) => [monster.id, monster.score]))
  let monsterScore = 0
  for (const value of submission.monsters) {
    if (!isRecord(value) || typeof value.monster_id !== 'string') {
      throw new Error('Invalid monster entry')
    }
    const score = monsterScores.get(value.monster_id)
    const percent = finiteNumber(value.percent_hp_left, 'percent_hp_left')
    if (score === undefined || percent < 0 || percent > 1) {
      throw new Error('Monster entry is outside the room limits')
    }
    monsterScore += Math.floor(percent * score)
  }

  if (monsterScore > room.monsters.reduce((sum, monster) => sum + monster.score, 0)) {
    monsterScore = room.monsters.reduce((sum, monster) => sum + monster.score, 0)
  }

  if (submission.quizzes.length !== room.quizzes.length) {
    throw new Error('Every room quiz must be answered')
  }
  const quizzesById = new Map(room.quizzes.map((quiz) => [quiz.id, quiz]))
  const submittedQuizIds = new Set<string>()
  let quizScore = 0
  for (const value of submission.quizzes) {
    if (!isRecord(value) || typeof value.quiz_id !== 'string' || typeof value.answer !== 'string') {
      throw new Error('Invalid quiz entry')
    }
    const quiz = quizzesById.get(value.quiz_id)
    if (!quiz || submittedQuizIds.has(value.quiz_id)) {
      throw new Error('Quiz is not part of this room or was submitted twice')
    }
    submittedQuizIds.add(value.quiz_id)
    const failAttempts = integerInRange(value.fail_attempts, 0, 100_000, 'fail_attempts')
    if (value.answer !== quiz.answer) {
      throw new Error('All room quizzes must be answered correctly')
    }
    quizScore += Math.max(0, 100 - failAttempts * 10)
  }

  const duration = room.timeLimit - timeLeft
  const timeScore = Math.floor((timeLeft / room.timeLimit) * 100)
  return { duration, score: timeScore + monsterScore + quizScore }
}

function integerInRange(value: unknown, min: number, max: number, name: string): number {
  if (typeof value !== 'number' || !Number.isInteger(value) || value < min || value > max) {
    throw new Error(`${name} must be an integer between ${min} and ${max}`)
  }
  return value
}

function finiteNumber(value: unknown, name: string): number {
  if (typeof value !== 'number' || !Number.isFinite(value)) {
    throw new Error(`${name} must be a finite number`)
  }
  return value
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value)
}
