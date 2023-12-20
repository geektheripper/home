#!/usr/bin/env bash

planetarian::tmux::init() {
  touch "$HOME/.tmux.conf"
  planetarian::tmux::ensure_profile_dir >/dev/null
  planetarian::toolbox text-block -f "$HOME/.tmux.conf" -key "planetarian" write <<'EOF'
# Ctrl+A: prefix
set-option -g prefix C-a
unbind-key C-a
bind-key C-a send-prefix

# Alt+Arrow: switch panes
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Shift+Arrow: switch windows
bind -n S-Left previous-window
bind -n S-Right next-window

# Mouse mode
set -g mouse on

# V and H: replace % and |
bind-key v split-window -h
bind-key h split-window -v

# R: reload config
bind-key r source-file ~/.tmux.conf \; display-message "tmux.conf reloaded"
EOF
}

planetarian::tmux::ensure_profile_dir() {
  profile_dir=$HOME/.config/planetarian/tmux/profiles
  if ! [ -d "$profile_dir" ]; then
    mkdir -p "$profile_dir"
    touch "$profile_dir"/default
    cat >"$profile_dir/example" <<EOF
send-keys 'echo Hello Planetarian' C-m
split-window -v
split-window -h
send-keys 'top' C-m
select-pane -t 1
split-window -v
send-keys 'ls' C-m
EOF
  fi
  echo "$profile_dir"
}

planetarian::tmux::select_profile() {
  profile_dir=$(planetarian::tmux::ensure_profile_dir)
  profiles=$(ls "$profile_dir")
  planetarian::toolbox tui select --prompt "📚 Tmux Profiles" --list "${profiles//$'\n'/,}"
}

planetarian::tmux::session() {
  if [ $# -lt 1 ]; then
    sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | tr '\n' ',' | sed 's/planetarian-/☄️  /')
    selected=$(planetarian::toolbox tui select --prompt "🎞️  Tmux Sessions" --list "$sessions" | sed 's/☄️  /planetarian-/')
    tmux attach-session -t "${selected}"
    return
  fi

  session_name="planetarian-$1"
  if tmux has-session -t "$session_name" 2>/dev/null; then
    tmux attach-session -t "$session_name"
    return
  fi

  profile_dir=$(planetarian::tmux::ensure_profile_dir)
  profile_name="$2"
  if [ -z "$profile_name" ]; then tmux new-session -s "$session_name"; fi

  if [ "$profile_name" = "@" ] || [ "$profile_name" = "select" ]; then
    profile_name=$(planetarian::tmux::select_profile)
  fi

  # https://stackoverflow.com/a/1252191
  # shellcheck disable=SC2046
  tmux new-session -s "$session_name" $(sed ':a;N;$!ba;s/\n/ ; /g' "$profile_dir/$profile_name")
}

planetarian::tmux::profile() {
  profile_dir=$(planetarian::tmux::ensure_profile_dir)

  if [ "$TERM_PROGRAM" = "vscode" ]; then
    code "$profile_dir"
    return
  fi

  profile_name=$1

  if [ -z "$profile_name" ]; then
    profile_name=$(planetarian::tmux::select_profile)
  fi

  planetarian::edit "$profile_dir/$profile_name"
}

planetarian::command 'tmux init' planetarian::tmux::init
planetarian::command 'tmux profile' planetarian::tmux::profile
planetarian::command 'tmux s' planetarian::tmux::session
