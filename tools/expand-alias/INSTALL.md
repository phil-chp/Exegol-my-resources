
1. Dans `~/.exegol/my-resources/setup/zshrc`:

```bash
expand_alias(){
    LBUFFER=$(/opt/my-resources/bin/expand-alias "$BUFFER")
}
zle -N expand_alias
bindkey '^\' expand_alias
```

2. Dans `~/.exegol/my-resources/bin`:

```bash
touch expand-alias
```

```bash
#!/bin/bash
# Tool to expand environment variables and cleanup arguments 
# in a shell-safe way, ready to be used in your writeups.
#
# Usage 1:
# - Write a command with arguments you want to expand.
# - Hit CTRL+\ (or CTRL+$)
#
# Usage 2:
# - Write a command with arguments you want to expand.
# - Go to the start of the command and add `expand-alias`
# - Run
#
# Made by NedX

safe='^[A-Za-z0-9._/:=-]+$'
inline=0

if [ $# -eq 1 ]; then
  inline=1
  eval "set -- $1"
fi

out=()
for arg in "$@"; do
  [ $inline -eq 1 ] && arg=$(printf '%s' "$(envsubst <<<"$arg")")
  [[ "$arg" =~ $safe ]] || arg=\"$(printf '%s' "$arg" | sed 's/[\\$"`!]/\\&/g')\"

  out+=$(printf '%s ' "$arg")
done

printf "%s\n" "${out% }"
```
