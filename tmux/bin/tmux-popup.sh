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
  target_session="$1"
  workdir="$2"
  shift 2

  if tmux has-session -t "$target_session" 2>/dev/null; then
    return
  fi

  if [ "$#" -eq 0 ]; then
    tmux new-session -d -s "$target_session" -c "$workdir"
  else
    tmux new-session -d -s "$target_session" -c "$workdir" "$@"
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

popup_title_for_kind() {
  case "$1" in
    claude) printf '%s\n' 'Claude Code' ;;
    codex) printf '%s\n' 'OpenAI Codex' ;;
    gemini) printf '%s\n' 'Google Gemini' ;;
    hermes) printf '%s\n' 'Hermes Agent' ;;
    opencode) printf '%s\n' 'OpenCode AI' ;;
    lazygit) printf '%s\n' 'Git' ;;
    nnn) printf '%s\n' 'Files' ;;
    term) printf '%s\n' 'Terminal' ;;
    *) printf '%s\n' "$1" ;;
  esac
}

set_popup_outer_context() {
  target_session="$1"
  outer_client="$2"
  outer_pane="$3"

  tmux set-option -t "$target_session" @popup_managed 1
  tmux set-option -t "$target_session" @popup_outer_client "$outer_client"
  tmux set-option -t "$target_session" @popup_outer_pane "$outer_pane"
}

close_popup() {
  tmux display-popup -C -c "$1"
}

client_has_popup() {
  client="$1"
  popup_active="$(tmux display-message -p -c "$client" '#{popup_active}' 2>/dev/null || true)"
  [ -n "$popup_active" ] && [ "$popup_active" != "0" ]
}

handle_active_popup_session() {
  option="$1"
  active_session="$2"
  outer_client="$3"

  if [ -z "$active_session" ]; then
    return 1
  fi

  if ! tmux has-session -t "$active_session" 2>/dev/null; then
    unset_option "$option"
    return 1
  fi

  unset_option "$option"

  if in_popup_context "${current_session:-}" "${outer_client:-}"; then
    close_popup "$outer_client"
    return 0
  fi

  if client_has_popup "$outer_client"; then
    close_popup "$outer_client"
    return 0
  fi

  return 1
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
  title="${7:-}"
  x_pos="${8:-}"
  y_pos="${9:-}"
  shift 9
  popup_session="$(popup_session_name "$kind" "$workdir")"
  option="$(popup_option_name "$kind" "$outer_client")"
  active_session="$(show_option "$option")"

  if handle_active_popup_session "$option" "$active_session" "$outer_client"; then
    return
  fi

  ensure_session "$popup_session" "$workdir" "$@"
  set_popup_outer_context "$popup_session" "$outer_client" "$outer_pane"
  set_option "$option" "$popup_session"

  set -- tmux display-popup -c "$outer_client" -d "$workdir" -w "$width" -h "$height"
  if [ -n "$title" ]; then
    set -- "$@" -T "$title"
  fi
  if [ -n "$x_pos" ]; then
    set -- "$@" -x "$x_pos"
  fi
  if [ -n "$y_pos" ]; then
    set -- "$@" -y "$y_pos"
  fi
  "$@" -E "exec tmux attach-session -t $popup_session"
}

is_popup_session() {
  target_session="$1"
  managed="$(tmux show-options -t "$target_session" -qv @popup_managed 2>/dev/null || true)"
  [ "$managed" = "1" ] || return 1

  case "$target_session" in
    claude-*|codex-*|gemini-*|hermes-*|opencode-*|lazygit-*|nnn-*|term-*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

clear_popup_option_for_session() {
  target_session="$1"
  outer_client="$2"

  case "$target_session" in
    lazygit-*)
      unset_option "$(popup_option_name lazygit "$outer_client")"
      ;;
    nnn-*)
      unset_option "$(popup_option_name nnn "$outer_client")"
      ;;
    term-*)
      unset_option "$(popup_option_name term "$outer_client")"
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

show_named_menu() {
  menu="$1"
  target_client="$2"
  target_pane="$3"

  case "$menu" in
    show)
      show_menu "$target_client" "$target_pane"
      ;;
    show-quick)
      show_quick_menu "$target_client" "$target_pane"
      ;;
    *)
      exit 1
      ;;
  esac
}

show_quick_menu() {
  target_client="$1"
  target_pane="$2"

  tmux display-menu -c "$target_client" -t "$target_pane" -T "#[align=centre]Quick tools" -x P -y P \
    "Files" f "run-shell -b 'nohup \"$script_path\" smart nnn \"#{pane_current_path}\" \"#{client_name}\" \"#{pane_id}\" \"#{session_name}\" \"#{@popup_outer_client}\" \"#{@popup_outer_pane}\" >/dev/null 2>&1 &'" \
    "Git" g "run-shell -b 'nohup \"$script_path\" smart lazygit \"#{pane_current_path}\" \"#{client_name}\" \"#{pane_id}\" \"#{session_name}\" \"#{@popup_outer_client}\" \"#{@popup_outer_pane}\" >/dev/null 2>&1 &'" \
    "Terminal" t "run-shell -b 'nohup \"$script_path\" smart term \"#{pane_current_path}\" \"#{client_name}\" \"#{pane_id}\" \"#{session_name}\" \"#{@popup_outer_client}\" \"#{@popup_outer_pane}\" >/dev/null 2>&1 &'"
}

show_named_menu_action() {
  menu="$1"
  show_named_menu "$menu" "$3" "$4"
}

show_menu_action() {
  show_named_menu_action show "$@"
}

show_quick_menu_action() {
  show_named_menu_action show-quick "$@"
}

open_popup() {
  tool="$1"
  workdir="$2"
  outer_client="$3"
  outer_pane="$4"
  title="$(popup_title_for_kind "$tool")"
  hash="$(hash_path "$workdir")"

  case "$tool" in
    claude|codex|gemini|hermes|opencode)
      popup_session="$tool-$hash"
      ;;
    *)
      exit 1
      ;;
  esac

  ensure_session "$popup_session" "$workdir" "$tool"
  set_popup_outer_context "$popup_session" "$outer_client" "$outer_pane"
  tmux display-popup -c "$outer_client" -d "$workdir" -T "$title" -x100% -y0 -w55% -h100% -E "exec tmux attach-session -t $popup_session"
}

reopen_named_menu_from_popup() {
  menu="$1"
  current_session="$2"
  outer_client="$3"
  outer_pane="$4"

  clear_popup_option_for_session "$current_session" "$outer_client"
  close_popup "$outer_client"
  run_after_popup_close "\"$script_path\" $menu \"$outer_client\" \"$outer_pane\""
}

reopen_menu_from_popup() {
  reopen_named_menu_from_popup show "$@"
}

reopen_quick_menu_from_popup() {
  reopen_named_menu_from_popup show-quick "$@"
}

toggle_lazygit_popup() {
  workdir="$1"
  outer_client="$2"
  outer_pane="$3"

  toggle_session_popup lazygit "$workdir" "$outer_client" "$outer_pane" 80% 80% "$(popup_title_for_kind lazygit)" "" "" lazygit
}

toggle_nnn_popup() {
  workdir="$1"
  outer_client="$2"
  outer_pane="$3"
  popup_session="$(popup_session_name nnn "$workdir")"
  option="$(popup_option_name nnn "$outer_client")"
  active_session="$(show_option "$option")"

  if handle_active_popup_session "$option" "$active_session" "$outer_client"; then
    return
  fi

  ensure_session "$popup_session" "$workdir" env \
    nnn -aP p
  set_popup_outer_context "$popup_session" "$outer_client" "$outer_pane"
  set_option "$option" "$popup_session"
  tmux display-popup -c "$outer_client" -d "$workdir" -T "$(popup_title_for_kind nnn)" -x0 -y0 -w40% -h100% -E "exec tmux attach-session -t $popup_session"
}

open_term_popup() {
  workdir="$1"
  outer_client="$2"
  outer_pane="$3"
  option="$(popup_option_name term "$outer_client")"
  active_session="$(show_option "$option")"

  toggle_session_popup term "$workdir" "$outer_client" "$outer_pane" 100% 50% "$(popup_title_for_kind term)" 0 100%
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
      dispatch_popup_action "$current_client" "$current_pane" "$current_session" "$outer_client" "$outer_pane" reopen_menu_from_popup show_menu_action "$current_session"
      ;;
    show-quick)
      dispatch_popup_action "$current_client" "$current_pane" "$current_session" "$outer_client" "$outer_pane" reopen_quick_menu_from_popup show_quick_menu_action "$current_session"
      ;;
    term)
      dispatch_popup_action "$current_client" "$current_pane" "$current_session" "$outer_client" "$outer_pane" open_term_popup open_term_popup "$workdir"
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
  show|show-quick)
    show_named_menu "$1" "$2" "$3"
    ;;
  open)
    open_popup "$2" "$3" "$4" "$5"
    ;;
  open-term)
    open_term_popup "$2" "$3" "$4"
    ;;
  reopen)
    reopen_named_menu_from_popup show "" "$2" "$3"
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
