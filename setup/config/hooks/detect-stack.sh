#!/bin/bash

# Détecte la stack du projet courant et exporte AGENT_FILTER
if [ -f "nuxt.config.ts" ] || [ -f "nuxt.config.js" ]; then
  AGENT_FILTER="nuxt-expert"
elif [ -f "angular.json" ]; then
  AGENT_FILTER="angular-expert"
elif [ -f "composer.json" ] && grep -q "symfony" composer.json 2>/dev/null; then
  AGENT_FILTER="symfony-expert"
else
  AGENT_FILTER=""
fi

# Retourne le filtre comme additionalContext pour Claude
if [ -n "$AGENT_FILTER" ]; then
  echo "{\"hookSpecificOutput\": {\"hookEventName\": \"SessionStart\", \"additionalContext\": \"Detected stack: $AGENT_FILTER — consider using the @$AGENT_FILTER agent for this project.\"}}"
fi
