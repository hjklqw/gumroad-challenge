// Entry point for the build script in your package.json
import '@hotwired/turbo-rails'
import './controllers'

import React from 'react'
import { createRoot } from 'react-dom/client'
import { Homepage } from './home'

import './shared/global.css'

document.addEventListener('turbo:load', () => {
  const root = createRoot(document.body.appendChild(document.createElement('div')))
  root.render(<Homepage />)
})
