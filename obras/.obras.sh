#!/bin/bash
## Crafted (c) 2013~2020 by ZoatWorks Software LTDA.
## Prepared : Roberto Nogueira
## File     : .obras.sh
## Version  : PA05
## Date     : 2020-04-16
## Project  : project-things-today
## Reference: bash
##
## Purpose  : Develop bash routines in order to help Rails development
##            projects.

# variables
export OS=`uname`
if [ $OS == 'Darwin' ]; then
  export CPPFLAGS="-I/usr/local/opt/mysql@5.7/include"
  export LDFLAGS="-L/usr/local/opt/mysql@5.7/lib"
  export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
fi

export MAILCATCHER_ENV=LOCALHOST
export MYSQL_DATABASE_DEV=demo_dev
export MYSQL_DATABASE_TST=demo_tst
export OBRAS="$HOME/Projects/obras"
export OBRAS_OLD="$HOME/Logbook/obras"
export RAILS_ENV=development
export RUBYOPT=-W0
export SITE=demo
unset HEADLESS
unset COVERAGE
unset SELENIUM_REMOTE_HOST

# aliases development
alias enogrob='cd $HOME;title enogrob'
alias downloads='cd $HOME/Downloads;title downloads'
alias code='code --disable-gpu .&'
alias mysql='mysql -u root'
alias olimpia='site set olimpia'
alias rioclaro='site set rioclaro'
alias suzano='site set suzano'
alias santoandre='site set santoandre'
alias demo='site set demo'
alias rc='rvm current'
alias window='tput cols;tput lines'

# aliases docker
alias dc='docker-compose'
alias dk='docker'
alias dkc='docker container'
alias dki='docker image'
alias dkis='docker images'

# functions
__pr(){
    if [ $# -eq 0 ]; then
        echo -e ""
    elif [ $# -eq 2 ]; then
        case $1 in
            dang|red)
                echo -e "\033[31m$2 \033[0m"
                ;;
            succ|green)
                echo -e "\033[32m$2 \033[0m"
                ;;
            warn|yellow)
                echo -e "\033[33m$2 \033[0m"
                ;;
            info|blue)
                echo -e "\033[36m$2 \033[0m"
                ;;
            infobold|lightcyan)
                echo -e "\033[1;96m$2 \033[0m"
                ;;
            bold|white)
                echo -e "\033[1;39m$2 \033[0m"
                ;;
        esac
    elif [ $# -eq 3 ]; then
        case $1 in
            dang|red)
                echo -e "$2 \033[31m$3 \033[0m"
                ;;
            succ|green)
                echo -e "$2 \033[32m$3 \033[0m"
                ;;
            warn|yellow)
                echo -e "$2 \033[33m$3 \033[0m"
                ;;
            info|blue)
                echo -e "$2 \033[36m$3 \033[0m"
                ;;
            infobold|lightcyan)
                echo -e "$2 \033[1;96m$3 \033[0m"
                ;;
            bold|white)
                echo -e "$2 \033[1;39m$3 \033[0m"
                ;;
        esac
    else
        __pr red "=> Error: Bad number of arguments."
        __pr
        return 1
    fi
}

function dash(){
  open dash://$1:$2
}

function title(){
  SITE=$1
  export PROMPT_COMMAND='echo -ne "\033]0;${SITE##*/}\007"'
}

function db(){
  case $1 in
    init)
      rake db:drop
      rake db:create
      rake db:migrate
      rake db:seed
      ;;

    ls)
      files_sql=$(ls *.sql)
      echo -e "db_sqls:"
      for file in ${files_sql[*]}
      do
        __pr info ' '$file
      done
      __pr
      ;;

    import)
      if test -f "$2"; then
        rake db:drop
        rake db:create
        __pr info "file: " $2
        mysql -u root -p $MYSQL_DATABASE_DEV < $2
        rake db:migrate
      else
        files_sql=(`ls *$SITE.sql`)
        if [ ! -z "$files_sql" ]; then
          IFS=$'\n'
          files_sql=( $(printf "%s\n" ${files_sql[@]} | sort -r ) )
          FILE=${files_sql[0]}
          if test -f "$FILE"; then
            rake db:drop
            rake db:create
            __pr info "file: " $(basename $FILE)
            mysql -u root -p $MYSQL_DATABASE_DEV < $FILE
            rake db:migrate
          else
            __pr dang "=> Error: Bad file "$2
            __pr
            return 1
          fi
        fi
      fi
      ;;

    docker)
      if test -f "$2"; then
        docker-compose exec $SITE rake db:drop
        docker-compose exec $SITE rake db:create
        __pr info "file: " $2
        docker exec -i db mysql -uroot -proot $MYSQL_DATABASE_DEV < $2
        docker-compose exec $SITE rake db:migrate
      else
        files_sql=(`ls *$SITE.sql`)
        if [ ! -z "$files_sql" ]; then
          IFS=$'\n'
          files_sql=( $(printf "%s\n" ${files_sql[@]} | sort -r ) )
          FILE=${files_sql[0]}
          if test -f "$FILE"; then
            docker-compose exec $SITE rake db:drop
            docker-compose exec $SITE rake db:create
            __pr info "file: " $(basename $FILE)
            docker exec -i db mysql -uroot -proot $MYSQL_DATABASE_DEV < $FILE
            docker-compose exec $SITE rake db:migrate
          else
            __pr dang "=> Error: Bad file "$FILE
            __pr
            return 1
          fi
        fi
      fi
      ;;

    restart)
      if [ $OS == 'Darwin' ]; then
        FILE=$HOME/Library/LaunchAgents/homebrew.mxcl.mysql@5.7.plist
        if test -f "$FILE"; then
          launchctl unload -w ~/Library/LaunchAgents/homebrew.mxcl.mysql@5.7.plist
          rm ~/Library/LaunchAgents/homebrew.mxcl.mysql@5.7.plist
          brew services start mysql@5.7
        else
          brew services stop mysql@5.7
          brew services start mysql@5.7
        fi
        brew services list
      else
        service mysql restart
        service mysql status
      fi
      ;;

    set)
      case $2 in
        olimpia|rioclaro|suzano|santoandre|demo)
          set -o allexport
          . ./.env/development/$2
          set +o allexport
          ;;

        *)
          __pr dang "=> Error: Bad site "$2
          __pr
          return 1
          ;;
      esac
      ;;

    status)
      if [ $OS == 'Darwin' ]; then
        brew services list
      else  
        service mysql status
      fi
      ;;

    show)
      if [ $RAILS_ENV == "development" ]; then
        mysqlshow -uroot  $MYSQL_DATABASE_DEV | head
      else
        mysqlshow -uroot  $MYSQL_DATABASE_TST | head
      fi
      ;;

    *)
      DB_DEV=`mysqlshow -uroot  $MYSQL_DATABASE_DEV | grep -v Wildcard | grep -o $MYSQL_DATABASE_DEV`
      if [ "$DB_DEV" == $MYSQL_DATABASE_DEV ]; then
        __pr succ "db_dev:" $MYSQL_DATABASE_DEV
      else  
        __pr dang "db_dev:" "no exist"
      fi
      DB_TST=`mysqlshow -uroot  $MYSQL_DATABASE_TST | grep -v Wildcard | grep -o $MYSQL_DATABASE_TST`
      if [ "$DB_TST" == $MYSQL_DATABASE_TST ]; then
        __pr succ "db_tst:" $MYSQL_DATABASE_TST
      else  
        __pr dang "db_tst:" "no exist"
      fi
      IFS=$'\n'
      files_sql=(`ls *$SITE.sql 2>/dev/null`)
      echo -e "db_sqls:"
      if [ ! -z "$files_sql" ]; then
        IFS=$'\n'
        files_sql=( $(printf "%s\n" ${files_sql[@]} | sort -r ) )
        for file in ${files_sql[*]}
        do
          __pr succ ' '$file
        done
      else
        __pr dang " no sql files"
      fi
      __pr
      ;;
  esac
}

function site(){
  case $1 in
    set)
      case $2 in
        olimpia|santoandre|demo)
          export SITE=$2
          unset HEADLESS
          unset COVERAGE
          unset SELENIUM_REMOTE_HOST
          cd "$OBRAS"
          db set $2
          title $2
          site
          ;;

        rioclaro|suzano)
          export SITE=$2
          unset HEADLESS
          unset COVERAGE
          unset SELENIUM_REMOTE_HOST
          cd "$OBRAS_OLD"
          db set $2
          title $2
          site
          ;;

        coverage)
          unset COVERAGE
          export COVERAGE=yes
          ;;

        headless)
          unset HEADLESS
          export HEADLESS=yes
          ;;

        selenium|selenium_remote)
          unset SELENIUM_REMOTE_HOST
          export SELENIUM_REMOTE_HOST=yes
          ;;

        env)
          case $3 in
            test|development|homolog_olimpia|homolog_rioclaro|homolog_suzano|homolog_santoandre|demo)
              unset RAILS_ENV
              export RAILS_ENV=$3
              ;;
            *)
              __pr dang "=> Error: Bad env "$3
              __pr
              return 1
              ;;
          esac  
          ;;

        *)
          __pr dang "=> Error: Bad site "$2
          __pr
          return 1
          ;;
      esac
      ;;

    unset)  
      case $2 in
        coverage)
          unset COVERAGE
          ;;

        headless)
          unset HEADLESS
          ;;

        selenium|selenium_remote)
          unset SELENIUM_REMOTE_HOST
          ;;

        *)
          __pr dang "=> Error: Bad parameter "$2
          __pr
          return 1
          ;;
      esac
      ;;

    *)
      __pr bold "site:" $SITE
      __pr bold "dir :" $PWD
      __pr infobold "rvm :" $(rvm current)
      __pr info "env :" $RAILS_ENV
      if [ -z "$COVERAGE" ]; then
        __pr dang "coverage:" "no"
      else
        __pr succ "coverage:" $COVERAGE
      fi
      if [ -z "$HEADLESS" ]; then
        __pr dang "headless:" "no"
      else
        __pr succ "headless:" $HEADLESS
      fi
      if [ -z "$SELENIUM_REMOTE_HOST" ]; then
        __pr dang "selenium remote:" "no"
      else
        __pr succ "selenium remote:" $SELENIUM_REMOTE_HOST
      fi
      db
      ;;
  esac
}
