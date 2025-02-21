# ~/.bash/functions.bash

# Make and CD dir.
fMkcd() {
    mkdir -p "$1" && cd $_
}

# Quick file extraction
fExtract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz) tar xzf "$1" ;;
            *.bz2) bunzip2 "$1" ;;
            *.rar) unrar x "$1" ;;
            *.gz) gunzip "$1" ;;
            *.tar) tar xf "$1" ;;
            *.tbz2) tar xjf "$1" ;;
            *.tgz) tar xzf "$1" ;;
            *.zip) unzip "$1" ;;
            *.Z) uncompress "$1" ;;
            *.7z) 7z x "$1" ;;
            *) echo "Unsupported format: $1" ;;
        esac
    else
        echo "$1 is not a valid file"
    fi
}

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

