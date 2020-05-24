#!/bin/bash
## Crafted (c) 2013~2020 by InMov - Intelligence in Movement
## Prepared : Roberto Nogueira
## File     : .obras_utils.sh
## Version  : PA30
## Date     : 2020-05-25
## Project  : project-obras-devtools
## Reference: bash
## Depends  : foreman, pipe viewer, ansi, revolver
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
export OBRASTMP="$HOME/Projects/obras"
export OBRASOLDTMP="$HOME/Logbook/obras"
export INSTALLDIRTMP=obras_dir
export OBRAS=$OBRASTMP
export OBRAS_OLD=$OBRASOLDTMP
export INSTALL_DIR=$INSTALLDIRTMP
export RAILS_ENV=development
export RUBYOPT=-W0
export SITE=default
unset MYSQL_DATABASE_DEV
unset MYSQL_DATABASE_TST
export HEADLESS=true
unset COVERAGE
unset DOCKER
unset SELENIUM_REMOTE_HOST

# aliases development
alias home='cd $HOME;title home'
alias obras='cd $OBRAS;title obras'
alias downloads='cd $HOME/Downloads;title downloads'
alias code='code --disable-gpu .&'
alias mysql='mysql -u root'
alias olimpia='cd $OBRAS;site olimpia'
alias rioclaro='cd $OBRAS;site rioclaro'
alias suzano='cd $OBRAS;site suzano'
alias santoandre='cd $OBRAS;site santoandre'
alias demo='cd $OBRAS;site demo'
alias downloads='cd $HOME/Downloads;title downloads'
alias default='cd $OBRAS;site default'
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
        ansi --no-newline --red-intense "==> "; ansi --white-intense "Error bad number of arguments "
        __pr
        return 1
    fi
}

dash(){
  open dash://$1:$2
}

title(){
  title=$1
  export PROMPT_COMMAND='echo -ne "\033]0;${title##*/}\007"'
}

__wr_env(){
  name=$1
  value=$2
  if [ -z "$value" ]; then
    ansi --no-newline --red $name;ansi --no-newline ", "
  else
    ansi --no-newline --green $name;ansi --no-newline ", "
  fi
}      

__pr_env(){
  name=$1
  value=$2
  if [ -z "$value" ]; then
    ansi --red $name
  else
    ansi --green $name
  fi
}      

__db(){
  if [ "$RAILS_ENV" == 'development' ]; then
    if [ -z $MYSQL_DATABASE_DEV ]; then
      echo obrasdev
    else
      echo $MYSQL_DATABASE_DEV
    fi  
  else
    if [ -z $MYSQL_DATABASE_TST ]; then
      echo obrastest
    else
      echo $MYSQL_DATABASE_TST
    fi  
  fi 
}      

__has_database(){
  if [ -z "$DOCKER" ]; then
    mysqlshow -uroot > /dev/null 2>&1
    if [ $? -eq 1 ]; then 
      ansi --no-newline --red-intense "==> "; ansi --white-intense "Database error"
      echo ""
    else  
      db=`mysqlshow -uroot | grep -o $1`
      if [ "$db" == $1 ]; then
        echo 'yes'
      else
        echo 'no'  
      fi
    fi
  else
    docker-compose exec db mysqlshow -uroot -proot > /dev/null 2>&1
    if [ $? -eq 1 ]; then 
      ansi --no-newline --red-intense "==> "; ansi --white-intense "Database error"
      exit 1
    else  
      db=`docker-compose exec db mysqlshow -uroot -proot | grep -o $1`
      if [ "$db" == $1 ]; then
        echo 'yes'
      else
        echo 'no'  
      fi
    fi
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
  if [ -z "$DOCKER" ]; then
    s=`mysql -u root -e "SELECT SUM(TABLE_ROWS) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '$1';"`
    echo $(echo -n $s | sed 's/[^0-9]*//g')
  else
    s=`docker-compose exec db mysql -uroot -proot -e "SELECT SUM(TABLE_ROWS) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '$1';"`
    echo $(echo -n $s | sed 's/[^0-9]*//g')
  fi
} 

__tables(){
  if [ -z "$DOCKER" ]; then
    s=`mysql -u root -e "SELECT count(*) AS TOTALNUMBEROFTABLES FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '$1';"`
    echo $(echo -n $s | sed 's/[^0-9]*//g')
  else
    s=`docker-compose exec db mysql -uroot -proot -e "SELECT count(*) AS TOTALNUMBEROFTABLES FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '$1';"`
    echo $(echo -n $s | sed 's/[^0-9]*//g')
  fi
}

__import(){
  rails=`rails --version`
  if [ $rails == 'Rails 6.0.2.1' ]; then
    ansi --no-newline --green-intense "==> "; ansi --white-intense "Dropping db "
    revolver --style 'simpleDotsScrolling' start 
    rails db:drop
    revolver stop
    ansi --no-newline --green-intense "==> "; ansi --white-intense "Creating db"
    revolver --style 'simpleDotsScrolling' start 
    rails db:create
    revolver stop
    ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Importing ";ansi --white-intense "$1"
    if [ $RAILS_ENV == "development" ]; then
      rails db:environment:set RAILS_ENV=development
      if [ -z $MYSQL_DATABASE_DEV ]; then
        pv $1 | mysql -u root obrasdev 
      else
        pv $1 | mysql -u root $MYSQL_DATABASE_DEV 
      fi
    else
      rails db:environment:set RAILS_ENV=test
      if [ -z $MYSQL_DATABASE_TST ]; then
        pv $1 | mysql -u root obrastest
      else
        pv $1 | mysql -u root $MYSQL_DATABASE_TST 
      fi
    fi    
    ansi --no-newline --green-intense "==> "; ansi --white-intense "Migrating db "
    rails db:migrate
  else
    ansi --no-newline --green-intense "==> "; ansi --white-intense "Dropping db "
    revolver --style 'simpleDotsScrolling' start 
    rake db:drop
    revolver stop
    ansi --no-newline --green-intense "==> "; ansi --white-intense "Creating db"
    revolver --style 'simpleDotsScrolling' start 
    rake db:create
    revolver stop
    ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Importing ";ansi --white-intense "$1"
    if [ $RAILS_ENV == "development" ]; then
      if [ -z $MYSQL_DATABASE_DEV ]; then
        pv $1 | mysql -u root obrasdev 
      else
        pv $1 | mysql -u root $MYSQL_DATABASE_DEV 
      fi 
    else
      if [ -z $MYSQL_DATABASE_DEV ]; then
        pv $1 | mysql -u root obrasdev 
      else
        pv $1 | mysql -u root $MYSQL_DATABASE_DEV 
      fi 
    fi   
    ansi --no-newline --green-intense "==> "; ansi --white-intense "Migrating db "
    rake db:migrate
  fi
} 

__import_docker(){
  rails=`rails --version`
  if [ $rails == 'Rails 6.0.2.1' ]; then
    ansi --no-newline --green-intense "==> "; ansi --white-intense "Dropping db "
    revolver --style 'simpleDotsScrolling' start 
    docker-compose exec $SITE rails db:drop
    revolver stop
    ansi --no-newline --green-intense "==> "; ansi --white-intense "Creating db"
    revolver --style 'simpleDotsScrolling' start 
    docker-compose exec $SITE rails db:create
    revolver stop
    ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Importing ";ansi --white-intense "$1"
    if [ $RAILS_ENV == "development" ]; then 
      rails db:environment:set RAILS_ENV=development
      if [ -z $MYSQL_DATABASE_DEV ]; then
        pv $1 | docker exec -i db mysql -uroot -proot obrasdev
      else
        pv $1 | docker exec -i db mysql -uroot -proot $MYSQL_DATABASE_DEV 
      fi  
    else
      rails db:environment:set RAILS_ENV=test
      if [ -z $MYSQL_DATABASE_TST ]; then
        pv $1 | docker exec -i db mysql -uroot -proot obrastest
      else
        pv $1 | docker exec -i db mysql -uroot -proot $MYSQL_DATABASE_TST 
      fi  
    fi
    ansi --no-newline --green-intense "==> "; ansi --white-intense "Migrating db "
    docker-compose exec $SITE rails db:migrate
  else
    ansi --no-newline --green-intense "==> "; ansi --white-intense "Dropping db "
    revolver --style 'simpleDotsScrolling' start 
    docker-compose exec $SITE rake db:drop
    revolver stop
    ansi --no-newline --green-intense "==> "; ansi --white-intense "Creating db"
    revolver --style 'simpleDotsScrolling' start 
    docker-compose exec $SITE rake db:create
    revolver stop
    ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Importing ";ansi --white-intense "$1"
    if [ $RAILS_ENV == "development" ]; then 
      if [ -z $MYSQL_DATABASE_DEV ]; then
        pv $1 | docker exec -i db mysql -uroot -proot obrasdev
      else
        pv $1 | docker exec -i db mysql -uroot -proot $MYSQL_DATABASE_DEV 
      fi  
    else
      if [ -z $MYSQL_DATABASE_TST ]; then
        pv $1 | docker exec -i db mysql -uroot -proot obrastest
      else
        pv $1 | docker exec -i db mysql -uroot -proot $MYSQL_DATABASE_TST
      fi  
    fi
    ansi --no-newline --green-intense "==> "; ansi --white-intense "Migrating db "
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

__pr_db(){
  env=$1
  if [ $env == "dev" ]; then
    if [ -z $MYSQL_DATABASE_DEV ]; then
      db=obrasdev
    else  
      db=$MYSQL_DATABASE_DEV
    fi
  else  
    if [ -z $MYSQL_DATABASE_TST ]; then
      db=obrastest
    else  
      db=$MYSQL_DATABASE_TST
    fi
  fi
  if [ "$(__has_database $db)" == 'yes' ]; then
    ansi --no-newline "db_"$env": "; ansi --no-newline --green $db' '; ansi --no-newline $(__tables $db)' '; ansi $(__records $db)
  else  
    ansi --no-newline "db_"$env": "; ansi --red $db
  fi
}

__port(){
  site=$1
  case $1 in
    default)
      port=3000
      ;;
    olimpia)
      port=3002
      ;;  
    rioclaro)
      port=3003
      ;;  
    suzano)
      port=3004
      ;;  
    santoandre)
      port=3005
      ;;  
    demo)
      port=3013
      ;;  
  esac
  echo $port
}  

__pid(){
  port=$1
  pid=$(lsof -i :$port | grep -e ruby -e docke | awk {'print $2'} | uniq)
  echo $pid
} 

__url(){
  port=$1
  pid=$(__pid $port)
  if [ -z $pid ]; then
    ansi --red http://localhost:$port
  else
    ansi --no-newline --underline --green http://localhost:$port; ansi ' '$pid
  fi
}

__is_obras(){
  [[ $PWD == $OBRAS || $PWD == $OBRAS_OLD ]]
}

__docker(){
  port=$(__port $SITE)
  pid=$(lsof -i :$port | grep -e docke | awk {'print $2'} | uniq)
  if [[ ! -z "$pid" && -z "$DOCKER" ]]; then
    unset DOCKER
    export DOCKER=true
    unset SELENIUM_REMOTE_HOST
    export SELENIUM_REMOTE_HOST=selenium
  fi
  if [ ! -z "$DOCKER" ]; then
    db=$(docker-compose ps db | grep -o Up)
    if [ -z $db ]; then
      docker-compose up -d db
    fi
    selenium=$(docker-compose ps selenium | grep -o Up)
    if [ -z $selenium ]; then
      docker-compose up -d selenium
    fi
    site=$(docker-compose ps $SITE | grep -o Up)
    if [ -z $site ]; then
      docker-compose up -d $SITE
    fi
  fi  
}

db(){
  __is_obras
  if [ $? -eq 0 ]; then
  case $1 in
    help|h|--help|-h)
      __pr bold "Crafted (c) 2013~2020 by InMov - Intelligence in Movement"
      __pr bold "::"
      __pr info "db" "[set sitename || ls || preptest || drop || create || migrate || seed || import [dbfile] || download || update [all]]"
      __pr info "db" "[status || start || stop || restart || tables || databases || socket]"
      __pr 
      ;; 

    preptest|init)
      if [ -z "$DOCKER" ]; then
        rails=`rails --version`
        if [ $rails == 'Rails 6.0.2.1' ]; then
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Dropping db "
          revolver --style 'simpleDotsScrolling' start 
          rails db:drop
          revolver stop
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Creating db"
          revolver --style 'simpleDotsScrolling' start 
          rails db:create
          revolver stop
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Migrating db "
          rails db:migrate
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Seeding ";ansi --white-intense "db/seeds.production.rb"
          revolver --style 'simpleDotsScrolling' start 
          rails runner "require Rails.root.join('db/seeds.production.rb')"
          revolver stop
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Seeding ";ansi --white-intense "db/seeds.development.rb"
          revolver --style 'simpleDotsScrolling' start 
          rails runner "require Rails.root.join('db/seeds.development.rb')"
          revolver stop
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Seeding ";ansi --white-intense "db/seeds.falta_rodar_suzano_e_rio_claro.rb"
          revolver --style 'simpleDotsScrolling' start 
          rails runner "require Rails.root.join('db/seeds.falta_rodar_suzano_e_rio_claro.rb')"
          revolver stop
        else
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Dropping db "
          revolver --style 'simpleDotsScrolling' start 
          rake db:drop
          revolver stop
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Creating db"
          revolver --style 'simpleDotsScrolling' start 
          rake db:create
          revolver stop
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Migrating db "
          rake db:migrate
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Seeding ";ansi --white-intense "db/seeds.rb"
          revolver --style 'simpleDotsScrolling' start 
          rake db:seed
          revolver stop
        fi
      else 
        rails=`rails --version`
        if [ $rails == 'Rails 6.0.2.1' ]; then
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Dropping db "
          revolver --style 'simpleDotsScrolling' start 
          docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rails db:drop
          revolver stop
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Creating db"
          revolver --style 'simpleDotsScrolling' start 
          docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rails db:create
          revolver stop
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Migrating db "
          docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rails db:migrate
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Seeding ";ansi --white-intense "db/seeds.production.rb"
          revolver --style 'simpleDotsScrolling' start 
          docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rails runner "require Rails.root.join('db/seeds.production.rb')"
          revolver stop
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Seeding ";ansi --white-intense "db/seeds.development.rb"
          revolver --style 'simpleDotsScrolling' start
          docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rails runner "require Rails.root.join('db/seeds.development.rb')"
          revolver stop
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Seeding ";ansi --white-intense "db/seeds.falta_rodar_suzano_e_rio_claro.rb"
          revolver --style 'simpleDotsScrolling' start 
          docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rails runner "require Rails.root.join('db/seeds.falta_rodar_suzano_e_rio_claro.rb')"
          revolver stop
        else
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Dropping db "
          revolver --style 'simpleDotsScrolling' start
          docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rake db:drop
          revolver stop
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Creating db "
          revolver --style 'simpleDotsScrolling' start 
          docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rake db:create
          revolver stop
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Migrating db "
          docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rake db:migrate
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Seeding ";ansi --white-intense "db/seeds.rb"
          revolver --style 'simpleDotsScrolling' start 
          docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rake db:seed
          revolver stop
        fi
      fi
      ;;

    ls)
      IFS=$'\n'
      files_sql=(`ls *.sql 2>/dev/null`)
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

    drop)
      if [ -z "$DOCKER" ]; then
        db=$(__db)
        if [ "$(__has_database $db)" == 'yes' ]; then
          rails=`rails --version`
          if [ $rails == 'Rails 6.0.2.1' ]; then
            ansi --no-newline --green-intense "==> "; ansi --white-intense "Dropping db "
            revolver --style 'simpleDotsScrolling' start
            rails db:drop
            revolver stop
          else
            ansi --no-newline --green-intense "==> "; ansi --white-intense "Dropping db "
            revolver --style 'simpleDotsScrolling' start 
            rake db:drop
            revolver stop
          fi
        else  
          ansi --no-newline --red-intense "==> "; ansi --white-intense "Error file "$db" does not exists"
        fi
      else
        db=$(__db)
        if [ "$(__has_database $db)" == 'yes' ]; then
          rails=`rails --version`
          if [ $rails == 'Rails 6.0.2.1' ]; then
            ansi --no-newline --green-intense "==> "; ansi --white-intense "Dropping db "
            revolver --style 'simpleDotsScrolling' start 
            docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rails db:drop
            revolver stop
          else  
            ansi --no-newline --green-intense "==> "; ansi --white-intense "Dropping db "
            revolver --style 'simpleDotsScrolling' start 
            docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rake db:drop
            revolver stop
          fi
        else  
          ansi --no-newline --red-intense "==> "; ansi --white-intense "Error file "$db" does not exists"
        fi
      fi
      ;;

    create)  
      if [ -z "$DOCKER" ]; then
        db=$(__db)
        if [ "$(__has_database $db)" == 'no' ]; then
          rails=`rails --version`
          if [ $rails == 'Rails 6.0.2.1' ]; then
            ansi --no-newline --green-intense "==> "; ansi --white-intense "Creating db"
            revolver --style 'simpleDotsScrolling' start 
            rails db:create
            revolver stop
          else
            ansi --no-newline --green-intense "==> "; ansi --white-intense "Creating db"
            revolver --style 'simpleDotsScrolling' start
            rake db:create
            revolver stop
          fi  
        else  
          ansi --no-newline --red-intense "==> "; ansi --white-intense "Error file "$db" already exists"
        fi
      else
        db=$(__db)
        if [ "$(__has_database $db)" == 'no' ]; then
          rails=`docker-compose exec rails --version`
          if [ $rails == 'Rails 6.0.2.1' ]; then
            ansi --no-newline --green-intense "==> "; ansi --white-intense "Creating db"
            revolver --style 'simpleDotsScrolling' start 
            docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rails db:create
            revolver stop
          else
            ansi --no-newline --green-intense "==> "; ansi --white-intense "Creating db"
            revolver --style 'simpleDotsScrolling' start 
            docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rake db:create
            revolver stop
          fi
        else  
          ansi --no-newline --red-intense "==> "; ansi --white-intense "Error file "$db" already exists"
        fi
      fi
      ;;

    migrate)
      if [ -z "$DOCKER" ]; then
        db=$(__db)
        if [ "$(__has_database $db)" == 'yes' ]; then
          rails=`rails --version`
          if [ $rails == 'Rails 6.0.2.1' ]; then
            ansi --no-newline --green-intense "==> "; ansi --white-intense "Migrating db "
            rails db:migrate
          else
            ansi --no-newline --green-intense "==> "; ansi --white-intense "Migrating db "
            rake db:migrate
          fi
        else  
          ansi --no-newline --red-intense "==> "; ansi --white-intense "Error file "$db" does not exist"
        fi
      else
        db=$(__db)
        if [ "$(__has_database $db)" == 'yes' ]; then
          rails=`docker-compose exec rails --version`
          if [ $rails == 'Rails 6.0.2.1' ]; then
            ansi --no-newline --green-intense "==> "; ansi --white-intense "Migrating db "
            docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rails db:migrate
          else
            ansi --no-newline --green-intense "==> "; ansi --white-intense "Migrating db "
            docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rake db:migrate
          fi  
        else  
          ansi --no-newline --red-intense "==> "; ansi --white-intense "Error file "$db" does not exist"
        fi
      fi
      __pr
      ;;    

    seed)
      if [ -z "$DOCKER" ]; then
        db=$(__db)
        tables=$(__tables $db)
        if [ '$(__has_database $db)' == 'yes' ] && [ $tables == 'no' ]; then
          rails=`rails --version`
          if [ $rails == 'Rails 6.0.2.1' ]; then
            ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Seeding ";ansi --white-intense "db/seeds.production.rb"
            revolver --style 'simpleDotsScrolling' start
            rails runner "require Rails.root.join('db/seeds.production.rb')"
            revolver stop
            ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Seeding ";ansi --white-intense "db/seeds.development.rb"
            revolver --style 'simpleDotsScrolling' start
            rails runner "require Rails.root.join('db/seeds.development.rb')"
            revolver stop
            ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Seeding ";ansi --white-intense "db/seeds.falta_rodar_suzano_e_rio_claro.rb"
            revolver --style 'simpleDotsScrolling' start
            rails runner "require Rails.root.join('db/seeds.falta_rodar_suzano_e_rio_claro.rb')"
            revolver stop
          else
            ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Seeding ";ansi --white-intense "db/seeds.rb"
            revolver --style 'simpleDotsScrolling' start
            rake db:seed
            revolver stop
          fi
        else   
          if [ '$(__has_database $db)' == 'yes' ]; then
            ansi --no-newline --red-intense "==> "; ansi --white-intense "Error file "$db" does not exist"
          fi
          if [ $tables == 'no' ]; then
            ansi --no-newline --red-intense "==> "; ansi --white-intense "Error file "$db" has tables"
          fi 
        fi   
      else
        db=$(__db)
        tables=$(__tables $db)
        if [ '$(__has_database $db)' == 'yes' ] && [ $tables == 'no' ]; then
          rails=`rails --version`
          if [ $rails == 'Rails 6.0.2.1' ]; then
            ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Seeding ";ansi --white-intense "db/seeds.production.rb"
            docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rails runner "require Rails.root.join('db/seeds.production.rb')"
            ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Seeding ";ansi --white-intense "db/seeds.development.rb"
            docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rails runner "require Rails.root.join('db/seeds.development.rb')"
            ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Seeding ";ansi --white-intense "db/seeds.falta_rodar_suzano_e_rio_claro.rb"
            docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rails runner "require Rails.root.join('db/seeds.falta_rodar_suzano_e_rio_claro.rb')"
          else
            ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Seeding ";ansi --white-intense "db/seeds.rb"
            docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rake db:seed
          fi
        else   
          if [ '$(__has_database $db)' == 'yes' ]; then
            ansi --no-newline --red-intense "==> "; ansi --white-intense "Error file "$db" does not exist"
          fi
          if [ $tables == 'no' ]; then
            ansi --no-newline --red-intense "==> "; ansi --white-intense "Error file "$db" has tables"
          fi 
        fi   
      fi
      __pr
      ;;    

    import)
      case $2 in
        all)
          if [ -z "$DOCKER" ]; then
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
              ansi --no-newline --red-intense "==> "; ansi --white-intense "Error no sql files"
              __pr
              return 1
            fi
          else
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
              ansi --no-newline --red-intense "==> "; ansi --white-intense "Error no sql files"
              __pr
              return 1
            fi
          fi
          ;;

        *)
          if [ -z "$DOCKER" ]; then
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
                ansi --no-newline --red-intense "==> "; ansi --white-intense "Error no sql files"
                __pr
                return 1
              fi
            fi
          else  
            if test -f "$2"; then
              __import_docker $2
            else
              files_sql=(`ls *$SITE.sql`)
              if [ ! -z "$files_sql" ]; then
                IFS=$'\n'
                files_sql=( $(printf "%s\n" ${files_sql[@]} | sort -r ) )
                file=${files_sql[0]}
                __import_docker $(basename $file)
              else
                ansi --no-newline --red-intense "==> "; ansi --white-intense "Error no sql files"
                __pr
                return 1
              fi
            fi
          fi
          ;;
      esac
      ;;

    download)
      case $SITE in 
        olimpia)
          files=$(echo 'sudo -i eybackup -e mysql -l obras' | ssh -t deploy@ec2-18-231-91-182.sa-east-1.compute.amazonaws.com | tail -2 | grep gz)
          IFS=' '
          read -ra file <<< "$files"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Listing ";ansi --white-intense "${file[0]}"
          echo "sudo -i eybackup -e mysql -d ${file[0]}" | ssh -t deploy@ec2-18-231-91-182.sa-east-1.compute.amazonaws.com 
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Downloading "${file[1]}
          scp deploy@ec2-18-231-91-182.sa-east-1.compute.amazonaws.com:/mnt/tmp/${file[1]} .
          IFS='T'
          read -ra sitefile <<< "${file[1]}"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Renaming to ";ansi --white-intense "${sitefile[0]}_$SITE.sql.gz"
          mv "${file[1]}" "${sitefile[0]}_$SITE.sql.gz"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Ungzipping ";ansi --white-intense "${sitefile[0]}_$SITE.sql.gz"
          pv "${sitefile[0]}_$SITE.sql.gz" | gunzip > "${sitefile[0]}_$SITE.sql"
          rm -rf "${sitefile[0]}_$SITE.sql~"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Cleaning ";ansi --white-intense "${sitefile[0]}_$SITE.sql"
          pv "${sitefile[0]}_$SITE.sql" | sed '/^\/\*\!50112/d' > temp && rm -f "${sitefile[0]}_$SITE.sql" && mv temp "${sitefile[0]}_$SITE.sql"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Removing ";ansi --white-intense "${sitefile[0]}_$SITE.sql.gz"
          rm -f "${sitefile[0]}_$SITE.sql.gz"
          ;;

        rioclaro)
          files=$(echo 'sudo -i eybackup -e mysql -l obras' | ssh -t deploy@ec2-54-232-181-209.sa-east-1.compute.amazonaws.com | tail -2 | grep gz)
          IFS=' '
          read -ra file <<< "$files"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Listing ";ansi --white-intense "${file[0]}"
          echo "sudo -i eybackup -e mysql -d ${file[0]}" | ssh -t deploy@ec2-54-232-181-209.sa-east-1.compute.amazonaws.com 
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Downloading "${file[1]}
          scp deploy@ec2-54-232-181-209.sa-east-1.compute.amazonaws.com:/mnt/tmp/${file[1]} .
          IFS='T'
          read -ra sitefile <<< "${file[1]}"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Renaming to ";ansi --white-intense "${sitefile[0]}_$SITE.sql.gz"
          mv "${file[1]}" "${sitefile[0]}_$SITE.sql.gz"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Ungzipping ";ansi --white-intense "${sitefile[0]}_$SITE.sql.gz"
          pv "${sitefile[0]}_$SITE.sql.gz" | gunzip > "${sitefile[0]}_$SITE.sql"
          rm -rf "${sitefile[0]}_$SITE.sql~"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Cleaning ";ansi --white-intense "${sitefile[0]}_$SITE.sql"
          pv "${sitefile[0]}_$SITE.sql" | sed '/^\/\*\!50112/d' > temp && rm -f "${sitefile[0]}_$SITE.sql" && mv temp "${sitefile[0]}_$SITE.sql"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Removing ";ansi --white-intense "${sitefile[0]}_$SITE.sql.gz"
          rm -f "${sitefile[0]}_$SITE.sql.gz"
          ;;

        suzano)  
          files=$(echo 'sudo -i eybackup -e mysql -l obras' | ssh -t deploy@ec2-52-67-14-193.sa-east-1.compute.amazonaws.com | tail -2 | grep gz)
          IFS=' '
          read -ra file <<< "$files"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Listing ";ansi --white-intense "${file[0]}"
          echo "sudo -i eybackup -e mysql -d ${file[0]}" | ssh -t deploy@ec2-52-67-14-193.sa-east-1.compute.amazonaws.com 
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Downloading "${file[1]}
          scp deploy@ec2-52-67-14-193.sa-east-1.compute.amazonaws.com:/mnt/tmp/${file[1]} .
          IFS='T'
          read -ra sitefile <<< "${file[1]}"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Renaming to ";ansi --white-intense "${sitefile[0]}_$SITE.sql.gz"
          mv "${file[1]}" "${sitefile[0]}_$SITE.sql.gz"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Ungzipping ";ansi --white-intense "${sitefile[0]}_$SITE.sql.gz"
          pv "${sitefile[0]}_$SITE.sql.gz" | gunzip > "${sitefile[0]}_$SITE.sql"
          rm -rf "${sitefile[0]}_$SITE.sql~"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Cleaning ";ansi --white-intense "${sitefile[0]}_$SITE.sql"
          pv "${sitefile[0]}_$SITE.sql" | sed '/^\/\*\!50112/d' > temp && rm -f "${sitefile[0]}_$SITE.sql" && mv temp "${sitefile[0]}_$SITE.sql"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Removing ";ansi --white-intense "${sitefile[0]}_$SITE.sql.gz"
          rm -f "${sitefile[0]}_$SITE.sql.gz"
          ;;

        santoandre)  
          files=$(echo 'sudo -i eybackup -e mysql -l obras' | ssh -t deploy@ec2-52-67-134-57.sa-east-1.compute.amazonaws.com | tail -2 | grep gz)
          IFS=' '
          read -ra file <<< "$files"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Listing ";ansi --white-intense "${file[0]}"
          echo "sudo -i eybackup -e mysql -d ${file[0]}" | ssh -t deploy@ec2-52-67-134-57.sa-east-1.compute.amazonaws.com 
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Downloading "${file[1]}
          scp deploy@ec2-52-67-134-57.sa-east-1.compute.amazonaws.com:/mnt/tmp/${file[1]} .
          IFS='T'
          read -ra sitefile <<< "${file[1]}"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Renaming to ";ansi --white-intense "${sitefile[0]}_$SITE.sql.gz"
          mv "${file[1]}" "${sitefile[0]}_$SITE.sql.gz"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Ungzipping ";ansi --white-intense "${sitefile[0]}_$SITE.sql.gz"
          pv "${sitefile[0]}_$SITE.sql.gz" | gunzip > "${sitefile[0]}_$SITE.sql"
          rm -rf "${sitefile[0]}_$SITE.sql~"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Cleaning ";ansi --white-intense "${sitefile[0]}_$SITE.sql"
          pv "${sitefile[0]}_$SITE.sql" | sed '/^\/\*\!50112/d' > temp && rm -f "${sitefile[0]}_$SITE.sql" && mv temp "${sitefile[0]}_$SITE.sql"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Removing ";ansi --white-intense "${sitefile[0]}_$SITE.sql.gz"
          rm -f "${sitefile[0]}_$SITE.sql.gz"
          ;;

        demo)
          files=$(echo 'sudo -i eybackup -e mysql -l obras' | ssh -t deploy@ec2-54-232-113-149.sa-east-1.compute.amazonaws.com | tail -2 | grep gz)
          IFS=' '
          read -ra file <<< "$files"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Listing ";ansi --white-intense "${file[0]}"
          echo "sudo -i eybackup -e mysql -d ${file[0]}" | ssh -t deploy@ec2-54-232-113-149.sa-east-1.compute.amazonaws.com 
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Downloading "${file[1]}
          scp deploy@ec2-54-232-113-149.sa-east-1.compute.amazonaws.com:/mnt/tmp/${file[1]} .
          IFS='T'
          read -ra sitefile <<< "${file[1]}"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Renaming to ";ansi --white-intense "${sitefile[0]}_$SITE.sql.gz"
          mv "${file[1]}" "${sitefile[0]}_$SITE.sql.gz"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Ungzipping ";ansi --white-intense "${sitefile[0]}_$SITE.sql.gz"
          pv "${sitefile[0]}_$SITE.sql.gz" | gunzip > "${sitefile[0]}_$SITE.sql"
          rm -rf "${sitefile[0]}_$SITE.sql~"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Cleaning ";ansi --white-intense "${sitefile[0]}_$SITE.sql"
          pv "${sitefile[0]}_$SITE.sql" | sed '/^\/\*\!50112/d' > temp && rm -f "${sitefile[0]}_$SITE.sql" && mv temp "${sitefile[0]}_$SITE.sql"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Removing ";ansi --white-intense "${sitefile[0]}_$SITE.sql.gz"
          rm -f "${sitefile[0]}_$SITE.sql.gz"
          ;;

        *)
          ansi --no-newline --red-intense "==> "; ansi --white-intense "Error bad site "$SITE
          __pr
          return 1
          ;;
      esac     
      ;;

    update)
      case $2 in
        all)
          sites=(olimpia rioclaro suzano santoandre demo)
          for site in "${sites[@]}"
          do
            site $site
            db download 
            db import 
          done
          site $SITE
          ;;

        *)
          db download
          db import  
          ;;
      esac
      ;;

    start)
      if [ -z "$DOCKER" ]; then
        if [ $OS == 'Darwin' ]; then
          brew services start mysql@5.7
        else
          service mysql start
        fi
      else
        docker-compose up -d db
      fi
      ;;

    stop)
      if [ -z "$DOCKER" ]; then
        if [ $OS == 'Darwin' ]; then
          brew services stop mysql@5.7
        else
          service mysql stop
        fi
      else
        docker-compose stop db
      fi
      ;;

    restart)
      if [ -z "$DOCKER" ]; then
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
      else
        docker-compose restart db
      fi
      ;;

    set)
      case $2 in
        olimpia|rioclaro|suzano|santoandre|demo)
          spring stop
          set -o allexport
          . ./.env/development/$2
          set +o allexport
          ;;

        default) 
          unset MYSQL_DATABASE_DEV
          unset MYSQL_DATABASE_TST
          ;;

        *)
          ansi --no-newline --red-intense "==> "; ansi --white-intense "Error bad site "$2
          __pr
          return 1
          ;;
      esac
      ;;

    status)
      if [ -z "$DOCKER" ]; then
        if [ $OS == 'Darwin' ]; then
          brew services list
        else  
          service mysql status
        fi
      else
        docker-compose ps db
      fi
      ;;

    socket)
      if [ -z "$DOCKER" ]; then
        mysql_config --socket
      else
        docker compose exec db mysql_config --socket
      fi
      ;; 

    tables)
      if [ -z "$DOCKER" ]; then
        db=$(__db)
        mysqlshow -uroot $db | more
      else
        db=$(__db)
        docker compose exexc db mysqlshow -uroot $db | more
      fi
      ;;

    databases)
      if [ -z "$DOCKER" ]; then
        mysqlshow -uroot | more
      else
        docker compose exec db mysqlshow -uroot | more
      fi
      ;;

    *)
      __pr_db dev
      __pr_db tst
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
  fi
}

site(){
  __is_obras
  if [ $? -eq 0 ]; then
  case $1 in
    help|h|--help|-h)
      __pr bold "Crafted (c) 2013~2020 by InMov - Intelligence in Movement"
      __pr bold "::"
      __pr info "site" "[sitename || flags || set/unset flag|| env development/test]"
      __pr info "site" "[check/ls || start/stop [sitename/all] || console || test || rspec]"
      __pr info "site" "[ngrok || mailcatcher start/stop]"
      __pr 
      ;;

    olimpia|santoandre|demo)
      export SITE=$1
      export HEADLESS=true
      unset COVERAGE
      unset SELENIUM_REMOTE_HOST
      cd "$OBRAS"
      db set $1
      title $1
      ;;

    rioclaro|suzano)
      export SITE=$1
      export HEADLESS=true
      unset COVERAGE
      unset SELENIUM_REMOTE_HOST
      cd "$OBRAS_OLD"
      db set $1
      title $1
      ;;

    default)
      export SITE=$1
      export HEADLESS=true
      unset COVERAGE
      unset SELENIUM_REMOTE_HOST
      cd "$OBRAS"
      db set $1
      title $1
      ;;

    env)
      case $2 in
        development|dev)
          unset RAILS_ENV
          export RAILS_ENV=development
          ;;
        test|tst)
          unset RAILS_ENV
          export RAILS_ENV=test
          ;;
        *)
          ansi --no-newline --red-intense "==> "; ansi --white-intense "Error bad env "$2
          __pr
          return 1
          ;;
      esac  
      ;;

    set)
      case $2 in
        coverage)
          unset COVERAGE
          export COVERAGE=true
          ;;

        headless)
          unset HEADLESS
          export HEADLESS=true
          ;;

        docker)
          docker info > /dev/null 2>&1
          status=$?
          if $(exit $status); then
            docker-compose up -d db selenium $SITE > /dev/null 2>&1
            status=$?
            if $(exit $status); then
              unset DOCKER
              export DOCKER=true
              unset SELENIUM_REMOTE_HOST
              export SELENIUM_REMOTE_HOST=selenium
            else  
              ansi --no-newline --red-intense "==> "; ansi --white-intense "Cannot turn Docker services up"
              __pr
              return 1
            fi
          else  
            ansi --no-newline --red-intense "==> "; ansi --white-intense "Cannot connect to the Docker daemon"
            __pr
            return 1
          fi  
          ;;
          
        selenium|selenium_remote)
          unset SELENIUM_REMOTE_HOST
          export SELENIUM_REMOTE_HOST=selenium
          ;;


        *)
          ansi --no-newline --red-intense "==> "; ansi --white-intense "Error bad site "$2
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

        docker)
          docker-compose down > /dev/null 2>&1
          status=$?
          if $(exit $status); then
            unset DOCKER
          fi
          ;;

        selenium|selenium_remote)
          unset SELENIUM_REMOTE_HOST
          ;;

        *)
          ansi --no-newline --red-intense "==> "; ansi --white-intense "Error bad parameter "$2
          __pr
          return 1
          ;;
      esac
      ;;

    start)
      if [ -z "$DOCKER" ]; then
        if [ -z "$2" ]; then
          test -f tmp/pids/server.pid && rm -f tmp/pids/server.pid
          foreman start $SITE
        else   
          case $2 in
            olimpia|rioclaro|suzano|santoandre|demo|default)
              test -f tmp/pids/server.pid && rm -f tmp/pids/server.pid
              foreman start $2
              ;;

            all)
              test -f tmp/pids/server.pid && rm -f tmp/pids/server.pid
              foreman start all
              ;;

            *)
              ansi --no-newline --red-intense "==> "; ansi --white-intense "Error bad site name "$2
              __pr
              return 1
              ;;
          esac
        fi
      else
        if [ -z "$2" ]; then
          docker-compose up -d $SITE
        else   
          case $2 in
            olimpia|rioclaro|suzano|santoandre|demo)
              docker-compose up -d $2
              ;;

            all)
              docker-compose up -d 
              ;;

            *)
              ansi --no-newline --red-intense "==> "; ansi --white-intense "Error bad site name "$2
              __pr
              return 1
              ;;
          esac
        fi
      fi
      ;;  

    stop)
      if [ -z "$DOCKER" ]; then
        if [ -z "$2" ]; then
          kill -9 $(__pid $(__port $SITE))
        else   
          case $2 in
            olimpia|rioclaro|suzano|santoandre|default)
              kill -9 $(__pid $(__port $2))
              ;;

            all)
            sites=(olimpia rioclaro suzano santoandre default)
            for site in "${sites[@]}"
            do
              pid=$(__pid $(__port $site))
              if [ ! -z $pid ]; then
                kill -9 $pid
              fi  
            done
            ;;

            *)
              ansi --no-newline --red-intense "==> "; ansi --white-intense "Error bad site name "$2
              __pr
              return 1
              ;;
          esac
        fi
      else
        if [ -z "$2" ]; then
          docker-compose stop $SITE
        else   
          case $2 in
            olimpia|rioclaro|suzano|santoandre|demo)
              docker-compose stop $2
              ;;

            all)
              docker-compose down
              unset DOCKER
              ;;

            *)
              ansi --no-newline --red-intense "==> "; ansi --white-intense "Error bad site name "$2
              __pr
              return 1
              ;;
          esac
        fi
      fi
      ;;

    console)
      if [ -z "$DOCKER" ]; then
        spring stop 
        rails console
      else
        docker-compose exec $SITE spring stop
        docker-compose exec -e RAILS_ENV=$RAILS_ENV -e SELENIUM_REMOTE_HOST=$SELENIUM_REMOTE_HOST -e COVERAGE=$COVERAGE $SITE rails console
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
          ansi --no-newline "mailcatcher : ";__url "1080"
          ;;
      esac    
      ;;

    ngrok) 
      port=$(cat Procfile | grep -i $SITE | awk '{print $7}')
      ngrok http $port 
      ;;

    flags) 
     ansi --no-newline "flags : "
      __wr_env "coverage" $COVERAGE 
      __wr_env "headless" $HEADLESS
      __wr_env  "docker" $DOCKER
      __pr_env  "selenium_remote" $SELENIUM_REMOTE_HOST
      __pr
      ;;

    db)
      shift
      db $*
      ;;  

    test)
      if [ -z $DOCKER ]; then
        rails test $*
      else
        docker-compose exec -e HEADLESS=$HEADLESS -e COVERAGE=$COVERAGE -e SELENIUM_REMOTE_HOST=$SELENIUM_REMOTE_HOST $SITE rails test $*
      fi
      ;;

    test:system)
      if [ -z $DOCKER ]; then
        rails test:system $*
      else
        docker-compose exec -e HEADLESS=$HEADLESS -e COVERAGE=$COVERAGE -e SELENIUM_REMOTE_HOST=$SELENIUM_REMOTE_HOST $SITE rails test:system $*
      fi
      ;;

    rspec)
      if [ -z $DOCKER ]; then
        rspec $*
      else
        docker-compose exec -e HEADLESS=$HEADLESS -e COVERAGE=$COVERAGE -e SELENIUM_REMOTE_HOST=$SELENIUM_REMOTE_HOST $SITE rspec $*
      fi
      ;;

    *)
      __docker
      __pr bold "site:" $SITE
      __pr infobold "rvm :" $(rvm current)
      ansi --no-newline "env : "
      if [ $RAILS_ENV == 'development' ]; then 
        ansi --no-newline --green "development"
      else
        ansi --no-newline --red "development"
      fi
      ansi --no-newline ", "
      if [ $RAILS_ENV == 'test' ]; then 
        ansi --green "test"
      else
        ansi --red "test"
      fi
      ansi --no-newline "rails server: ";__url $(__port $SITE)
      site mailcatcher
      ansi --no-newline "flags : "
      __wr_env "coverage" $COVERAGE 
      __wr_env "headless" $HEADLESS
      __wr_env  "docker" $DOCKER
      __pr_env  "selenium_remote" $SELENIUM_REMOTE_HOST
      db
      ;;
  esac
  fi
}
