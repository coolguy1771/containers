version=$(curl -L -s -XGET -H "Accept: application/vnd.github+json"  -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/backstage/backstage/releases | jq --raw-output '.[] | select(.draft == false) | select(.prerelease == false) | .tag_name' | head -n1)
version="${version#*v}"
printf "%s" "${version}"
