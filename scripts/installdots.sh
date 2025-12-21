#!/usr/bin/env bash
# from theprimeagen@github
dry_run="0"

if [ -z "$XDG_CONFIG_HOME" ]; then
    echo "no xdg config hom"
    echo "using ~/.config"
    XDG_CONFIG_HOME=$HOME/.config
fi

if [ -z "$DEV_ENV" ]; then
    echo "env var DEV_ENV needs to be present"
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
                log "    removing: rm -rf $directory"
                if [[ $dry_run == "0" ]]; then
                    rm -rf $directory
                fi
                log "    copying: cp -r $c $2"
                if [[ $dry_run == "0" ]]; then
                    cp -r ./$c $2
                fi
            fi
        done

    )
    popd &> /dev/null
}

copy() {
    log "removing: $2"
    if [[ $dry_run == "0" ]]; then
        rm $2
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
~/.config/hypr/monitor-setup.sh