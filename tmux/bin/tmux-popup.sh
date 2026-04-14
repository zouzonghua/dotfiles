#!/usr/bin/env sh

set -eu
trap '' HUP

script_path="$HOME/.config/tmux/bin/tmux-popup.sh"
popup_delay="0.05"

# ------------------------------
# Infrastructure: tmux / shell common operations
# ------------------------------

hash_path() {
  if command -v md5sum >/dev/null 2>&1; then
    printf '%s' "$1" | md5sum | cut -c1-8
  else
    md5 -q -s "$1" | cut -c1-8
  fi
}

option_key() {
  printf '%s_%s\n' "$1" "$(hash_path "$2")"
}

tmux_get_global_option() {
  tmux show-options -gqv "$1" 2>/dev/null || true
}

tmux_set_global_option() {
  tmux set-option -gq "$1" "$2"
}

tmux_unset_global_option() {
  tmux set-option -guq "$1"
}

tmux_ensure_session() {
  session_id="$1"
  workdir="$2"
  shift 2

  if tmux has-session -t "$session_id" 2>/dev/null; then
    return
  fi

  if [ "$#" -eq 0 ]; then
    tmux new-session -d -s "$session_id" -c "$workdir"
  else
    tmux new-session -d -s "$session_id" -c "$workdir" "$@"
  fi
}

tmux_run_after_popup_close() {
  tmux run-shell -b "nohup sh -c 'sleep $popup_delay; $1' >/dev/null 2>&1 &"
}

tmux_close_popup_for_client() {
  tmux display-popup -C -c "$1"
}

tmux_client_has_popup() {
  client_name="$1"
  popup_active="$(tmux display-message -p -c "$client_name" '#{popup_active}' 2>/dev/null || true)"
  [ -n "$popup_active" ] && [ "$popup_active" != "0" ]
}

tmux_display_popup_session() {
  client_name="$1"
  workdir="$2"
  session_id="$3"
  width="$4"
  height="$5"
  title="${6:-}"
  x_pos="${7:-}"
  y_pos="${8:-}"

  set -- tmux display-popup -c "$client_name" -d "$workdir" -w "$width" -h "$height"
  if [ -n "$title" ]; then
    set -- "$@" -T "$title"
  fi
  if [ -n "$x_pos" ]; then
    set -- "$@" -x "$x_pos"
  fi
  if [ -n "$y_pos" ]; then
    set -- "$@" -y "$y_pos"
  fi
  "$@" -E "exec tmux attach-session -t $session_id"
}

# ------------------------------
# Configuration layer: popup kind differences are centralized here
# ------------------------------

popup_session_name() {
  kind="$1"
  workdir="$2"
  printf '%s-%s\n' "$kind" "$(hash_path "$workdir")"
}

popup_option_name() {
  kind="$1"
  client_name="$2"
  option_key "@tmux_${kind}_session" "$client_name"
}

popup_title() {
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

popup_is_session_name() {
  case "$1" in
    claude-*|codex-*|gemini-*|hermes-*|opencode-*|lazygit-*|nnn-*|term-*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

popup_kind_from_session() {
  case "$1" in
    claude-*) printf '%s\n' 'claude' ;;
    codex-*) printf '%s\n' 'codex' ;;
    gemini-*) printf '%s\n' 'gemini' ;;
    hermes-*) printf '%s\n' 'hermes' ;;
    opencode-*) printf '%s\n' 'opencode' ;;
    lazygit-*) printf '%s\n' 'lazygit' ;;
    nnn-*) printf '%s\n' 'nnn' ;;
    term-*) printf '%s\n' 'term' ;;
    *) return 1 ;;
  esac
}

popup_width() {
  case "$1" in
    lazygit) printf '%s\n' '80%' ;;
    nnn) printf '%s\n' '40%' ;;
    term) printf '%s\n' '100%' ;;
    claude|codex|gemini|hermes|opencode) printf '%s\n' '80%' ;;
    *) return 1 ;;
  esac
}

popup_height() {
  case "$1" in
    lazygit) printf '%s\n' '80%' ;;
    nnn) printf '%s\n' '100%' ;;
    term) printf '%s\n' '50%' ;;
    claude|codex|gemini|hermes|opencode) printf '%s\n' '80%' ;;
    *) return 1 ;;
  esac
}

popup_x() {
  case "$1" in
    nnn|term) printf '%s\n' '0' ;;
    claude|codex|gemini|hermes|opencode|lazygit) printf '%s\n' '' ;;
    *) return 1 ;;
  esac
}

popup_y() {
  case "$1" in
    nnn) printf '%s\n' '0' ;;
    term) printf '%s\n' '100%' ;;
    claude|codex|gemini|hermes|opencode|lazygit) printf '%s\n' '' ;;
    *) return 1 ;;
  esac
}

# Here we centralize the differences in starting various popups in one function,
# the upper layer only cares about "opening which popup", without caring about the underlying command.
popup_bootstrap_session() {
  kind="$1"
  session_id="$2"
  workdir="$3"

  case "$kind" in
    lazygit)
      tmux_ensure_session "$session_id" "$workdir" lazygit
      ;;
    nnn)
      tmux_ensure_session "$session_id" "$workdir" env nnn -aP p
      ;;
    term)
      tmux_ensure_session "$session_id" "$workdir"
      ;;
    claude|codex|gemini|hermes|opencode)
      tmux_ensure_session "$session_id" "$workdir" "$kind"
      ;;
    *)
      return 1
      ;;
  esac
}

menu_command_open_ai() {
  tool="$1"
  printf '%s' "run-shell -b 'nohup \"$script_path\" popup/open-ai \"$tool\" \"#{pane_current_path}\" \"#{client_name}\" \"#{pane_id}\" >/dev/null 2>&1 &'"
}

menu_command_context_action() {
  action_name="$1"
  workdir_expr="$2"
  printf '%s' "run-shell -b 'nohup \"$script_path\" context/dispatch \"$action_name\" \"$workdir_expr\" \"#{client_name}\" \"#{pane_id}\" \"#{session_name}\" \"#{@popup_outer_client}\" \"#{@popup_outer_pane}\" >/dev/null 2>&1 &'"
}

# ------------------------------
# Context layer: identify whether the current pane is a normal pane or a popup panel
# ------------------------------

popup_mark_outer_context() {
  session_id="$1"
  outer_client="$2"
  outer_pane="$3"

  tmux set-option -t "$session_id" @popup_managed 1
  tmux set-option -t "$session_id" @popup_outer_client "$outer_client"
  tmux set-option -t "$session_id" @popup_outer_pane "$outer_pane"
}

action_in_popup_context() {
  current_session="$1"
  outer_client="$2"

  [ -n "$outer_client" ] && popup_is_session_name "$current_session"
}

# The popup panel overrides the outer client.
# Here we only use "outer client exists + current session name matches popup rules" to determine the popup panel context,
# to avoid over-reliance on session options and reduce the risk of misjudgment caused by runtime state inconsistencies.
resolve_action_target() {
  current_client="$1"
  current_pane="$2"
  current_session="$3"
  outer_client="$4"
  outer_pane="$5"

  if action_in_popup_context "$current_session" "$outer_client"; then
    printf '%s\n%s\n' "$outer_client" "$outer_pane"
  else
    printf '%s\n%s\n' "$current_client" "$current_pane"
  fi
}

clear_managed_popup_option_by_session() {
  session_id="$1"
  outer_client="$2"
  popup_kind="$(popup_kind_from_session "$session_id" 2>/dev/null || true)"

  case "$popup_kind" in
    lazygit|nnn|term)
      tmux_unset_global_option "$(popup_option_name "$popup_kind" "$outer_client")"
      ;;
  esac
}

# ------------------------------
# Use case layer: close, open, switch popup
# ------------------------------

close_existing_managed_popup_if_needed() {
  option_name="$1"
  active_session="$2"
  outer_client="$3"

  if [ -z "$active_session" ]; then
    return 1
  fi

  if ! tmux has-session -t "$active_session" 2>/dev/null; then
    tmux_unset_global_option "$option_name"
    return 1
  fi

  tmux_unset_global_option "$option_name"

  if action_in_popup_context "${current_session:-}" "${outer_client:-}"; then
    tmux_close_popup_for_client "$outer_client"
    return 0
  fi

  if tmux_client_has_popup "$outer_client"; then
    tmux_close_popup_for_client "$outer_client"
    return 0
  fi

  return 1
}

open_popup_kind() {
  kind="$1"
  workdir="$2"
  outer_client="$3"
  outer_pane="$4"
  session_id="$(popup_session_name "$kind" "$workdir")"

  popup_bootstrap_session "$kind" "$session_id" "$workdir"
  popup_mark_outer_context "$session_id" "$outer_client" "$outer_pane"
  tmux_display_popup_session \
    "$outer_client" \
    "$workdir" \
    "$session_id" \
    "$(popup_width "$kind")" \
    "$(popup_height "$kind")" \
    "$(popup_title "$kind")" \
    "$(popup_x "$kind")" \
    "$(popup_y "$kind")"
}

toggle_managed_popup_kind() {
  kind="$1"
  workdir="$2"
  outer_client="$3"
  outer_pane="$4"
  option_name="$(popup_option_name "$kind" "$outer_client")"
  active_session="$(tmux_get_global_option "$option_name")"
  session_id="$(popup_session_name "$kind" "$workdir")"

  if close_existing_managed_popup_if_needed "$option_name" "$active_session" "$outer_client"; then
    return
  fi

  popup_bootstrap_session "$kind" "$session_id" "$workdir"
  popup_mark_outer_context "$session_id" "$outer_client" "$outer_pane"
  tmux_set_global_option "$option_name" "$session_id"
  tmux_display_popup_session \
    "$outer_client" \
    "$workdir" \
    "$session_id" \
    "$(popup_width "$kind")" \
    "$(popup_height "$kind")" \
    "$(popup_title "$kind")" \
    "$(popup_x "$kind")" \
    "$(popup_y "$kind")"
}

reopen_menu_after_popup_close() {
  menu_name="$1"
  current_session="$2"
  outer_client="$3"
  outer_pane="$4"

  clear_managed_popup_option_by_session "$current_session" "$outer_client"
  tmux_close_popup_for_client "$outer_client"
  tmux_run_after_popup_close "\"$script_path\" $menu_name \"$outer_client\" \"$outer_pane\""
}

dispatch_action_by_context() {
  current_client="$1"
  current_pane="$2"
  current_session="$3"
  outer_client="$4"
  outer_pane="$5"
  popup_action="$6"
  root_action="$7"
  workdir="${8:-}"

  set -- $(resolve_action_target "$current_client" "$current_pane" "$current_session" "$outer_client" "$outer_pane")

  if action_in_popup_context "$current_session" "$outer_client"; then
    "$popup_action" "$workdir" "$1" "$2"
  else
    "$root_action" "$workdir" "$1" "$2"
  fi
}

# ------------------------------
# Display layer: menu
# ------------------------------

show_ai_tools_menu() {
  target_client="$1"
  target_pane="$2"

  tmux display-menu -c "$target_client" -t "$target_pane" -T "#[align=centre]AI tools" -x P -y P \
    "Quick tools" Tab "$(menu_command_context_action menu/show-quick '')" \
    "" "" "" \
    "OpenCode AI" o "$(menu_command_open_ai opencode)" \
    "Claude Code" c "$(menu_command_open_ai claude)" \
    "OpenAI Codex" x "$(menu_command_open_ai codex)" \
    "Google Gemini" g "$(menu_command_open_ai gemini)" \
    "Hermes Agent" h "$(menu_command_open_ai hermes)"
}

show_quick_tools_menu() {
  target_client="$1"
  target_pane="$2"

  tmux display-menu -c "$target_client" -t "$target_pane" -T "#[align=centre]Quick tools" -x P -y P \
    "AI tools" Tab "$(menu_command_context_action menu/show-ai '')" \
    "" "" "" \
    "Files" f "$(menu_command_context_action popup/toggle-files '#{pane_current_path}')" \
    "Git" g "$(menu_command_context_action popup/toggle-git '#{pane_current_path}')" \
    "Terminal" t "$(menu_command_context_action popup/toggle-term '#{pane_current_path}')"
}

show_menu() {
  menu_name="$1"
  target_client="$2"
  target_pane="$3"

  case "$menu_name" in
    menu/show-ai)
      show_ai_tools_menu "$target_client" "$target_pane"
      ;;
    menu/show-quick)
      show_quick_tools_menu "$target_client" "$target_pane"
      ;;
    *)
      exit 1
      ;;
  esac
}

show_menu_action() {
  show_menu menu/show-ai "$2" "$3"
}

show_quick_menu_action() {
  show_menu menu/show-quick "$2" "$3"
}

# ------------------------------
# Adaptation layer: map external commands to internal use cases
# ------------------------------

usecase_open_ai_tool() {
  tool="$1"
  workdir="$2"
  outer_client="$3"
  outer_pane="$4"

  open_popup_kind "$tool" "$workdir" "$outer_client" "$outer_pane"
}

usecase_render_menu() {
  menu_name="$1"
  target_client="$2"
  target_pane="$3"

  show_menu "$menu_name" "$target_client" "$target_pane"
}

usecase_reopen_menu() {
  menu_name="$1"
  current_session="$2"
  outer_client="$3"
  outer_pane="$4"

  reopen_menu_after_popup_close "$menu_name" "$current_session" "$outer_client" "$outer_pane"
}

usecase_toggle_managed_popup() {
  kind="$1"
  workdir="$2"
  outer_client="$3"
  outer_pane="$4"

  toggle_managed_popup_kind "$kind" "$workdir" "$outer_client" "$outer_pane"
}

context_show_ai_menu() {
  usecase_render_menu menu/show-ai "$2" "$3"
}

context_show_quick_menu() {
  usecase_render_menu menu/show-quick "$2" "$3"
}

context_reopen_ai_menu() {
  usecase_reopen_menu menu/show-ai "$@"
}

context_reopen_quick_menu() {
  usecase_reopen_menu menu/show-quick "$@"
}

context_toggle_term_popup() {
  usecase_toggle_managed_popup term "$@"
}

context_toggle_git_popup() {
  usecase_toggle_managed_popup lazygit "$@"
}

context_toggle_files_popup() {
  usecase_toggle_managed_popup nnn "$@"
}

handle_context_action() {
  action_name="$1"
  workdir="$2"
  current_client="$3"
  current_pane="$4"
  current_session="$5"
  outer_client="$6"
  outer_pane="$7"

  case "$action_name" in
    menu/show-ai)
      dispatch_action_by_context "$current_client" "$current_pane" "$current_session" "$outer_client" "$outer_pane" context_reopen_ai_menu context_show_ai_menu "$current_session"
      ;;
    menu/show-quick)
      dispatch_action_by_context "$current_client" "$current_pane" "$current_session" "$outer_client" "$outer_pane" context_reopen_quick_menu context_show_quick_menu "$current_session"
      ;;
    popup/toggle-term)
      dispatch_action_by_context "$current_client" "$current_pane" "$current_session" "$outer_client" "$outer_pane" context_toggle_term_popup context_toggle_term_popup "$workdir"
      ;;
    popup/toggle-git)
      dispatch_action_by_context "$current_client" "$current_pane" "$current_session" "$outer_client" "$outer_pane" context_toggle_git_popup context_toggle_git_popup "$workdir"
      ;;
    popup/toggle-files)
      dispatch_action_by_context "$current_client" "$current_pane" "$current_session" "$outer_client" "$outer_pane" context_toggle_files_popup context_toggle_files_popup "$workdir"
      ;;
    *)
      exit 1
      ;;
  esac
}

case "${1:-}" in
  menu/show-ai|menu/show-quick)
    usecase_render_menu "$1" "$2" "$3"
    ;;
  popup/open-ai)
    usecase_open_ai_tool "$2" "$3" "$4" "$5"
    ;;
  popup/toggle-term)
    usecase_toggle_managed_popup term "$2" "$3" "$4"
    ;;
  popup/toggle-git)
    usecase_toggle_managed_popup lazygit "$2" "$3" "$4"
    ;;
  popup/toggle-files)
    usecase_toggle_managed_popup nnn "$2" "$3" "$4"
    ;;
  context/dispatch)
    handle_context_action "$2" "${3:-}" "${4:-}" "${5:-}" "${6:-}" "${7:-}" "${8:-}"
    ;;
  *)
    exit 1
    ;;
esac
