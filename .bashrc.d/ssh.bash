# ~/.bashrc.d/ssh.bash

# Launch ssh-agent
#[[ ! "${SSH_AGENT_PID}" || -z "${SSH_AGENT_PID}" ]] && { eval $(ssh-agent)&>/dev/null; }

### Dont forget to add this to your .bash_logout :
### [[ "${SSH_AGENT_PID}" && -n "${SSH_AGENT_PID}" ]] && { kill -9 $SSH_AGENT_PID; }

# ssh-add
fSshAdd(){
    [[ -n "$*" ]] && ssh-add ~/.ssh/"$*";
}

# ssh-keygen: one rsa4096 and one ed25519 keypair per email, named
# <domain>_<user>_<type> (see the key naming convention in SSH.md)
fSshKeygen(){
    [[ -n "$*" ]] || return
    local email="$*" user domain type key
    if [[ ! $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        echo "$email is not a valid email"
        return
    fi
    user=${email%@*}
    domain=${email#*@}
    for type in rsa4096 ed25519; do
        key="${domain}_${user}_${type}"
        if [ -f "$HOME/.ssh/$key" ]; then
            echo "$key keypair already exists"
        elif [ "$type" = rsa4096 ]; then
            ssh-keygen -q -t rsa -b 4096 -a 100 -C "$email" -f "$HOME/.ssh/$key"
        else
            ssh-keygen -q -t ed25519 -a 100 -C "$email" -f "$HOME/.ssh/$key"
        fi
    done
}

# Aliases
alias sshadd=fSshAdd
alias sshkg=fSshKeygen
