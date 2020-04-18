
#!/bin/bash
## Crafted (c) 2013~2020 by InMov - Intelligence in Movement
## Prepared : Roberto Nogueira
## File     : install.sh
## Version  : PA01
## Date     : 2020-04-18
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
        unset OBRAS
        export OBRAS="$3"
        ;;

      obras_old)  
        unset OBRAS_OLD
        export OBRAS_OLD="$3"
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
      echo -e "\033[1;39m=> Installing... 'obras-utils' \033[0m"  
      echo 'source $HOME/obras_utils.sh' >> $HOME/.bashrc
    else  
      echo -e "\033[1;39m=> Updating... 'obras-utils' \033[0m"  
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

  *)
    echo -e "\033[1;39mCrafted (c) 2013~2020 by InMov - Intelligence in Movement \033[0m"
    echo "::"
    echo -e "1. \033[36minstall.sh" " [env <obras || obras_old>] \033[0m"
    echo -e "2. \033[36minstall.sh" " [obras || docker || vscode || rubymine] \033[0m"
    echo "::"
    echo -e '\033[1;39m=> dir envs\033[0m'
    echo -e " \033[36m OBRAS    : $OBRAS\033[0m"
    echo -e " \033[36m OBRAS_OLD: $OBRAS_OLD\033[0m"
    ;;
esac
