#!/usr/bin/env bash
set -euo pipefail
project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir"
mkdir -p tests/results tests/screenshots
"scripts/check-dependencies.sh" > tests/results/dependencies.txt 2>&1
python3 -m pytest -q tests/test_lifecycle.py > tests/results/lifecycle.txt
python3 -m pytest -q tests/test_maritime.py > tests/results/maritime.txt
/usr/lib/qt6/bin/qmllint -I /usr/lib/qt6/qml src/theme/Main.qml src/theme/components/*.qml \
    > tests/results/qmllint.txt 2>&1
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software /usr/lib/qt6/bin/qmltestrunner \
    -input tests/qml -o tests/results/qml-tests.txt,txt
python3 scripts/capture.py
printf '%s\n' 'Pruebas completadas; resultados en tests/results y tests/screenshots.'
