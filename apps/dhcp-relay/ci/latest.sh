#!/usr/bin/env bash
version=$(curl -sX GET -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "https://api.github.com/repos/ipxe/ipxe/tags" | jq --raw-output '.[0].name' 2>/dev/null)
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
