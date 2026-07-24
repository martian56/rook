#!/bin/sh
# Install or update rook on Linux. Run with:
#
#   curl -fsSL https://raw.githubusercontent.com/martian56/rook/main/scripts/install.sh | bash
#
# Downloads the latest release tarball, finds the rook binary inside it, and
# places it where rook already lives (or ~/.local/bin for a first install).
# If the existing location is not writable, the copy retries with sudo.

set -eu

case "$(uname -s)" in
    Linux) ;;
    *)
        echo "error: prebuilt releases cover Linux and Windows; on this platform build from source (github.com/martian56/rook)" >&2
        exit 1
        ;;
esac

api="https://api.github.com/repos/martian56/rook/releases/latest"
json="$(curl -fsSL -H 'User-Agent: rook-install' "$api")"
tag="$(printf '%s' "$json" | grep -o '"tag_name": *"[^"]*"' | head -n 1 | sed 's/.*"tag_name": *"//; s/"$//')"
url="$(printf '%s' "$json" | grep -o '"browser_download_url": *"[^"]*x86_64\.tar\.gz"' | head -n 1 | sed 's/.*"browser_download_url": *"//; s/"$//')"
if [ -z "$url" ]; then
    echo "error: the latest release has no Linux tarball asset" >&2
    exit 1
fi
echo "Installing rook $tag ..."

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
curl -fsSL -H 'User-Agent: rook-install' -o "$work/rook.tar.gz" "$url"
mkdir -p "$work/unpacked"
tar -xzf "$work/rook.tar.gz" -C "$work/unpacked"
bin="$(find "$work/unpacked" -type f -name rook | head -n 1)"
if [ -z "$bin" ]; then
    echo "error: rook binary not found inside the release tarball" >&2
    exit 1
fi
chmod +x "$bin"

# Prefer the directory of an existing install; fall back to ~/.local/bin.
target=""
if command -v rook >/dev/null 2>&1; then
    target="$(dirname "$(command -v rook)")"
else
    target="$HOME/.local/bin"
    mkdir -p "$target"
fi
dest="$target/rook"

if cp "$bin" "$dest" 2>/dev/null; then
    :
else
    echo "$target needs elevated permissions; retrying with sudo"
    sudo cp "$bin" "$dest"
fi

echo "rook $tag installed to $dest"
case ":$PATH:" in
    *":$target:"*) ;;
    *) echo "Note: $target is not on your PATH; add it to your shell profile." ;;
esac
echo "If rook is running, restart it to use the new version."
