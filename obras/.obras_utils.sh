#!/bin/bash
## Crafted (c) 2013~2020 by InMov - Intelligence in Movement
## Prepared : Roberto Nogueira
## Project  : project-obras-devtools
## Reference: bash
## Depends  : foreman, pipe viewer, ansi, revolver
## Purpose  : Develop bash routines in order to help Rails development
##            projects.
## File     : .obras_utils.sh

# variables
export OBRAS_UTILS_VERSION=1.4.69
export OBRAS_UTILS_VERSION_DATE=2020.09.16

export OS=`uname`
if [ $OS == 'Darwin' ]; then
  export CPPFLAGS="-I/usr/local/opt/mysql@5.7/include"
  export LDFLAGS="-L/usr/local/opt/mysql@5.7/lib"
  export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
fi

export MAILCATCHER_ENV=LOCALHOST
export RAILSVERSIONTMP="Rails 6.0.2.1"
export SITESTMP="+(default|olimpia|rioclaro|suzano|santoandre|demo)"
export SITESOLDTMP="+(none)"
export OBRASTMP="$HOME/Projects/obras"
export OBRASOLDTMP="$HOME/Logbook/obras"
export INSTALLDIRTMP=obras_dir
export RAILS_VERSION=$RAILSVERSIONTMP
export SITES=$SITESTMP
export SITES_OLD=$SITESOLDTMP
export OBRAS=$OBRASTMP
export OBRAS_OLD=$OBRASOLDTMP
export INSTALL_DIR=$INSTALLDIRTMP
export RAILS_ENV=development
export RUBYOPT=-W0
export SITE=default
export SITEPREV=default
unset MYSQL_DATABASE_DEV
unset MYSQL_DATABASE_TST
unset DB_TABLES_DEV
unset DB_RECORDS_DEV
unset DB_TABLES_TST
unset DB_RECORDS_TST
export HEADLESS=true
unset COVERAGE
unset DOCKER

# aliases development
alias home='cd $HOME;title home'
alias obras='cd $OBRAS;title obras'
alias obras_old='cd $OBRAS_OLD;title obras_old'
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
get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

version_gt(){
  test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; 
}

obras_utils() {
  case $1 in
    --version|-v|v|version)
      ansi --white-intense "Crafted (c) 2013~2020 by InMov - Intelligence in Movement"
      ansi --white --no-newline "Obras Utils ";ansi --white-intense $OBRAS_UTILS_VERSION
      ansi --white "::"
      ;;

    check|-c)
      first_version=$(get_latest_release enogrob/research-obras-devtools)
      second_version=$OBRAS_UTILS_VERSION
      ansi --white --no-newline "Your release of Obras Utils is ";ansi --white-intense $second_version
      if version_gt $first_version $second_version; then
        ansi --white --no-newline "There is a newer release which is ";ansi --white-intense $first_version
        ansi --white ""
      else   
        ansi --white --no-newline "There is no newer release"
        ansi --white ""
      fi
      ;;  

    update|-u)
      ansi --no-newline --green-intense "==> "; ansi --white-intense "Updating Obras utils "
      ansi --white --no-newline "Obras Utils is at ";ansi --white-intense $OBRAS_UTILS_VERSION
      test -f obras_temp && rm -rf obras_temp*
      test -f .obras_utils.sh && rm -rf .obras_utils.sh
      wget https://raw.githubusercontent.com/enogrob/research-obras-devtools/master/obras/.obras_utils.sh
      sed 's@\$OBRASTMP@'"$OBRAS"'@' .obras_utils.sh > obras_temp
      sed 's@\$OBRASOLDTMP@'"$OBRAS_OLD"'@' obras_temp > obras_temp1 
      echo -e "\033[1;92m==> \033[0m\033[1;39mUpdating \".obras_utils.sh\" \033[0m"
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
      cowsay "* site command is now faster"
      ;;

    *)
      ansi --white-intense "Crafted (c) 2013~2020 by InMov - Intelligence in Movement"
      ansi --white --no-newline "Obras Utils ";ansi --white-intense $OBRAS_UTILS_VERSION
      ansi --white "::"
      __pr info "obras_utils " "[version/update/check]"
      __pr
      ;;  
    esac  
}

__pr(){
    if [ $# -eq 0 ]; then
        ansi --white ""
    elif [ $# -eq 2 ]; then
        case $1 in
            dang|red)
                ansi --red $2
                ;;
            succ|green)
                ansi --green $2
                ;;
            warn|yellow)
                ansi --yellow $2
                ;;
            info|blue)
                ansi --cyan $2
                ;;
            infobold|lightcyan)
                ansi --cyan-intense $2
                ;;
            bold|white)
                ansi --white $2
                ;;
        esac
    elif [ $# -eq 3 ]; then
        case $1 in
            dang|red)
                ansi --no-newline --white $2;ansi --red $3
                ;;
            succ|green)
                ansi --no-newline --white $2;ansi --green $3
                ;;
            warn|yellow)
                ansi --no-newline --white $2;ansi --yellow $3
                ;;
            info|blue)
                ansi --no-newline --white $2;ansi --cyan $3
                ;;
            infobold|lightcyan)
                ansi --no-newline --white $2;ansi --cyan-intense $3
                ;;
            bold|white)
                ansi --no-newline --white $2;ansi --white-intense $3
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

__pr_site(){
  ansi --white --no-newline "site: "
  ansi --white-intense $SITE
}

__db(){
  if [ -z $1 ]; then
    env=$RAILS_ENV
  else
    env=$1
  fi
  if [ "$env" == 'development' ]; then
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
    echo $(echo -n $s | sed 's/[^0-9]*//g' | tr -d '\n')
  else
    s=`docker-compose exec db mysql -uroot -proot -e "SELECT SUM(TABLE_ROWS) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '$1';"`
    echo $(echo -n $s | sed 's/[^0-9]*//g' | tr -d '\n')
  fi
} 

__tables(){
  if [ -z "$DOCKER" ]; then
    s=`mysql -u root -e "SELECT count(*) AS TOTALNUMBEROFTABLES FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '$1';"`
    echo $(echo -n $s | sed 's/[^0-9]*//g' | tr -d '\n')
  else
    s=`docker-compose exec db mysql -uroot -proot -e "SELECT count(*) AS TOTALNUMBEROFTABLES FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '$1';"`
    echo $(echo -n $s | sed 's/[^0-9]*//g' | tr -d '\n')
  fi
}

__update_db_dev_stats(){
  db=$(__db development)
  if [ "$(__has_database $db)" == 'yes' ]; then
    export DB_TABLES_DEV=$(__tables $db)
    export DB_RECORDS_DEV=$(__records $db)
  fi
}

__update_db_tst_stats(){
  db=$(__db test)
  if [ "$(__has_database $db)" == 'yes' ]; then
    export DB_TABLES_TST=$(__tables $db)
    export DB_RECORDS_TST=$(__records $db)
  fi
}

__update_db_stats(){
  db=$(__db $RAILS_ENV)
  if [ "$(__has_database $db)" == 'yes' ]; then
    case $RAILS_ENV in 
      development)
        export DB_TABLES_DEV=$(__tables $db)
        export DB_RECORDS_DEV=$(__records $db)
        ;;
      test)
        export DB_TABLES_TST=$(__tables $db)
        export DB_RECORDS_TST=$(__records $db)
        ;;
    esac
  fi
}

__zeroed_db_stats(){
  unset DB_TABLES_DEV
  unset DB_RECORDS_DEV
  unset DB_TABLES_TST
  unset DB_RECORDS_TST
}

__update_db_stats_site(){
  if [ -z "$DB_TABLES_DEV" ]; then
    __update_db_dev_stats
  fi  
  if [ -z "$DB_TABLES_TST" ]; then
    __update_db_tst_stats
  fi  
}

__import(){
  rails=`rails --version`
  if [ $rails == $RAILS_VERSION ]; then
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
  if [ $rails == $RAILS_VERSION ]; then
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
    db=$(__db development)
  else  
    db=$(__db test)
  fi
  if [ "$(__has_database $db)" == 'yes' ]; then
    if [ $env == "dev" ]; then
      ansi --no-newline "db_"$env": "; ansi --no-newline --green $db' '; ansi --white --no-newline $DB_TABLES_DEV' '; ansi --white $DB_RECORDS_DEV
    else
      ansi --no-newline "db_"$env": "; ansi --no-newline --green $db' '; ansi --white --no-newline $DB_TABLES_TST' '; ansi --white $DB_RECORDS_TST
    fi  
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
      ansi --white-intense "Crafted (c) 2013~2020 by InMov - Intelligence in Movement"
      ansi --white --no-newline "Obras Utils ";ansi --white-intense $OBRAS_UTILS_VERSION
      ansi --white "::"
      __pr info "db " "[set sitename || ls || preptest/init || drop || create || migrate || seed]"
      __pr info "db " "[backups || download [filenumber] || import [dbfile] || update [all]]"
      __pr info "db " "[status || start || stop || restart || tables || databases || socket || connect]"
      __pr info "db " "[api [dump/export || import]]"
      __pr 
      ;; 

    --version|-v|v)  
      ansi --white-intense "Crafted (c) 2013~2020 by InMov - Intelligence in Movement"
      ansi --white --no-newline "Obras Utils ";ansi --white-intense $OBRAS_UTILS_VERSION
      ansi --white "::"
      ;;

    api)
      case $2 in
        dump|export)
          IFS=$'\n'
          if [ -z "$DOCKER" ]; then
            files_sql=(`mysqlshow -uroot $MYSQL_DATABASE_DEV | sed 's/[|+-]//g' | grep "^\sapi" | sed -e 's/^[[:space:]]*//' 2>/dev/null`)
          else
            files_sql=(`docker exec -i db mysqlshow -uroot $MYSQL_DATABASE_DEV | sed 's/[|+-]//g' | grep "^\sapi" | sed -e 's/^[[:space:]]*//' 2>/dev/null`)
          fi  
          if [ ! -z "$files_sql" ]; then
            IFS=$'\n'
            files_sql=( $(printf "%s\n" ${files_sql[@]} | sort -r ) )
            for file in ${files_sql[*]}
            do
              file1=$(echo -e "${file}" | tr -d '[:space:]')
              ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Dumping ";ansi --green $file1
              if [ -z "$DOCKER" ]; then
                mysqldump -uroot $MYSQL_DATABASE_DEV $file1 > "$file1.sql"
              else
                docker exec -i db mysqldump -uroot -proot $MYSQL_DATABASE_DEV $file1 > "$file1.sql"
              fi  
            done
          else
            __pr dang " no api files"
          fi
          unset IFS
          __pr
          ;;
        import)
          IFS=$'\n'
          files_sql=(`ls api*.sql 2>/dev/null`)
          if [ ! -z "$files_sql" ]; then
            IFS=$'\n'
            files_sql=( $(printf "%s\n" ${files_sql[@]} | sort -r ) )
            for file in ${files_sql[*]}
            do
              ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Importing ";ansi --green $file
              if [ -z "$DOCKER" ]; then
                pv $file | mysql -uroot $MYSQL_DATABASE_DEV 
              else
                pv $file | docker exec -i db mysql -uroot -proot $MYSQL_DATABASE_DEV
              fi  
            done
          else
            __pr dang " no api files"
          fi
          unset IFS
          __pr
          ;;
        *)
          IFS=$'\n'
          files_sql=(`ls api*.sql 2>/dev/null`)
          echo -e "table_apis:"
          if [ ! -z "$files_sql" ]; then
            IFS=$'\n'
            files_sql=( $(printf "%s\n" ${files_sql[@]} | sort -r ) )
            for file in ${files_sql[*]}
            do
              __pr succ ' '$file
            done
          else
            __pr dang " no api files"
          fi
          unset IFS
          __pr
          ;;
      esac
      ;;

    preptest|init)
      if [ -z "$DOCKER" ]; then
        rails=`rails --version`
        if [ $rails == $RAILS_VERSION ]; then
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
        __update_db_stats
      else 
        rails=`rails --version`
        if [ $rails == $RAILS_VERSION ]; then
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
        __update_db_stats
      fi
      ;;

    ls)
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
      unset IFS
      __pr
      ;;

    drop)
      if [ -z "$DOCKER" ]; then
        db=$(__db)
        if [ "$(__has_database $db)" == 'yes' ]; then
          rails=`rails --version`
          if [ $rails == $RAILS_VERSION ]; then
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
          __zeroed_db_stats 
        else  
          ansi --no-newline --red-intense "==> "; ansi --white-intense "Error file "$db" does not exists"
        fi
      else
        db=$(__db)
        if [ "$(__has_database $db)" == 'yes' ]; then
          rails=`rails --version`
          if [ $rails == $RAILS_VERSION ]; then
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
          __zeroed_db_stats
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
          if [ $rails == $RAILS_VERSION ]; then
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
          __zeroed_db_stats 
        else  
          ansi --no-newline --red-intense "==> "; ansi --white-intense "Error file "$db" already exists"
        fi
      else
        db=$(__db)
        if [ "$(__has_database $db)" == 'no' ]; then
          rails=`rails --version`
          if [ $rails == $RAILS_VERSION ]; then
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
          __zeroed_db_stats
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
          if [ $rails == $RAILS_VERSION ]; then
            ansi --no-newline --green-intense "==> "; ansi --white-intense "Migrating db "
            rails db:migrate
          else
            ansi --no-newline --green-intense "==> "; ansi --white-intense "Migrating db "
            rake db:migrate
          fi
          __update_db_stats
        else  
          ansi --no-newline --red-intense "==> "; ansi --white-intense "Error file "$db" does not exist"
        fi
      else
        db=$(__db)
        if [ "$(__has_database $db)" == 'yes' ]; then
          rails=`rails --version`
          if [ $rails == $RAILS_VERSION ]; then
            ansi --no-newline --green-intense "==> "; ansi --white-intense "Migrating db "
            docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rails db:migrate
          else
            ansi --no-newline --green-intense "==> "; ansi --white-intense "Migrating db "
            docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rake db:migrate
          fi  
          __update_db_stats
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
          if [ $rails == $RAILS_VERSION ]; then
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
          __update_db_stats
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
          if [ $rails == $RAILS_VERSION ]; then
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
          __update_db_stats
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
                  __update_db_stats
                fi
                if [ $(__contains "$file" "rioclaro") == "y" ]; then
                  site set rioclaro
                  __import $(basename $file)
                  __update_db_stats
                fi
                if [ $(__contains "$file" "suzano") == "y" ]; then
                  site set suzano
                  __import $(basename $file)
                  __update_db_stats
                fi
                if [ $(__contains "$file" "santoandre") == "y" ]; then
                  site set santoandre
                  __import $(basename $file)
                  __update_db_stats
                fi
                if [ $(__contains "$file" "demo") == "y" ]; then
                  site set demo
                  __import $(basename $file)
                  __update_db_stats
                fi
              done
              unset IFS
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
                  __update_db_stats
                fi
                if [ $(__contains "$file" "rioclaro") == "y" ]; then
                  site set rioclaro
                  __import_docker $(basename $file)
                  __update_db_stats
                fi
                if [ $(__contains "$file" "suzano") == "y" ]; then
                  site set suzano
                  __import_docker $(basename $file)
                  __update_db_stats
                fi
                if [ $(__contains "$file" "santoandre") == "y" ]; then
                  site set santoandre
                  __import_docker $(basename $file)
                  __update_db_stats
                fi
                if [ $(__contains "$file" "demo") == "y" ]; then
                  site set demo
                  __import_docker $(basename $file)
                  __update_db_stats
                fi
              done
              unset IFS
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
              IFS=$'\n' 
              files_sql=($(ls *$SITE.sql))
              if [ ! -z "$files_sql" ]; then
                IFS=$'\n'
                files_sql=( $(printf "%s\n" ${files_sql[@]} | sort -r ) )
                file=${files_sql[0]}
                echo $file
                __import $(basename $file)
              else   
                ansi --no-newline --red-intense "==> "; ansi --white-intense "Error no sql files"
                __pr
                return 1
              fi
              unset IFS
            fi
            __update_db_stats
          else  
            if test -f "$2"; then
              __import_docker $2
            else
              IFS=$'\n'
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
              unset IFS
            fi
            __update_db_stats
          fi
          ;;
      esac
      ;;

    download)
      case $SITE in 
        olimpia)
          if [ -z "$2" ]; then
            files=$(echo 'sudo -i eybackup -e mysql -l obras' | ssh -t deploy@ec2-18-231-91-182.sa-east-1.compute.amazonaws.com | tail -2 | grep gz)
          else  
            files=$(echo 'sudo -i eybackup -e mysql -l obras' | ssh -t deploy@ec2-18-231-91-182.sa-east-1.compute.amazonaws.com | grep gz | grep "$2:obras")
          fi
          IFS=' '
          read -ra file <<< "$files"
          filenumber=${file[0]}
          filename_orig="${file[1]}"

          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Listing ";ansi --white-intense "$filenumber"
          echo "sudo -i eybackup -e mysql -d $filenumber" | ssh -t deploy@ec2-18-231-91-182.sa-east-1.compute.amazonaws.com 
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Downloading "$filename_orig
          scp deploy@ec2-18-231-91-182.sa-east-1.compute.amazonaws.com:/mnt/tmp/$filename_orig .
          IFS='T'
          read -ra file1 <<< "${file[1]}"

          prefix="${file1[0]}"
          IFS='.'
          read -ra file2 <<< "${file1[1]}"
          filename=$prefix'_'${file2[0]}'_'$SITE

          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Renaming to ";ansi --white-intense "$filename.sql.gz"
          mv "$filename_orig" "$filename.sql.gz"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Ungzipping ";ansi --white-intense "$filename.sql.gz"
          pv "$filename.sql.gz" | gunzip > "$filename.sql"
          rm -rf "$filename.sql~"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Cleaning ";ansi --white-intense "$filename.sql"
          pv "$filename.sql" | sed '/^\/\*\!50112/d' > temp && rm -f "$filename.sql" && mv temp "$filename.sql"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Removing ";ansi --white-intense "$filename.sql.gz"
          rm -f "$filename.sql.gz"
          unset IFS
          ;;

        rioclaro)
          if [ -z "$2" ]; then
            files=$(echo 'sudo -i eybackup -e mysql -l obras' | ssh -t deploy@ec2-54-232-181-209.sa-east-1.compute.amazonaws.com | tail -2 | grep gz)
          else  
            files=$(echo 'sudo -i eybackup -e mysql -l obras' | ssh -t deploy@ec2-54-232-181-209.sa-east-1.compute.amazonaws.com | grep gz | grep "$2:obras")
          fi
          IFS=' '
          read -ra file <<< "$files"
          filenumber=${file[0]}

          filename_orig="${file[1]}"

          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Listing ";ansi --white-intense "${file[0]}"
          echo "sudo -i eybackup -e mysql -d $filenumber" | ssh -t deploy@ec2-54-232-181-209.sa-east-1.compute.amazonaws.com 
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Downloading "${file[1]}
          scp deploy@ec2-54-232-181-209.sa-east-1.compute.amazonaws.com:/mnt/tmp/${file[1]} .
          IFS='T'
          read -ra file1 <<< "${file[1]}"

          prefix="${file1[0]}"
          IFS='.'
          read -ra file2 <<< "${file1[1]}"
          filename=$prefix'_'${file2[0]}'_'$SITE

          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Renaming to ";ansi --white-intense "$filename.sql.gz"
          mv "$finame_orig" "$filename.sql.gz"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Ungzipping ";ansi --white-intense "$filename.sql.gz"
          pv "$filename.sql.gz" | gunzip > "$filename.sql"
          rm -rf "$filename.sql~"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Cleaning ";ansi --white-intense "$filename.sql"
          pv "$filename.sql" | sed '/^\/\*\!50112/d' > temp && rm -f "$filename.sql" && mv temp "$filename.sql"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Removing ";ansi --white-intense "$filename.sql.gz"
          rm -f "$filename.sql.gz"
          unset IFS
          ;;

        suzano)  
          if [ -z "$2" ]; then
            files=$(echo 'sudo -i eybackup -e mysql -l obras' | ssh -t deploy@ec2-52-67-14-193.sa-east-1.compute.amazonaws.com | tail -2 | grep gz)
          else  
            files=$(echo 'sudo -i eybackup -e mysql -l obras' | ssh -t deploy@ec2-52-67-14-193.sa-east-1.compute.amazonaws.com | grep gz | grep "$2:obras")
          fi
          IFS=' '
          read -ra file <<< "$files"
          filenumber=${file[0]}

          filename_orig="${file[1]}"

          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Listing ";ansi --white-intense "$filenumber"
          echo "sudo -i eybackup -e mysql -d $filenumber" | ssh -t deploy@ec2-52-67-14-193.sa-east-1.compute.amazonaws.com 
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Downloading "$filename_orig
          scp deploy@ec2-52-67-14-193.sa-east-1.compute.amazonaws.com:/mnt/tmp/$filename_orig .
          IFS='T'
          read -ra file1 <<< "${file[1]}"

          prefix="${file1[0]}"
          IFS='.'
          read -ra file2 <<< "${file1[1]}"
          filename=$prefix'_'${file2[0]}'_'$SITE

          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Renaming to ";ansi --white-intense "$filename.sql.gz"
          mv "$filename_orig" "$filename.sql.gz"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Ungzipping ";ansi --white-intense "$filename.sql.gz"
          pv "$filename.sql.gz" | gunzip > "$filename.sql"
          rm -rf "$filename.sql~"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Cleaning ";ansi --white-intense "$filename.sql"
          pv "$filename.sql" | sed '/^\/\*\!50112/d' > temp && rm -f "$filename.sql" && mv temp "$filename.sql"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Removing ";ansi --white-intense "$filename.sql.gz"
          rm -f "$filename.sql.gz"
          unset IFS
          ;;

        santoandre)  
          filename_orig="${file[1]}"
          if [ -z "$2" ]; then
            files=$(echo 'sudo -i eybackup -e mysql -l obras' | ssh -t deploy@ec2-52-67-134-57.sa-east-1.compute.amazonaws.com | tail -2 | grep gz)
          else  
            files=$(echo 'sudo -i eybackup -e mysql -l obras' | ssh -t deploy@ec2-52-67-134-57.sa-east-1.compute.amazonaws.com | grep gz | grep "$2:obras")
          fi
          IFS=' '
          read -ra file <<< "$files"
          filenumber=${file[0]}
          filename_orig="${file[1]}"


          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Listing ";ansi --white-intense "$filenumber"
          echo "sudo -i eybackup -e mysql -d $filenumber" | ssh -t deploy@ec2-52-67-134-57.sa-east-1.compute.amazonaws.com 
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Downloading "$filename_orig
          scp deploy@ec2-52-67-134-57.sa-east-1.compute.amazonaws.com:/mnt/tmp/$filename_orig .
          IFS='T'
          read -ra file1 <<< "${file[1]}"

          prefix="${file1[0]}"
          IFS='.'
          read -ra file2 <<< "${file1[1]}"
          filename=$prefix'_'${file2[0]}'_'$SITE

          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Renaming to ";ansi --white-intense "$filename.sql.gz"
          mv "$filename_orig" "$filename.sql.gz"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Ungzipping ";ansi --white-intense "$filename.sql.gz"
          pv "$filename.sql.gz" | gunzip > "$filename.sql"
          rm -rf "$filename.sql~"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Cleaning ";ansi --white-intense "$filename.sql"
          pv "$filename.sql" | sed '/^\/\*\!50112/d' > temp && rm -f "$filename.sql" && mv temp "$filename.sql"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Removing ";ansi --white-intense "$filename.sql.gz"
          rm -f "$filename.sql.gz"
          unset IFS
          ;;

        demo)
          filename_orig="${file[1]}"
          if [ -z "$2" ]; then
            files=$(echo 'sudo -i eybackup -e mysql -l obras' | ssh -t deploy@ec2-54-232-113-149.sa-east-1.compute.amazonaws.com | tail -2 | grep gz)
          else  
            files=$(echo 'sudo -i eybackup -e mysql -l obras' | ssh -t deploy@ec2-54-232-113-149.sa-east-1.compute.amazonaws.com | grep gz | grep "$2:obras")
          fi
          IFS=' '
          read -ra file <<< "$files"
          filenumber=${file[0]}
          filename_orig="${file[1]}"

          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Listing ";ansi --white-intense "$filenumber"
          echo "sudo -i eybackup -e mysql -d $filenumber" | ssh -t deploy@ec2-54-232-113-149.sa-east-1.compute.amazonaws.com 
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Downloading "$filename_orig
          scp deploy@ec2-54-232-113-149.sa-east-1.compute.amazonaws.com:/mnt/tmp/$filename_orig .
          IFS='T'
          read -ra file1 <<< "${file[1]}"

          prefix="${file1[0]}"
          IFS='.'
          read -ra file2 <<< "${file1[1]}"
          filename=$prefix'_'${file2[0]}'_'$SITE

          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Renaming to ";ansi --white-intense "$filename.sql.gz"
          mv "$filename_orig" "$filename.sql.gz"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Ungzipping ";ansi --white-intense "$filename.sql.gz"
          pv "$filename.sql.gz" | gunzip > "$filename.sql"
          rm -rf "$filename.sql~"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Cleaning ";ansi --white-intense "$filename.sql"
          pv "$filename.sql" | sed '/^\/\*\!50112/d' > temp && rm -f "$filename.sql" && mv temp "$filename.sql"
          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Removing ";ansi --white-intense "$filename.sql.gz"
          rm -f "$filename.sql.gz"
          unset IFS
          ;;

        *)
          ansi --no-newline --red-intense "==> "; ansi --white-intense "Error bad site "$SITE
          __pr
          return 1
          ;;
      esac     
      ;;

    backups)
      case $SITE in 
        olimpia)
          echo 'sudo -i eybackup -e mysql -l obras' | ssh -t deploy@ec2-18-231-91-182.sa-east-1.compute.amazonaws.com | grep -e 'Listing database backups for obras' -e 'backup(s) found' -e 'gz'
          ;;

        rioclaro)
          echo 'sudo -i eybackup -e mysql -l obras' | ssh -t deploy@ec2-54-232-181-209.sa-east-1.compute.amazonaws.com | grep -e 'Listing database backups for obras' -e 'backup(s) found' -e 'gz'
          ;;

        suzano)  
          echo 'sudo -i eybackup -e mysql -l obras' | ssh -t deploy@ec2-52-67-14-193.sa-east-1.compute.amazonaws.com | grep -e 'Listing database backups for obras' -e 'backup(s) found' -e 'gz'
          ;;

        santoandre)  
          echo 'sudo -i eybackup -e mysql -l obras' | ssh -t deploy@ec2-52-67-134-57.sa-east-1.compute.amazonaws.com | grep -e 'Listing database backups for obras' -e 'backup(s) found' -e 'gz'
          ;;

        demo)
          echo 'sudo -i eybackup -e mysql -l obras' | ssh -t deploy@ec2-54-232-113-149.sa-east-1.compute.amazonaws.com | grep -e 'Listing database backups for obras' -e 'backup(s) found' -e 'gz'
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
          __update_db_stats 
          ;;
      esac
      ;;

    start)
      if [ -z "$DOCKER" ]; then
        if [ $OS == 'Darwin' ]; then
          brew services start mysql@5.7
        else
          sudo service mysql start
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
          sudo service mysql stop
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
          sudo service mysql restart
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
        ansi ""
      else
        ansi --red-intense --no-newline " mysql_admin ";ansi --red " not installed in db"
        ansi ""
      fi
      ;; 

    connect)
      db=$(__db)
      if [ "$(__has_database $db)" == 'yes' ]; then
        if [ -z "$DOCKER" ]; then
          mycli -uroot $db
        else
          mycli -proot db://root@localhost:33060/$db
        fi 
      else   
        ansi --red-intense --no-newline $db;ansi --red " does not exist"
        ansi ""
      fi
      ;; 


    tables)
      if [ -z "$DOCKER" ]; then
        db=$(__db)
        mysqlshow -uroot $db | more
      else
        db=$(__db)
        docker-compose exec db mysqlshow -uroot -proot $db | more
      fi
      ;;

    databases)
      if [ -z "$DOCKER" ]; then
        mysqlshow -uroot | more
      else
        docker-compose exec db mysqlshow -uroot -proot | more
      fi
      ;;

    *)
      __pr_db dev
      __pr_db tst
      IFS=$'\n'
      files_sql=(`ls *$SITE.sql 2>/dev/null`)
      ansi --white "db_sqls:"
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
      unset IFS
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
      ansi --white-intense "Crafted (c) 2013~2020 by InMov - Intelligence in Movement"
      ansi --white --no-newline "Obras Utils ";ansi --white-intense $OBRAS_UTILS_VERSION
      ansi --white "::"
      __pr info "site " "[sitename || flags || set/unset flag|| env development/test]"
      __pr info "site " "[check/ls || start/stop [sitename/all] || console || test/test:system || rspec]"
      __pr info "site " "[ngrok || mailcatcher start/stop]"
      __pr 
      ;;

    --version|-v|v)  
      ansi --white-intense "Crafted (c) 2013~2020 by InMov - Intelligence in Movement"
      ansi --white --no-newline "Obras Utils ";ansi --white-intense $OBRAS_UTILS_VERSION
      ansi --white "::"
      ;;

    $SITES)
      export SITEPREV=$SITE
      export SITE=$1
      export HEADLESS=true
      unset COVERAGE
      cd "$OBRAS"
      db set $1
      title $1
      if [ "$SITE" != "$SITEPREV" ]; then
        unset DB_TABLES_DEV
        unset DB_RECORDS_DEV
        unset DB_TABLES_TST
        unset DB_RECORDS_TST
      fi
      __update_db_stats_site
      ;;

    $SITES_OLD)
      case $1 in
        none)
          ;;

        *)  
          export SITEPREV=$SITE
          export SITE=$1
          export HEADLESS=true
          unset COVERAGE
          cd "$OBRAS_OLD"
          db set $1
          title $1
          if [ "$SITE" != "$SITEPREV" ]; then
            unset DB_TABLES_DEV
            unset DB_RECORDS_DEV
            unset DB_TABLES_TST
            unset DB_RECORDS_TST
          fi
          __update_db_stats_site
          ;;
      esac
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
            docker-compose up -d db > /dev/null 2>&1
            # status=$?
            # if $(exit $status); then
            #   ansi --no-newline --red-intense "==> "; ansi --white-intense "Cannot turn Docker db service up"
            #   __pr
            #   return 1
            # fi
            docker-compose up -d redis > /dev/null 2>&1
            # status=$?
            # if $(exit $status); then
            #   ansi --no-newline --red-intense "==> "; ansi --white-intense "Cannot turn Docker redis service up"
            #   __pr
            #   return 1
            # fi
            docker-compose up -d selenium > /dev/null 2>&1
            # status=$?
            # if $(exit $status); then
            #   ansi --no-newline --red-intense "==> "; ansi --white-intense "Cannot turn Docker selenium service up"
            #   __pr
            #   return 1
            # fi
            docker-compose up -d $SITE > /dev/null 2>&1
            # status=$?
            # if $(exit $status); then
            #   ansi --no-newline --red-intense "==> "; ansi --white-intense "Cannot turn Docker $SITE service up"
            #   __pr
            #   return 1
            # fi
            unset DOCKER
            export DOCKER=true
          else  
            ansi --no-newline --red-intense "==> "; ansi --white-intense "Cannot connect to the Docker daemon"
            __pr
            return 1
          fi  
          ;;
          
        *)
          ansi --no-newline --red-intense "==> "; ansi --white-intense "Error bad flag "$2
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
          docker-compose up -d db redis $SITE
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
          docker-compose rm -f -s -v $SITE
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
        docker-compose exec -e RAILS_ENV=$RAILS_ENV -e COVERAGE=$COVERAGE $SITE rails console
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
      __pr
      ;;

    db)
      shift
      db $*
      ;;  

    test)
      if [ -z $DOCKER ]; then
        rails test ${@: 2}
      else
        docker-compose exec -e HEADLESS=$HEADLESS -e COVERAGE=$COVERAGE $SITE rails test ${@: 2}
      fi
      ;;

    test:system)
      if [ -z $DOCKER ]; then
        rails test:system 
      else
        docker-compose exec -e HEADLESS=$HEADLESS -e COVERAGE=$COVERAGE $SITE rails test:system 
      fi
      ;;

    rspec)
      if [ -z $DOCKER ]; then
        rspec ${@: 2}
      else
        docker-compose exec -e HEADLESS=$HEADLESS -e COVERAGE=$COVERAGE $SITE rspec ${@: 2}
      fi
      ;;

    *)
      __docker
      __update_db_stats_site
      __pr_site
      ansi --white --no-newline "rvm : ";ansi --cyan-intense $(rvm current)
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
      __pr_env  "docker" $DOCKER
      db
      ;;
  esac
  fi
}
