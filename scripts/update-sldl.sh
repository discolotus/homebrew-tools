#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <version>   (example: $0 2.6.1)" >&2
  exit 1
fi

VER="$1"
TAG="v${VER}"
API_URL="https://api.github.com/repos/fiso64/slsk-batchdl/releases/tags/${TAG}"
FORMULA="Formula/sldl.rb"

json="$(curl -fsSL "$API_URL")"

asset_url() {
  local name="$1"
  echo "$json" | python3 - "$name" <<'PY'
import json,sys
name=sys.argv[1]
data=json.load(sys.stdin)
for a in data.get("assets",[]):
    if a.get("name")==name:
        print(a.get("browser_download_url",""))
        break
PY
}

arm_name="sldl_osx-arm64.zip"
intel_name="sldl_osx-x64.zip"
arm_url="$(asset_url "$arm_name")"
intel_url="$(asset_url "$intel_name")"

if [[ -z "$arm_url" || -z "$intel_url" ]]; then
  echo "Could not find expected macOS assets in release $TAG" >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

curl -fsSL "$arm_url" -o "$tmpdir/$arm_name"
curl -fsSL "$intel_url" -o "$tmpdir/$intel_name"

arm_sha="$(shasum -a 256 "$tmpdir/$arm_name" | awk '{print $1}')"
intel_sha="$(shasum -a 256 "$tmpdir/$intel_name" | awk '{print $1}')"

python3 - "$FORMULA" "$VER" "$arm_url" "$arm_sha" "$intel_url" "$intel_sha" <<'PY'
from pathlib import Path
import re,sys
p=Path(sys.argv[1])
ver,arm_url,arm_sha,intel_url,intel_sha=sys.argv[2:]
s=p.read_text()
s=re.sub(r'version\s+"[^"]+"', f'version "{ver}"', s, count=1)
s=re.sub(r'url\s+"https://github.com/fiso64/slsk-batchdl/releases/download/[^"]+/sldl_osx-arm64.zip"', f'url "{arm_url}"', s, count=1)
s=re.sub(r'sha256\s+"[0-9a-f]{64}"', f'sha256 "{arm_sha}"', s, count=1)
# second url/sha pair for intel
s=s.replace('on_intel do\n      url "https://github.com/fiso64/slsk-batchdl/releases/download/v2.6.0/sldl_osx-x64.zip"', f'on_intel do\n      url "{intel_url}"')
# replace next sha in on_intel block
s=re.sub(r'(on_intel do\n\s+url\s+"[^"]+"\n\s+sha256\s+")([0-9a-f]{64})(")', rf'\g<1>{intel_sha}\3', s, count=1)
# update test version string
s=re.sub(r'assert_match\s+"[0-9]+\.[0-9]+\.[0-9]+"', f'assert_match "{ver}"', s, count=1)
p.write_text(s)
PY

echo "Updated $FORMULA to $VER"
echo "  arm64 : $arm_sha"
echo "  x64   : $intel_sha"
echo "Run: brew uninstall sldl && brew install --build-from-source ./Formula/sldl.rb (optional local test)"
