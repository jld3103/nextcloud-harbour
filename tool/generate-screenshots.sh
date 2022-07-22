#!/bin/bash
set -euxo pipefail
cd "$(dirname "$0")/.."

(
  cd packages/neon
  fvm flutter drive \
    --driver=test_driver/integration_test.dart \
    --target=integration_test/screenshot_test.dart \
    -d emulator
)
