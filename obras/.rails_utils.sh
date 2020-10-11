#!/bin/bash
## Crafted (c) 2013~2020 by InMov - Intelligence in Movement
## Prepared : Roberto Nogueira
## Project  : project-obras-devtools
## Reference: bash
## Depends  : foreman, pipe viewer, ansi, revolver
## Purpose  : Develop bash routines in order to help Rails development
##            projects.
## File     : .rails_utils.sh

APP=$(rails r "puts Rails.application.class.module_parent")
dbs.set

site(){
  local $action=$1  
  case $action in
    *)
      app.status
      dbs.status
      ;;
  esac    
}
app.status(){
  ansi --white --no-newline "app:   "
  ansi --no-newline --white-intense --underline $APP
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
app.env.set(){
  local env=$1
  case $1 in
    development|dev)
      unset RAILS_ENV
      export RAILS_ENV=development
      ;;
    test|tst)
      unset RAILS_ENV
      export RAILS_ENV=test
      ;;
    *)
      ansi --no-newline --red-intense "==> "; ansi --white-intense "Error bad env "$1
      ansi ""
      ;;
  esac  
}      
app.env.set.development(){
  unset RAILS_ENV
  export RAILS_ENV=development
}      
app.env.set.test(){
  unset RAILS_ENV
  export RAILS_ENV=test
}      
app.env.unset(){
  unset RAILS_ENV
  export RAILS_ENV=development
}      

dbs.current(){
  local env=$1
  if [ -z $env ]; then
    env=$RAILS_ENV
  fi
  if [ "$env" == "development" ]; then
    echo $DB_DEV
  elif [ "$env" == "test" ]; then 
    echo $DB_TST
  fi 
}
dbs.exists(){
  echo 'yes'    
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
  if [ "$(dbs.exists $db)" == 'yes' ]; then
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
  local env=$RAILS_ENV
  export DB_DEV=$(rails r "puts Rails.configuration.database_configuration['development']['database']")
  export DB_TST=$(rails r "puts Rails.configuration.database_configuration['test']['database']")
}
dbs.status(){
  ansi "dbs:"
  dbs.print_db development
  dbs.print_db test 
}
