# .bash_functions
# vi: ft=sh

# GPG Symetric Cipher
fSimpleGpgFileCipher(){
  for vFile in "$*"; do
    [[ -s "$vFile" ]] && gpg -c "$vFile"
  done
}

# GPG Uncipher
fSimpleGpgFileUncipher(){
  for vFile in "$*"; do
    [[ -s "$vFile" ]] && gpg "$vFile";
  done
}

# calc w/ bc
fCalc()
{
    if [[ -z "$*" ]]; then bc -q; else bc <<< "$*"; fi
}

# list of hosts
fSearchHosts()
{
    [[ -n "$*" ]] && grep -wi 'host\|hostname' ~/.ssh/config.d/* | grep -v '^\s*\#' | awk '{print $2}' |grep "$*";
}

# ssh-add
fSshAdd(){
    [[ -n "$*" ]] && ssh-add ~/.ssh/"$*";
}

# ssh-keygen
fSshKeygen(){
    [[ -n "$*" ]] && {
        email="$*"
        if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$  ]]; then
            user=${*%@*}
            domain=${*#*@}
            if [ -f "/home/$USER/.ssh/${domain}_${user}_rsa4096" ]; then 
                echo "${domain}_${user}_rsa4096 keypair allready exist"
            else
                ssh-keygen -q -t rsa -b 4096 -a 100 -C "$email" -f "/home/$USER/.ssh/${domain}_${user}_rsa4096"
            fi
            if [ -f "/home/$USER/.ssh/${domain}_${user}_ed25519" ]; then 
                echo "${domain}_${user}_ed25519 keypair allready exist"
            else
                ssh-keygen -q -t ed25519 -a 100 -C "$email" -f "/home/$USER/.ssh/${domain}_${user}_ed25519"
            fi
        else
            echo "$email is not a valid email"
        fi
    }  
}
