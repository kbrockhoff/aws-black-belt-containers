#!/bin/bash

set -e

PASSWD=$(sf-pwgen -l 16 -c 1)
jq -n --arg pass "$PASSWD" '{"argocdpwd":$pass}'
