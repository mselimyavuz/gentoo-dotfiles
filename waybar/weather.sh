#!/usr/bin/env bash
# Clear, no escaping nightmares
wttrbar --location Istanbul --nerd --lang tr | jq -c '
  .icon = (.text | split(" ")[0]) | 
  .text = .icon + " " + (
    (.tooltip | split("\n")[6] | split(" ")[2]) + " " + 
    (.tooltip | split("\n")[0] | gsub("<[^>]+>"; ""))
  )
'

