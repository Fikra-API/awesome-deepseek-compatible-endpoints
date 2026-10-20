#!/bin/bash
# Regenerates endpoints.json from README rows: reads PR-added README rows and append..
# Hand-run only; accepts a row like: | [Name](url) | https://host/v1 | Region | Billing | models ; | also | [pricing](url) |
set -euo pipefail
echo "sync-json.sh: write endpoints.json from README rows, or skip generated merges"
