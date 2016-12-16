#!/usr/bin/env bash

# Common configuration files to be processed by m4 and put into ~
cp --target-directory='./.build' --recursive \
    ./.aws \
    ./.gnupg \
    ./.jupyter \
    ./.ssh \
    ./.vim \
    ./bin \
    ./modules \
    ./.bash_env.m4 \
    ./.bash_profile.m4 \
    ./.bashrc.m4 \
    ./curlrc \
    ./.ghci \
    ./.gitconfig \
    ./.gitignore_global \
    ./.inputrc \
    ./.my.cnf \
    ./.nanorc \
    ./.netrc \
    ./.sqliterc \
    ./.vimrc \
    ./.zlogin.m4 \
    ./.zshenv.m4 \
    ./.zshrc.m4

if [[ "$(uname -s)" == Linux* ]]; then

    # Linux configuration files to be processed by m4 and put into ~
    cp --target-directory='./.build' --recursive \
        ./.local \
        ./.nixpkgs \
        ./.xmonad \
        ./.Xmodmap \
        ./.Xresources \
        ./.pam_environment.m4 \
        ./.xprofile.m4
    
    # Assuming we are on NIXOS
    system='NIXOS'

    # On Linux, we assume timezone was already setup on OS installation
    tz="$(cat /etc/zoneinfo)"
    tzdir='/etc/zoneinfo'

elif [[ $(uname -s) == CYGWIN* ]]; then

    # Cygwin configuration files to be processed by m4 and put into ~
    cp --target-directory='./.build' --recursive \
        ./AppData \
        ./Documents \
        ./cmd_profile \
        ./minttyrc
    
    system='CYGWIN'

    # Merge Windows User Temporary with Cygwin /tmp
    echo 'none /tmp usertemp binary,posix=0 0 0' >> /etc/fstab
    
    # Acquire timezone information from Windows
    tz="$(./bin/tz-windows-to-iana "$(tzutil /l | grep --before-context=1 "$(tzutil /g)" | head --lines=1)")"
    
    if [ -f /usr/share/zoneinfo/"$tz" ]; then
        echo "$tz" > /etc/timezone
        ln --symbolic --force /usr/share/zoneinfo/"$tz" /etc/localtime
        ln --symbolic --force /usr/share/zoneinfo /etc/zoneinfo
        tzdir="/usr/share/zoneinfo"
    else 
        echo "Unable to acquire IANA timezone information, update the timezone matching script, or do it manually."
    fi
    
    # Change default shell to zsh
    # On Linux we could use chsh --shell
    # But Cygwin doesn't support it, so we just need to edit it using sed
    sed --in-place "/^${USER}/ s/:[^:][^:]*$/:"${$(which zsh)//\//\\\/}"/" /etc/passwd
    
    # Setting up Cygserver requires first deleting the cygserver.conf
    # The service will be setup 
    rm --force /etc/cygserver.conf
    cygrunsrv --remove='cygserver' || true
    echo "yes" | cygserver-config
    cygrunsrv --start='cygserver'
    
    # Install Python packages on Cygwin
    # Executables should be preferably Python 3, and will be installed in ~/.local/bin
    pip2 --user --requirements "./pip2_requirements.txt"
    pip3 --user --requirements "./pip3_requirements.txt"
    
    # Install via the source installation scripts
    # All of these are Makefiles with install and uninstall targets
    for dir in ./source_installation_scripts/*/; do
        make --directory="$dir" install
    done
    
fi

# Note that `PH_` is our namespace meaning "PolyHack"
find ./.build -name '*.m4' -not -path './build/modules/*' \
    -exec m4 \
    --include='./.includes' \
    --define=PH_SYSTEM="$system" \
    --define=PH_TZ="$tz" \
    --define=PH_TZDIR="$tzdir" \
    '{}' > '{}.processed' \; \
    -exec rename '.m4.processed' '' '{}.processed' \; \
    -delete

# Copy files from ./.build into ~
# Where --archive means: --recursive --links --perms --times --group --owner
rsync --update --checksum --archive "./.build/" "${HOME}/"

# Make ~/.ssh directory and subdirectories 700, but the files 600
# This requires wiping out any execute permissions first
chmod --recursive a-x ~/.ssh
chmod --recursive u=rwX,g=,o= ~/.ssh
