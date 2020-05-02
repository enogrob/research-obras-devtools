
#!/bin/bash
## Crafted (c) 2013~2020 by InMov - Intelligence in Movement
## Prepared : Roberto Nogueira
## File     : install.sh
## Version  : PA04
## Date     : 2020-05-02
## Project  : project-obras-devtools
## Reference: bash
## Depends  : foreman, pipe viewer, ansi
## Purpose  : Develop bash routines in order to help Rails development
##            projects.
# set -x

case $1 in 
  obras_dir)
    if test -d "$2"; then
      unset INSTALL_DIR
      export INSTALL_DIR="obras_dir"
      unset OBRAS
      export OBRAS="$2"
    else  
      echo -e "\033[1;31m==> \033[0m\033[1;39mDirectory \"$2\" does not exist \033[0m"
      echo ""
    fi  
    if test -d "$3"; then
      unset OBRAS_OLD
      export OBRAS_OLD="$3"
    else  
      echo -e "\033[1;31m==> \033[0m\033[1;39mDirectory \"$3\" does not exist \033[0m"
      echo ""
    fi  
    test -f obras/temp && rm -rf obras/temp*
    sed 's@\$OBRASTMP@'"$1"'@' obras/.obras_utils.sh > obras/temp
    sed 's@\$OBRASOLDTMP@'"$2"'@' obras/temp > obras/temp1 
    source obras/temp1 
    echo -e '\033[1;39m=> envs\033[0m'
    echo -e " \033[36m INSTALL_DIR: $INSTALL_DIR\033[0m"
    echo ""
    echo -e " \033[36m OBRAS      : $OBRAS\033[0m"
    echo -e " \033[36m OBRAS_OLD  : $OBRAS_OLD\033[0m"
    ;;

  obras_old_dir)  
    if test -d "$2"; then
      unset INSTALL_DIR
      export INSTALL_DIR="obras_old_dir"
      unset OBRAS
      export OBRAS="$2"
    else  
      echo -e "\033[1;31m==> \033[0m\033[1;39mDirectory \"$2\" does not exist \033[0m"
      echo ""
    fi  
    if test -d "$3"; then
      unset OBRAS_OLD
      export OBRAS_OLD="$3"
    else  
      echo -e "\033[1;31m==> \033[0m\033[1;39mDirectory \"$3\" does not exist \033[0m"
      echo ""
    fi  
    test -f obras/temp && rm -rf obras/temp*
    sed 's@\$OBRASTMP@'"$1"'@' obras/.obras_utils.sh > obras/temp
    sed 's@\$OBRASOLDTMP@'"$2"'@' obras/temp > obras/temp1 
    source obras/temp1 
    echo -e '\033[1;39m=> envs\033[0m'
    echo -e " \033[36m INSTALL_DIR: $INSTALL_DIR\033[0m"
    echo ""
    echo -e " \033[36m OBRAS      : $OBRAS\033[0m"
    echo -e " \033[36m OBRAS_OLD  : $OBRAS_OLD\033[0m"
    ;;


  obras)  
    if ! test -f $HOME/.obras_utils.sh; then
      echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"obras utils\" \033[0m"
      echo 'source $HOME/obras_utils.sh' >> $HOME/.bashrc
    else  
      echo -e "\033[1;92m==> \033[0m\033[1;39mUpdating \"obras utils\" \033[0m"
    fi  
    if ! test -f obras/temp1 then
      exit 1
    end  
    cp obras/temp1 $HOME/.obras_utils.sh
    source $HOME/.obras_utils.sh 

    if ! test -f /usr/local/bin/pv; then
      echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"pipe viewer\" \033[0m"
      if [ "$OS" == 'Darwin' ]; then
        brew install pv
      else  
        sudo apt-get install pv 
      fi
    fi

    if ! test -f /usr/local/bin/ansi; then
      echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"ansi\" \033[0m"
      curl -OL git.io/ansi
      chmod 755 ansi
      sudo mv ansi /usr/local/bin/
    fi 

    if ! test -f /usr/local/bin/revolver; then
      echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"revolver\" \033[0m"
      if [ "$OS" == 'Darwin' ]; then
        brew install molovo/revolver/revolver
      else  
        git clone https://github.com/molovo/revolver revolver
        chmod u+x revolver/revolver
        sudo mv revolver/revolver /usr/local/bin
        rm -rf revolver
      fi
    fi

    __pr
    exec bash
    ;;

  vscode)
      if [ -z "$INSTALL_DIR"]; then
        echo -e "\033[1;31m==> \033[0m\033[1;39m\"INSTALL_DIR\" has not been defined \033[0m"
        echo ""
      else
        if ! test -d $HOME/.vscode; then
          echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"home.vscode\" \033[0m"
        else  
          echo -e "\033[1;92m==> \033[0m\033[1;39mUpdating \"home.vscode\" \033[0m"
        fi
        cp -r vscode/home.vscode $HOME/.vscode
        if ! test -d $INSTALL_DIR/.vscode; then
          echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"obras.vscode\" \033[0m"
        else  
          echo -e "\033[1;92m==> \033[0m\033[1;39mUpdating \"obras.vscode\" \033[0m"
        fi
        cp -r vscode/obras.vscode $INSTALL_DIR/.vscode
      fi
      ;;

  rubymine)
      if [ -z "$INSTALL_DIR"]; then
        echo -e "\033[1;31m==> \033[0m\033[1;39m\"INSTALL_DIR\" has not been defined \033[0m"
        echo ""
      else
        if ! test -d $INSTALL_DIR/.idea; then
          echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"rubymine.idea\" \033[0m"
        else  
          echo -e "\033[1;92m==> \033[0m\033[1;39mUpdating \"rubymine.idea\" \033[0m"
        fi
        cp -r rubymine/.idea $INSTALL_DIR/.idea
      fi  
      ;;

  foreman)
      if [ -z "$INSTALL_DIR"]; then
        echo -e "\033[1;31m==> \033[0m\033[1;39m\"INSTALL_DIR\" has not been defined \033[0m"
        echo ""
      else
        if ! test -f $INSTALL_DIR/Procfile; then
          echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"foreman.Profile\" \033[0m"
        else  
          echo -e "\033[1;92m==> \033[0m\033[1;39mUpdating \"foreman.Procfile\" \033[0m"
        fi
        cp foreman/Procfile $INSTALL_DIR/.idea
      fi  
      ;;

  docker)
      if [ -z "$INSTALL_DIR"]; then
        echo -e "\033[1;31m==> \033[0m\033[1;39m\"INSTALL_DIR\" has not been defined \033[0m"
        echo ""
      else
        if ! test -f $INSTALL_DIR/Dockerfile; then
          echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"docker\" \033[0m"
        else  
          echo -e "\033[1;92m==> \033[0m\033[1;39mUpdating \"docker\" \033[0m"
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
    echo -e "1. \033[36minstall.sh" " [install_dir [obras || obras_old] obras_dir obras_old_dir] \033[0m"
    echo -e "2. \033[36minstall.sh" " [obras || docker || vscode || rubymine] \033[0m"
    echo "::"
    echo -e '\033[1;39m=> envs\033[0m'
    echo -e " \033[36m INSTALL_DIR: $INSTALL_DIR\033[0m"
    echo ""
    echo -e " \033[36m OBRAS      : $OBRAS\033[0m"
    echo -e " \033[36m OBRAS_OLD  : $OBRAS_OLD\033[0m"
    ;;
esac
