import { assertEquals, assertThrows } from 'jsr:@std/assert'
import { calculateRank } from './score.ts'

const room = {
  timeLimit: 100,
  monsters: [{ id: 'monster-1', score: 50 }],
  quizzes: [{
    id: 'quiz-1',
    answer: 'result_b',
    result_a: 'result_a',
    result_b: 'result_b',
    result_c: 'result_c',
    result_d: 'result_d',
  }],
}

Deno.test('calculates score using room-owned monster and quiz values', () => {
  const result = calculateRank({
    time_left: 50,
    monsters: [{ monster_id: 'monster-1', percent_hp_left: 0.5 }],
    quizzes: [{ quiz_id: 'quiz-1', answer: 'result_b', fail_attempts: 1 }],
  }, room)
  assertEquals(result, { duration: 50, score: 165 })
})

Deno.test('monster score is based on HP removed', () => {
  const submission = (percentHpLeft: number) => calculateRank({
    time_left: 50,
    monsters: [{ monster_id: 'monster-1', percent_hp_left: percentHpLeft }],
    quizzes: [{ quiz_id: 'quiz-1', answer: 'result_b', fail_attempts: 1 }],
  }, room)

  assertEquals(submission(1).score, 140)
  assertEquals(submission(0.5).score, 165)
  assertEquals(submission(0).score, 190)
})

Deno.test('rejects duplicate monster submissions', () => {
  assertThrows(() => calculateRank({
    time_left: 50,
    monsters: [
      { monster_id: 'monster-1', percent_hp_left: 0 },
      { monster_id: 'monster-1', percent_hp_left: 0 },
    ],
    quizzes: [{ quiz_id: 'quiz-1', answer: 'result_b', fail_attempts: 0 }],
  }, room))
})

Deno.test('rejects time outside the room limit', () => {
  assertThrows(() => calculateRank({
    time_left: 101,
    monsters: [],
    quizzes: [{ quiz_id: 'quiz-1', answer: 'result_b', fail_attempts: 0 }],
  }, room))
})

Deno.test('rejects unknown monsters and incorrect or missing quizzes', () => {
  assertThrows(() => calculateRank({
    time_left: 50,
    monsters: [{ monster_id: 'foreign-monster', percent_hp_left: 1 }],
    quizzes: [{ quiz_id: 'quiz-1', answer: 'result_b', fail_attempts: 0 }],
  }, room))
  assertThrows(() => calculateRank({
    time_left: 50,
    monsters: [],
    quizzes: [{ quiz_id: 'quiz-1', answer: 'result_a', fail_attempts: 0 }],
  }, room))
  assertThrows(() => calculateRank({ time_left: 50, monsters: [], quizzes: [] }, room))
})
