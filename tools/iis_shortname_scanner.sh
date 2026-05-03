#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[ ! -d "$SCRIPT_DIR/IIS-ShortName-Scanner" ] && { echo "Missing IIS-Shortname-Scanner directory."; exit 1; }
[ ! -d "$SCRIPT_DIR/IIS-ShortName-Scanner/release" ] && { echo "Missing release directory in IIS-ShortName-Scanner."; exit 1; }
[ ! -f "$SCRIPT_DIR/IIS-ShortName-Scanner/release/iis_shortname_scanner.jar" ] && { echo "Missing iis_shortname_scanner.jar in release directory."; exit 1; }
cd "$SCRIPT_DIR/IIS-ShortName-Scanner/release" || exit 1
exec java -jar iis_shortname_scanner.jar "$@"
