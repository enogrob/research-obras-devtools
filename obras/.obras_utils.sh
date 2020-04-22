#!/bin/bash
## Crafted (c) 2013~2020 by InMov - Intelligence in Movement
## Prepared : Roberto Nogueira
## File     : .obras.sh
## Version  : PA07
## Date     : 2020-04-21
## Project  : project-obras-devtools
## Reference: bash
## Depends  : foreman, pipe viewer, ansi
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
export OBRAS="$HOME/Projects/obras"
export OBRAS_OLD="$HOME/Logbook/obras"
export RAILS_ENV=development
export RUBYOPT=-W0
unset SITE
unset MYSQL_DATABASE_DEV
unset MYSQL_DATABASE_TST
unset HEADLESS
unset COVERAGE
unset SELENIUM_REMOTE_HOST

# aliases development
alias home='cd $HOME;title home'
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

dash(){
  open dash://$1:$2
}

title(){
  SITE=$1
  export PROMPT_COMMAND='echo -ne "\033]0;${SITE##*/}\007"'
}

__wr_env(){
  name=$1
  value=$2
  if [ -z "$2" ]; then
    ansi --no-newline "$name"; ansi --no-newline --red "no";ansi --no-newline ", "
  else
    ansi --no-newline "$name"; ansi --no-newline --green $value;ansi --no-newline ", "
  fi
}      

__pr_env(){
  name=$1
  value=$2
  nonewline=$3
  if [ -z "$2" ]; then
    ansi --no-newline "$name"; ansi --red "no "
  else
    ansi --no-newline "$name"; ansi --green $value" "
  fi
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
  echo $(echo $s | sed 's/[^0-9]*//g')
} 

__tables(){
  s=`mysql -u root -e "SELECT count(*) AS TOTALNUMBEROFTABLES FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '$1';"`
  echo $(echo $s | sed 's/[^0-9]*//g')
}

__import(){
  rails=`rails --version`
  if [ $rails == 'Rails 6.0.2.1' ]; then
    rails db:environment:set RAILS_ENV=development
    rails db:drop
    rails db:create
    __pr info "file: " $1
    pv $1 | mysql -u root $MYSQL_DATABASE_DEV 
    rails db:migrate
  else
    rake db:drop
    rake db:create
    __pr info "file: " $1
    pv $1 | mysql -u root $MYSQL_DATABASE_DEV 
    rake db:migrate
  fi
} 

__import_docker(){
  rails=`rails --version`
  if [ $rails == 'Rails 6.0.2.1' ]; then
    rails db:environment:set RAILS_ENV=development
    docker-compose exec $SITE rails db:drop
    docker-compose exec $SITE rails db:create
    __pr info "file: " $1
    pv $1 | docker exec -i db mysql -uroot -proot $MYSQL_DATABASE_DEV 
    docker-compose exec $SITE rails db:migrate
  else
    docker-compose exec $SITE rake db:drop
    docker-compose exec $SITE raake db:create
    __pr info "file: " $1
    pv $1 | docker exec -i db mysql -uroot -proot $MYSQL_DATABASE_DEV 
    docker-compose exec $SITE rake db:migrate
  fi
} 

__contains() {
  local n=$#
  local value=${!n}
  for ((i=1;i < $#;i++)) {
      if [[ ${!i} == *"${value}"* ]]; then
          echo "y"
          return 0
      fi
  }
  echo "n"
  return 1
}

db(){
  case $1 in
    help|h|--help|-h)
      __pr bold "Crafted (c) 2013~2020 by InMov - Intelligence in Movement"
      __pr bold "::"
      __pr info "db" "[ls || preptest || drop || create || migrate || seed || import [dbfile] || docker [dbfile]]"
      __pr info "db" "[status || start || stop || restart || tables || databases || socket]"
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
        __pr info "Seeding:" "db/seeds.falta_rodar_suzano_e_rio_claro.rb"
        rails runner "require Rails.root.join('db/seeds.falta_rodar_suzano_e_rio_claro.rb')"
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
          __pr info "Seeding:" "db/seeds.falta_rodar_suzano_e_rio_claro.rb"
          rails runner "require Rails.root.join('db/seeds.falta_rodar_suzano_e_rio_claro.rb')"
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
      case $2 in
        docker)
          case $3 in
            all)
              files_sql=(`ls *.sql`)
              if [ ! -z "$files_sql" ]; then
                IFS=$'\n'
                files_sql=( $(printf "%s\n" ${files_sql[@]} | sort -r ) )
                for file in "${files_sql[@]}"
                do
                  if [ $(__contains "$file" "olimpia") == "y" ]; then
                    site set olimpia
                    __import_docker $(basename $file)
                  fi
                  if [ $(__contains "$file" "rioclaro") == "y" ]; then
                    site set rioclaro
                    __import_docker $(basename $file)
                  fi
                  if [ $(__contains "$file" "suzano") == "y" ]; then
                    site set suzano
                    __import_docker $(basename $file)
                  fi
                  if [ $(__contains "$file" "santoandre") == "y" ]; then
                    site set santoandre
                    __import_docker $(basename $file)
                  fi
                  if [ $(__contains "$file" "demo") == "y" ]; then
                    site set demo
                    __import_docker $(basename $file)
                  fi
                done
              else   
                __pr dang "=> Error: No sql files"
                __pr
                return 1
              fi
              ;;

            *)
              if test -f "$3"; then
                __import_docker $3
              else
                files_sql=(`ls *$SITE.sql`)
                if [ ! -z "$files_sql" ]; then
                  IFS=$'\n'
                  files_sql=( $(printf "%s\n" ${files_sql[@]} | sort -r ) )
                  file=${files_sql[0]}
                  __import_docker $(basename $file)
                else
                  __pr dang "=> Error: No sql files"
                  __pr
                  return 1
                fi
              fi
              ;;

          esac
          ;;

        all)
          files_sql=(`ls *.sql`)
          if [ ! -z "$files_sql" ]; then
            IFS=$'\n'
            files_sql=( $(printf "%s\n" ${files_sql[@]} | sort -r ) )
            for file in "${files_sql[@]}"
            do
              if [ $(__contains "$file" "olimpia") == "y" ]; then
                site set olimpia
                __import $(basename $file)
              fi
              if [ $(__contains "$file" "rioclaro") == "y" ]; then
                site set rioclaro
                __import $(basename $file)
              fi
              if [ $(__contains "$file" "suzano") == "y" ]; then
                site set suzano
                __import $(basename $file)
              fi
              if [ $(__contains "$file" "santoandre") == "y" ]; then
                site set santoandre
                __import $(basename $file)
              fi
              if [ $(__contains "$file" "demo") == "y" ]; then
                site set demo
                __import $(basename $file)
              fi
            done
          else   
            __pr dang "=> Error: No sql files"
            __pr
            return 1
          fi
          ;;

        *)
          if test -f "$2"; then
            __import $2
          else
            files_sql=(`ls *$SITE.sql`)
            if [ ! -z "$files_sql" ]; then
              IFS=$'\n'
              files_sql=( $(printf "%s\n" ${files_sql[@]} | sort -r ) )
              file=${files_sql[0]}
              __import $(basename $file)
            else   
              __pr dang "=> Error: No sql files"
              __pr
              return 1
            fi
          fi
          ;;
      esac
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

        default) 
          current_rails_env=$RAILS_ENV
          export RAILS_ENV=development
          export MYSQL_DATABASE_DEV=$(rails r "puts Rails.configuration.database_configuration[Rails.env]['database']")
          export RAILS_ENV=test
          export MYSQL_DATABASE_TST=$(rails r "puts Rails.configuration.database_configuration[Rails.env]['database']")
          export RAILS_ENV=$current_rails_env
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

    tables)
      db=$(__db)
      mysqlshow -uroot $db | more
      ;;

    databases)
      mysqlshow -uroot | more
      ;;

    *)
      if [ "$(__has_database $MYSQL_DATABASE_DEV)" == 'yes' ]; then
        ansi --no-newline "db_dev: "; ansi --no-newline --green $MYSQL_DATABASE_DEV' '; ansi --no-newline $(__tables $MYSQL_DATABASE_DEV)' '; ansi $(__records $MYSQL_DATABASE_DEV)
      else  
        ansi --no-new-line "db_dev: "; ansi --no-new-line --red "no exist"
      fi
      if [ "$(__has_database $MYSQL_DATABASE_TST)" == 'yes' ]; then
        ansi --no-newline "db_tst: "; ansi --no-newline --green $MYSQL_DATABASE_TST' '; ansi --no-newline $(__tables $MYSQL_DATABASE_TST)' '; ansi $(__records $MYSQL_DATABASE_TST)
      else  
        ansi --no-newline "db_tst: "; ansi --red "no exist"
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

site(){
  case $1 in
    help|h|--help|-h)
      __pr bold "Crafted (c) 2013~2020 by InMov - Intelligence in Movement"
      __pr bold "::"
      __pr info "site" "[set sitename || envs || set/unset env]"
      __pr info "site" "[check/ls || start [sitename || all]]"
      __pr info "site" "[ngrok || mailcatcher start/stop]"
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
          ;;

        rioclaro|suzano)
          export SITE=$2
          unset HEADLESS
          unset COVERAGE
          unset SELENIUM_REMOTE_HOST
          cd "$OBRAS_OLD"
          db set $2
          title $2
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

    mailcatcher) 
      case $2 in
        start)
          mailcatcher& 2>&1 > /dev/null
          ;;

        stop)
          running=$(lsof -i :1080 | grep -i ruby | awk {'print $2'})
          kill -9 $running 2>&1 > /dev/null
          ;;

        status)
          lsof -i :1080
          ;;  

        *)
          running=$(lsof -i :1080 | grep -i ruby | awk {'print $2'})
          __pr_env "mailcatcher: " $running
          ;;
      esac    
      ;;

    ngrok) 
      port=$(cat Procfile | grep -i $SITE | awk '{print $7}')
      ngrok http $port 
      ;;

    envs) 
      __wr_env "coverage: " $COVERAGE 
      __wr_env "headless: " $HEADLESS 
      __pr_env  "selenium remote: " $SELENIUM_REMOTE_HOST
      ;;

    db)
      shift
      db $*
      ;;  

    *)
      __pr bold "site:" $SITE
      __pr bold "home:" $PWD
      __pr infobold "rvm :" $(rvm current)
      if [ $RAILS_ENV == 'development' ]; then 
        ansi --no-newline "env : ";ansi --cyan --underline $RAILS_ENV
      else
        ansi --no-newline "env : ";ansi --yellow --underline $RAILS_ENV
      fi
      site envs
      site mailcatcher
      db
      ;;
  esac
}
