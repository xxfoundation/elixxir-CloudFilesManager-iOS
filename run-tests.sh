#!/bin/sh
set -e

echo "\n\033[1;32m▶ Running package tests on iOS Simulator...\033[0m"
set -o pipefail && xcodebuild -scheme 'xxm-cloud-providers-Package' -sdk iphonesimulator -destination 'platform=iOS Simulator,OS=16.0,name=iPhone 14' test | ./xcbeautify
