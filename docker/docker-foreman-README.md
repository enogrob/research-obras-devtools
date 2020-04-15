```
(C) 2020 Crafted by Roberto Nogueira
email : roberto.nogueira@tecnogrupo.com.br.com
trello: robertonogueira17
```

Fluxo de Desenvolvimento com Docker para  Obras

---

Caracteristicas Importantes:

* Introdução de Fluxo de Desenvolvimento com `Docker` sem interferir no atual. 
* Permitir acesso a `Dockerhub` devido restrições impostas pelos proxies.
* Tem IP fixos para os nós, importante principalmente para o nó de banco de dados `db`.
* Volume de cache para `Gems`.

Para isto requer a instalação de `Docker` e `docker-compose` no Linux veja instruções abaixo:

* Docker
```shell
$ sudo apt-get update
$ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ sudo apt-key fingerprint 0EBFCD88
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
$ sudo apt-get update
$ sudo apt-get install docker-ce
# sudo groupadd docker
$ sudo usermod -aG docker $USER
$ sudo shutdown -h now
# sudo chmod 666 /var/run/docker.sock
$ docker info
```

* Docker Compose
```shell
$ sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
$ docker-compose version
```

Para se criar e baixar as imagens de Docker necessárias:
```shell
$ docker-compose build
:

$ docker images
demo                latest              073ee4b6f408        27 minutes ago      1.49GB
olimpia             latest              073ee4b6f408        27 minutes ago      1.49GB
rioclaro            latest              073ee4b6f408        27 minutes ago      1.49GB
santoandre          latest              073ee4b6f408        27 minutes ago      1.49GB
suzano              latest              073ee4b6f408        27 minutes ago      1.49GB
<none>              <none>              d81931c04e91        41 minutes ago      1.49GB
mysql               5.7.23              1b30b36ae96a        11 months ago       372MB
ruby                2.3.3               0e1db669d557        2 years ago         734MB
```

Para iniciar os respectivos containers
```shell
$ docker-compose up -d
:

$ docker-compose ps
Name                   Command               State           Ports         
-------------------------------------------------------------------------------
db           docker-entrypoint.sh mysqld      Up      3306/tcp, 33060/tcp   
demo         ./docker-entrypoint.sh bin ...   Up      0.0.0.0:3013->3000/tcp
olimpia      ./docker-entrypoint.sh bin ...   Up      0.0.0.0:3002->3000/tcp
rioclaro     ./docker-entrypoint.sh bin ...   Up      0.0.0.0:3003->3000/tcp
santoandre   ./docker-entrypoint.sh bin ...   Up      0.0.0.0:3005->3000/tcp
suzano       ./docker-entrypoint.sh bin ...   Up      0.0.0.0:3004->3000/tcp
```

Para zerar os volumes e redes no `Docker`:
```shell
$ docker volume prune
$ docker network prune
```

Para importar dados para os containeres p.e. `rioclaro`(ver abaixo), repetir comandos para os demais:
**Obs:** o arquivo de dump deve estar na pasta de projeto.
```shell
$ docker-compose exec rioclaro bundle exec rails db:drop
$ docker-compose exec rioclaro bundle exec rails db:create
$ docker exec -i db mysql -uroot -proot rioclaro_dev < obras.2019-10-07_rioclaro.sql
$ docker-compose exec $1 bundle exec rails db:migrate
```

A seguinte função e aliases por ser util para `Docker` em se ter em `~/.bashrc`:

```bash
function dkimportdb(){
  docker-compose exec $1 bundle exec rails db:drop
  docker-compose exec $1 bundle exec rails db:create
  docker exec -i db mysql -uroot -proot $2 < $3
  docker-compose exec $1 bundle exec rails db:migrate
}

alias dk='docker'
alias dki='docker image'
alias dkis='docker images'
alias dkins="docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'"
alias dkc='docker container'

alias dc=docker-compose
alias dc-exec='docker-compose exec"'
alias dc-db='docker-compose exec db"'
```


Para se importar os banco de dados usando a função `dkimportdb`
```shell
$ ls -la *.sql
-rw-r--r--   1 rnogueira rnogueira 1104375624 Oct  7 11:37 obras.2019-10-07_demo.sql
-rw-r--r--   1 rnogueira rnogueira 1133044012 Oct  7 11:37 obras.2019-10-07_olimpia.sql
-rw-r--r--   1 rnogueira rnogueira 1369770764 Oct  7 11:38 obras.2019-10-07_rioclaro.sql
-rw-r--r--   1 rnogueira rnogueira    5345253 Oct  7 11:38 obras.2019-10-07_santoandre.sql
-rw-r--r--   1 rnogueira rnogueira  302326652 Oct  7 11:39 obras.2019-10-07_suzano.sql
:

$ dkimportdb rioclaro rioclaro_dev obras.2019-10-07_rioclaro.sql
$ dkimportdb olimpia olimpia_dev obras.2019-10-07_olimpia.sql
$ dkimportdb suzano suzano_dev obras.2019-07-10_suzano.sql
$ dkimportdb santoandre santoandre_dev obras.2019-10-07_santoandre.sql
$ dkimportdb demo demo_dev obras.2019-10-07_demo.sql
```

Para listar os volumes no `Docker`:
Obs: It is recomendable remove the volumes in case of error when building. `/bundle` dir shall be created.
```shell
$ docker volume ls
```

Se quiser iniciar os sites do zero rodar os seguintes comandos para cada site p.e. `demo`:
```
$ docker-compose up -d

$ docker-compose exec olimpia rails db:drop
$ docker-compose exec olimpia rails db:create 
$ docker-compose exec olimpia rails db:migrate
$ docker-compose exec olimpia rails db:seed

$ docker-compose exec rioclaro rails db:drop
$ docker-compose exec rioclaro rails db:create 
$ docker-compose exec rioclaro rails db:migrate
$ docker-compose exec rioclaro rails db:seed

$ docker-compose exec suzano rails db:drop
$ docker-compose exec suzano rails db:create 
$ docker-compose exec suzano rails db:migrate
$ docker-compose exec suzano rails db:seed

$ docker-compose exec santoandre rails db:drop
$ docker-compose exec santoandre rails db:create 
$ docker-compose exec santoandre rails db:migrate
$ docker-compose exec santoandre rails db:seed

$ docker-compose exec demo rails db:drop
$ docker-compose exec demo rails db:create 
$ docker-compose exec demo rails db:migrate
$ docker-compose exec demo rails db:seed

$ docker-compose down
```

Ou inclua a seguinte função em `~/.bashrc`
```
function dkinitdb(){
  docker-compose exec $1 bundle exec rails db:drop
  docker-compose exec $1 bundle exec rails db:create
  docker-compose exec $1 bundle exec rails db:migrate
  docker-compose exec $1 bundle exec rails db:seed
}
```

E para executar:
```
$ docker-compose up -d

$ dkinitdb olimpia
$ dkinitdb rioclaro
$ dkinitdb suzano
$ dkinitdb santoandre
$ dkinitdb demo

$ docker-compose down
```

Se quiser iniciar o site para rodar testes com p.e. `rspec` ou `minitest` p.e. `demo`:
```
$ docker-compose exec -e RAILS_ENV=test demo bundle exec rails db:drop
$ docker-compose exec -e RAILS_ENV=test demo bundle exec rails db:create 
$ docker-compose exec -e RAILS_ENV=test demo bundle exec rails db:migrate
$ docker-compose exec -e RAILS_ENV=test demo bundle exec rails db:seed

$ docker-compose exec demo bundle exec rspec
$ docker-compose exec demo bundle exec rails test
$ docker-compose exec demo bundle exec rails test:system

$ docker-compose exec -e HEADLESS=0 bundle exec demo rspec
$ docker-compose exec -e HEADLESS=0 bundle exec demo rails test
$ docker-compose exec -e HEADLESS=0 bundle exec demo rails test:system

$ docker-compose exec -e COVERAGE=0 bundle exec demo rspec
$ docker-compose exec -e COVERAGE=0 bundle exec demo rails test
$ docker-compose exec -e COVERAGE=0 bundle exec demo rails test:system
```

Fluxo de Desenvolvimento com Foreman para  Obras

---

A seguinte função e aliases por ser util para `foreman` em se ter em `~/.bashrc`:
```bash
function setdb(){
  spring stop
  set -o allexport
  . ./.env/development/$1
  set +o allexport
  db
}

function db(){
  echo $MYSQL_DATABASE_DEV
  echo $MYSQL_DATABASE_TST
}

function importdb(){
  rails db:drop
  rails db:create
  mysql -u root -p $MYSQL_DATABASE_DEV < $1
  rails db:migrate
}

function initdb(){
  rails db:drop
  rails db:create
  rails db:migrate
  rails db:seed
}
```

Instalar gem `foreman`:
```bash
$ gem install foreman
```

Check file foreman `Procfile`:
```bash
$ foreman check
```

Importar `dbs` no RDBM local:
Obs: Repetir a sequencia para cada site
```bash
$ setdb olimpia
$ db
$ importdb obras.2019-10-07_olimpia.sql
```

Start um site ou todos com `foreman`:
```bash
$ foreman start olimpia
:
$ foreman start all
:
```

