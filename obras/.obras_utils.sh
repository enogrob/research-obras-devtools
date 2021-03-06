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
export OBRAS_UTILS_VERSION=1.5.11
export OBRAS_UTILS_VERSION_DATE=2021.03.08
export OBRAS_UTILS_UPDATE_MESSAGE="General improvements."

export OS=`uname`
if [ $OS == 'Darwin' ]; then
  export CPPFLAGS="-I/usr/local/opt/mysql@5.7/include"
  export LDFLAGS="-L/usr/local/opt/mysql@5.7/lib"
  export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
fi

export INSTALLDIRTMP=obras_dir
export OBRASTMP="$HOME/Projects/obras"
export OBRASOLDTMP="$HOME/Projects/obras"
export RAILSVERSIONTMP="Rails 6.0.2.1"

export INSTALL_DIR=$INSTALLDIRTMP
export OBRAS=$OBRASTMP
export OBRAS_OLD=$OBRASOLDTMP
export RAILS_VERSION=$RAILSVERSIONTMP

pushd . > /dev/null 2>&1
cd $OBRAS

! test -d tmp/devtools && mkdir -p tmp/devtools

if hash foreman 2>/dev/null; then
  export SITES=$(foreman check | awk -F[\(\)] '{print $2}' | sed 's/,//g')
else
  export SITES="none"
fi
if [ "$OBRAS" != "$OBRAS_OLD" ]; then 
  cd $OBRAS_OLD
  if hash foreman 2>/dev/null; then
    export SITES_OLD=$(foreman check | awk -F[\(\)] '{print $2}' | sed 's/,//g')
  else
    export SITES_OLD="none"
  fi
else  
  export SITES_OLD="none"
fi  
popd > /dev/null 2>&1

export SITES_CASE="+($(echo $SITES | sed 's/ /|/g'))"
export SITES_OLD_CASE="+($(echo $SITES_OLD | sed 's/ /|/g'))"

export RAILS_ENV=development
export RUBYOPT=-W0
export MAILCATCHER_ENV=LOCALHOST
unset MYSQL_DATABASE_DEV
unset MYSQL_DATABASE_TST
unset DB_TABLES_DEV
unset DB_RECORDS_DEV
unset DB_TABLES_TST
unset DB_RECORDS_TST


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
__gitignore(){
  local file=$1  
  git update-index --assume-unchanged $file
}
obras_utils() {
  get_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
      grep '"tag_name":' |                                            # Get tag line
      sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
  }
  
  version_gt(){
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; 
  }

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

      if ! test -f /usr/local/bin/pipx && ! test -f $HOME/.local/bin/pipx ; then
        echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"pip\" \033[0m"
        echo ""
        if [ "$OS" == 'Darwin' ]; then
          brew install pipx
          pipx ensurepath
        else 
          python3 -m pip install --user pipx
          python3 -m pipx ensurepath 
          source $HOME/.bashrc
        fi
      fi

      if ! test -f $HOME/.local/bin/iredis; then
        echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"iredis\" \033[0m"
        echo ""
        if [ "$OS" == 'Darwin' ]; then
          brew install iredis
        else 
          apt-get install python3-venv
          pipx install iredis
        fi
      fi

      if ! test -f /usr/local/bin/ngrok && ! test -f $HOME/bin/ngrok; then
        echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"ngrok\" \033[0m"
        echo ""
        if [ "$OS" == 'Darwin' ]; then
          brew cask install ngrok
        else  
          sudo snap install ngrok
        fi
      fi

      if [ "$OS" != 'Darwin' ]; then
        if ! test -f /bin/netstat; then
          echo -e "\033[1;92m==> \033[0m\033[1;39mInstalling \"net-tools\" \033[0m"
          echo ""
          sudo apt-get install net-tools
        fi 
      fi

      source $HOME/.bashrc
      site $SITE
      ansi --white --no-newline "Obras Utils is now updated to ";ansi --white-intense $OBRAS_UTILS_VERSION
      cowsay $OBRAS_UTILS_UPDATE_MESSAGE
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
__sites(){
  case $# in
    0)
      if [ $(__contains "$SITES" "$SITE") == "y" ]; then
        echo $SITES
      elif [ $(__contains "$SITES_OLDS" "$SITE") == "y" ]; then
        echo $SITES_OLD
      else  
        echo ""
      fi
      ;;
    1)
      case $1 in
        case)
          if [ $(__contains "$SITES" "$SITE") == "y" ]; then
            echo $SITES_CASE
          elif [ $(__contains "$SITES_OLDS" "$SITE") == "y" ]; then
            echo $SITES_OLD_CASE
          else  
            echo ""
          fi
          ;;
      esac    
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
  if [ -z "$title" ]; then
    title=$(basename "$PWD")
  fi
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
  db=$(dbs.current development)
  if [ "$(__has_database $db)" == 'yes' ]; then
    export DB_TABLES_DEV=$(__tables $db)
    export DB_RECORDS_DEV=$(__records $db)
  fi
}
__update_db_tst_stats(){
  db=$(dbs.current current test)
  if [ "$(__has_database $db)" == 'yes' ]; then
    export DB_TABLES_TST=$(__tables $db)
    export DB_RECORDS_TST=$(__records $db)
  fi
}
__update_db_stats(){
  db=$(dbs.current $RAILS_ENV)
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
  if [ "$rails" == "$RAILS_VERSION" ]; then
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
  dumps.activate $1
} 
__import_docker(){
  rails=`rails --version`
  if [ "$rails" == "$RAILS_VERSION" ]; then
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
  dumps.activate $1
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
  local port=$1
  if [ "$OS" == 'Darwin' ]; then
    local pid=$(netstat -anv | grep LISTEN | grep "[.]$port" | awk '{print $9}' | uniq)
    echo $pid
  else  
    local pid=$(sudo netstat -peanut | grep "[:]$port" | awk '{print $9}' | uniq)
    arrIN=(${pid//\// })
    echo ${arrIN[0]}  
  fi
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
  local port=$(__port $SITE)
  local pid=$(__pid $port)
  if [[ ! -z "$pid" && ! -z "$DOCKER" ]]; then
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


rubocop.run(){
  local params=$(git diff --name-only --diff-filter AMT | grep -i 'rb' | tr '\n' ' ')
  if [ "$(flags.is_set rubocop)" == "y" ]; then 
    if [ $# -eq 0 ]; then
      ansi --no-newline --green-intense "==> "; ansi --white-intense "Running RuboCop "
      revolver --style 'simpleDotsScrolling' start
      rubocop -f h -o tmp/rubocop/overview.html $params
      revolver stop
    else
      ansi --no-newline --green-intense "==> "; ansi --white-intense "Running RuboCop "
      revolver --style 'simpleDotsScrolling' start
      rubocop -f h -o tmp/rubocop/overview.html $* 
      revolver stop
    fi
  else  
    ansi --no-newline --green-intense "==> "; ansi --red "rubocop shall be set"
    ansi ""
  fi
}
rubycritic.run(){
  local params=$(git diff --name-only --diff-filter AMT | grep -i 'rb' | tr '\n' ' ')
  if [ "$(flags.is_set rubycritic)" == "y" ]; then 
    if [ $# -eq 0 ]; then
      ansi --no-newline --green-intense "==> "; ansi --white-intense "Running RubyCritic "
      revolver --style 'simpleDotsScrolling' start
      rubycritic $params
      revolver stop
    else
      ansi --no-newline --green-intense "==> "; ansi --white-intense "Running RubyCritic "
      revolver --style 'simpleDotsScrolling' start
      rubycritic  $*
      revolver stop
    fi
  else  
    ansi --no-newline --green-intense "==> "; ansi --red "rubycritic shall be set"
    ansi ""
  fi
}
flags.methods(){
  local methods=(any_not_set any_set get is_set get is_set print print_all print_down print_downs print_up print_ups set status unset 
  )
  echo ${methods[@]}
  echo ${#methods[@]}
}
flags.any_not_set(){
  local flags=(coverage rubycritic rubocop docker headless)
  local result="n"
  for f in ${flags[@]}
  do
    if [ "$(flags.is_set $f)" == "n" ]; then
      result="y"
      break
    fi
  done
  echo $result
}
flags.any_set(){
  local flags=(coverage rubycritic rubocop docker headless)
  local result="n"
  for f in ${flags[@]}
  do
    if [ "$(flags.is_set $f)" == "y" ]; then
      result="y"
      break
    fi
  done
  echo $result
}
flags.get(){
  local flag=$1
  case $flag in
    coverage)
      echo $COVERAGE
      ;;
    rubycritic)
      echo $RUBYCRITIC
      ;;
    rubocop)
      echo $RUBOCOP
      ;;
    docker)
      echo $DOCKER
      ;;
    headless)
      echo $HEADLESS
      ;;
  esac
}
flags.is_set(){
  local flag=$1
  flag=$(flags.get $1)
  if [ -z $flag ]; then
    echo "n"
  else
    echo "y"
  fi
}
flags.print(){
  local flag=$1
  local last=$2
  case $flag in
    coverage)
      if [ "$(flags.is_set coverage)" == "y" ]; then
        if [ "$last" == "true" ]; then
          if test -f coverage/index.html; then
            ansi --underline --green "coverage/index.html"
          else
            ansi --green "coverage"
          fi
        else
          if test -f coverage/index.html; then
            ansi --no-newline --underline --green "coverage/index.html"
          else
            ansi --no-newline --green "coverage"
          fi
        fi
      else
        if [ "$last" == "true" ]; then
          ansi --red "coverage";
        else
          ansi --no-newline --red "coverage";
        fi
      fi
      ;;

    rubycritic)
      if [ "$(flags.is_set rubycritic)" == "y" ]; then
        if [ "$last" == "true" ]; then
          if test -f tmp/rubycritic/overview.html; then
            ansi --underline --green "tmp/rubycritic/overview.html"
          else
            ansi --green "rubycritic"
          fi
        else
          if test -f tmp/rubycritic/overview.html; then
            ansi --no-newline --underline --green "tmp/rubycritic/overview.html"
          else
            ansi --no-newline --green "rubycritic"
          fi
        fi
      else
        if [ "$last" == "true" ]; then
          ansi --red "rubycritic";
        else
          ansi --no-newline --red "rubycritic";
        fi
      fi
      ;;

    rubocop)
      if [ "$(flags.is_set rubocop)" == "y" ]; then
        if [ "$last" == "true" ]; then
          if test -f tmp/rubocop/overview.html; then
            ansi --underline --green "tmp/rubocop/overview.html"
          else
            ansi --green "rubocop"
          fi
        else
          if test -f tmp/rubocop/overview.html; then
            ansi --no-newline --underline --green "tmp/rubocop/overview.html"
          else
            ansi --no-newline --green "rubocop"
          fi
        fi
      else
        if [ "$last" == "true" ]; then
          ansi --red "rubocop";
        else
          ansi --no-newline --red "rubocop";
        fi
      fi
      ;;


    docker)
      if [ "$(flags.is_set docker)" == "y" ]; then
        if [ "$last" == "true" ]; then
          ansi --green "docker"
        else
          ansi --no-newline --green "docker"
        fi
      else  
        if [ "$last" == "true" ]; then
          ansi --red "docker";
        else
          ansi --no-newline --red "docker";
        fi
      fi
      ;;

    headless)
      if [ "$(flags.is_set headless)" == "y" ]; then
        if [ "$last" == "true" ]; then
          ansi --green "headless"
        else
          ansi --no-newline --green "headless"
        fi
      else
        if [ "$last" == "true" ]; then
          ansi --red "headless";
        else
          ansi --no-newline --red "headless";
        fi
      fi
      ;;
  esac
}
flags.print_all(){
  local flags=(docker headless)
  if [ "$(flags.is_set coverage)" == "n" ]; then
    flags+=(coverage)
  fi
  if [ "$(flags.is_set rubycritic)" == "n" ]; then
    flags+=(rubycritic)
  fi
  if [ "$(flags.is_set rubocop)" == "n" ]; then
    flags+=(rubocop)
  fi
  local flags_set
  ansi --no-newline "  "
  for f in ${flags[@]}
  do
    if [ "$f" == "${flags[${#flags[@]}-1]}" ]; then
      flags.print $f true
    else
      flags.print $f
      ansi --no-newline ", "
    fi
  done
}
flags.print_down(){
  local flag=$1
  local last=$2
  case $flag in
    coverage)
      if [ "$(flags.is_set coverage)" == "n" ]; then
        if [ "$last" == "true" ]; then
          ansi --red "coverage";
        else
          ansi --no-newline --red "coverage";
        fi
      fi
      ;;

    rubycritic)
      if [ "$(flags.is_set rubycritic)" == "n" ]; then
        if [ "$last" == "true" ]; then
          ansi --red "rubycritic";
        else
          ansi --no-newline --red "rubycritic";
        fi
      fi
      ;;

    rubocop)
      if [ "$(flags.is_set rubocop)" == "n" ]; then
        if [ "$last" == "true" ]; then
          ansi --red "rubocop";
        else
          ansi --no-newline --red "rubocop";
        fi
      fi
      ;;

    docker)
      if [ "$(flags.is_set docker)" == "n" ]; then
        if [ "$last" == "true" ]; then
          ansi --red "docker";
        else
          ansi --no-newline --red "docker";
        fi
      fi
      ;;

    headless)
      if [ "$(flags.is_set headless)" == "n" ]; then
        if [ "$last" == "true" ]; then
          ansi --red "headless";
        else
          ansi --no-newline --red "headless";
        fi
      fi
    ;;
  esac
}
flags.print_downs(){
  local flags=(coverage rubycritic rubocop docker headless)
  local flags_not_set
  for f in ${flags[@]}
  do
    if [ "$(flags.is_set $f)" == "n" ]; then
      flags_not_set+=($f)
    fi
  done
  if [ "$(flags.any_not_set)" == "y" ]; then
    ansi --no-newline "  "
    for f in ${flags_not_set[@]}
    do
      if [ "$f" == "${flags_not_set[${#flags_not_set[@]}-1]}" ]; then
        flags.print_down $f true
      else
        flags.print_down $f
        ansi --no-newline ", "
      fi
    done
  fi
}
flags.print_up(){
  local flag=$1
  local major=$2
  local flag_name
  case $flag in
    coverage)
      if [ "$(flags.is_set coverage)" == "y" ]; then
        if test -f coverage/index.html; then
          flag_name=$(printf "%-${major}s" "coverage")
          ansi --no-newline "  ${flag_name} ";
          ansi --underline --green "coverage/index.html"
        else
          flag_name=$(printf "%-${major}s" "coverage")
          ansi --no-newline "  ${flag_name} ";
          ansi --green "coverage"
        fi
      fi
      ;;

    rubycritic)
      if [ "$(flags.is_set rubycritic)" == "y" ]; then
        if test -f tmp/rubycritic/overview.html; then
          flag_name=$(printf "%-${major}s" "rubycritic")
          ansi --no-newline "  ${flag_name} ";
          ansi --underline --green "tmp/rubycritic/overview.html"
        else
          flag_name=$(printf "%-${major}s" "rubycritic")
          ansi --no-newline "  ${flag_name} ";
          ansi --green "rubycritic"
        fi
      fi
      ;;
    rubocop)
      if [ "$(flags.is_set rubocop)" == "y" ]; then
        if test -f tmp/rubocop/overview.html; then
          flag_name=$(printf "%-${major}s" "rubocop")
          ansi --no-newline "  ${flag_name} ";
          ansi --underline --green "tmp/rubocop/overview.html"
        else
          flag_name=$(printf "%-${major}s" "rubocop")
          ansi --no-newline "  ${flag_name} ";
          ansi --green "rubocop"
        fi
      fi
      ;;
  esac
}
flags.print_ups(){
  local flag_name_lens=()
  local major
  local flags=(rubycritic rubocop coverage)
  local flags_set
  for f in ${flags[@]}
  do
    if [ "$(flags.is_set $f)" == "y" ]; then
      flag_name_lens+=(${#f})
    fi
  done
  IFS=$'\n'
  major=$(echo "${flag_name_lens[*]}" | sort -nr | head -n1)
  unset IFS
  for f in ${flags[@]}
  do
    if [ "$(flags.is_set $f)" == "y" ]; then
      flags.print_up $f $major
    fi
  done
}
flags.set(){
  local flag=$1
  case $flag in
    coverage)
      unset COVERAGE
      export COVERAGE=true
      ;;

    rubycritic)
      unset RUBYCRITIC
      export RUBYCRITIC=true
      ;;

    rubocop)
      unset RUBOCOP
      export RUBOCOP=true
      ;;

    headless)
      unset HEADLESS
      export HEADLESS=true
      ;;

    docker)
      docker info > /dev/null 2>&1
      status=$?
      if $(exit $status); then
        docker-compose up -d db redis selenium $SITE > /dev/null 2>&1
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
}
flags.status(){
  ansi "flags:"
  flags.print_ups
  flags.print_all
}
flags.unset(){
  local flag=$1
  case $flag in
    coverage)
      unset COVERAGE
      ;;

    rubycritic)
      unset RUBYCRITIC
      ;;

    rubocop)
      unset RUBOCOP
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
}


__mailcatcher(){
  local port=1080
  pid=$(__pid $port)
  case $1 in
    pid)
      echo $pid
      ;;

    port)
      echo $port
      ;;

    is_running)
      if [ -z $pid ];then
        echo "n"
      else
        echo "y"
      fi
      ;;

    start)
      if [ -z $pid ];then
        test -f tmp/pids/server.pid && rm -f tmp/pids/server.pid
        ! test -d tmp/devtools && mkdir -p tmp/devtools
        if ! test -f tmp/devtools/${SITE}.procfile; then
          cat Procfile.services > tmp/devtools/${SITE}.procfile.temp
          cat Procfile | grep $SITE | sed "s/$SITE/rails/" >> tmp/devtools/${SITE}.procfile.temp
          sed 's@\$PORT@'"$PORT"'@' tmp/devtools/${SITE}.procfile.temp > tmp/devtools/${SITE}.procfile
          rm -rf tmp/devtools/${SITE}.procfile.temp
        fi  
        foreman start mailcatcher -f tmp/devtools/${SITE}.procfile
      else
        ansi --no-newline --green-intense "==> "; ansi --red "Mailcatcher is started already"
        ansi ""
      fi
      ;; 

    stop)  
      if [ -z $pid ];then
        ansi --no-newline --green-intense "==> "; ansi --red "Mailcatcher is stopped already"
        ansi ""
      else
        kill -9 $pid 2>&1 > /dev/null
      fi
      ;;

    restart)
      __mailcatcher stop
      __mailcatcher start
      ;;

    status)
      if [ -z $pid ]; then
        ansi --no-newline --green-intense "==> "; ansi --red "Mailcatcher is not running"
        ansi ""
      else
        ansi --no-newline --green-intense "==> "; ansi --white-intense "Mailcatcher is started"
        ansi ""
      fi 
      ;;

    print_up)
      local major=$2
      local service_name
      if [ ! -z $pid ]; then
        service_name=$(printf "%-${major}s" "mailcatcher")
        ansi --no-newline "  ${service_name} ";
        ansi --no-newline --underline  --green "http://localhost:$port";ansi " $pid"
      fi  
      ;;

    print_down) 
      local last=$2
      local service=mailcatcher
      local services_disabled
      ! test -d tmp/devtools && mkdir -p tmp/devtools
      services_disabled=$(cat tmp/devtools/${SITE}.procfile | grep -v '##' | sed 's/:.*/ /g' | grep -i '#' | tr '\n' ' ' | sed 's/#//g')
      if [ -z $pid ]; then
        if [ "$last" == "true" ]; then
          if [ $(__contains "$services_disabled" "$service") == "y" ]; then
            ansi --strike --red "$service";
          else  
            ansi --red "$service";
          fi
        else  
          if [ $(__contains "$services_disabled" "$service") == "y" ]; then
            ansi --no-newline --strike --red "$service";
          else  
            ansi --no-newline --red "$service";
          fi 
        fi  
      fi
      ;;
  esac
}
__mysql(){
  local action=$1
  if [ -z $DOCKER ]; then
    local port="3306"
    local pid=$(__pid $port)
  else
    local port="33060"
    local pid=$(__pid $port)
  fi  
  case $action in
    pid)
      echo $pid
      ;;

    is_running)
      if [ -z $pid ];then
        echo "n"
      else
        echo "y"
      fi
      ;;

    start)
      if [ -z $DOCKER ]; then
        if [ -z $pid ]; then
          if [ $OS == 'Darwin' ]; then
            brew services start mysql@5.7
          else
            sudo service start mysql
          fi
        else
          ansi --no-newline --green-intense "==> "; ansi --red "Mysql is started already"
          ansi ""
        fi   
      else  
        docker-compose up -d db
      fi
      ;; 

    stop)  
      if [ -z $DOCKER ]; then
        if [ ! -z $pid ]; then
          if [ $OS == 'Darwin' ]; then
            brew services stop mysql@5.7
          else
            sudo service stop db
          fi
        else
          ansi --no-newline --green-intense "==> "; ansi --red "Mysql is stopped already"
          ansi ""
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

    status)
      if [ -z $DOCKER ]; then
       if [ $OS == 'Darwin' ]; then
         brew services 
       else
         service mysql status
       fi
      else  
        docker-compose ps db
      fi
      ;;

    print_up)
      local major=$2
      local service_name
      if [ ! -z $pid ]; then
        service_name=$(printf "%-${major}s" "mysql")
        ansi --no-newline "  ${service_name} ";
        ansi --no-newline --underline --green "localhost:$port";ansi " $pid"
      fi  
      ;;

    print_down) 
      local last=$2
      local service=mysql
      local services_disabled
      ! test -d tmp/devtools && mkdir -p tmp/devtools
      services_disabled=$(cat tmp/devtools/${SITE}.procfile | grep -v '##' | sed 's/:.*/ /g' | grep -i '#' | tr '\n' ' ' | sed 's/#//g')
      if [ -z $pid ]; then
        if [ "$last" == "true" ]; then
          if [ $(__contains "$services_disabled" "$service") == "y" ]; then
            ansi --strike --red "$service";
          else  
            ansi --red "$service";
          fi
        else  
          if [ $(__contains "$services_disabled" "$service") == "y" ]; then
            ansi --no-newline --strike --red "$service";
          else  
            ansi --no-newline --red "$service";
          fi 
        fi  
      fi
      ;;
  esac
}
__sidekiq(){
  local pid=""
  local port=""
  test -f "tmp/pids/sidekiq.pid" && pid=$(cat tmp/pids/sidekiq.pid)
  case $1 in
    pid)
      echo $pid
      ;;

    is_running)
      if [ -z $pid ];then
        echo "n"
      else
        echo "y"
      fi
      ;;

    start)
      if [ -z $pid ]; then
        ! test -d tmp/devtools && mkdir -p tmp/devtools
        if ! test -f tmp/devtools/${SITE}.procfile; then
          cat Procfile.services > tmp/devtools/${SITE}.procfile.temp
          cat Procfile | grep $SITE | sed "s/$SITE/rails/" >> tmp/devtools/${SITE}.procfile.temp
          sed 's@\$PORT@'"$PORT"'@' tmp/devtools/${SITE}.procfile.temp > tmp/devtools/${SITE}.procfile
          rm -rf tmp/devtools/${SITE}.procfile.temp
        fi  
        foreman start sidekiq -f tmp/devtools/${SITE}.procfile
      else
        ansi --no-newline --green-intense "==> "; ansi --red "Sidekiq is started already"
        ansi ""
      fi   
      ;; 

    stop)  
      if [ ! -z $pid ]; then
        sidekiqctl stop "tmp/pids/sidekiq.pid" > /dev/null 2>&1
        if [ $? -eq 1 ];then
          test -f tmp/pids/sidekiq.pid && rm -rf tmp/pids/sidekiq.pid
        fi
      else  
        test -f tmp/pids/sidekiq.pid && rm -rf tmp/pids/sidekiq.pid
        ansi --no-newline --green-intense "==> "; ansi --red "Sidekiq is stopped already"
        ansi ""
      fi
      ;;

    restart)
      __sidekiq stop
      __sidekiq start
      ;;

    status)
      if [ -z $pid ]; then
        ansi --no-newline --green-intense "==> "; ansi --red "Sidekiq is not running"
        ansi ""
      else
        ansi --no-newline --green-intense "==> "; ansi --white-intense "Sidekiq is started"
        ansi ""
      fi 
      ;;

    print_up)
      local major=$2
      local service_name
      if [ ! -z $pid ]; then
        service_name=$(printf "%-${major}s" "sidekiq")
        ansi --no-newline "  ${service_name} ";
        port=$(__rails port)
        ansi --no-newline --underline --green "http://localhost:$port/sidekiq";ansi " $pid"
      fi  
      ;;

    print_down) 
      local last=$2
      local service=sidekiq
      local services_disabled
      ! test -d tmp/devtools && mkdir -p tmp/devtools
      services_disabled=$(cat tmp/devtools/${SITE}.procfile | grep -v '##' | sed 's/:.*/ /g' | grep -i '#' | tr '\n' ' ' | sed 's/#//g')
      if [ -z $pid ]; then
        if [ "$last" == "true" ]; then
          if [ $(__contains "$services_disabled" "$service") == "y" ]; then
            ansi --strike --red "$service";
          else  
            ansi --red "$service";
          fi
        else  
          if [ $(__contains "$services_disabled" "$service") == "y" ]; then
            ansi --no-newline --strike --red "$service";
          else  
            ansi --no-newline --red "$service";
          fi 
        fi  
      fi
      ;;
  esac
}
__ngrok(){
  local action=$1
  if [ -z $DOCKER ]; then
    local port="4040"
  else
    local port="40400"
  fi  
  local pid=$(__pid $port)
  case $action in
    pid)
      echo $pid
      ;;

    is_running)
      if [ -z $pid ];then
        echo "n"
      else
        echo "y"
      fi
      ;;

    start)
      local rails_port=$(__rails port)
      if [ -z $DOCKER ]; then
        if [ -z $pid ]; then 
          if [ "$(__rails is_running)" == "y" ]; then
            test -f tmp/pids/server.pid && rm -f tmp/pids/server.pid
            ! test -d tmp/devtools && mkdir -p tmp/devtools
            if ! test -f tmp/devtools/${SITE}.procfile; then
              cat Procfile.services > tmp/devtools/${SITE}.procfile.temp
              cat Procfile | grep $SITE | sed "s/$SITE/rails/" >> tmp/devtools/${SITE}.procfile.temp
              sed 's@\$PORT@'"$PORT"'@' tmp/devtools/${SITE}.procfile.temp > tmp/devtools/${SITE}.procfile
              rm -rf tmp/devtools/${SITE}.procfile.temp
            fi  
            foreman start ngrok -f tmp/devtools/${SITE}.procfile
          else  
            ansi --no-newline --green-intense "==> "; ansi --red "NGrok requires ${SITE} running"
            ansi ""
          fi  
        else
          ansi --no-newline --green-intense "==> "; ansi --red "NGrok is started already"
          ansi ""
        fi 
      fi
      ;; 

    stop)  
      if [ -z $pid ];then
        ansi --no-newline --green-intense "==> "; ansi --red "NGrok is stopped already"
        ansi ""
      else
        kill -9 $pid 2>&1 > /dev/null
      fi
      ;;

    restart)
      __ngrok stop
      __ngrok start
      ;;

    status)
      if [ -z $pid ]; then
        ansi --no-newline --green-intense "==> "; ansi --red "NGrok is not running"
        ansi ""
      else
        ansi --no-newline --green-intense "==> "; ansi --white-intense "NGrok is started"
        ansi ""
      fi 
      ;;

    print_up)
      local major=$2
      local service_name
      if [ ! -z $pid ]; then
        service_name=$(printf "%-${major}s" "ngrok")
        ansi --no-newline "  ${service_name} ";
        ansi --no-newline --underline --green "http://localhost:$port";ansi " $pid"
      fi  
      ;;

    print_down) 
      local last=$2
      local service=ngrok
      local services_disabled
      ! test -d tmp/devtools && mkdir -p tmp/devtools
      services_disabled=$(cat tmp/devtools/${SITE}.procfile | grep -v '##' | sed 's/:.*/ /g' | grep -i '#' | tr '\n' ' ' | sed 's/#//g')
      if [ -z $pid ]; then
        if [ "$last" == "true" ]; then
          if [ $(__contains "$services_disabled" "$service") == "y" ]; then
            ansi --strike --red "$service";
          else  
            ansi --red "$service";
          fi
        else  
          if [ $(__contains "$services_disabled" "$service") == "y" ]; then
            ansi --no-newline --strike --red "$service";
          else  
            ansi --no-newline --red "$service";
          fi 
        fi  
      fi
      ;;
  esac
}
__redis(){
  local action=$1
  if [ -z $DOCKER ]; then
      local port="6379"
      local pid=$(__pid $port)
  else
    local port="63790"
    local pid=$(__pid $port)
  fi  
  case $action in
    pid)
      echo $pid
      ;;

    is_running)
      if [ -z $pid ];then
        echo "n"
      else
        echo "y"
      fi
      ;;

    start)
      if [ -z $DOCKER ]; then
        if [ -z $pid ]; then
          if [ $OS == 'Darwin' ]; then
            brew services start redis
          else
            sudo service start redis
          fi
        else
          ansi --no-newline --green-intense "==> "; ansi --red "Redis is started already"
          ansi ""
        fi   
      else  
        docker-compose up -d redis
      fi
      ;; 

    stop)  
      if [ -z $DOCKER ]; then
        if [ ! -z $pid ]; then
          if [ $OS == 'Darwin' ]; then
            brew services stop redis
          else
            sudo service stop redis
          fi
        else
          ansi --no-newline --green-intense "==> "; ansi --red "Redis is stopped already"
          ansi ""
        fi   
      else  
        docker-compose stop redis
      fi
      ;;

    restart)
      __redis stop
      __redis start
      ;;

    status)
      if [ -z $DOCKER ]; then
       if [ $OS == 'Darwin' ]; then
         brew services 
       else
         service redis status
       fi
      else  
        docker-compose ps redis
      fi
      ;;

    print_up)
      local major=$2
      local service_name
      if [ ! -z $pid ]; then
        service_name=$(printf "%-${major}s" "redis")
        ansi --no-newline "  ${service_name} ";
        ansi --no-newline --underline --green "localhost:$port";ansi " $pid"
      fi  
      ;;

    print_down) 
      local last=$2
      local service=redis
      local services_disabled
      ! test -f tmp/devtools && mkdir -p tmp/devtools
      services_disabled=$(cat tmp/devtools/${SITE}.procfile | grep -v '##' | sed 's/:.*/ /g' | grep -i '#' | tr '\n' ' ' | sed 's/#//g')
      if [ -z $pid ]; then
        if [ "$last" == "true" ]; then
          if [ $(__contains "$services_disabled" "$service") == "y" ]; then
            ansi --strike --red "$service";
          else  
            ansi --red "$service";
          fi
        else  
          if [ $(__contains "$services_disabled" "$service") == "y" ]; then
            ansi --no-newline --strike --red "$service";
          else  
            ansi --no-newline --red "$service";
          fi 
        fi  
      fi
      ;;
  esac
}
__rails(){
  local action=$1
  local port=$(cat Procfile | grep -i $SITE | awk '{print $7}')
  local pid=$(__pid $port)
  case $action in
    pid)
      echo $pid
      ;;

    port)   
      echo $port
      ;;

    is_running)
      if [ -z $pid ]; then
        echo "n"
      else
        echo "y"
      fi
      ;;

    start)
      db migrate:status
      if [ -z $pid ]; then
        if [ -z "$DOCKER" ]; then
          if [ -z "$2" ]; then
            test -f tmp/pids/server.pid && rm -f tmp/pids/server.pid
            ! test -d tmp/devtools && mkdir -p tmp/devtools
            if ! test -f tmp/devtools/${SITE}.procfile; then
              cat Procfile.services > tmp/devtools/${SITE}.procfile.temp
              cat Procfile | grep $SITE | sed "s/$SITE/rails/" >> tmp/devtools/${SITE}.procfile.temp
              sed 's@\$PORT@'"$PORT"'@' tmp/devtools/${SITE}.procfile.temp > tmp/devtools/${SITE}.procfile
              rm -rf tmp/devtools/${SITE}.procfile.temp
            fi  
            db migrate:status
            foreman start rails -f tmp/devtools/${SITE}.procfile
          else  
            BELONGS=$(__sites case)
            case $2 in
              $BELONGS)
                test -f tmp/pids/server.pid && rm -f tmp/pids/server.pid
                if [ -z "$3" ]; then
                  foreman start $2
                else  
                  foreman start $2 &
                fi
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
      else
        ansi --no-newline --green-intense "==> "; ansi --red "$SITE is started already"
        ansi ""
      fi
      ;;  

    stop)  
      if [ ! -z $pid ]; then
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
      else
        ansi --no-newline --green-intense "==> "; ansi --red "$SITE is stopped already"
        ansi ""
      fi
      ;;

    restart)
      __rails stop
      __rails start
      ;;

    status)
      if [ -z $pid ]; then
        ansi --no-newline --green-intense "==> "; ansi --red "${SITE} is not running"
        ansi ""
      else
        ansi --no-newline --green-intense "==> "; ansi --white-intense "${SITE} is started"
        ansi ""
      fi 
      ;;

    print)
      ;; 

    print_up)
      local major=$2
      local service_name
      if [ ! -z $pid ]; then
        service_name=$(printf "%-${major}s" "rails")
        ansi --no-newline "  ${service_name} ";
        ansi --no-newline --underline --green-intense "http://localhost:$port";ansi " $pid"
      fi  
      ;;

    print_down) 
      local last=$2
      local service=rails
      local services_disabled
      ! test -d tmp/devtools && mkdir -p tmp/devtools
      services_disabled=$(cat tmp/devtools/${SITE}.procfile | grep -v '##' | sed 's/:.*/ /g' | grep -i '#' | tr '\n' ' ' | sed 's/#//g')
      if [ -z $pid ]; then
        if [ "$last" == "true" ]; then
          if [ $(__contains "$services_disabled" "$service") == "y" ]; then
            ansi --strike --red "$service";
          else  
            ansi --red "$service";
          fi
        else  
          if [ $(__contains "$services_disabled" "$service") == "y" ]; then
            ansi --no-newline --strike --red "$service";
          else  
            ansi --no-newline --red "$service";
          fi 
        fi  
      fi
      ;;
  esac
}
__services(){
  local action=$1
  local services=(mysql redis mailcatcher sidekiq ngrok rails)
  case $action in
    help|h|--help|-h)
      ansi --white-intense "Crafted (c) 2013~2020 by InMov - Intelligence in Movement"
      ansi --white --no-newline "Obras Utils ";ansi --white-intense $OBRAS_UTILS_VERSION
      ansi --white "::"
      __pr info "services " "[ls/check]"
      __pr info "services " "[start/stop/restart/status mysql/ngrok/redis/sidekiq/mailcatcher || all]"
      __pr info "services " "[enable/disable ngrok/sidekiq/mailcatcher]"
      __pr info "services " "[conn/connect mysql/db/redis]"
      __pr 
      __pr info "obs: " "redis and mysql are not involved when all is specified"
      __pr 
      ;;
    ls|check)
      ! test -d tmp/devtools && mkdir -p tmp/devtools
      if test -f tmp/devtools/${SITE}.procfile; then
        foreman check -f tmp/devtools/${SITE}.procfile
      else
        cat Procfile.services > tmp/devtools/${SITE}.procfile.temp
        cat Procfile | grep $SITE | sed "s/$SITE/rails/" >> tmp/devtools/${SITE}.procfile.temp
        sed 's@\$PORT@'"$PORT"'@' tmp/devtools/${SITE}.procfile.temp > tmp/devtools/${SITE}.procfile
        rm -rf tmp/devtools/${SITE}.procfile.temp
        foreman check -f tmp/devtools/${SITE}.procfile
      fi
      ;;
    start)
      case $2 in
        rails|mysql|ngrok|redis|sidekiq|mailcatcher)
          __$2 start
          ;;
        all)
          ! test -d tmp/devtools && mkdir -p tmp/devtools
          if ! test -f tmp/devtools/${SITE}.procfile; then
            cat Procfile.services > tmp/devtools/${SITE}.procfile.temp
            cat Procfile | grep $SITE | sed "s/$SITE/rails/" >> tmp/devtools/${SITE}.procfile.temp
            sed 's@\$PORT@'"$PORT"'@' tmp/devtools/${SITE}.procfile.temp > tmp/devtools/${SITE}.procfile
            rm -rf tmp/devtools/${SITE}.procfile.temp
          fi  
          db migrate:status
          foreman start all -f tmp/devtools/${SITE}.procfile
          ;;
      esac;
      if [ -z "$2" ]; then
        ! test -d tmp/devtools && mkdir -p tmp/devtools
        if ! test -f tmp/devtools/${SITE}.procfile; then
          cat Procfile.services > tmp/devtools/${SITE}.procfile.temp
          cat Procfile | grep $SITE | sed "s/$SITE/rails/" >> tmp/devtools/${SITE}.procfile.temp
          sed 's@\$PORT@'"$PORT"'@' tmp/devtools/${SITE}.procfile.temp > tmp/devtools/${SITE}.procfile
          rm -rf tmp/devtools/${SITE}.procfile.temp
        fi  
        db migrate:status
        foreman start all -f tmp/devtools/${SITE}.procfile
      fi 
      ;;   

    stop)
      local site_services
      ! test -d tmp/devtools && mkdir -p tmp/devtools
      case $2 in
        rails|mysql|ngrok|redis|sidekiq|mailcatcher)
          __$2 stop
         ;;
        
        all)
          if test -f tmp/devtools/${SITE}.procfile; then
            site_services=$(foreman check -f tmp/devtools/${SITE}.procfile | awk -F[\(\)] '{print $2}' | sed 's/,//g')
            for s in ${site_services[@]}
            do
              if [ "$(__$s is_running)" == "y" ]; then
                __$s stop
              fi
            done
          else  
            ansi --no-newline --green-intense "==> "; ansi --red "Procfile.${SITE} does not exist"
            ansi ""
          fi
          ;;
      esac; 
      if [ -z "$2" ]; then
        if test -f tmp/devtools/${SITE}.procfile; then
          site_services=$(foreman check -f tmp/devtools/${SITE}.procfile | awk -F[\(\)] '{print $2}' | sed 's/,//g')
          for s in ${site_services[@]}
          do
            if [ "$(__$s is_running)" == "y" ]; then
              __$s stop
            fi
          done
        else  
          ansi --no-newline --green-intense "==> "; ansi --red "Procfile.${SITE} does not exist"
          ansi ""
        fi
      fi 
      ;;   

    restart)
      case $2 in
        rails|mysql|ngrok|redis|sidekiq|mailcatcher)
          __$s restart
         ;;
        
        all)
          ! test -d tmp/devtools && mkdir -p tmp/devtools
          if test -f tmp/devtools/${SITE}.procfile; then
            services=$(foreman check | awk -F[\(\)] '{print $2}' | sed 's/,//g')
            for s in ${services[@]}
            do
              if [ "$(__$s is_running)" == "y" ]; then
                __$s stop
              fi
            done
            foreman start all -f tmp/devtools/${SITE}.procfile
          else  
            ansi --no-newline --green-intense "==> "; ansi --red "Procfile.{$SITE} does not exist"
            ansi ""
          fi
          ;;
        *)
          __services print
          ;;  
      esac; 
      ;;   

    status)
      __services print
      ;;
    enable)
      shift
      local site_services=()
      local params=("$@")
      ! test -d tmp/devtools && mkdir -p tmp/devtools
      site_services=$(cat tmp/devtools/${SITE}.procfile | grep -v '##' | sed 's/:.*/ /g' | tr -d "\n" | tr '\n' ' ' | sed 's/#//g')
      for p in ${params[@]}
      do
        if [ $(__contains "$site_services" "$p") == "y" ]; then
          sed -e "/#$p/ s/^#$p*/$p/" tmp/devtools/${SITE}.procfile > temp && rm -f "tmp/devtools/${SITE}.procfile" && mv temp "tmp/devtools/${SITE}.procfile"
        else 
          ansi --no-newline --green-intense "==> "; ansi --red "Procfile.${SITE} does not contain this '${p}' service"
          ansi ""
        fi
      done
      foreman check -f tmp/devtools/${SITE}.procfile
      ;;  
    disable)
      shift
      local site_services=()
      local params=("$@")
      ! test -d tmp/devtools && mkdir -p tmp/devtools
      site_services=$(foreman check -f tmp/devtools/${SITE}.procfile | awk -F[\(\)] '{print $2}' | sed 's/,//g' | sed 's/#//g')
      for p in ${params[@]}
      do
        if [ $(__contains "$site_services" "$p") == "y" ]; then
          sed -e "/$p/ s/^#*/#/" tmp/devtools/${SITE}.procfile > temp && rm -f "tmp/devtools/${SITE}.procfile" && mv temp "tmp/devtools/${SITE}.procfile"
        else 
          ansi --no-newline --green-intense "==> "; ansi --red "Procfile.${SITE} does not contain this '${p}' service"
          ansi ""
        fi
      done
      foreman check -f tmp/devtools/${SITE}.procfile
      ;;
    any_running)
      local result="n"
      for s in ${services[@]}
      do
        # result=$(__$s is_running)
        if [ "$(__$s is_running)" == "y" ]; then
          result="y"
          break
        fi
      done
      echo $result
      ;;

    any_not_running)
      local result="n"
      for s in ${services[@]}
      do
        if [ "$(__$s is_running)" == "n" ]; then
          result="y"
          break
        fi
      done
      echo $result
      ;;

    print_ups)
      local service_name_lens=()
      local major
      for s in ${services[@]}
      do
        if [ "$(__$s is_running)" == "y" ]; then
          service_name_lens+=(${#s})
        fi
      done
      IFS=$'\n'
      major=$(echo "${service_name_lens[*]}" | sort -nr | head -n1)
      unset IFS
      for s in ${services[@]}
      do
        if [ "$(__$s is_running)" == "y" ]; then
          __$s print_up $major
        fi
      done
      ;;

    print_downs)
      local services_not_running
      local site_services
      local sites_disabled
      ! test -d tmp/devtools && mkdir -p tmp/devtools
      if ! test -f tmp/devtools/${SITE}.procfile; then
        cat Procfile.services > tmp/devtools/${SITE}.procfile.temp
        cat Procfile | grep $SITE | sed "s/$SITE/rails/" >> tmp/devtools/${SITE}.procfile.temp
        sed 's@\$PORT@'"$PORT"'@' tmp/devtools/${SITE}.procfile.temp > tmp/devtools/${SITE}.procfile
        rm -rf tmp/devtools/${SITE}.procfile.temp
      fi  
      site_services=($(cat tmp/devtools/${SITE}.procfile | grep -v '##' | sed 's/:.*/ /g' | tr -d "\n" | tr '\n' ' ' | sed 's/#//g'))
      sites_disabled=$(cat tmp/devtools/${SITE}.procfile | grep -v '##' | sed 's/:.*/ /g' | grep -i '#' | tr '\n' ' ' | sed 's/#//g')
      site_services+=(mysql)
      site_services+=(redis)
      for s in ${site_services[@]}
      do
        if [ "$(__$s is_running)" == "n" ]; then
          services_not_running+=($s)
        fi
      done
      if [ "$(__services any_not_running)" == "y" ]; then
        ansi --no-newline "  "
        for s in ${services_not_running[@]}
        do
          if [ "$s" == "${services_not_running[${#services_not_running[@]}-1]}" ]; then
            __$s print_down true
          else  
            __$s print_down
            ansi --no-newline ", "
          fi
        done
      fi  
      ;;

    print)
      ansi "services:"
      __services print_ups
      __services print_downs
      ;;  
    *)
      services.status
      ;;   
  esac
}
services.status(){
  __services print
}


db(){
  __is_obras
  if [ $? -eq 0 ]; then
  case $1 in
    help|h|--help|-h)
      ansi --white-intense "Crafted (c) 2013~2020 by InMov - Intelligence in Movement"
      ansi --white --no-newline "Obras Utils ";ansi --white-intense $OBRAS_UTILS_VERSION
      ansi --white "::"
      __pr info "db " "[set dbname || init || preptest || drop [all] || create || migrate migrate:status || seed]"
      __pr info "db " "[databases || tables || socket || connect]"
      __pr info "db " "[api [dump/export || import]]"
      __pr info "db " "[backups || download [backupfile] || update [all]]"
      __pr info "db " "[dumps/ls || import [dumpfile] || update [all]]"
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
            __pr dang " no api dump files"
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
            __pr dang " no api dump files"
          fi
          unset IFS
          __pr
          ;;
        *)
          IFS=$'\n'
          files_sql=(`ls api*.sql 2>/dev/null`)
          echo -e "backups:"
          if [ ! -z "$files_sql" ]; then
            IFS=$'\n'
            files_sql=( $(printf "%s\n" ${files_sql[@]} | sort -r ) )
            for file in ${files_sql[*]}
            do
              __pr succ '  '$file
            done
          else
            __pr dang "  no api backup files"
          fi
          unset IFS
          __pr
          ;;
      esac
      ;;

    init)
      if [ -z "$DOCKER" ]; then
        rails=`rails --version`
        if [ "$rails" == "$RAILS_VERSION" ]; then
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
        dumps.deactivate
        __update_db_stats
      else 
        rails=`rails --version`
        if [ "$rails" == "$RAILS_VERSION" ]; then
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
        dumps.deactivate
        __update_db_stats
      fi
      ;;

    preptest)
      case $SITE in
        demo)
          ansi --no-newline --green-intense "==> "; ansi --white-intense "This site $SITE will be prepared for test"
          ansi ""
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Set env to development"
          site env development
          db init
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Set env to test"
          site env test
          db init
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Set env to development"
          site env development
          ;;

        *)
          ansi --no-newline --green-intense "==> "; ansi --white-intense "This site $SITE will be prepared for test"
          ansi ""
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Set env to development"
          site env development
          db update
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Set env to test"
          site env test
          db import
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Set env to development"
          site env development
          ;;
      esac
      ;;

    drop)
      case $# in
        1)
          if [ -z "$DOCKER" ]; then
            db=$(dbs.current)
            if [ "$(__has_database $db)" == 'yes' ]; then
              rails=`rails --version`
              if [ "$rails" == "$RAILS_VERSION" ]; then
                ansi --no-newline --green-intense "==> "; ansi --white-intense "Dropping db "
                revolver --style 'simpleDotsScrolling' start
                rails db:drop
                dumps.deactivate
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
            db=$(dbs.current)
            if [ "$(__has_database $db)" == 'yes' ]; then
              rails=`rails --version`
              if [ "$rails" == "$RAILS_VERSION" ]; then
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
        2)
          case $2 in
          all)
            sites=(`__sites`)
            for site in "${sites[@]}"
            do
              site $site
              db drop
            done
            site $SITE
            ;;
          *)
            ansi --no-newline --red-intense "==> "; ansi --white-intense "Error bad parameter "$2
            __pr
            return 1
            ;;
          esac    
          ;;
        *)
          ansi --no-newline --red-intense "==> "; ansi --white-intense "Error bad number of parameters"
          __pr
          return 1
          ;;
      esac  
      ;;  

    create)  
      if [ -z "$DOCKER" ]; then
        db=$(dbs.current)
        if [ "$(__has_database $db)" == 'no' ]; then
          rails=`rails --version`
          if [ "$rails" == "$RAILS_VERSION" ]; then
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
        db=$(dbs.current)
        if [ "$(__has_database $db)" == 'no' ]; then
          rails=`rails --version`
          if [ "$rails" == "$RAILS_VERSION" ]; then
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
        db=$(dbs.current)
        if [ "$(__has_database $db)" == 'yes' ]; then
          rails=`rails --version`
          if [ "$rails" == "$RAILS_VERSION" ]; then
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
        db=$(dbs.current)
        if [ "$(__has_database $db)" == 'yes' ]; then
          rails=`rails --version`
          if [ "$rails" == "$RAILS_VERSION" ]; then
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

    migrate:status)
      if [ -z "$DOCKER" ]; then
        db=$(dbs.current)
        if [ "$(__has_database $db)" == 'yes' ]; then
          rails=`rails --version`
          if [ "$rails" == "$RAILS_VERSION" ]; then
            ansi --no-newline --green-intense "==> "; ansi --white-intense "Status Migrating db "
            rails db:migrate:status | grep "^\s*down" && rails db:migrate || ansi --no-newline --green-intense "==> "; ansi --white-intense  "No pending migrations found"
          else
            ansi --no-newline --green-intense "==> "; ansi --white-intense "Status Migrating db "
            rake db:migrate:status | grep "^\s*down" && rake db:migrate || ansi --no-newline --green-intense "==> "; ansi --white-intense  "No pending migrations found"
          fi
        else  
          ansi --no-newline --red-intense "==> "; ansi --white-intense "Error file "$db" does not exist"
        fi
      else
        db=$(dbs.current)
        if [ "$(__has_database $db)" == 'yes' ]; then
          rails=`rails --version`
          if [ "$rails" == "$RAILS_VERSION" ]; then
            ansi --no-newline --green-intense "==> "; ansi --white-intense "Status Migrating db "
            docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rails db:migrate:status | grep "^\s*down" && rails db:migrate || ansi --no-newline --green-intense "==> "; ansi --white-intense  "No pending migrations found"

          else
            ansi --no-newline --green-intense "==> "; ansi --white-intense "Status Migrating db "
            docker-compose exec -e RAILS_ENV=$RAILS_ENV $SITE rake db:migrate:status | grep "^\s*down" && rake db:migrate || ansi --no-newline --green-intense "==> "; ansi --white-intense  "No pending migrations found"
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
        db=$(dbs.current)
        tables=$(__tables $db)
        if [ '$(__has_database $db)' == 'yes' ] && [ $tables == 'no' ]; then
          rails=`rails --version`
          if [ "$rails" == "$RAILS_VERSION" ]; then
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
        db=$(dbs.current)
        tables=$(__tables $db)
        if [ '$(__has_database $db)' == 'yes' ] && [ $tables == 'no' ]; then
          rails=`rails --version`
          if [ "$rails" == "$RAILS_VERSION" ]; then
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
              ansi --no-newline --red-intense "==> "; ansi --white-intense "Error no dump file"
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
              ansi --no-newline --red-intense "==> "; ansi --white-intense "Error no dump file"
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
                ansi --no-newline --red-intense "==> "; ansi --white-intense "Error no dump file"
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
                ansi --no-newline --red-intense "==> "; ansi --white-intense "Error no dump file"
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

          ansi --no-newline --green-intense "==> "; ansi --no-newline --white-intense "Listing ";ansi --white-intense "$filenumber"
          echo "sudo -i eybackup -e mysql -d $filenumber" | ssh -t deploy@ec2-54-232-181-209.sa-east-1.compute.amazonaws.com 
          ansi --no-newline --green-intense "==> "; ansi --white-intense "Downloading "$filename_orig
          scp deploy@ec2-54-232-181-209.sa-east-1.compute.amazonaws.com:/mnt/tmp/$filename_orig .
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

    ls|dumps)
      dumps.status
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
          ansi --no-newline --red-intense "==> "; ansi --white-intense "${SITE} does not have backups"
          __pr
          return 1
          ;;
      esac     
      ;;

    update)
      case $2 in
        all)
          sites=(`__sites`)
          for site in "${sites[@]}"
          do
            case $site in
              default)
                site default
                db preptest
                ;;
              *)  
                site $site
                db download 
                db import 
                ;;
            esac    
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




    set)
      dbs.set $2
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

    connect|conn)
      db=$(dbs.current)
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
        db=$(dbs.current)
        mysqlshow -uroot $db | more
      else
        db=$(dbs.current)
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
      dbs.status
      ;;
  esac
  fi
}
dbs.current(){
  local env=$1
  if [ -z $env ]; then
    env=$RAILS_ENV
  fi
  if [ "$env" == "development" ]; then
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
dbs.print_db(){
  local env=$1
  local db
  local dbs
  local db_lens=()
  db=$(dbs.current development)
  db_lens+=(${#db})
  db=$(dbs.current test)
  db_lens+=(${#db})
  IFS=$'\n'
  major=$(echo "${db_lens[*]}" | sort -nr | head -n1)
  unset IFS
  if [ -z $env ]; then
    env=$RAILS_ENV
  fi
  if [ "$env" == "development" ]; then
    db=$(dbs.current development)
  else  
    db=$(dbs.current test)
  fi
  db=$(printf "%-${major}s" "${db}")
  if [ "$(__has_database $db)" == 'yes' ]; then
    if [ $env == "development" ]; then
      ansi --no-newline "  "; ansi --no-newline --green $db' '; ansi --white --no-newline $DB_TABLES_DEV' '; ansi --white $DB_RECORDS_DEV
    else
      ansi --no-newline "  "; ansi --no-newline --green $db' '; ansi --white --no-newline $DB_TABLES_TST' '; ansi --white $DB_RECORDS_TST
    fi  
  else  
    ansi --no-newline "  "; ansi --red $db
  fi
}
dbs.set(){
  local site=$1
  case $1 in
    olimpia|rioclaro|suzano|santoandre|demo)
      spring stop
      set -o allexport
      . ./.env/development/$1
      set +o allexport
      ;;

    default) 
      unset MYSQL_DATABASE_DEV
      unset MYSQL_DATABASE_TST
      ;;

    *)
      ansi --no-newline --red-intense "==> "; ansi --white-intense "Error bad site "$1
      __pr
      return 1
      ;;
  esac
}
dbs.status(){
  ansi "dbs:"
  dbs.print_db development
  dbs.print_db test 
}


dumps.activate(){
  local dump_active=$1
  local dumps
  IFS=$'\n'
  dumps=(`ls *$SITE.sql 2>/dev/null`)
  if [ ! -z "$dumps" ]; then
    ! test -d tmp/devtools && mkdir -p tmp/devtools
    for dump in ${dumps[*]}
    do
      if [ "$dump" == "$dump_active" ]; then
        echo $dump > tmp/devtools/${SITE}.dump_active 
      fi
    done
  fi
  unset IFS
}
dumps.deactivate(){
  test -f tmp/devtools/${SITE}.dump_active && rm -rf tmp/devtools/${SITE}.dump_active
}
dumps.print_all(){
  local dump_active
  local dumps
  if test -f tmp/devtools/${SITE}.dump_active; then
    dump_active=$(cat tmp/devtools/${SITE}.dump_active)
  fi  
  IFS=$'\n'
  dumps=(`ls *$SITE.sql 2>/dev/null`)
  dumps=($(printf "%s\n" ${dumps[@]} | sort -r )) 
  if [ ! -z "$dumps" ]; then
    for dump in ${dumps[*]}
    do
      ansi --no-newline "  "
      if [ "$dump" == "$dump_active" ]; then
        ansi --green $dump
      else
        ansi --red $dump  
      fi
    done
  else  
    ansi --red "  no dumps"
  fi
  unset IFS
}
dumps.print_downs(){
  local dump_active
  local dumps
  IFS=$'\n'
  dumps=(`ls *$SITE.sql 2>/dev/null`)
  dumps=($(printf "%s\n" ${dumps[@]} | sort -r )) 
  if test -f tmp/devtools/${SITE}.dump_active; then
    dump_active=$(cat tmp/devtools/${SITE}.dump_active)
    dumps=("${dumps[@]/$dump_active}")
  fi  
  if [ ! -z "$dumps" ]; then 
    ansi --no-newline "  ";
    for dump in ${dumps[*]}
    do
    if [ "$dump" == "${dumps[${#dumps[@]}-1]}" ]; then
      ansi --red $dump
    else
      ansi --red --no-newline $dump
      ansi --no-newline ", "
    fi
    done
  fi  
  unset IFS
}
dumps.print_up(){
  local dump_up
  if test -f tmp/devtools/${SITE}.dump_active; then
    dump_up=$(cat tmp/devtools/${SITE}.dump_active)
    if [ ! -z "$dump_up" ]; then
      ansi --no-newline "  ";
      ansi --green $dump_up
    fi
  fi
}
dumps.status(){
  ansi "dumps:"
  dumps.print_all
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
      __pr info "site " "[mysql/ngrok/redis/mailcatcher/sidekiq start/stop/restart/status]"
      __pr info "site " "[dumps [activate dumpfile]]"
      __pr info "site " "[db/mysql/redis conn/connect]"
      __pr info "site " "[conn/connect]"
      __pr info "site " "[stats]"
      __pr info "site " "[rubycritic/rubocop [files]]"
      __pr info "site " "[db:drop || db:create || db:migrate db:migrate:status || db:seed]"
      __pr 
      ;;

    --version|-v|v)  
      ansi --white-intense "Crafted (c) 2013~2020 by InMov - Intelligence in Movement"
      ansi --white --no-newline "Obras Utils ";ansi --white-intense $OBRAS_UTILS_VERSION
      ansi --white "::"
      ;;

    $SITES_CASE)
      site.init $1 $SITE
      ;;

    $SITES_OLD_CASE)
      export SITEPREV=$SITE
      export SITE=$1
      export PORT=$(cat Procfile | grep -i $SITE | awk '{print $7}')
      export OBRAS_CURRENT=$OBRAS_OLD
      cd "$OBRAS_OLD"
      dbs.set $1
      title $1
      if [ "$SITE" != "$SITEPREV" ]; then
        unset DB_TABLES_DEV
        unset DB_RECORDS_DEV
        unset DB_TABLES_TST
        unset DB_RECORDS_TST
      fi
      unset DOCKER
      unset COVERAGE
      unset RUBYCRITIC
      unset RUBOCOP
      export HEADLESS=true
      __update_db_stats_site
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
      flags.set $2
      ;;

    unset)
      flags.unset $2
      ;;

    start)
      __rails start $2
      ;;  

    stop)
      __rails stop $2
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
    stats)
      ansi --no-newline --green-intense "==> "; ansi --white-intense "Rails Statistics "
      revolver --style 'simpleDotsScrolling' start
      rails stats
      revolver stop
      ;;  
    conn|connect)
      site.connect
      ;;
    ngrok|mysql|redis|sidekiq|mailcatcher)
      case $2 in
        start)
          __$1 start
          ;;

        stop)
          __$1 stop
          ;;

        status)
          __$1 status
          ;; 

        connect|conn)
          case $1 in
            mysql)
              db=$(dbs.current)
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
            redis)
              if [ "$(__has_database $db)" == 'yes' ]; then
                if [ -z "$DOCKER" ]; then
                  iredis -d redis://localhost:6379/4
                else
                  iredis -d redis://localhost:63790/4
                fi 
              else   
                ansi --red-intense --no-newline $db;ansi --red " does not exist"
                ansi ""
              fi
              ;;
          esac 
          ;;      

          *)
            __$1 status
            ;;
      esac    
      ;;

    flags) 
      flags.status
      ;;

    rubycritic)
      shift 
      rubycritic.run $*
      ;;

    rubocop)
      shift 
      rubocop.run $*
      ;;  
    dbs|db)
      shift
      db $*
      ;;  
    db:drop)
      db drop
      ;;  
    db:create)
      db create
      ;;  
    db:migrate:status)
      db migrate:status
      ;;  
    db:migrate)
      db migrate
      ;;  
    db:seed)
      db seed
      ;;  
    services)
      shift
      __services $*
      ;; 

    dumps)
      case $2 in
        activate)
          dumps.activate $3
          ;;
        *)
          dumps.status
          ;; 
      esac      
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
    site|status)
      site.status
      ;;  
    *)
      __docker
      __update_db_stats_site
      ! test -d tmp/devtools && mkdir -p tmp/devtools
      
      site.status
      flags.status
      services.status
      dbs.status
      dumps.status
      ;;
  esac
  fi
}
site.init(){
  cd "$OBRAS"
  export SITE=$1
  export SITEPREV=$2
  export OBRAS_CURRENT=$OBRAS
  export PORT=$(cat Procfile | grep -i $SITE | awk '{print $7}')
  dbs.set $1
  title $1
  if [ "$SITE" != "$SITEPREV" ]; then
    unset DB_TABLES_DEV
    unset DB_RECORDS_DEV
    unset DB_TABLES_TST
    unset DB_RECORDS_TST
  fi
  unset DOCKER
  unset COVERAGE
  unset RUBYCRITIC
  unset RUBOCOP
  export HEADLESS=true
  __update_db_stats_site
}
site.connect(){
  case $SITE in
    olimpia)
      ssh -t deploy@ec2-18-231-91-182.sa-east-1.compute.amazonaws.com "cd /data/obras/current/ey_bundler_binstubs; exec \$SHELL -l"
      ;;
    rioclaro)
      ssh -t deploy@ec2-54-232-181-209.sa-east-1.compute.amazonaws.com "cd /data/obras/current/ey_bundler_binstubs; exec \$SHELL -l"
      ;;
    suzano)
      ssh -t deploy@ec2-52-67-14-193.sa-east-1.compute.amazonaws.com "cd /data/obras/current/ey_bundler_binstubs; exec \$SHELL -l"
      ;;
    santoandre)
      ssh -t deploy@ec2-52-67-134-57.sa-east-1.compute.amazonaws.com "cd /data/obras/current/ey_bundler_binstubs; exec \$SHELL -l"
      ;;
    demo)
      ssh -t deploy@ec2-54-232-113-149.sa-east-1.compute.amazonaws.com "cd /data/obras/current/ey_bundler_binstubs; exec \$SHELL -l"
      ;;
    *)
      ansi --no-newline --red-intense "==> "; ansi --white-intense "Error bad site "$SITE
      ansi ""
     ;;          
  esac 
}
site.status(){
  ansi --white --no-newline "site:   "
  ansi --no-newline --white-intense --underline $SITE
  ansi --white --no-newline " ";ansi --cyan-intense $(rvm current)
  ansi --no-newline "  env   "
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
}

pushd .
site.init demo
popd
title
