import React from 'react'

import './styles.css'

import { DEFAULT_QUESTION } from './data'

export const Homepage = () => {
  return (
    <>
      <header>
        <a href="https://www.amazon.com/Minimalist-Entrepreneur-Great-Founders-More/dp/0593192397">
          <img src="/book.png" alt="book" loading="lazy" />
        </a>
        <h1>Ask My Book</h1>
      </header>

      <main>
        <p className="credits">
          This is an experiment in using AI to make my book's content more accessible. Ask
          a question and AI'll answer it in real-time:
        </p>

        <form>
          <textarea defaultValue={DEFAULT_QUESTION} />

          <div className="buttons">
            <button type="submit">Ask question</button>
            <button className="lucky-button" type="button">
              I'm feeling lucky
            </button>
          </div>
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
