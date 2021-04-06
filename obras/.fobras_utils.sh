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
      
      if ! test -f /usr/local/bin/mycli && ! test -f /usr/bin/mycli; then
        echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"mycli\" \033[0m"
        echo ""
        if [ "$OS" == 'Darwin' ]; then
          brew install mycli
        else  
          sudo apt-get install mycli
        fi
      fi

      if ! test -f /usr/local/bin/wget && ! test -f /usr/bin/wget; then
        echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"wget\" \033[0m"
        echo ""
        if [ "$OS" == 'Darwin' ]; then
          brew install wget
        else  
          sudo apt-get install wget
        fi
      fi

      if ! test -f /usr/local/bin/cowsay && ! test -f /usr/games/cowsay; then
        echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"cowsay\" \033[0m"
        echo ""
        if [ "$OS" == 'Darwin' ]; then
          brew install cowsay
        else  
          sudo apt-get install cowsay
        fi
      fi

      if ! test -f /usr/local/bin/pipx && ! test -f /usr/bin/pip3; then
        echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"pip\" \033[0m"
        echo ""
        if [ "$OS" == 'Darwin' ]; then
          brew install pipx
          pipx ensurepath
        else 
          sudo apt-get install python3-pip
        fi
      fi

      if ! test -f $HOME/.local/bin/iredis && ! test -f /usr/local/bin/iredis; then
        echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"iredis\" \033[0m"
        echo ""
        if [ "$OS" == 'Darwin' ]; then
          brew install iredis
        else 
          test -f /tmp/iredis.tar.gz && rm -f /tmp/iredis.tar.gz
          test -f /tmp/iredis && rm -f /tmp/iredis
          test -d /tmp/lib && rm -rf /tmp/lib
          wget "https://github.com/laixintao/iredis/releases/latest/download/iredis.tar.gz" && test -f ./iredis.tar.gz && tar -xzf ./iredis.tar.gz -C /tmp && sudo mv /tmp/iredis /usr/local/bin && sudo mv /tmp/lib /usr/local/bin
          test -f /tmp/iredis.tar.gz && rm -f /tmp/iredis.tar.gz
          test -f /tmp/iredis && rm -f /tmp/iredis
          test -d /tmp/lib && rm -rf /tmp/lib
        fi
      fi

      if ! test -f /usr/local/bin/ngrok && ! test -f $HOME/bin/ngrok; then
        echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"ngrok\" \033[0m"
        echo ""
        if [ "$OS" == 'Darwin' ]; then
          brew cask install ngrok
        else  
          test -f ./ngrok-stable-linux-amd64.zip && rm -f ngrok-stable-linux-amd64.zip
          test -f ./ngrok && rm -f ngrok
          wget "https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip" && test -f ./ngrok-stable-linux-amd64.zip && unzip ngrok-stable-linux-amd64.zip && sudo mv ./ngrok /usr/local/bin
          test -f ./ngrok-stable-linux-amd64.zip && rm -f ngrok-stable-linux-amd64.zip
          test -f ./ngrok && rm -f ngrok
        fi
      fi
      
      if [ "$OS" != 'Darwin' ]; then
        if ! test -f /bin/netstat && ! test -f /usr/bin/netstat; then
          echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"net-tools\" \033[0m"
          echo ""
          sudo apt-get install net-tools
        fi 
      fi

      if ! test -f /usr/local/bin/lazygit && ! test -f /usr/bin/lazygit; then
        echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"Lazygit\" \033[0m"
        echo ""
        if [ "$OS" == 'Darwin' ]; then
          brew cask install lazygit
        else  
          sudo add-apt-repository ppa:lazygit-team/release
          sudo apt-get update
          sudo apt-get install lazygit
        fi
      fi
      
      source ~/.bashrc
      site $SITE
      ansi --white --no-newline "Obras Utils is now updated to ";ansi --white-intense $OBRAS_UTILS_VERSION
      test -f .fobras_utils.sh && rm -rf .fobras_utils.sh
      cowsay $OBRAS_UTILS_UPDATE_MESSAGE
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
