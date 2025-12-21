# ============================
# Badwolf Theme (Dark)
# ============================

# Enable colors
autoload -U colors && colors

# Palette (mapped to terminal colors)
BW_BG='%K{234}'         # #1c1b1a
BW_FG='%F{255}'         # #f8f6f2
BW_PRIMARY='%F{196}'    # #ff0044
BW_SECONDARY='%F{221}'  # #fade3e
BW_ACCENT='%F{148}'     # #afd700
BW_MUTED='%F{245}'      # muted
BW_RESET='%f%k'

# Git info
ZSH_THEME_GIT_PROMPT_PREFIX="${BW_MUTED}git:${BW_ACCENT}"
ZSH_THEME_GIT_PROMPT_SUFFIX="${BW_RESET}"
ZSH_THEME_GIT_PROMPT_DIRTY="${BW_PRIMARY}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="${BW_ACCENT}✓"

# Exit status
function badwolf_exit_status() {
  if [[ $? -ne 0 ]]; then
    echo "${BW_PRIMARY}✘ "
  fi
}

# Prompt
PROMPT='${BW_BG}${BW_FG} %n ${BW_MUTED}at ${BW_SECONDARY}%m \
${BW_MUTED}in ${BW_ACCENT}%~ \
$(git_prompt_info) \
$(badwolf_exit_status)
${BW_PRIMARY}❯ ${BW_RESET}'

# Right prompt (time)
RPROMPT='${BW_MUTED}%D{%H:%M}${BW_RESET}'

