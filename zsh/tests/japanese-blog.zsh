#!/bin/zsh -f
# Run with zsh -f zsh/tests/japanese-blog.zsh.
set -eo pipefail

zsh_dir=${0:A:h:h}
TERM=xterm source "$zsh_dir/zshenv"
[[ $JAPANESE_BLOG == "$HOME/wiki/lang/japanese/blog" ]]
source "$zsh_dir/aliasrc"
source "$zsh_dir/zshfuncs"
set -u

scratch=$(mktemp -d "${TMPDIR:-/tmp}/jpb-test.XXXXXXXX")
trap 'rm -rf -- "$scratch"' EXIT
export WIKI="$scratch/test wiki"
export JAPANESE_BLOG="$WIKI/lang/japanese/blog"
export calls="$scratch/calls"
mkdir "$scratch/bin"
for tool in cat chmod cmp cp diff grep ln mkdir mktemp rm touch; do
    ln -s "${commands[$tool]}" "$scratch/bin/$tool"
done
path=("$scratch/bin")

# Record each argument separately, including arguments containing spaces.
cat > "$scratch/bin/obsidian" <<'SH'
#!/bin/sh
printf '%s\n' "${0##*/}" "$@" > "$calls"
SH
chmod +x "$scratch/bin/obsidian"
cp "$scratch/bin/obsidian" "$scratch/bin/my editor"
cp "$scratch/bin/obsidian" "$scratch/bin/nvim"
export EDITOR="$scratch/bin/my editor"
assert_opened() {
    printf '%s\n' "$@" | diff - "$calls"
}

date() { [[ $1 == +%F ]] && print '2026-01-02'; }
entry="$JAPANESE_BLOG/2026/01/2026-01-02.md"
jpf
[[ ! -e $JAPANESE_BLOG && ! -e $calls ]]
jpb
printf '# Japanese Blog: 2026-01-02\n\n' | diff - "$entry"
assert_opened obsidian vault=wiki open "path=lang/japanese/blog/2026/01/2026-01-02.md"
print 'Practiced today.' >> "$entry"
cp "$entry" "$scratch/written"
rm "$calls"
jpb
cmp "$scratch/written" "$entry"
assert_opened obsidian vault=wiki open "path=lang/japanese/blog/2026/01/2026-01-02.md"

older='2025/12/2025-12-31 notes.md'
newer='2026/02/2026-02-01.md'
mkdir -p "$JAPANESE_BLOG/2026/02" "$JAPANESE_BLOG/2025/12"
touch "$JAPANESE_BLOG/$newer" "$JAPANESE_BLOG/$older" "$JAPANESE_BLOG/ignore.txt"
fzf() {
    print -rl -- "$@" > "$scratch/picker-options"
    cat > "$scratch/candidates"
    [[ ${cancel:-no} == no ]] || return 130
    print -rN -- "$older"
}
jpf
print -rN -- "$older" '2026/01/2026-01-02.md' "$newer" | cmp - "$scratch/candidates"
for option in --layout=reverse --no-sort --no-tac; do
    grep -Fxq -- "$option" "$scratch/picker-options"
done
assert_opened obsidian vault=wiki open "path=lang/japanese/blog/$older"

rm "$calls"
cp -R "$JAPANESE_BLOG" "$scratch/before-cancel"
cancel=yes jpf && exit 1
[[ ! -e $calls ]]
diff -r "$scratch/before-cancel" "$JAPANESE_BLOG"

rm "$scratch/bin/obsidian"
rehash
jpf
assert_opened 'my editor' "$JAPANESE_BLOG/$older"
unset EDITOR
jpb
assert_opened nvim "$entry"
print 'Japanese blog smoke test passed.'
