import React, { useState, useEffect, useRef } from 'react'

import './styles.css'

import { DEFAULT_QUESTION } from './data'
import { Question } from './models'
import { useTypewriterEffect } from '../shared/useTypewriterEffect'

export const Homepage = () => {
  const questionRef = useRef<HTMLTextAreaElement>(null)

  const [result, setResult] = useState<Question>()
  const [isLoading, setLoading] = useState<boolean>(false)
  const [error, setError] = useState<string>()

  const {
    startTypewriterEffect,
    bypassTypewriterEffect,
    text: typewrittenResult,
    isTypewriterEffectFinished,
  } = useTypewriterEffect()

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
      bypassTypewriterEffect(json.answer)
      if (questionRef.current) {
        questionRef.current.value = json.question
      }
    } catch (e) {
      setError(`A question with an ID of ${id} does not exist.`)
    }
  }

  async function ask(e: React.MouseEvent | React.FormEvent) {
    e.preventDefault()

    const question = questionRef.current?.value || ''

    if (question === '') {
      alert('Please ask a question!')
      return
    }

    setLoading(true)

    try {
      const token =
        document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
      const res = await fetch('/api/ask', {
        method: 'POST',
        headers: {
          'X-CSRF-Token': token,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ question }),
      })

      const json: Question = await res.json()
      setResult(json)
      startTypewriterEffect(json.answer)
      setError(undefined)

      history.pushState(undefined, '', `/question/${json.id}`)
    } catch (e) {
      setError('A server error has occured; please try again later.')
    }

    setLoading(false)
  }

  function askAnotherQuestion() {
    setResult(undefined)
    questionRef.current?.select()
    questionRef.current?.focus()
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

        <form onSubmit={ask}>
          <textarea defaultValue={DEFAULT_QUESTION} ref={questionRef} />

          {result ? (
            <>
              <div className="answer-container">
                <p>
                  <strong>Answer:</strong> <span>{typewrittenResult}</span>
                </p>
                {isTypewriterEffectFinished && (
                  <button onClick={askAnotherQuestion}>Ask another question</button>
                )}
              </div>
            </>
          ) : (
            <div className="buttons" style={result ? { display: 'none' } : undefined}>
              <button type="submit" disabled={isLoading}>
                {isLoading ? 'Asking...' : 'Ask question'}
              </button>
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
