# Skip the Ubuntu global compinit
skip_global_compinit=1

# Do not export fpath. An exported FPATH is inherited by child shells and by the
# tmux server, where it overrides zsh's compiled-in default fpath (which
# includes the core functions directory). After a zsh upgrade the inherited path
# can go stale, leaving the core functions unfindable. Keeping FPATH unexported
# lets each shell start from the correct compiled-in default.
typeset +x FPATH
