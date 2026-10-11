#!/bin/sh
# Install Andromeda on an existing LuCI system, without an OpenWrt SDK.
set -eu

ROOT=
SOURCE=
ACTION=install
WORK=
OLD_MEDIA=
ACTIVATING=0

fail() { echo "Andromeda: $*" >&2; exit 1; }

while [ "$#" -gt 0 ]; do
    case "$1" in
        --restore) ACTION=restore; shift ;;
        --source) [ "$#" -ge 2 ] || fail '--source needs a directory'; SOURCE=$2; shift 2 ;;
        --root) [ "$#" -ge 2 ] || fail '--root needs a directory'; ROOT=${2%/}; shift 2 ;;
        *) fail "Unknown option: $1" ;;
    esac
done

# --root is for staging/tests. Normal router installation requires root.
if [ -z "$ROOT" ]; then
    [ "$(id -u)" = 0 ] || fail 'Run this script as root.'
else
    case "$ROOT" in /*) ;; *) fail '--root must be an absolute directory' ;; esac
fi
command -v uci >/dev/null 2>&1 || fail 'LuCI/UCI is required.'
[ -f "$ROOT/etc/config/luci" ] || fail 'LuCI configuration was not found.'
uci_cmd() { uci -c "$ROOT/etc/config" "$@"; }

cleanup() {
    result=$?
    trap - EXIT
    if [ "$result" -ne 0 ] && [ "$ACTIVATING" = 1 ]; then
        uci_cmd set "luci.main.mediaurlbase=$OLD_MEDIA" && uci_cmd commit luci || true
        echo 'Activation failed; attempted to restore the previous theme.' >&2
    fi
    if [ -n "$WORK" ]; then rm -rf "$WORK"; fi
    exit "$result"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

BACKUP="$ROOT/etc/andromeda/previous-media"
if [ "$ACTION" = restore ]; then
    [ -s "$BACKUP" ] || fail 'No previous theme has been saved.'
    previous=$(cat "$BACKUP")
    case "$previous" in /luci-static/*) ;; *) fail 'Invalid saved theme path.' ;; esac
    [ -d "$ROOT/www$previous" ] || fail 'The previous theme files are missing.'
    uci_cmd set "luci.main.mediaurlbase=$previous"
    uci_cmd commit luci
    echo "Restored $previous. Refresh LuCI with Ctrl+F5."
    exit 0
fi

[ -d "$ROOT/usr/share/ucode/luci/template" ] || fail 'Andromeda requires LuCI ucode templates (OpenWrt 23.05 or later).'

OLD_MEDIA=$(uci_cmd -q get luci.main.mediaurlbase) || fail 'Cannot read the current theme.'
case "$OLD_MEDIA" in /luci-static/*) ;; *) fail 'Unexpected current theme path.' ;; esac
[ -d "$ROOT/www$OLD_MEDIA" ] || fail 'The current theme files are missing.'

if [ -z "$SOURCE" ]; then
    script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
    if [ -f "$script_dir/htdocs/luci-static/resources/menu-andromeda.js" ]; then
        SOURCE=$script_dir
    else
        WORK=$(mktemp -d /tmp/andromeda.XXXXXX)
        url='https://codeload.github.com/kostenkodm/luci-theme-andromeda/tar.gz/refs/heads/main'
        echo 'Downloading Andromeda...'
        if command -v curl >/dev/null 2>&1; then
            curl -fL --retry 2 -o "$WORK/theme.tar.gz" "$url"
        elif command -v wget >/dev/null 2>&1; then
            wget -O "$WORK/theme.tar.gz" "$url"
        else
            fail 'Install wget or curl first.'
        fi
        tar -xzf "$WORK/theme.tar.gz" -C "$WORK"
        SOURCE="$WORK/luci-theme-andromeda-main"
    fi
fi

for file in Makefile htdocs/luci-static/andromeda/main.css htdocs/luci-static/andromeda/login.css htdocs/luci-static/resources/menu-andromeda.js htdocs/luci-static/resources/router-andromeda.js root/etc/config/andromeda; do
    [ -s "$SOURCE/$file" ] || fail "Missing source file: $file"
done
for file in header footer sysauth; do
    [ -s "$SOURCE/ucode/template/themes/andromeda/$file.ut" ] || fail "Missing $file.ut"
done
version=$(sed -n 's/^PKG_VERSION:=[[:space:]]*//p' "$SOURCE/Makefile")
case "$version" in ''|*[!0-9A-Za-z.+_-]*) fail 'Invalid theme version.' ;; esac

mkdir -p "$ROOT/etc/andromeda" "$ROOT/www/luci-static/andromeda" "$ROOT/www/luci-static/resources"
if [ "$OLD_MEDIA" != /luci-static/andromeda ]; then
    printf '%s\n' "$OLD_MEDIA" > "$BACKUP"
fi
cp -R "$SOURCE/htdocs/luci-static/andromeda/." "$ROOT/www/luci-static/andromeda/"
cp -R "$SOURCE/htdocs/luci-static/resources/." "$ROOT/www/luci-static/resources/"
mkdir -p "$ROOT/usr/share/ucode/luci/template/themes/andromeda"
for file in header footer sysauth; do
    # luci.mk replaces this marker in SDK packages; stamp direct installs too.
    sed "s/{# PKG_VERSION #}/$version/g" "$SOURCE/ucode/template/themes/andromeda/$file.ut" > "$ROOT/usr/share/ucode/luci/template/themes/andromeda/$file.ut"
done
if [ ! -f "$ROOT/etc/config/andromeda" ]; then
    cp "$SOURCE/root/etc/config/andromeda" "$ROOT/etc/config/andromeda"
fi

# Select the theme only after every file was copied successfully.
ACTIVATING=1
uci_cmd set 'luci.themes.Andromeda=/luci-static/andromeda'
uci_cmd set 'luci.main.mediaurlbase=/luci-static/andromeda'
uci_cmd commit luci
ACTIVATING=0
echo 'Andromeda installed. Refresh LuCI with Ctrl+F5; no reboot is needed.'
echo 'To restore the previous theme: sh /tmp/install-andromeda.sh --restore'
