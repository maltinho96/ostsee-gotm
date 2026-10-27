#!/usr/bin/env bash
# Startet den Container und bindet den aktuellen Projektordner als /work ein.
# Dateien, die im Container entstehen, gehören deinem Benutzer (nicht root).
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "$PWD":/work \
  -w /work \
  -p 8888:8888 \
  ghcr.io/maltinho96/ostsee-gotm:v0.1 "$@"
