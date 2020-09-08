
#!/bin/bash
## Crafted (c) 2013~2020 by InMov - Intelligence in Movement
## Prepared : Roberto Nogueira
## File     : install.sh
## Version  : PA07
## Date     : 2020-05-13
## Project  : project-obras-devtools
## Reference: bash
## Depends  : foreman, pipe viewer, ansi
## Purpose  : Develop bash routines in order to help Rails development
##            projects.
# set -x

case $1 in 
  obras_dir|obras_old_dir)
    case $# in
      1)
        if test -f obras/temp2; then
          source obras/temp2
        fi
        if [ -z $OBRAS ]; then
          echo -e "\033[1;31m==> \033[0m\033[1;39mDirectory \"obras\" has to be defined \033[0m"
          echo ""
          exit 1
        fi
        if [ -z $OBRAS_OLD ]; then
          echo -e "\033[1;31m==> \033[0m\033[1;39mDirectory \"obras_old\" has to be defined \033[0m"
          echo ""
          exit 1
        fi
        unset INSTALL_DIR
        export INSTALL_DIR="$1"
        echo -e "\033[1;92m==> \033[0m\033[1;39mConfiguring \"obras utils\" \033[0m"
        test -f obras/temp2 && rm -rf obras/temp2
        sed 's@\$INSTALLDIRTMP@'"$1"'@' obras/temp1 > obras/temp2 
        source obras/temp2
        echo -e '\033[1;39m=> envs\033[0m'
        echo -e " \033[36m INSTALL_DIR: $INSTALL_DIR\033[0m"
        echo ""
        echo -e " \033[36m OBRAS      : $OBRAS\033[0m"
        echo -e " \033[36m OBRAS_OLD  : $OBRAS_OLD\033[0m"
        ;;

      3)
        case $1 in
          obras_dir)
            if [ -z $2 ]; then
              echo -e "\033[1;31m==> \033[0m\033[1;39mDirectory \"obras\" has to be defined \033[0m"
              echo ""
              exit 1
            fi
            if [ -z $3 ]; then
              echo -e "\033[1;31m==> \033[0m\033[1;39mDirectory \"obras_old\" has to be defined \033[0m"
              echo ""
              exit 1
            fi
            if test -d "$2"; then
              unset OBRAS
              export OBRAS="$2"
            else  
              echo -e "\033[1;31m==> \033[0m\033[1;39mDirectory \"$2\" does not exist \033[0m"
              echo ""
              exit 1
            fi  
            if test -d "$3"; then
              unset OBRAS_OLD
              export OBRAS_OLD="$3"
            else  
              echo -e "\033[1;31m==> \033[0m\033[1;39mDirectory \"$3\" does not exist \033[0m"
              echo ""
              exit 1
            fi  
            unset INSTALL_DIR
            export INSTALL_DIR="obras_dir"
            echo -e "\033[1;92m==> \033[0m\033[1;39mConfiguring \"obras utils\" \033[0m"
            test -f obras/temp && rm -rf obras/temp*
            sed 's@\$OBRASTMP@'"$2"'@' obras/.obras_utils.sh > obras/temp
            sed 's@\$OBRASOLDTMP@'"$3"'@' obras/temp > obras/temp1 
            sed 's@\$INSTALLDIRTMP@'"obras_dir"'@' obras/temp1 > obras/temp2 
            source obras/temp2
            echo -e '\033[1;39m=> envs\033[0m'
            echo -e " \033[36m INSTALL_DIR: $INSTALL_DIR\033[0m"
            echo ""
            echo -e " \033[36m OBRAS      : $OBRAS\033[0m"
            echo -e " \033[36m OBRAS_OLD  : $OBRAS_OLD\033[0m"
            ;;

          obras_old_dir)
            if test -d "$2"; then
              unset OBRAS
              export OBRAS="$2"
            else  
              echo -e "\033[1;31m==> \033[0m\033[1;39mDirectory \"$2\" does not exist \033[0m"
              echo ""
              exit 1
            fi  
            if test -d "$3"; then
              unset OBRAS_OLD
              export OBRAS_OLD="$3"
            else  
              echo -e "\033[1;31m==> \033[0m\033[1;39mDirectory \"$3\" does not exist \033[0m"
              echo ""
              exit 1
            fi  
            unset INSTALL_DIR
            export INSTALL_DIR="obras_old_dir"
            echo -e "\033[1;92m==> \033[0m\033[1;39mConfiguring \"obras utils\" \033[0m"
            test -f obras/temp && rm -rf obras/temp*
            sed 's@\$OBRASTMP@'"$2"'@' obras/.obras_utils.sh > obras/temp
            sed 's@\$OBRASOLDTMP@'"$3"'@' obras/temp > obras/temp1 
            sed 's@\$INSTALLDIRTMP@'"obras_old_dir"'@' obras/temp1 > obras/temp2 
            source obras/temp2
            echo -e '\033[1;39m=> envs\033[0m'
            echo -e " \033[36m INSTALL_DIR: $INSTALL_DIR\033[0m"
            echo ""
            echo -e " \033[36m OBRAS      : $OBRAS\033[0m"
            echo -e " \033[36m OBRAS_OLD  : $OBRAS_OLD\033[0m"
            ;;

          *)
            echo -e "\033[1;31m==> \033[0m\033[1;39mInstallation Directory has to be defined \033[0m"
            echo ""
            exit 1
            ;; 
        esac    
        ;;

      *)
        echo -e "\033[1;31m==> \033[0m\033[1;39mNumber of Parameters not allowed \033[0m"
        echo ""
        exit 1
        ;;
    esac    
    ;;

  obras)  
    if ! test -f obras/temp2; then
      echo -e "\033[1;31m==> \033[0m\033[1;39mInstallation not configured \033[0m"
      echo ""
      exit 1
    fi
    if ! test -f $HOME/.obras_utils.sh; then
      echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"obras utils\" \033[0m"
      echo ""
      echo 'source $HOME/obras_utils.sh' >> $HOME/.bashrc
    else  
      echo -e "\033[1;92m==> \033[0m\033[1;39mUpdating \"obras utils\" \033[0m"
      echo ""
    fi  
    cp obras/temp2 $HOME/.obras_utils.sh
    source $HOME/.obras_utils.sh 

    if ! test -f /usr/local/bin/pv; then
      echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"pipe viewer\" \033[0m"
      echo ""
      if [ "$OS" == 'Darwin' ]; then
        brew install pv
      else  
        sudo apt-get install pv 
      fi
    fi

    if ! test -f /usr/local/bin/ansi; then
      echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"ansi\" \033[0m"
      echo ""
      curl -OL git.io/ansi
      chmod 755 ansi
      sudo mv ansi /usr/local/bin/
    fi 

    if ! test -f /usr/local/bin/revolver; then
      echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"revolver\" \033[0m"
      echo ""
      if [ "$OS" == 'Darwin' ]; then
        brew install molovo/revolver/revolver
      else  
        git clone https://github.com/molovo/revolver revolver
        chmod u+x revolver/revolver
        sudo mv revolver/revolver /usr/local/bin
        rm -rf revolver
      fi
    fi
    ;;

  vscode)
      if test -f obras/temp2; then
        source obras/temp2
      fi
      if [ -z "$INSTALL_DIR" ]; then
        echo -e "\033[1;31m==> \033[0m\033[1;39m\"INSTALL_DIR\" has not been defined \033[0m"
        echo ""
      else
        if [ $INSTALL_DIR == "obras_dir" ];then
          unset INSTALL_DIR
          export INSTALL_DIR=$OBRAS
        else
          unset INSTALL_DIR
          export INSTALL_DIR=$OBRAS_OLD
        fi
        if ! test -d $HOME/.vscode; then
          echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"home.vscode\" in "$HOME" \033[0m"
        else  
          echo -e "\033[1;92m==> \033[0m\033[1;39mUpdating \"home.vscode\" in "$HOME" \033[0m"
          rm -rf $HOME/.vscode
        fi
        cp -r vscode/home.vscode $HOME/.vscode
        if ! test -d $INSTALL_DIR/.vscode; then
          echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"obras.vscode\" in "$INSTALL_DIR" \033[0m"
          echo ""
        else  
          echo -e "\033[1;92m==> \033[0m\033[1;39mUpdating \"obras.vscode\" in "$INSTALL_DIR" \033[0m"
          echo ""
          rm -rf $INSTALL_DIR/.vscode
        fi
        cp -r vscode/obras.vscode $INSTALL_DIR/.vscode
      fi
      ;;

  rubymine)
      if test -f obras/temp2; then
        source obras/temp2
      fi
      if [ -z "$INSTALL_DIR" ]; then
        echo -e "\033[1;31m==> \033[0m\033[1;39m\"INSTALL_DIR\" has not been defined \033[0m"
        echo ""
      else
        if [ $INSTALL_DIR == "obras_dir" ]; then
          unset INSTALL_DIR
          export INSTALL_DIR=$OBRAS
        else
          unset INSTALL_DIR
          export INSTALL_DIR=$OBRAS_OLD
        fi
        if ! test -d $INSTALL_DIR/.idea; then
          echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"rubymine.idea\" in "$INSTALL_DIR" \033[0m"
          echo ""
        else  
          echo -e "\033[1;92m==> \033[0m\033[1;39mUpdating \"rubymine.idea\" in "$INSTALL_DIR" \033[0m"
          echo ""
          rm -rf $INSTALL_DIR/.idea
        fi
        if [ $INSTALL_DIR == $OBRAS ]; then
          cp -r rubymine/obras.idea $INSTALL_DIR/.idea
        else
          cp -r rubymine/obras_old.idea $INSTALL_DIR/.idea
        fi  
      fi  
      ;;

  *)
    if test -f obras/temp2; then
      source obras/temp2
    fi
    echo -e "\033[1;39mCrafted (c) 2013~2020 by InMov - Intelligence in Movement \033[0m"
    echo "::"
    echo -e "1. \033[36minstall.sh" " obras_dir || obras_old_dir [<obras_dir> <obras_old_dir>] \033[0m"
    echo -e "2. \033[36minstall.sh" " [obras || vscode || rubymine] \033[0m"
    echo "::"
    echo -e '\033[1;39m=> envs\033[0m'
    echo -e " \033[36m INSTALL_DIR: $INSTALL_DIR\033[0m"
    echo ""
    echo -e " \033[36m OBRAS      : $OBRAS\033[0m"
    echo -e " \033[36m OBRAS_OLD  : $OBRAS_OLD\033[0m"
    ;;
esac
