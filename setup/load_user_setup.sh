#!/bin/bash
set -e

# This script will be executed on the first startup of each new container with the "my-resources" feature enabled.
# Arbitrary code can be added in this file, in order to customize Exegol (dependency installation, configuration file copy, etc).
# It is strongly advised **not** to overwrite the configuration files provided by exegol (e.g. /root/.zshrc, /opt/.exegol_aliases, ...), official updates will not be applied otherwise.

# Exegol also features a set of supported customization a user can make.
# The /opt/supported_setups.md file lists the supported configurations that can be made easily.

ARCH=$(uname -m)
MY_RES="/opt/my-resources"
TOOLS_DIR="$MY_RES/tools"
BIN_DIR="$MY_RES/bin"

mkdir -p "$MY_RES/bin"

function log() {
    # local start=$SECONDS
    "$@" # 2>&1 >> "$MY_RES/setup_debug.log"
    # local duration=$(( SECONDS - start ))
    # echo "$(date '+%H:%M:%S') - $1 : ${duration}s" >> "$MY_RES/setup_benchmark.log"
}

# > "$MY_RES/setup_debug.log"
# > "$MY_RES/setup_benchmark.log"

# ============================================
# setup

function add_nvim() {
    if [ ! -d "$TOOLS_DIR/nvim/squashfs-root" ]; then
        mkdir -p "$TOOLS_DIR/nvim"
        cd "$TOOLS_DIR/nvim"
        
        if [ "$ARCH" = "aarch64" ]; then
            wget -O "nvim.appimage" "https://github.com/neovim/neovim/releases/download/v0.12.2/nvim-linux-arm64.appimage"
        else
            wget -O "nvim.appimage" "https://github.com/neovim/neovim/releases/download/v0.12.2/nvim-linux-x86_64.appimage"
        fi
        chmod +x nvim.appimage
        ./nvim.appimage --appimage-extract > /dev/null
        rm nvim.appimage
        
        ln -sf "$TOOLS_DIR/nvim/squashfs-root/usr/bin/nvim" "$BIN_DIR/nvim"
        cd - > /dev/null
    fi

    mkdir -p /root/.config /root/.local/share /root/.local/state
    mkdir -p "$MY_RES/setup/nvim-data/share" "$MY_RES/setup/nvim-data/state" "$MY_RES/setup/nvim-data/github-copilot"
    rm -rf /root/.config/nvim /root/.local/share/nvim /root/.local/state/nvim /root/.config/github-copilot

    ln -sf "$MY_RES/setup/nvim" /root/.config/nvim
    ln -sf "$MY_RES/setup/nvim-data/share" /root/.local/share/nvim
    ln -sf "$MY_RES/setup/nvim-data/state" /root/.local/state/nvim
    ln -sf "$MY_RES/setup/nvim-data/github-copilot" /root/.config/github-copilot

    local NODE_PATH=$(which node)
    if [[ "$NODE_PATH" != "$BIN_DIR/node" ]]; then
        ln -sf "$NODE_PATH" "$BIN_DIR/node"
    fi

    if command -v nvim &>/dev/null; then
        nvim --headless "+TSUpdateSync" +qa &>/dev/null || true
    fi
}

log add_nvim

# ============================================
# tools

function add_winrmexec() {
    # submodule
    [ ! -d "$TOOLS_DIR/winrmexec" ] && return
    [ -d "$TOOLS_DIR/winrmexec/venv" ] && return

    cd "$TOOLS_DIR/winrmexec"
    python3 -m venv venv
    ./venv/bin/python3 -m pip install --upgrade pip
    ./venv/bin/python3 -m pip install -r requirements.txt prompt_toolkit
    cd - > /dev/null
}


function add_dnscat2() {
    # submodule
    [ ! -d "$TOOLS_DIR/dnscat2" ] && return
    [ -f "$TOOLS_DIR/dnscat2/server/vendor/.setup_done" ] && return

    echo "rvm_silence_path_mismatch_check_flag=1" > ~/.rvmrc
    cd "$TOOLS_DIR/dnscat2/server" || return
    source /usr/local/rvm/scripts/rvm || true
    rvm use default@dnscat2 --create
    rm -rf .bundle/ vendor/ Gemfile.lock
    bundle install --no-cache
    rvm use default
    touch vendor/.setup_done
    cd - > /dev/null
}


function add_wpprobe() {
    # submodule
    [ ! -d "$TOOLS_DIR/wpprobe" ] && return
    [ -f "$TOOLS_DIR/wpprobe/venv/bin/wpprobe" ] && return

    cd "$TOOLS_DIR/wpprobe" || return
    mkdir -p venv/bin
    go build -ldflags="-s -w" -o venv/bin/wpprobe main.go
    cd - > /dev/null

    ln -sf "$TOOLS_DIR/wpprobe/venv/bin/wpprobe" "$MY_RES/bin/wpprobe"
}


function add_reconspider() {
    # Not a submodule, this version of reconspider is an archive from the CPTS modules
     [ ! -d "$TOOLS_DIR/ReconSpider" ] && return
    [ -d "$TOOLS_DIR/ReconSpider/venv" ] && return

    cd "$TOOLS_DIR/ReconSpider" || return
    python3 -m venv venv
    ./venv/bin/python3 -m pip install --upgrade pip
    ./venv/bin/python3 -m pip install -r requirements.txt
    cd - > /dev/null
}


function add_flask_unsign() {
    # submodule (+ the wordlist submodule)
    [ ! -d "$TOOLS_DIR/Flask-Unsign" ] && return

    if [ ! -d "$MY_RES/lists/Flask-Unsign-Wordlist" ] && [ -d "$TOOLS_DIR/Flask-Unsign-Wordlist" ]; then
        mkdir -p "$MY_RES/lists/Flask-Unsign-Wordlist"
        ln -sf "$TOOLS_DIR/Flask-Unsign-Wordlist/flask_unsign_wordlist/wordlists"/* "$MY_RES/lists/Flask-Unsign-Wordlist/"
    fi

    [ -d "$TOOLS_DIR/Flask-Unsign/venv" ] && return

    cd "$TOOLS_DIR/Flask-Unsign" || return
    python3 -m venv venv
    ./venv/bin/python3 -m pip install --upgrade pip
    ./venv/bin/python3 -m pip install -e ".[wordlist]"
    cd - > /dev/null
}


function add_joomlascan() {
    [ ! -d "$TOOLS_DIR/JoomlaScan" ] && return
    [ -d "$TOOLS_DIR/JoomlaScan/venv" ] && return

    cd "$TOOLS_DIR/JoomlaScan" || return
    virtualenv -p python2.7 venv
    ./venv/bin/pip install requests beautifulsoup4
    sed -i 's/"comptotestdb.txt"/sys.path[0] + "\/comptotestdb.txt"/g' joomlascan.py
    cd - > /dev/null
}

# =============================================
# linux/windows

function add_rcat() {
    [ ! -d "$TOOLS_DIR/rcat" ] && return
    [ -f "$MY_RES/windows/rcat_HOST_PORT.exe" ] && [ -f "$MY_RES/linux/rcat_HOST_PORT" ] && return

    cd "$TOOLS_DIR/rcat" || return
    if [ ! -f "$MY_RES/windows/rcat_HOST_PORT.exe" ]; then
        rustup target add x86_64-pc-windows-gnu > /dev/null 2>&1
        cargo build --release --target x86_64-pc-windows-gnu
        mkdir -p "$MY_RES/windows"
        cp target/x86_64-pc-windows-gnu/release/rcat.exe "$MY_RES/windows/rcat_HOST_PORT.exe"
    fi

    if [ ! -f "$MY_RES/linux/rcat_HOST_PORT" ]; then
        cargo build --release
        mkdir -p "$MY_RES/linux"
        cp target/release/rcat "$MY_RES/linux/rcat_HOST_PORT"
    fi
    cd - > /dev/null
}


function add_ptunnel_ng() {
    [ ! -d "$TOOLS_DIR/ptunnel-ng" ] && return
    [ -f "$MY_RES/linux/ptunnel-ng" ] && return

    cd "$TOOLS_DIR/ptunnel-ng" || return
    ./autogen.sh
    if [ -f "src/ptunnel-ng" ]; then
        mkdir -p "$MY_RES/linux"
        cp src/ptunnel-ng "$MY_RES/linux/ptunnel-ng"
    fi
    cd - > /dev/null
}


function add_chisel() {
    [ ! -d "$TOOLS_DIR/chisel" ] && return
    [ -f "$MY_RES/linux/chisel" ] && [ -f "$MY_RES/windows/chisel.exe" ] && return

    cd "$TOOLS_DIR/chisel" || return
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags="-s -w" -buildvcs=false -o chisel_linux .
    upx -9 chisel_linux > /dev/null 2>&1

    CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -trimpath -ldflags="-s -w" -buildvcs=false -o chisel.exe .
    upx -9 chisel.exe > /dev/null 2>&1

    if [ -f "chisel_linux" ] && [ -f "chisel.exe" ]; then
        mkdir -p "$MY_RES/linux" "$MY_RES/windows"
        mv chisel_linux "$MY_RES/linux/chisel"
        mv chisel.exe "$MY_RES/windows/chisel.exe"
    fi
    cd - > /dev/null
}

# ============================================
# call

# build
log add_winrmexec
log add_dnscat2
log add_wpprobe
log add_reconspider
log add_flask_unsign
log add_joomlascan

# compilation
log add_rcat
log add_ptunnel_ng
log add_chisel
