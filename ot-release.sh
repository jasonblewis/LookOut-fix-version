#!/bin/sh
# Build a release of the self-hosted LookOut fork (branch "ot").
#
# Builds dist/lookout-fix-version-<version>.xpi from src/, then rewrites
# updates.json to point at the GitHub release asset for that version.
# Commit updates.json, push, and create the release (commands printed at the
# end). Thunderbird reads updates.json through the update_url in
# src/manifest.json.
set -eu
cd "$(dirname "$0")"

repo=jasonblewis/LookOut-fix-version
id=$(python3 -I -c 'import json;print(json.load(open("src/manifest.json"))["browser_specific_settings"]["gecko"]["id"])')
version=$(python3 -I -c 'import json;print(json.load(open("src/manifest.json"))["version"])')
min=$(python3 -I -c 'import json;print(json.load(open("src/manifest.json"))["browser_specific_settings"]["gecko"]["strict_min_version"])')
xpi=dist/lookout-fix-version-$version.xpi

mkdir -p dist
rm -f "$xpi"
# File list matches upstream src/build.sh (which uses 7z and prompts).
(cd src && zip -qr "../$xpi" _locales api icons options scripts \
  background.html background.js message-content-script.js changes.txt LICENSE manifest.json)

hash=$(sha256sum "$xpi" | cut -d' ' -f1)
url=https://github.com/$repo/releases/download/v$version/$(basename "$xpi")

python3 -I - "$id" "$version" "$url" "$hash" "$min" <<'EOF'
import json, sys
id_, version, url, hash_, min_ = sys.argv[1:]
data = {"addons": {id_: {"updates": [{
    "version": version,
    "update_link": url,
    "update_hash": "sha256:" + hash_,
    "applications": {"gecko": {"strict_min_version": min_}},
}]}}}
with open("updates.json", "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
EOF

echo "Built $xpi (sha256 $hash)"
echo "Next:"
echo "  git commit -m 'Release $version' updates.json src/manifest.json && git push origin ot"
echo "  gh release create v$version $xpi --repo $repo --target ot --title 'LookOut fork $version' --notes '...'"
