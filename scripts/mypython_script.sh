to view python scripts running by user ubuntu

#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────────
# Display running Python processes in a formatted, colorized table
# Usage: .mypython_script.sh [-h|--help] [username]
# ─────────────────────────────────────────────────────────────

SCRIPT_NAME="$(basename "$0")"
TARGET_USER="${1:-$USER}"

case "${1:-}" in
    -h|--help)
        cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS] [USERNAME]

Display running Python processes in a formatted, colorized table.

Options:
  -h, --help    Show this help message

Arguments:
  USERNAME      Target user to filter by (default: \$USER)
EOF
        exit 0
        ;;
esac

ps aux | grep -E '[p]ython|[p]ython3' | grep "^${TARGET_USER}" \
    | grep -Ev 'networkd-dispatcher|unattended-upgrade|vscode-server|'"${SCRIPT_NAME}" \
    | gawk -v target_user="$TARGET_USER" '
BEGIN {
    # Colors
    BOLD    = "\033[1m"
    DIM     = "\033[2m"
    YELLOW  = "\033[33m"
    GREEN   = "\033[32m"
    BLUE    = "\033[34m"
    MAGENTA = "\033[35m"
    CYAN    = "\033[36m"
    RED     = "\033[31m"
    RESET   = "\033[0m"

    # Minimum column widths
    user_width   = 8
    pid_width    = 6
    cpu_width    = 5
    mem_width    = 5
    status_width = 10
    cmd_width    = 36

    total_cpu = 0
    total_mem = 0
}
{
    # Dynamically widen columns as needed
    if (length($1) > user_width)  user_width  = length($1)
    if (length($2) > pid_width)   pid_width   = length($2)
    if (length($3) > cpu_width)   cpu_width   = length($3)
    if (length($4) > mem_width)   mem_width   = length($4)

    # Accumulate totals for summary
    total_cpu += $3
    total_mem += $4

    # Reconstruct the full command (fields 11+)
    command = ""
    for (i = 11; i <= NF; i++) command = command " " $i
    command = substr(command, 2)

    # Extract the Python script path (.py file)
    # BUG FIX: use ordered iteration instead of "for (i in array)"
    script_path = ""
    n_parts = split(command, cmd_parts, " ")
    for (i = 1; i <= n_parts; i++) {
        if (cmd_parts[i] ~ /\.py$/) {
            script_path = cmd_parts[i]
            break
        }
    }

    if (script_path == "") {
        script_path = command
    } else {
        # Get working directory of the process via pwdx
        cmd = "pwdx " $2 " 2>/dev/null | cut -d: -f2-"
        cmd | getline pwd_dir
        close(cmd)
        gsub(/^[ \t]+/, "", pwd_dir)   # Trim leading whitespace

        # Build full path
        if (script_path ~ /^\//) {
            full_path = script_path
        } else if (pwd_dir != "") {
            full_path = pwd_dir "/" script_path
        } else {
            full_path = script_path
        }

        # Normalize: strip /home/<user>/ prefix for brevity
        sub("^/home/" target_user "/", "", full_path)

        # Show at most 3 path components (dir/dir/file.py)
        n_path = split(full_path, path_parts, "/")
        if (n_path > 3) {
            script_path = path_parts[n_path-2] "/" path_parts[n_path-1] "/" path_parts[n_path]
        } else {
            script_path = full_path
        }
    }

    # Get process elapsed time in seconds
    cmd = "ps -o etimes= -p " $2 " 2>/dev/null"
    cmd | getline process_uptime
    close(cmd)
    gsub(/^[ \t]+/, "", process_uptime)   # Trim leading whitespace
    gsub(/[ \t]+$/, "", process_uptime)   # Trim trailing whitespace

    uptime_str = "Up " format_uptime(process_uptime + 0)
    if (length(uptime_str) > status_width) status_width = length(uptime_str)

    if (length(script_path) > cmd_width) cmd_width = length(script_path)

    pid_array[$2] = sprintf("%s|%s|%s|%s|%s|%s", $1, $2, $3, $4, uptime_str, script_path)
}
END {
    count = length(pid_array)
    if (count == 0) {
        printf "%sNo Python processes found for user %s.%s\n", DIM, target_user, RESET
        exit 0
    }

    # Get terminal width (fallback to 80)
    cmd = "tput cols 2>/dev/null"
    cmd | getline term_width
    close(cmd)
    if (term_width + 0 == 0) term_width = 80

    # Adjust command column to fit terminal width
    # 13 = 7 borders (│) + 6 extra padding chars
    fixed_width = user_width + pid_width + cpu_width + mem_width + status_width + 13
    available_cmd_width = term_width - fixed_width
    if (available_cmd_width < 20) available_cmd_width = 20
    if (cmd_width > available_cmd_width) cmd_width = available_cmd_width

    # Table border helpers (dimmed for visual contrast)
    D  = DIM
    R  = RESET
    TL = D "┌" R;  TM = D "┬" R;  TR = D "┐" R
    ML = D "├" R;  MM = D "┼" R;  MR = D "┤" R
    BL = D "└" R;  BM = D "┴" R;  BR = D "┘" R
    H  = D "─" R;  V  = D "│" R

    # Draw top border
    printf "%s%s%s%s%s%s%s%s%s%s%s%s\n", \
        TL, dim_rep("─", user_width), TM, dim_rep("─", pid_width), \
        TM, dim_rep("─", cpu_width),  TM, dim_rep("─", mem_width), \
        TM, dim_rep("─", status_width), TM, dim_rep("─", cmd_width) TR

    # Draw header row (build each cell separately to avoid ANSI/%-*s miscount)
    h_user = sprintf("%s%-*s%s", BOLD, user_width, "USER", RESET)
    h_pid  = sprintf("%s%-*s%s", BOLD, pid_width,  "PID",  RESET)
    h_cpu  = sprintf("%s%*s%s",  BOLD, cpu_width,  "CPU%", RESET)
    h_mem  = sprintf("%s%*s%s",  BOLD, mem_width,  "MEM%", RESET)
    h_up   = sprintf("%s%-*s%s", BOLD, status_width, "UPTIME",  RESET)
    h_cmd  = sprintf("%s%-*s%s", BOLD, cmd_width, "COMMAND", RESET)
    printf "%s%s%s%s%s%s%s%s%s%s%s%s%s\n", \
        V, h_user, V, h_pid, V, h_cpu, V, h_mem, V, h_up, V, h_cmd, V

    # Draw middle border
    printf "%s%s%s%s%s%s%s%s%s%s%s%s\n", \
        ML, dim_rep("─", user_width), MM, dim_rep("─", pid_width), \
        MM, dim_rep("─", cpu_width),  MM, dim_rep("─", mem_width), \
        MM, dim_rep("─", status_width), MM, dim_rep("─", cmd_width) MR

    # Sort by path and print rows
    n = asorti(pid_array, sorted_indices, "compare_paths")
    for (i = 1; i <= n; i++) {
        split(pid_array[sorted_indices[i]], data, "|")

        username = sprintf("%s%-*s%s", YELLOW, user_width, data[1], RESET)
        pid      = sprintf("%s%-*s%s", GREEN, pid_width, data[2], RESET)

        # Highlight high CPU values: >=50 red, >=10 yellow, else blue
        cpu_val   = data[3] + 0
        cpu_color = (cpu_val >= 50) ? RED : (cpu_val >= 10) ? YELLOW : BLUE
        cpu       = sprintf("%s%*s%s", cpu_color, cpu_width, data[3], RESET)

        # Highlight high MEM values: >=50 red, >=10 yellow, else magenta
        mem_val   = data[4] + 0
        mem_color = (mem_val >= 50) ? RED : (mem_val >= 10) ? YELLOW : MAGENTA
        mem       = sprintf("%s%*s%s", mem_color, mem_width, data[4], RESET)

        status = sprintf("%s%-*s%s", CYAN, status_width, data[5], RESET)

        colored_cmd = colorize_path(data[6], cmd_width, RED, BLUE, GREEN, RESET)

        printf "%s%s%s%s%s%s%s%s%s%s%s%s%s\n", \
            V, username, V, pid, V, cpu, V, mem, V, status, V, colored_cmd, V
    }

    # Draw bottom border
    printf "%s%s%s%s%s%s%s%s%s%s%s%s\n", \
        BL, dim_rep("─", user_width), BM, dim_rep("─", pid_width), \
        BM, dim_rep("─", cpu_width),  BM, dim_rep("─", mem_width), \
        BM, dim_rep("─", status_width), BM, dim_rep("─", cmd_width) BR

    # Summary line
    plural = (count == 1) ? "" : "es"
    printf " %s%d process%s%s | CPU: %s%.1f%%%s | MEM: %s%.1f%%%s\n", \
        BOLD, count, plural, RESET, \
        BLUE, total_cpu, RESET, \
        MAGENTA, total_mem, RESET
}

# ── Helper functions ──────────────────────────────────────────

function rep(c, n,    s) {
    s = ""
    while (n-- > 0) s = s c
    return s
}

function dim_rep(c, n) {
    return DIM rep(c, n) RESET
}

function format_uptime(seconds,    d, h, m, s) {
    if (seconds < 60)   return seconds "s"
    if (seconds < 3600) {
        m = int(seconds / 60)
        return m "m"
    }
    if (seconds < 86400) {
        h = int(seconds / 3600)
        m = int((seconds % 3600) / 60)
        return h "h " m "m"
    }
    d = int(seconds / 86400)
    h = int((seconds % 86400) / 3600)
    return d "d " h "h"
}

function compare_paths(i1, v1, i2, v2,    a1, a2, dir1, dir2) {
    split(v1, a1, "|")
    split(v2, a2, "|")
    split(a1[6], dir1, "/")
    split(a2[6], dir2, "/")

    if (dir1[1] < dir2[1]) return -1
    if (dir1[1] > dir2[1]) return 1
    if (a1[6] < a2[6]) return -1
    if (a1[6] > a2[6]) return 1
    return 0
}

function colorize_path(path, width, c1, c2, c3, reset,    \
        parts, n, colored, vis_len, padding, j) {
    vis_len = length(path)

    # Truncate with ellipsis if too wide
    if (vis_len > width) {
        path = substr(path, 1, width - 3) "..."
        vis_len = width
    }

    n = split(path, parts, "/")
    if (n == 3)
        colored = sprintf("%s%s%s/%s%s/%s%s", c1, parts[1], c2, parts[2], c3, parts[3], reset)
    else if (n == 2)
        colored = sprintf("%s%s%s/%s%s", c2, parts[1], c3, parts[2], reset)
    else
        colored = sprintf("%s%s%s", c3, path, reset)

    # Manual padding (ANSI codes break %-*s width calculation)
    padding = ""
    for (j = vis_len; j < width; j++) padding = padding " "

    return colored padding
}
'
