#!/usr/bin/env bash
channel=$1
version=$(curl -sL "https://registry.access.redhat.com/v2/ubi9/tags/list?ordering=name&name=$channel" | jq --raw-output --arg s "$channel" '.tags[] | select(. | contains($s))' 2>/dev/null | sort -r | head -n1)
version="${version#*v}"
version="${version#*release-}"
version="${version%_*}"
version="${version%-source*}"
printf "%s" "${version}"
