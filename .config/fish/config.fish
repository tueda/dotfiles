set fish_greeting

function fish_prompt --description 'Write out the prompt'
    set -l last_pipestatus $pipestatus
    set -l normal (set_color normal)

    # Color the prompt differently when we're root
    set -l color_cwd $fish_color_cwd
    set -l prefix
    set -l suffix '>'
    if contains -- $USER root toor
        if set -q fish_color_cwd_root
            set color_cwd $fish_color_cwd_root
        end
        set suffix '#'
    end

    # If we're running via SSH, change the host color.
    set -l color_host $fish_color_host
    if set -q SSH_TTY
        set color_host $fish_color_host_remote
    end

    echo -s \
        $normal [ \
        (set_color $fish_color_user) "$USER" \
        $normal @ \
        (set_color $color_host) (prompt_hostname) \
        $normal ' ' \
        (set_color $color_cwd) (prompt_pwd) \
        (set_color --bold $fish_color_status) (fish_vcs_prompt) \
        $normal ]
    echo -n -s $normal $suffix ' '
end

function fish_right_prompt --description 'Write out the right prompt'
    set -l last_pipestatus $pipestatus
    set -l last_duration $CMD_DURATION

    set -l prompt_status \
        (__fish_print_pipestatus \
            " [" "]" "|" \
            (set_color $fish_color_status) \
            (set_color --bold $fish_color_status) \
            $last_pipestatus \
        )

    set -l duration \
        (echo "$last_duration 1000" | awk '{printf "%.3fs", $1 / $2}')

    echo -s \
        (set_color normal) $prompt_status \
        (set_color $fish_color_autosuggestion) ' ' $duration
end

alias ll='ls -l'
alias la='ls --almost-all'
alias l='ls'

alias screen='screen -D -RR'

function s --description 'sets the starting directory of GNU screen'
    command screen -X chdir (pwd)
end

alias sd='s'

if command -q bat
    alias cat='bat --plain'
end

if command -q colordiff
    if command -q diff-highlight
        function diff --description 'compare files line by line'
            colordiff -u $argv | diff-highlight
        end
    else
        alias diff='colordiff -u'
    end
else
    if command -q diff-highlight
        function diff --description 'compare files line by line'
            command diff -u $argv | diff-highlight
        end
    else
        alias diff='diff -u'
    end
end

if command -q exa
    alias ls='exa --classify --git --group-directories-first --header'
    alias la='ls --all'
end

if command -q vim
    alias vi='vim'
    alias view='vim -R'
    set -x EDITOR (which vim)
    set -x GIT_EDITOR $EDITOR
end
