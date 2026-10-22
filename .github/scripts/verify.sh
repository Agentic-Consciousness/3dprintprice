#!/usr/bin/env bash
# Checks for this repository on GitHub. There was no earlier pipeline, so these are the checks package.json
# defines that can run: type checks, the API tests and every workspace's production build (through turbo).
# The repository has no lockfile, so dependencies install the way a fresh checkout does. Lint is not run yet:
# no ESLint configuration exists in the repository, so its lint scripts cannot run until one is added.
# Nothing deploys and no real credentials are used.
set -euo pipefail
test "${GITHUB_SERVER_URL:?}" = 'https://github.com'
case "${GITHUB_REPOSITORY:?}" in
  HallyAus/3dprintprice|Agentic-Consciousness/3dprintprice) ;;
  *) echo "Unexpected repository: $GITHUB_REPOSITORY" >&2; exit 1 ;;
esac
test "$(git rev-parse HEAD)" = "${GITHUB_SHA:?}"
node -e 'if (process.versions.node.split(".")[0] !== "22") throw Error("Use the Node 22 runtime the project pins")'
unset VERCEL_TOKEN VERCEL_OIDC_TOKEN DATABASE_URL REDIS_URL
export CI=1 NEXT_TELEMETRY_DISABLED=1 TURBO_TELEMETRY_DISABLED=1 NODE_OPTIONS=--max-old-space-size=3072
corepack enable
corepack prepare pnpm@8.15.0 --activate

pnpm install --no-frozen-lockfile
pnpm typecheck
pnpm test
pnpm build
