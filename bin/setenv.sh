#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    printf 'Source this script to update the current shell: source %s\n' "$0" >&2
    exit 1
fi

if selected=$(env | fzf --bind='enter:accept'); then
    :
else
    status=$?
    if [[ $status -eq 1 || $status -eq 130 ]]; then
        return 0
    fi
    printf 'fzf failed with status %s\n' "$status" >&2
    return "$status"
fi

if [[ $selected != *=* ]]; then
    printf 'Selected entry is not an environment variable\n' >&2
    return 1
fi

name=${selected%%=*}
if [[ ! $name =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
    printf 'Invalid environment variable name: %s\n' "$name" >&2
    return 1
fi

if ! IFS= read -r -p "New value for ${name}: " value; then
    printf '\nFailed to read new value for %s\n' "$name" >&2
    return 1
fi

if ! printf -v "$name" '%s' "$value" || ! export "$name"; then
    printf 'Could not update environment variable: %s\n' "$name" >&2
    return 1
fi
