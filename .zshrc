# Shared zsh tweaks for team/personal dev machines.
#
# How to use:
#   1. Open your personal ~/.zshrc
#   2. Paste the snippet below (or: `cat /path/to/aitools/.zshrc >> ~/.zshrc`)
#   3. Reload: `source ~/.zshrc` (or open a new terminal)
#
# This file is a reference, not auto-loaded. Zsh only reads ~/.zshrc,
# ~/.zshenv, ~/.zprofile — not files inside project directories.

# ---- Smart tab completion ---------------------------------------------------
# Makes `cd projects<TAB>` complete to `Projects/`, plus partial/substring
# matching on path separators. Equivalent to oh-my-zsh's default
# CASE_SENSITIVE="false" + HYPHEN_INSENSITIVE="true" behavior.
#
# Requires zsh's completion system to be initialized first:
#   autoload -Uz compinit && compinit
#
# Rule 1: case-insensitive  (projects -> Projects)
# Rule 2: match on word boundaries ._-  (my-l<TAB> -> my-long-name)
# Rule 3: substring / partial fuzzy match
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'
