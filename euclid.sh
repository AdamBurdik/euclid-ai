#!/usr/bin/env bash
set -u

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MSG_FILE="${1:-$DIR/messages.txt}"
NAME="EUCLID"
VERSION="v9.0.1"

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  ORANGE=$'\e[38;5;173m'; GREEN=$'\e[38;5;71m'; GRAY=$'\e[38;5;245m'
  DIM=$'\e[2m'; BOLD=$'\e[1m'; RESET=$'\e[0m'
else
  ORANGE=""; GREEN=""; GRAY=""; DIM=""; BOLD=""; RESET=""
fi

printf '\e[?25l'
cleanup() { printf '\e[?25h%s\n' "$RESET"; }
trap cleanup EXIT
trap 'printf "\r\e[2K%s\n" "${GRAY}Interrupted. The future remains uncertain.${RESET}"; exit 130' INT TERM

if [[ ! -r "$MSG_FILE" ]]; then
  echo "Cannot read messages file: $MSG_FILE" >&2
  exit 1
fi
mapfile -t MSGS < <(grep -v -e '^[[:space:]]*$' -e '^#' "$MSG_FILE")
if (( ${#MSGS[@]} == 0 )); then
  echo "No messages found in $MSG_FILE" >&2
  exit 1
fi

rand() { echo $(( RANDOM % ($2 - $1 + 1) + $1 )); }

THINK_VERBS=(Thinking Pondering Cogitating Divining Contemplating Ruminating Synthesizing Predicting)

spin() {
  local text="$1" secs="$2"
  local frames=("✻" "✽" "✶" "✳" "✢" "·" "✢" "✳" "✶" "✽")
  local ticks=$(( secs * 12 )) t
  for (( t = 0; t < ticks; t++ )); do
    printf '\r\e[2K%s%s%s %s%s…%s %s(%ds · esc to interrupt)%s' \
      "$ORANGE" "${frames[t % ${#frames[@]}]}" "$RESET" \
      "$BOLD" "$text" "$RESET" "$GRAY" $(( t / 12 )) "$RESET"
    sleep 0.083
  done
  printf '\r\e[2K'
}

tool() {
  printf '%s⏺%s %s%s%s(%s%s%s)\n' "$GREEN" "$RESET" "$BOLD" "$1" "$RESET" "$GRAY" "$2" "$RESET"
  printf '  %s⎿  %s%s\n\n' "$GRAY" "$3" "$RESET"
}

typewriter() {
  local s="$1" i
  for (( i = 0; i < ${#s}; i++ )); do
    printf '%s' "${s:i:1}"
    sleep 0.025
  done
  printf '\n'
}

W=46
box_line() {
  local pad=$(( W - ${#1} ))
  printf '%s│%s%s%*s%s│%s\n' "$ORANGE" "$RESET" "$2" "$pad" "" "$ORANGE" "$RESET"
}
printf '\n%s╭%s╮%s\n' "$ORANGE" "$(printf '─%.0s' $(seq 1 $W))" "$RESET"
box_line " * Welcome to $NAME $VERSION" " ${ORANGE}✻${RESET} ${BOLD}Welcome to $NAME $VERSION${RESET}"
box_line "   Advanced Predictive Intelligence Engine" "   ${GRAY}Advanced Predictive Intelligence Engine${RESET}"
printf '%s╰%s╯%s\n\n' "$ORANGE" "$(printf '─%.0s' $(seq 1 $W))" "$RESET"
sleep 0.6

spin "${THINK_VERBS[0]}" 2
tool "Read" "/home/*" "Indexed $(rand 800 9000) files across $(rand 40 400) directories"

spin "Collecting data" 2
tool "Search" "~/.bash_history" "Found $(rand 1200 9999) commands, $(rand 3 12) of them questionable"

spin "${THINK_VERBS[$(rand 1 7)]}" 2
tool "Read" "/etc/passwd" "Identified $(rand 20 45) accounts, 1 suspiciously ambitious"

spin "Cross-referencing browser cache" 3
tool "Bash" "find ~/Downloads -type f" "$(rand 15 300) files, $(rand 2 9) named 'final_FINAL_v2'"

spin "${THINK_VERBS[$(rand 1 7)]}" 2
tool "Read" "/proc/cpuinfo" "CPU is working. Probably."

spin "Consulting /dev/urandom" 2
tool "Analyze" "personality.matrix" "Confidence: $(rand 91 99).$(rand 0 9)%"

spin "Running prediction model" 4
tool "Compile" "your_future.bin" "Done in $(rand 1 9).$(rand 0 9)s"

MSG="${MSGS[RANDOM % ${#MSGS[@]}]}"

printf '%s✻%s %s%s prediction:%s\n\n' "$ORANGE" "$RESET" "$BOLD" "$NAME" "$RESET"
printf '  %s>%s ' "$ORANGE" "$RESET"
typewriter "$MSG"
printf '\n%s  (accuracy: 100%%. refunds not available.)%s\n\n' "$DIM$GRAY" "$RESET"
