#!/usr/bin/env bash
set -euo pipefail
project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
"$project_dir/scripts/check-dependencies.sh"
exec python3 "$project_dir/scripts/preview.py" "$@"
