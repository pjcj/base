# Skip the Ubuntu global compinit
skip_global_compinit=1

# Put linuxbrew on PATH here rather than in .zshrc so that non-interactive
# shells (ssh host cmd, and tools such as cmux that resolve commands over ssh)
# find brew binaries like tmux instead of older system ones.
if [[ $EUID -ne 0 && -d /home/linuxbrew/.linuxbrew/bin ]]; then
  path=(/home/linuxbrew/.linuxbrew/bin /home/linuxbrew/.linuxbrew/sbin $path)
fi

# Do not export fpath. An exported FPATH is inherited by child shells and by the
# tmux server, where it overrides zsh's compiled-in default fpath (which
# includes the core functions directory). After a zsh upgrade the inherited path
# can go stale, leaving the core functions unfindable. Keeping FPATH unexported
# lets each shell start from the correct compiled-in default.
typeset +x FPATH
