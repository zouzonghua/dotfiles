#!/usr/bin/env sh

set -eu
trap '' HUP

script_path="$HOME/.config/tmux/bin/tmux-popup.sh"
popup_delay="0.05"

hash_path() {
  if command -v md5sum >/dev/null 2>&1; then
    printf '%s' "$1" | md5sum | cut -c1-8
  else
    md5 -q -s "$1" | cut -c1-8
  fi
}

option_name() {
  printf '%s_%s\n' "$1" "$(hash_path "$2")"
}

show_option() {
  tmux show-options -gqv "$1" 2>/dev/null || true
}

set_option() {
  tmux set-option -gq "$1" "$2"
}

unset_option() {
  tmux set-option -guq "$1"
}

ensure_session() {
  session="$1"
  workdir="$2"
  shift 2

  if tmux has-session -t "$session" 2>/dev/null; then
    return
  fi

  if [ "$#" -eq 0 ]; then
    tmux new-session -d -s "$session" -c "$workdir"
  else
    tmux new-session -d -s "$session" -c "$workdir" "$@"
  fi
}

popup_session_name() {
  kind="$1"
  workdir="$2"
  printf '%s-%s\n' "$kind" "$(hash_path "$workdir")"
}

popup_option_name() {
  kind="$1"
  client="$2"
  option_name "@tmux_${kind}_session" "$client"
}

set_popup_outer_context() {
  session="$1"
  outer_client="$2"
  outer_pane="$3"

  tmux set-option -t "$session" @popup_outer_client "$outer_client"
  tmux set-option -t "$session" @popup_outer_pane "$outer_pane"
}

close_popup() {
  tmux display-popup -C -c "$1"
}

run_after_popup_close() {
  tmux run-shell -b "nohup sh -c 'sleep $popup_delay; $1' >/dev/null 2>&1 &"
}

target_popup_context() {
  current_client="$1"
  current_pane="$2"
  current_session="$3"
  outer_client="$4"
  outer_pane="$5"

  if is_popup_session "$current_session" && [ -n "$outer_client" ]; then
    printf '%s\n%s\n' "$outer_client" "$outer_pane"
  else
    printf '%s\n%s\n' "$current_client" "$current_pane"
  fi
}

in_popup_context() {
  current_session="$1"
  outer_client="$2"

  is_popup_session "$current_session" && [ -n "$outer_client" ]
}

dispatch_popup_action() {
  current_client="$1"
  current_pane="$2"
  current_session="$3"
  outer_client="$4"
  outer_pane="$5"
  popup_action="$6"
  root_action="$7"
  workdir="${8:-}"
  set -- $(target_popup_context "$current_client" "$current_pane" "$current_session" "$outer_client" "$outer_pane")

  if in_popup_context "$current_session" "$outer_client"; then
    "$popup_action" "$workdir" "$1" "$2"
  else
    "$root_action" "$workdir" "$1" "$2"
  fi
}

toggle_session_popup() {
  kind="$1"
  workdir="$2"
  outer_client="$3"
  outer_pane="$4"
  width="$5"
  height="$6"
  x_pos="${7:-}"
  y_pos="${8:-}"
  shift 8
  session="$(popup_session_name "$kind" "$workdir")"
  option="$(popup_option_name "$kind" "$outer_client")"
  active_session="$(show_option "$option")"

  if [ -n "$active_session" ] && tmux has-session -t "$active_session" 2>/dev/null; then
    unset_option "$option"
    close_popup "$outer_client"
    return
  fi

  ensure_session "$session" "$workdir" "$@"
  set_popup_outer_context "$session" "$outer_client" "$outer_pane"
  set_option "$option" "$session"

  set -- tmux display-popup -c "$outer_client" -d "$workdir" -w "$width" -h "$height"
  if [ -n "$x_pos" ]; then
    set -- "$@" -x "$x_pos"
  fi
  if [ -n "$y_pos" ]; then
    set -- "$@" -y "$y_pos"
  fi
  "$@" -E "exec tmux attach-session -t $session"
}

is_popup_session() {
  case "$1" in
    claude-*|codex-*|gemini-*|hermes-*|opencode-*|lazygit-*|nnn-*|term-*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

show_menu() {
  target_client="$1"
  target_pane="$2"

  tmux display-menu -c "$target_client" -t "$target_pane" -T "#[align=centre]AI tools" -x P -y P \
    "OpenCode AI" o "run-shell -b 'nohup \"$script_path\" open opencode \"#{pane_current_path}\" \"#{client_name}\" \"#{pane_id}\" >/dev/null 2>&1 &'" \
    "Claude Code" c "run-shell -b 'nohup \"$script_path\" open claude \"#{pane_current_path}\" \"#{client_name}\" \"#{pane_id}\" >/dev/null 2>&1 &'" \
    "OpenAI Codex" x "run-shell -b 'nohup \"$script_path\" open codex \"#{pane_current_path}\" \"#{client_name}\" \"#{pane_id}\" >/dev/null 2>&1 &'" \
    "Google Gemini" g "run-shell -b 'nohup \"$script_path\" open gemini \"#{pane_current_path}\" \"#{client_name}\" \"#{pane_id}\" >/dev/null 2>&1 &'" \
    "Hermes Agent" h "run-shell -b 'nohup \"$script_path\" open hermes \"#{pane_current_path}\" \"#{client_name}\" \"#{pane_id}\" >/dev/null 2>&1 &'"
}

show_menu_action() {
  show_menu "$2" "$3"
}

open_popup() {
  tool="$1"
  workdir="$2"
  outer_client="$3"
  outer_pane="$4"
  hash="$(hash_path "$workdir")"

  case "$tool" in
    claude|codex|gemini|hermes|opencode)
      session="$tool-$hash"
      ;;
    *)
      exit 1
      ;;
  esac

  ensure_session "$session" "$workdir" "$tool"
  set_popup_outer_context "$session" "$outer_client" "$outer_pane"
  tmux display-popup -c "$outer_client" -d "$workdir" -w80% -h80% -E "exec tmux attach-session -t $session"
}

reopen_menu_from_popup() {
  outer_client="$2"
  outer_pane="$3"

  close_popup "$outer_client"
  run_after_popup_close "\"$script_path\" show \"$outer_client\" \"$outer_pane\""
}

reopen_term_from_popup() {
  workdir="$1"
  outer_client="$2"
  outer_pane="$3"

  close_popup "$outer_client"
  run_after_popup_close "\"$script_path\" open-term \"$workdir\" \"$outer_client\" \"$outer_pane\""
}

toggle_lazygit_popup() {
  workdir="$1"
  outer_client="$2"
  outer_pane="$3"

  toggle_session_popup lazygit "$workdir" "$outer_client" "$outer_pane" 80% 80% "" "" lazygit
}

toggle_nnn_popup() {
  workdir="$1"
  outer_client="$2"
  outer_pane="$3"
  session="$(popup_session_name nnn "$workdir")"
  option="$(popup_option_name nnn "$outer_client")"
  active_session="$(show_option "$option")"

  if [ -n "$active_session" ] && tmux has-session -t "$active_session" 2>/dev/null; then
    unset_option "$option"
    close_popup "$outer_client"
    return
  fi

  ensure_session "$session" "$workdir" env \
    NNN_PLUG='p:preview-tui' \
    NNN_SPLIT='v' \
    NNN_SPLITSIZE='50' \
    NNN_ICONLOOKUP='1' \
    nnn -aP p
  set_popup_outer_context "$session" "$outer_client" "$outer_pane"
  set_option "$option" "$session"
  tmux display-popup -c "$outer_client" -d "$workdir" -w90% -h85% -E "exec tmux attach-session -t $session"
}

open_term_popup() {
  workdir="$1"
  outer_client="$2"
  outer_pane="$3"

  toggle_session_popup term "$workdir" "$outer_client" "$outer_pane" 100% 50% 0 100%
}

smart_action() {
  action="$1"
  workdir="$2"
  current_client="$3"
  current_pane="$4"
  current_session="$5"
  outer_client="$6"
  outer_pane="$7"

  case "$action" in
    show)
      dispatch_popup_action "$current_client" "$current_pane" "$current_session" "$outer_client" "$outer_pane" reopen_menu_from_popup show_menu_action
      ;;
    term)
      dispatch_popup_action "$current_client" "$current_pane" "$current_session" "$outer_client" "$outer_pane" reopen_term_from_popup open_term_popup "$workdir"
      ;;
    lazygit)
      dispatch_popup_action "$current_client" "$current_pane" "$current_session" "$outer_client" "$outer_pane" toggle_lazygit_popup toggle_lazygit_popup "$workdir"
      ;;
    nnn)
      dispatch_popup_action "$current_client" "$current_pane" "$current_session" "$outer_client" "$outer_pane" toggle_nnn_popup toggle_nnn_popup "$workdir"
      ;;
    *)
      exit 1
      ;;
  esac
}

case "${1:-}" in
  show)
    show_menu "$2" "$3"
    ;;
  open)
    open_popup "$2" "$3" "$4" "$5"
    ;;
  open-term)
    open_term_popup "$2" "$3" "$4"
    ;;
  reopen-term)
    reopen_term_from_popup "$2" "$3" "$4"
    ;;
  reopen)
    reopen_menu_from_popup "" "$2" "$3"
    ;;
  show-lazygit)
    toggle_lazygit_popup "$2" "$3" "$4"
    ;;
  smart)
    smart_action "$2" "${3:-}" "${4:-}" "${5:-}" "${6:-}" "${7:-}" "${8:-}"
    ;;
  *)
    exit 1
    ;;
esac
