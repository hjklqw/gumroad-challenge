import React, { useState, useEffect, useRef } from 'react'

import './styles.css'

import { DEFAULT_QUESTION } from './data'
import { Question } from './models'

export const Homepage = () => {
  const questionRef = useRef<HTMLTextAreaElement>(null)

  const [result, setResult] = useState<Question>()
  const [error, setError] = useState<string>()

  useEffect(() => {
    const [_, questionId] = window.location.pathname.match(/\/question\/(\w+)/i) || []
    if (questionId) {
      if (Number.isNaN(parseInt(questionId))) {
        setError('Please enter a numeric question ID.')
      } else {
        getQuestionOfId(questionId)
      }
    }
  }, [])

  async function getQuestionOfId(id: string) {
    try {
      const res = await fetch(`/api/question/${id}`)
      const json: Question = await res.json()
      setResult(json)
      if (questionRef.current) {
        questionRef.current.value = json.question
      }
    } catch (e) {
      setError(`A question with an ID of ${id} does not exist.`)
    }
  }

  return (
    <>
      <header>
        <a href="https://www.amazon.com/Minimalist-Entrepreneur-Great-Founders-More/dp/0593192397">
          <img src="/book.png" alt="book" loading="lazy" />
        </a>
        <h1>Ask My Book</h1>
      </header>

      {error && <div className="error">{error}</div>}

      <main>
        <p className="credits">
          This is an experiment in using AI to make my book's content more accessible. Ask
          a question and AI'll answer it in real-time:
        </p>

        <form>
          <textarea defaultValue={DEFAULT_QUESTION} ref={questionRef} />

          {result ? (
            <>
              <div className="answer-container">
                <p>
                  <strong>Answer:</strong> <span>{result.answer}</span>
                </p>
                <button>Ask another question</button>
              </div>
            </>
          ) : (
            <div className="buttons" style={result ? { display: 'none' } : undefined}>
              <button type="submit">Ask question</button>
              <button className="lucky-button" type="button">
                I'm feeling lucky
              </button>
            </div>
          )}
        </form>
      </main>

      <footer>
        <p>
          Project by <a href="https://twitter.com/shl">Sahil Lavingia</a> •{' '}
          <a href="https://github.com/slavingia/askmybook">Fork on GitHub</a>
        </p>
      </footer>
    </>
  )
}
