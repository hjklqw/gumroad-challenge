import { useState, useEffect, useRef } from 'react'

function randomInteger(min: number, max: number) {
  return Math.floor(Math.random() * (max - min + 1)) + min
}

export function useTypewriterEffect() {
  const [currCharacterIndex, setCurrCharacterIndex] = useState<number>(0)
  const [text, setText] = useState<string>()
  const intervalId = useRef<number>()

  useEffect(() => {
    return () => {
      if (intervalId.current) {
        clearInterval(intervalId.current)
      }
    }
  }, [])

  function startTypewriterEffect(text: string) {
    setText(text)
    const numCharacters = text.length

    setCurrCharacterIndex(0)
    const interval = randomInteger(30, 70)
    intervalId.current = setInterval(() => {
      setCurrCharacterIndex((v) => {
        if (v === numCharacters) {
          clearInterval(intervalId.current)
          return v
        }
        return v + 1
      })
    }, interval)
  }

  function bypassTypewriterEffect(text: string) {
    setText(text)
    setCurrCharacterIndex(text.length)
  }

  return {
    startTypewriterEffect,
    /**
     * Just display the final text, rather than typing it out.
     * Useful for situations where the `text` property returned from this hook
     * is used in display; this avoids the need to add checks or use other variables.
     */
    bypassTypewriterEffect,
    text: text?.substring(0, currCharacterIndex),
    isTypewriterEffectFinished: currCharacterIndex === text?.length,
  }
}
