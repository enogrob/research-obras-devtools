#!/bin/bash
## Crafted (c) 2013~2020 by InMov - Intelligence in Movement
## Prepared : Roberto Nogueira
## Project  : project-obras-devtools
## Reference: bash
## Depends  : foreman, pipe viewer, ansi, revolver
## Purpose  : Develop bash routines in order to help Rails development
##            projects.
## File     : .fobras_utils.sh

# functions
get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

version_gt(){
  test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; 
}

fobras_utils() {
  case $1 in
    --version|-v|v|version)
      if [ -z $OBRAS_UTILS_VERSION ]; then
       V=(`cat $HOME/.obras_utils.sh | grep Version | cut -d':' -f 2`)
       export OBRAS_UTILS_VERSION=${V[0]}
      fi
      ansi --white-intense "Crafted (c) 2013~2020 by InMov - Intelligence in Movement"
      ansi --white --no-newline "Obras Utils ";ansi --white-intense $OBRAS_UTILS_VERSION
      ansi --white "::"
      ;;

    check|-c)
      if [ -z $OBRAS_UTILS_VERSION ]; then
       V=(`cat $HOME/.obras_utils.sh | grep Version | cut -d':' -f 2`)
       export OBRAS_UTILS_VERSION=${V[0]}
      fi
      first_version=$(get_latest_release enogrob/research-obras-devtools)
      second_version=$OBRAS_UTILS_VERSION
      if version_gt $first_version $second_version; then
        ansi --white --no-newline "There is a newer relese of Obras Utils ";ansi --white-intense $first_version
        ansi --white ""
      fi
      ;;  

    update|-u)
      if [ -z $OBRAS_UTILS_VERSION ]; then
       V=(`cat $HOME/.obras_utils.sh | grep Version | cut -d':' -f 2`)
       export OBRAS_UTILS_VERSION=${V[0]}
      fi
      ansi --no-newline --green-intense "==> "; ansi --white-intense "Updating Obras utils "
      ansi --white --no-newline "Obras Utils is at ";ansi --white-intense $OBRAS_UTILS_VERSION
      test -f obras_temp && rm -rf obras_temp*
      test -f .obras_utils.sh && rm -rf .obras_utils.sh
      wget https://raw.githubusercontent.com/enogrob/research-obras-devtools/master/obras/.obras_utils.sh
      sed 's@\$OBRASTMP@'"$OBRAS"'@' .obras_utils.sh > obras_temp
      sed 's@\$OBRASOLDTMP@'"$OBRAS_OLD"'@' obras_temp > obras_temp1 
      cp obras_temp1 $HOME/.obras_utils.sh 
      test -f obras_temp && rm -rf obras_temp*
      test -f .obras_utils.sh && rm -rf .obras_utils.sh
      if ! test -f /usr/local/bin/mycli; then
        echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"mycli\" \033[0m"
        echo ""
        if [ "$OS" == 'Darwin' ]; then
          brew install mycli
        else  
          sudo apt-get install mycli
        fi
      fi
      if ! test -f /usr/local/bin/cowsay; then
        echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"cowsay\" \033[0m"
        echo ""
        if [ "$OS" == 'Darwin' ]; then
          brew install cowsay
        else  
          sudo apt-get install cowsay
        fi
      fi
      source ~/.bashrc
      ansi --white --no-newline "Obras Utils is now updated to ";ansi --white-intense $OBRAS_UTILS_VERSION
      test -f .fobras_utils.sh && rm -rf .fobras_utils.sh
      cowsay "* site command is now faster"
      ;;

    *)
      if [ -z $OBRAS_UTILS_VERSION ]; then
       V=(`cat $HOME/.obras_utils.sh | grep Version | cut -d':' -f 2`)
       export OBRAS_UTILS_VERSION=${V[0]}
      fi
      ansi --white-intense "Crafted (c) 2013~2020 by InMov - Intelligence in Movement"
      ansi --white --no-newline "Obras Utils ";ansi --white-intense $OBRAS_UTILS_VERSION
      ansi --white "::"
      __pr info "obras_utils " "[version/update/check]"
      __pr
      ;;  
    esac  
}