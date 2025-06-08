# ~/.bashrc.d/ssh.bash

# Launch ssh-agent
#[[ ! "${SSH_AGENT_PID}" || -z "${SSH_AGENT_PID}" ]] && { eval $(ssh-agent)&>/dev/null; }

### Dont forget to add this to your .bash_logout :
### [[ "${SSH_AGENT_PID}" && -n "${SSH_AGENT_PID}" ]] && { kill -9 $SSH_AGENT_PID; }

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

# Aliases
alias sshadd=fSshAdd
alias sshkg=fSshKeygen
