#!/bin/bash
set -eou pipefail

HOST=$1

ssh-keyscan $HOST | nix run nixpkgs#ssh-to-age
