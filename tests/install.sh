#!/bin/sh
set -eu
SOURCE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
WORK=$(mktemp -d "${TMPDIR:-/tmp}/andromeda-test.XXXXXX")
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/bin"
cat > "$WORK/bin/uci" <<'MOCK'
#!/bin/sh
set -eu
[ "$1" = -c ]
config=$2
shift 2
[ "$1" != -q ] || shift
case "$1" in
    get) cat "$config/.media" ;;
    set)
        case "$2" in
            luci.main.mediaurlbase=*) printf '%s\n' "${2#*=}" > "$config/.pending" ;;
            luci.themes.Andromeda=*) : ;;
            *) exit 1 ;;
        esac ;;
    commit)
        if [ -f "$config/.fail-once" ]; then rm "$config/.fail-once"; exit 1; fi
        mv "$config/.pending" "$config/.media" ;;
    *) exit 1 ;;
esac
MOCK
chmod +x "$WORK/bin/uci"
PATH="$WORK/bin:$PATH"
export PATH

fixture() {
    fixture_root="$WORK/$1"
    mkdir -p "$fixture_root/etc/config" "$fixture_root/www/luci-static/bootstrap"
    printf 'config core main\n' > "$fixture_root/etc/config/luci"
    printf '/luci-static/bootstrap\n' > "$fixture_root/etc/config/.media"
}

for backend in ucode lua hybrid; do
    fixture "$backend"
    [ "$backend" = lua ] || mkdir -p "$fixture_root/usr/share/ucode/luci/template"
    [ "$backend" = ucode ] || mkdir -p "$fixture_root/usr/lib/lua/luci/view"
    sh "$SOURCE/install.sh" --source "$SOURCE" --root "$fixture_root"
    [ "$(cat "$fixture_root/etc/config/.media")" = /luci-static/andromeda ]
    [ -s "$fixture_root/www/luci-static/resources/menu-andromeda.js" ]
    [ "$backend" = lua ] || [ -s "$fixture_root/usr/share/ucode/luci/template/themes/andromeda/header.ut" ]
    [ "$backend" = ucode ] || [ -s "$fixture_root/usr/lib/lua/luci/view/themes/andromeda/header.htm" ]
    printf '\n# custom settings\n' >> "$fixture_root/etc/config/andromeda"
    sh "$SOURCE/install.sh" --source "$SOURCE" --root "$fixture_root"
    [ "$(tail -n 1 "$fixture_root/etc/config/andromeda")" = '# custom settings' ]
    [ "$(cat "$fixture_root/etc/andromeda/previous-media")" = /luci-static/bootstrap ]
    sh "$SOURCE/install.sh" --restore --root "$fixture_root"
    [ "$(cat "$fixture_root/etc/config/.media")" = /luci-static/bootstrap ]
done

fixture unsupported
if sh "$SOURCE/install.sh" --source "$SOURCE" --root "$fixture_root"; then exit 1; fi
[ ! -d "$fixture_root/www/luci-static/andromeda" ]

fixture missing
mkdir -p "$fixture_root/usr/share/ucode/luci/template" "$WORK/empty"
if sh "$SOURCE/install.sh" --source "$WORK/empty" --root "$fixture_root"; then exit 1; fi
[ "$(cat "$fixture_root/etc/config/.media")" = /luci-static/bootstrap ]
[ ! -d "$fixture_root/www/luci-static/andromeda" ]

fixture failure
mkdir -p "$fixture_root/usr/share/ucode/luci/template"
touch "$fixture_root/etc/config/.fail-once"
if sh "$SOURCE/install.sh" --source "$SOURCE" --root "$fixture_root"; then exit 1; fi
[ "$(cat "$fixture_root/etc/config/.media")" = /luci-static/bootstrap ]
echo 'PASS: ucode/Lua/hybrid install, preserved settings, reinstall, restore, preflight and activation failure'
