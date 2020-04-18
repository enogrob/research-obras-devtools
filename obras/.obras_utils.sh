#!/bin/bash
## Crafted (c) 2013~2020 by ZoatWorks Software LTDA.
## Prepared : Roberto Nogueira
## File     : .obras.sh
## Version  : PA07
## Date     : 2020-04-18
## Project  : project-things-today
## Reference: bash
## Depends  : foreman, pipe viewer

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
install_obras_utils(){
  __pr bold "=> Installing..." "obras-utils"  
  if [ ! test -s $HOME/.obras_utils.sh ]; then
    cp ./obras_utils.sh $HOME
    echo 'source $HOME/obras_utils.sh' >> $HOME/.bashrc
  fi  

  __pr info "=> Installing..." "pipe viewer"  
  if [ ! test -s /usr/local/bin/pv ]; then
    if [ "$OS" == 'Darwin' ]; then
      brew install pv
    else  
      sudo apt-get install pv 
    fi
  fi

  __pr info "=> Installing..." "ansi"  
  if [ ! test -s /usr/local/bin/ansi ]; then
    curl -OL git.io/ansi
    chmod 755 ansi
    sudo mv ansi /usr/local/bin/
  fi 
}

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

__db(){
  if [ "$RAILS_ENV" == 'development' ]; then
    echo $MYSQL_DATABASE_DEV
  else
    echo $MYSQL_DATABASE_TST
  fi 
}      

__has_database(){
  db=`mysqlshow -uroot  $1 | grep -v Wildcard | grep -o $1`
  if [ "$db" == $1 ]; then
    echo 'yes'
  else
    echo 'no'  
  fi
}

__has_tables(){
  tables=$(__tables $1)
  if [ ! "$tables" == '0' ] && [ ! -z $tables ]; then
    echo 'yes'
  else
    echo 'no'  
  fi
}

__has_records(){
  records=$(__records $1)
  if [ ! "$records" == '' ] && [ ! -z $records ]; then
    echo 'yes'
  else
    echo 'no'  
  fi
}

__records(){
      s=`mysql -u root -e "SELECT SUM(TABLE_ROWS) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '$1';"`
      RECORDS=$(echo $s | sed 's/[^0-9]*//g')
      echo $RECORDS
} 

__tables(){
      s=`mysql -u root -e "SELECT count(*) AS TOTALNUMBEROFTABLES FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '$1';"`
      TABLES=$(echo $s | sed 's/[^0-9]*//g')
      echo $TABLES
}

function db(){
  case $1 in
    help|h|--help|-h)
      __pr bold "Crafted (c) 2013~2020 by InMov - Intelligence in Movement"
      __pr bold "::"
      __pr info "db" "[ls || preptest || drop || create || migrate || seed || import [dbfile] || docker [dbfile]]"
      __pr info "db" "[status || start || stop || restart || show || socket]"
      __pr 
      ;; 

    preptest)
      rails=`rails --version`
      if [ $rails == 'Rails 6.0.2.1' ]; then
        rails db:drop
        rails db:create
        rails db:migrate
        __pr info "Seeding:" "db/seeds.production.rb"
        rails runner "require Rails.root.join('db/seeds.production.rb')"
        __pr info "Seeding:" "db/seeds.development.rb"
        rails runner "require Rails.root.join('db/seeds.development.rb')"
      else
        rake db:drop
        rake db:create
        rake db:migrate
        __pr info "Seeding:" "db/seeds.rb"
        rake db:seed
      fi 
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

    drop)
      db=$(__db)
      if [ "$(__has_database $db)" == 'yes' ]; then
        rake db:drop
      else  
        __pr dang "=> Error: file "$db" does not exists"
      fi
      ;;

    create)  
      db=$(__db)
      if [ "$(__has_database $db)" == 'no' ]; then
        rake db:create
      else  
        __pr dang "=> Error: file "$db" already exists"
      fi
      ;;

    migrate)
      db=$(__db)
      tables=$(__has_tables $db)
      if [ "$(__has_database $db)" == 'yes' ] && [ "$tables" == 'no' ]; then
        rake db:migrate
      else  
        if [ "$(__has_database $db)" == 'no' ]; then
          __pr dang "=> Error: file "$db" does not exist"
        fi
        if [ "$tables" == 'yes' ]; then
          __pr dang "=> Error: $db has tables"
        fi 
      fi
      ;;    

    seed)
      db=$(__db)
      tables=$(__tables $db)
      if [ '$(__has_database $db)' == 'yes' ] && [ $tables == 'no' ]; then
        rails=`rails --version`
        if [ $rails == 'Rails 6.0.2.1' ]; then
          __pr info "Seeding:" "db/seeds.production.rb"
          rails runner "require Rails.root.join('db/seeds.production.rb')"
          __pr info "Seeding:" "db/seeds.development.rb"
          rails runner "require Rails.root.join('db/seeds.development.rb')"
        else
          __pr info "Seeding:" "db/seeds.rb"
          rake db:seed
        fi
      else   
        if [ '$(__has_database $db)' == 'yes' ]; then
          __pr dang "=> Error: file "$db" does not exist"
        fi
        if [ $tables == 'no' ]; then
          __pr dang "=> Error: $db has no tables"
        fi 
      fi   
      __pr
      ;;    

    import)
      rails=`rails --version`
      if test -f "$2"; then
        if [ $rails == 'Rails 6.0.2.1' ]; then
          rails db:environment:set RAILS_ENV=development
          rails db:drop
          rails db:create
          __pr info "file: " $2
          pv $2 | mysql -u root $MYSQL_DATABASE_DEV 
          rails db:migrate
        else
          rake db:drop
          rake db:create
          __pr info "file: " $2
          pv $2 | mysql -u root $MYSQL_DATABASE_DEV 
          rake db:migrate
        fi  
      else
        files_sql=(`ls *$SITE.sql`)
        if [ ! -z "$files_sql" ]; then
          IFS=$'\n'
          files_sql=( $(printf "%s\n" ${files_sql[@]} | sort -r ) )
          file=${files_sql[0]}
          if test -f "$file"; then
            if [ $rails == 'Rails 6.0.2.1' ]; then
              rails db:environment:set RAILS_ENV=development
              rails db:drop
              rails db:create
              __pr info "file: " $(basename $file)
              pv $file | mysql -u root $MYSQL_DATABASE_DEV 
              rails db:migrate
            else
              rake db:drop
              rake db:create
              __pr info "file: " $(basename $file)
              pv $file | mysql -u root $MYSQL_DATABASE_DEV 
              rake db:migrate
            fi
          else   
            __pr dang "=> Error: Bad file "$2
            __pr
            return 1
          fi
        fi
      fi
      ;;

    docker)
      rails=`rails --version`
      if test -f "$2"; then
        if [ $rails == 'Rails 6.0.2.1' ]; then
          rails db:environment:set RAILS_ENV=development
          docker-compose exec $SITE rails db:drop
          docker-compose exec $SITE rails db:create
          __pr info "file: " $2
          pv $2 | docker exec -i db mysql -uroot -proot $MYSQL_DATABASE_DEV 
          docker-compose exec $SITE rails db:migrate
        else  
          docker-compose exec $SITE rake db:drop
          docker-compose exec $SITE raake db:create
          __pr info "file: " $2
          pv $2 | docker exec -i db mysql -uroot -proot $MYSQL_DATABASE_DEV 
          docker-compose exec $SITE rake db:migrate
        fi
      else
        files_sql=(`ls *$SITE.sql`)
        if [ ! -z "$files_sql" ]; then
          IFS=$'\n'
          files_sql=( $(printf "%s\n" ${files_sql[@]} | sort -r ) )
          file=${files_sql[0]}
          if test -f "$file"; then
            if [ $rails == 'Rails 6.0.2.1' ]; then
              rails db:environment:set RAILS_ENV=development
              docker-compose exec $SITE rails db:drop
              docker-compose exec $SITE rails db:create
              __pr info "file: " $(basename $file)
              pv $file | docker exec -i db mysql -uroot -proot $MYSQL_DATABASE_DEV 
              docker-compose exec $SITE rails db:migrate
            else  
              docker-compose exec $SITE rake db:drop
              docker-compose exec $SITE rake db:create
              __pr info "file: " $(basename $file)
              pv $file | docker exec -i db mysql -uroot -proot $MYSQL_DATABASE_DEV
              docker-compose exec $SITE rake db:migrate
            fi
          else
            __pr dang "=> Error: Bad file "$FILE
            __pr
            return 1
          fi
        fi
      fi
      ;;

    start)
      if [ $OS == 'Darwin' ]; then
        brew services start mysql@5.7
      else
        service mysql start
      fi
      ;;

    stop)
      if [ $OS == 'Darwin' ]; then
        brew services stop mysql@5.7
      else
        service mysql stop
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

    socket)
      mysql_config --socket
      ;; 

    *)
      if [ "$(__has_database $MYSQL_DATABASE_DEV)" == 'yes' ]; then
        __pr succ "db_dev:" $MYSQL_DATABASE_DEV' '$(__tables $MYSQL_DATABASE_DEV)' '$(__records $MYSQL_DATABASE_DEV)
      else  
        __pr dang "db_dev:" "no exist"
      fi
      if [ "$(__has_database $MYSQL_DATABASE_TST)" == 'yes' ]; then
        __pr succ "db_tst:" $MYSQL_DATABASE_TST' '$(__tables $MYSQL_DATABASE_TST)' '$(__records $MYSQL_DATABASE_TST)
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
    help|h|--help|-h)
      __pr bold "Crafted (c) 2013~2020 by InMov - Intelligence in Movement"
      __pr bold "::"
      __pr info "site" "[set sitename || set/unset env]"
      __pr info "site" "[check/ls || start [sitename || all]]"
      __pr 
      ;;

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

    start)
      if [ -z "$2" ]; then
        foreman start $SITE
      else   
        case $2 in
          olimpia|rioclaro|suzano|santoandre|demo)
            foreman start $2
            ;;

          all)
            foreman start all
            ;;

          *)
            __pr dang "=> Error: Bad site name "$2
            __pr
            return 1
            ;;
        esac
      fi
      ;;  

    check|ls)
      foreman check  
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
