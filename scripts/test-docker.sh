#!/bin/sh
set -e

echo "=== Building Docker test image ==="
docker build -f scripts/docker/Dockerfile.test -t koala-clash-test .

echo "=== Running emerge dry-run ==="
docker run --rm koala-clash-test

echo "=== DOCKER TEST PASSED ==="
