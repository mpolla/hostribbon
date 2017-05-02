# Print a color ribbon to be included in shell prompts
#
# bash/dash:
#            . hostribbon.sh
#            PS1="$(hostribbon) $PS1"
#
# zsh:
#            . hostribbon.sh
#            PROMPT="$(hostribbon) $PROMPT"
#

gethostpubkeyfile () {
    keyfile="/etc/ssh/ssh_host_dsa_key.pub"; [ -f $keyfile ] && printf $keyfile && return
    keyfile="/etc/ssh/ssh_host_rsa_key.pub"; [ -f $keyfile ] && printf $keyfile && return
    keyfile="/etc/ssh/ssh_host_ecdsa_key.pub"; [ -f $keyfile ] && printf $keyfile && return
    keyfile="/etc/ssh/ssh_host_ed25519_key.pub"; [ -f $keyfile ] && printf $keyfile && return
}

hostribbon () {
    # A host pubkey is available
    pubkeyfile=$(gethostpubkeyfile)
    type ssh-keygen >/dev/null 2>&1
    sshavailable=$?
    hostfpr=""
    if [ -n "$pubkeyfile" ]; then
        if [ "$sshavailable" -eq "0" ]; then
            # Parse SSH key fingerprint from e.g.
            # 2048 00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd:ee:ff /Users/somebody
            # 1024 SHA256:19n6fkdz0qqmowiBy6XEaA87EuG/jgWUr44ZSBhJl6Y (DSA)
            hostfpr=$(ssh-keygen -l -f $pubkeyfile | cut -d ' ' -f2 | sed -e 's/[A-Z]\+[0-9]\+\://g' | sed -e 's/\://g')
            ribbonlen=3;
        fi
    fi
    # No host key available, use hostname
    if [ "$hostfpr" = "" ]; then
        hostfpr=$(printf $(hostname).$(domainname) | md5sum | cut -d ' ' -f 1)
        ribbonlen=2;
    fi
    # Map host fingerprint to ANSI shell colors 040 .. 047
    for pos in $(seq 1 $ribbonlen); do
        digit=$(printf "$hostfpr" | cut -c $pos | tr '[:lower:]' '[:upper:]')
        bcexpr="ibase=16;$digit % 8"
        color=$(echo "$bcexpr" | bc)
        printf "\033[1;4"$color"m "
    done
    # Reset color
    printf "\033[0m"
}
