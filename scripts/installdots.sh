#!/usr/bin/env bash
# from theprimeagen@github
dry_run="0"

require_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        echo "missing source dir: $dir" >&2
        return 1
    fi
    return 0
}

require_file() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "missing source file: $file" >&2
        return 1
    fi
    return 0
}

if [ -z "$XDG_CONFIG_HOME" ]; then
    echo "no xdg config hom"
    echo "using ~/.config"
    XDG_CONFIG_HOME=$HOME/.config
fi

if [ -z "$DEV_ENV" ]; then
    echo "env var DEV_ENV needs to be present"
    exit 1
fi

DEV_ENV="$(realpath -m "$DEV_ENV")"
if [[ ! -d "$DEV_ENV" ]]; then
    echo "DEV_ENV is not a directory: $DEV_ENV"
    exit 1
fi

if [[ $1 == "--dry" ]]; then
    dry_run="1"
fi

log() {
    if [[ $dry_run == "1" ]]; then
        echo "[DRY_RUN]: $1"
    else
        echo "$1"
    fi
}

log "env: $DEV_ENV"

update_files() {
    if [[ ! -d $1 ]]; then
        log "skip (source not found): $1"
        return 0
    fi
    log "updating files from: $1"
    pushd $1 &> /dev/null
    (
        configs=`find . -mindepth 1 -maxdepth 1 -type d`
        for c in $configs; do
            directory=${2%/}/${c#./}
            config_name=${c#./}
            if [[ $config_name == "Code" ]]; then
                log "    syncing (preserving): rsync -a $c/ $directory/"
                if [[ $dry_run == "0" ]]; then
                    rsync -a ./$c/ $directory/
                fi
            else
                if [[ -d ./$c ]]; then
                    log "    removing: rm -rf $directory"
                    if [[ $dry_run == "0" ]]; then
                        rm -rf $directory
                    fi
                    log "    copying: cp -r $c $2"
                    if [[ $dry_run == "0" ]]; then
                        cp -r ./$c $2
                    fi
                else
                    log "    skip (missing): $c"
                fi
            fi
        done

    )
    popd &> /dev/null
}

copy() {
    if [[ ! -f $1 ]]; then
        log "skip (missing file): $1"
        return 0
    fi
    log "removing: $2"
    if [[ $dry_run == "0" ]]; then
        rm -f $2
    fi
    log "copying: $1 to $2"
    if [[ $dry_run == "0" ]]; then
        cp $1 $2
    fi
}

update_files $DEV_ENV/.config $XDG_CONFIG_HOME
update_files $DEV_ENV/.local $HOME/.local

copy $DEV_ENV/.zshrc $HOME/.zshrc

hyprctl reload
if [[ -x $XDG_CONFIG_HOME/hypr/scripts/monitor-setup.sh ]]; then
    $XDG_CONFIG_HOME/hypr/scripts/monitor-setup.sh
else
    log "monitor-setup.sh not found at $XDG_CONFIG_HOME/hypr/scripts/monitor-setup.sh"
fi
