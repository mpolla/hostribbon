# Print a color ribbon to be included in shell prompts.
function hostribbon {
    # A host pubkey is available
    if [ -e /etc/ssh/ssh_host_rsa_key.pub ]; then
        hostid=$(ssh-keygen -l -f /etc/ssh/ssh_host_rsa_key.pub | cut -d ' ' -f 2 | sed -e 's/://g')
        ribbonlen=3;
    # No host key available, use hostname
    else
        hostid=$(echo $(hostname).$(domainname) | md5sum | cut -d ' ' -f 1)
        ribbonlen=2;
    fi
    # Map to ANSI shell colors 040 .. 047
    for pos in $(seq 1 $ribbonlen); do
        color=$(echo $((0x$(echo $hostid | cut -c $pos))) % 8 | bc)
        echo -n "\[\e[1;4"$color"m\] "
    done
    echo -n "\[\e[0m\]"
}
