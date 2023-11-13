#!/usr/bin/env bash

version=$(curl -L -s -XGET -H "Accept: application/vnd.github+json"  -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/akimrx/space-engineers-exporter/releases | jq -r .[0].tag_name)
printf "%s" "${version}"
