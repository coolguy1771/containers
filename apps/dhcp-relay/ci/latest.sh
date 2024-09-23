#!/usr/bin/env bash
version=$(curl -sX GET -H "Accept: application/vnd.github.VERSION.sha" "https://api.github.com/repos/ipxe/ipxe/commits/master" 2>/dev/null)
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
