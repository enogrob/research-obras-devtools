
#!/bin/bash
## Crafted (c) 2013~2020 by InMov - Intelligence in Movement
## Prepared : Roberto Nogueira
## File     : install.sh
## Version  : PA02
## Date     : 2020-04-21
## Project  : project-obras-devtools
## Reference: bash
## Depends  : foreman, pipe viewer, ansi
## Purpose  : Develop bash routines in order to help Rails development
##            projects.
# set -x

case $1 in 
  env)
    case $2 in 
      obras)
        if test -d "$3"; then
          unset OBRAS
          export OBRAS="$3"
        else  
          echo -e " \033[33m Directory $3 does not exist\033[0m"
          echo ""
        fi  
        ;;

      obras_old)  
        if test -d "$3"; then
          unset OBRAS_OLD
          export OBRAS_OLD="$3"
        else  
          echo -e " \033[33m Directory $3 does not exist\033[0m"
          echo ""
        fi  
        ;;

      install_dir) 
        case $3 in 
          obras)
            if [ ! -z "$OBRAS" ]; then
              unset INSTALL_DIR
              export INSTALL_DIR="$OBRAS"
            else
              echo -e " \033[33m Env OBRAS has not been defined\033[0m"
              echo ""
            fi  
            ;;

          obras_old)
            if [ ! -z "$OBRAS_OLD" ]; then
              unset INSTALL_DIR
              export INSTALL_DIR="$OBRAS_OLD"
            else
              echo -e " \033[33m Env OBRAS_OLD has not been defined\033[0m"
              echo ""
            fi  
            ;;

          *)
            echo -e " \033[33m Parameter $3 not valid\033[0m"
            echo ""
            ;;
        esac
        ;;      

      *)
        echo -e '\033[1;39m=> dir envs\033[0m'
        echo -e '\033[1;36mOBRAS    : \033[0m'$OBRAS  
        echo -e '\033[1;36mOBRAS_OLD: \033[0m'$OBRAS_OLD  
        echo ""
    esac 
    ;;   
    
  obras)  
    if ! test -f $HOME/.obras_utils.sh; then
      echo -e "\033[1;39m=> Installing... 'obras utils' \033[0m"  
      echo 'source $HOME/obras_utils.sh' >> $HOME/.bashrc
    else  
      echo -e "\033[1;39m=> Updating..... 'obras utils' \033[0m"  
    fi  
    cp obras/.obras_utils.sh $HOME
    source $HOME/.obras_utils.sh 

    if ! test -f /usr/local/bin/pv; then
      __pr info "=> Installing..." "pipe viewer"  
      if [ "$OS" == 'Darwin' ]; then
        brew install pv
      else  
        sudo apt-get install pv 
      fi
    fi

    if ! test -f /usr/local/bin/ansi; then
      __pr info "=> Installing..." "ansi"  
      curl -OL git.io/ansi
      chmod 755 ansi
      sudo mv ansi /usr/local/bin/
    fi 

    __pr
    exec bash
    ;;

  vscode)
      if [ -z "$INSTALL_DIR"]; then
        echo -e " \033[33m INSTALL_DIR has not been defined\033[0m"
        echo ""
      else
        if ! test -d $HOME/.vscode; then
          echo -e "\033[1;39m=> Installing... 'home.vscode' \033[0m"  
        else  
          echo -e "\033[1;39m=> Updating..... 'home.vscode' \033[0m"  
        fi
        cp -r vscode/home.vscode $HOME/.vscode
        if ! test -d $INSTALL_DIR/.vscode; then
          echo -e "\033[1;39m=> Installing... 'obras.vscode' \033[0m"  
        else  
          echo -e "\033[1;39m=> Updating..... 'obras.vscode' \033[0m"  
        fi
        cp -r vscode/obras.vscode $INSTALL_DIR/.vscode
      fi
      ;;

  rubymine)
      if [ -z "$INSTALL_DIR"]; then
        echo -e " \033[33m INSTALL_DIR has not been defined\033[0m"
        echo ""
      else
        if ! test -d $INSTALL_DIR/.idea; then
          echo -e "\033[1;39m=> Installing... 'rubymine.idea' \033[0m"  
        else  
          echo -e "\033[1;39m=> Updating..... 'rubymine.idea' \033[0m"  
        fi
        cp -r rubymine/.idea $INSTALL_DIR/.idea
      fi  
      ;;

  foreman)
      if [ -z "$INSTALL_DIR"]; then
        echo -e " \033[33m INSTALL_DIR has not been defined\033[0m"
        echo ""
      else
        if ! test -f $INSTALL_DIR/Procfile; then
          echo -e "\033[1;39m=> Installing... 'foreman.Procfile' \033[0m"  
        else  
          echo -e "\033[1;39m=> Updating..... 'foreman.Procfile' \033[0m"  
        fi
        cp foreman/Procfile $INSTALL_DIR/.idea
      fi  
      ;;

  docker)
      if [ -z "$INSTALL_DIR"]; then
        echo -e " \033[33m INSTALL_DIR has not been defined\033[0m"
        echo ""
      else
        if ! test -f $INSTALL_DIR/Dockerfile; then
          echo -e "\033[1;39m=> Installing... 'docker' \033[0m"  
        else  
          echo -e "\033[1;39m=> Updating..... 'docker' \033[0m"  
        fi
        cp docker/Dockerfile $INSTALL_DIR
        cp docker/.dockerignore $INSTALL_DIR
        cp docker/docker-compose.yaml $INSTALL_DIR
        cp docker/entrypoint.sh $INSTALL_DIR
        cp docker/obras-devtools-README.md $INSTALL_DIR
      fi  
      ;;

  *)
    echo -e "\033[1;39mCrafted (c) 2013~2020 by InMov - Intelligence in Movement \033[0m"
    echo "::"
    echo -e "1. \033[36minstall.sh" " [env <obras value> || <obras_old value> || <install_dir value>] \033[0m"
    echo -e "2. \033[36minstall.sh" " [obras || docker || vscode || rubymine] \033[0m"
    echo "::"
    echo -e '\033[1;39m=> envs\033[0m'
    echo -e " \033[36m INSTALL_DIR: $INSTALL_DIR\033[0m"
    echo ""
    echo -e " \033[36m OBRAS      : $OBRAS\033[0m"
    echo -e " \033[36m OBRAS_OLD  : $OBRAS_OLD\033[0m"
    ;;
esac
