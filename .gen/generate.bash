#!/bin/bash
# generate.bash rev2
# Usage:
#     generate.bash [do]
#        do:
#            clean: Deletes everything that isn't a dot file or the generate.bash file, then exits
#            regen: Performs a 'clean' before generating
set -euo pipefail

DIR="$(realpath "$PWD")"

[[ -d "$DIR/.git" && -d "$DIR/.gen" \
        && -f "$DIR/.gen/cargo-generate.values.toml" \
        && -f "$DIR/.gen/template-name" ]] || {
    echo "error: generate.bash: not a valid site directory"
    exit 1
}

function do_clean {
    echo -n "generate.bash: cleaning repository ... "

    for f in "$DIR"/*; do
        [[ "$f" != "$DIR/generate.bash" ]] && {
            rm -rf "$f"
        }
    done

    echo "done"
}

function trim_whitespace {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}

SOURCE="sourcetrait/templates"

DO="${1:-}"
[[ -n "$DO" ]] && {
    case "$DO" in
        clean)
            do_clean
            exit 0
            ;;
        local)
            SOURCE="--path "$SRCTRAIT/templates""
            ;;
        regen)
            do_clean
            ;;
        *)
            echo "error: generate.bash: unknown argument: $DO"
            exit 1
            ;;
    esac
}


SITE="$(basename "$DIR")"
GEN_NAME="${SITE//\./-}"
TMPL_NAME="$(trim_whitespace "$(<"$DIR/.gen/template-name")")"

cargo generate --init --overwrite --allow-commands \
    --name "$GEN_NAME" \
    --values-file "$DIR/.gen/cargo-generate.values.toml" \
    $SOURCE "$TMPL_NAME"
