#!/usr/bin/env bash
channel=$1
version=$(curl -s "https://registry.hub.docker.com/v2/repositories/redhat/ubi9-micro/tags?ordering=name&name=$channel" | jq --raw-output --arg s "$channel" '.results[] | select(.name | contains($s)) | .name' 2>/dev/null | head -n1)
version="${version#*v}"
version="${version#*release-}"
version="${version%_*}"
version="${version%-*}"
printf "%s" "${version}"
