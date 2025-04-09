# Default Theme
# If changes made here does not take effect, then try to re-create the tmux session to force reload.

export TMUX_POWERLINE_STATUS_JUSTIFICATION=left
export TMUX_POWERLINE_STATUS_INTERVAL=1
export TMUX_POWERLINE_SEG_TIME_FORMAT="%R %Z"

TMUX_POWERLINE_SEPARATOR_LEFT_BOLD=""
TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD=""
# TMUX_POWERLINE_SEPARATOR_LEFT_THIN=""
TMUX_POWERLINE_SEPARATOR_RIGHT_THIN=""

: "${TMUX_POWERLINE_DEFAULT_BACKGROUND_COLOR:=#0e3c49}"
: "${TMUX_POWERLINE_DEFAULT_FOREGROUND_COLOR:=#ced4d4}"

: "${TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR:=$TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD}"
: "${TMUX_POWERLINE_DEFAULT_RIGHTSIDE_SEPARATOR:=$TMUX_POWERLINE_SEPARATOR_LEFT_BOLD}"

export TMUX_POWERLINE_WINDOW_STATUS_CURRENT=(
  "#[$(format inverse)]"
  "$TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR"
  " #I#F#W "
  "#[$(format regular)]"
  "$TMUX_POWERLINE_DEFAULT_LEFTSIDE_SEPARATOR"
)

export TMUX_POWERLINE_WINDOW_STATUS_STYLE=(
  "$(format regular)"
)

export TMUX_POWERLINE_WINDOW_STATUS_FORMAT=(
  "#[$(format regular)]"
  " #I#{?window_flags,#F, }#W "
  "$TMUX_POWERLINE_SEPARATOR_RIGHT_THIN"
)

# Format: segment_name background_color foreground_color [non_default_separator] [separator_background_color] [separator_foreground_color] [spacing_disable] [separator_disable]
#
# * background_color and foreground_color. Formats:
#   * Named colors (check man page of tmux for complete list) e.g. black, red, green, yellow, blue, magenta, cyan, white
#   * a hexadecimal RGB string e.g. #ffffff
#   * 'default' for the default tmux color.
# * non_default_separator - specify an alternative character for this segment's separator
# * separator_background_color - specify a unique background color for the separator
# * separator_foreground_color - specify a unique foreground color for the separator
# * spacing_disable - remove space on left, right or both sides of the segment:
#   * "left_disable" - disable space on the left
#   * "right_disable" - disable space on the right
#   * "both_disable" - disable spaces on both sides
#   * - any other character/string produces no change to default behavior (eg "none", "X", etc.)
#
# * separator_disable - disables drawing a separator on this segment, very useful for segments
#   with dynamic background colours (eg tmux_mem_cpu_load):
#   * "separator_disable" - disables the separator
#   * - any other character/string produces no change to default behavior
#
# Example segment with separator disabled and right space character disabled:
# "hostname 33 0 {TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD} 33 0 right_disable separator_disable"
#
# Note that although redundant the non_default_separator, separator_background_color and
# separator_foreground_color options must still be specified so that appropriate index
# of options to support the spacing_disable and separator_disable features can be used

if [ -z "$TMUX_POWERLINE_LEFT_STATUS_SEGMENTS" ]; then
  TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
    "local_hostname 0 15 $TMUX_POWERLINE_SEPARATOR_RIGHT_BOLD 0 7 both_disable separator_disable"
    # "tmux_session_info #0e3c49 7 $TMUX_POWERLINE_SEPARATOR_RIGHT_THIN 0 7"
    "tmux_session_info 0 7"
  )
fi

if [ -z "$TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS" ]; then
  TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
    # "vcs_branch #017008 15"
    # "vcs_compare 3 8"
    # "vcs_staged 9 7"
    # "vcs_modified #0F1363 7"
    # "vcs_others 4 7"
    # "ifstat_sys 0 7"
    "lan_ip 8 7"
    # "pwd 0 7 $TMUX_POWERLINE_SEPARATOR_LEFT_BOLD 0 0 right_disable"
    "local_tmux_mem_cpu_load 0 7 x 0 0 both_disable separator_disable"
    "battery 0 15 $TMUX_POWERLINE_SEPARATOR_LEFT_BOLD 0 0 left_disable"
    "time 8 7 $TMUX_POWERLINE_SEPARATOR_LEFT_BOLD 0 0 right_disable"
  )
fi
