# Aliases (for interactive only)
# Remember to use the `\` prefix to avoid alias recursion.

# enable alias expansion when using sudo or pkexec
alias sudo='sudo '
alias pkexec='pkexec '

# explicit PATH propagation for sudo
alias sudop='\sudo PATH="$PATH" '
# pkexec is only useful for GUI applications, it makes sense to make this the default
# unfortunately changing policykit's action for org.freedesktop.policykit.policy seems difficult
alias pkexecp='\pkexec env PATH="$PATH" DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" '

# file manipulation
alias cp='cp --interactive --verbose'
alias mv='mv --interactive --verbose'
alias ln='ln --interactive --verbose'
alias rename='rename --verbose'
alias grep='grep --color=auto'
alias less='less --LONG-PROMPT --HILITE-UNREAD --status-column --chop-long-lines --shift .3'

# view system
alias df='df --human-readable'
alias du='du --human-readable'
alias opened='fuser --verbose'

# navigation
alias ...='cd ../..'
alias ....='cd ../../..'
alias ls='ls --classify --color=auto --human-readable --group-directories-first'
alias ll='ls --classify --color=auto --human-readable -l --group-directories-first'
alias la='ls --classify --color=auto --human-readable -l --almost-all --group-directories-first'

# always load the standard math library which sets scale to 20, makes it easier to do floating point math
alias bc='bc -l'

# ssh related
alias ssh='ssh -F <(cat ~/.ssh/config ~/.ssh/hosts)'
alias scp='scp -F <(cat ~/.ssh/config ~/.ssh/hosts) -C'
alias sftp='sftp -F <(cat ~/.ssh/config ~/.ssh/hosts) -C'
alias sshf='\ssh -F <(cat ~/.ssh/config ~/.ssh/hosts) -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias sshv='\ssh -F <(vagrant ssh-config) default'
alias scpv='\scp -F <(vagrant ssh-config) default -C'
alias sftpv='\sftp -F <(vagrant ssh-config) -C'

# networked dead drops (remember to use GPG encryption)
alias droptext='nc termbin.com 9999'
alias dropfile='curl http://chunk.io/ --upload-file'
alias dropfile2='curl https://transfer.sh/ --upload-file'

# completely make a repository new, like as if you deleted the entire thing and cloned it again
alias git-renew='git reset --hard HEAD && git clean --force -d -x'

# statically archive an entire website and turn it into offline viewable (only for links to the same host)
alias archive-web='wget --mirror --convert-links --adjust-extension'

# calendar
alias cal='cal --monday --color'

ifelse(PH_SYSTEM, CYGWIN, 
    
    # aliases for Cygwin
    alias open='cygstart' # Open things like Windows would 
    alias powershell='powershell -NoLogo –ExecutionPolicy Bypass'
    alias copy-clip='putclip'
    alias paste-clip='getclip'
    alias winln='winln --verbose'

,
    # aliases for non-Cygwin
    alias open='xdg-open' # Open things like your desktop environment would 
    alias copy-clip='xclip -selection c'
    alias paste-clib='xclip -selection clipboard -o'
    # scale-down scales down large images
    # auto-zoom scales up small images
    # keep-zoom-vp is required if there very different sized images, we don't want the window jumping up and down
    # magick-timeout allows using imagemagick to lookup SVG files
    alias feh='feh \
               --scale-down \
               --auto-zoom \
               --borderless \
               --image-bg black \
               --draw-filename \
               --draw-tinted \
               --keep-zoom-vp \
               --magick-timeout 1'
)
