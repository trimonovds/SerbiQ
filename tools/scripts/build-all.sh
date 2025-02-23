#!/bin/bash

# Exit immediately if any command exits with a non-zero status
set -e

swift build --package-path shared
swift build --package-path backend
swift build --package-path ios