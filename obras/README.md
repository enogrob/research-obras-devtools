```
(C) 2020 Crafted by InMov - Intelligence in Movement
```

#### Docker Development Flux with `Obras - DevTools`

##### Installation and Configuation

Important Characteristics:

* Development Flux with `Docker` without interference with the usual. 
* Static IPs, important mainly for the `db` service.
* Cache volume for the `Gems`.

Follows the `Docker` and `docker-compose` installation in Linux:

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

In order to create and download `Docker` images if required:
```shell
$ docker-compose build
:

$ docker images
REPOSITORY                         TAG                 IMAGE ID            CREATED             SIZE
olimpia                            latest              1b6ac5ab5aa6        8 days ago          1.82GB
santoandre                         latest              1b6ac5ab5aa6        8 days ago          1.82GB
selenium/standalone-chrome-debug   latest              ab22600a9c2b        2 weeks ago         939MB
demo                               latest              0d61793ca14e        4 weeks ago         1.81GB
ruby                               2.6.5               8f309d9e27ea        8 weeks ago         840MB
mysql                              5.7.23              1b30b36ae96a        18 months ago       372MB
ruby                               2.3.3               0e1db669d557        3 years ago         734MB
```

In order to cleanup `Docker` Networks and Volumes:
```shell
$ docker volume prune
$ docker network prune
```

In order to list `Docker` Networks and Volumes:
**Obs:** It is recomendable remove the volumes in case of error when building. `/bundle` dir shall be created.
```shell
$ docker volume ls
$ docker network ls
```

#### Develoment Flux with Docker

Is the same as the Regular except that you have to setup an env variable `DOCKER` in the beginning and unset at the end, e.g.:
```shell
$ site set docker
:
:
$ site
site: santoandre
rvm : ruby-2.6.5@rails-6.0.2.1
env : development
rails server: http://localhost:3005 25380
mailcatcher : http://localhost:1080
test  : {coverage: false, headless: true}
docker: {status: true, selenium remote: false}
db_dev: santoandre_dev 584 805657
db_tst: santoandre_tst 0
db_sqls:
 obras.2020-04-27_santoandre.sql
:
:
$ site unset docker
```

##### Regular Development Flux with `Obras - DevTools`

In order to setup the site for development you just have to setup the db:
```
$ site db status
$ site set santoandre

$ site
site: santoandre
rvm : ruby-2.6.5@rails-6.0.2.1
env : development
rails server: http://localhost:3005
mailcatcher : http://localhost:1080
coverage: false, headless: true, selenium remote: false
db_dev: santoandre_dev
db_tst: santoandre_tst
db_sqls:
 no sql files

$ site db update

$ site 
site: santoandre
rvm : ruby-2.6.5@rails-6.0.2.1
env : development
rails server: http://localhost:3005
mailcatcher : http://localhost:1080
coverage: false, headless: true, selenium remote: false
db_dev: santoandre_dev 583 804261
db_tst: santoandre_tst
db_sqls:
 obras.2020-04-26_santoandre.sql

$ site start

$ site
site: santoandre
rvm : ruby-2.6.5@rails-6.0.2.1
env : development
rails server: http://localhost:3005 19614
mailcatcher : http://localhost:1080
coverage: false, headless: true, selenium remote: false
db_dev: santoandre_dev 583 804261
db_tst: santoandre_tst
db_sqls:
 obras.2020-04-26_santoandre.sql
```

#### Tests

In order to run `RSpec` or `Minitest` tests, the site db has to be prepared i.e. for `default` site:
```shell
$ default

$ site
 site: demo
 rvm : ruby-2.6.5@rails-6.0.2.1
 env : development
 rails server: http://localhost:3013
 mailcatcher : http://localhost:1080
 coverage: false, headless: true, selenium remote: false
 db_dev: demo_dev
 db_tst: demo_test
 db_sqls:
  no sql files

 $ site db preptest
 $ site set env test
 $ site db preptest
 $ site set env development

 $ site
 site: demo
 rvm : ruby-2.6.5@rails-6.0.2.1
 env : development
 rails server: http://localhost:3013
 mailcatcher : http://localhost:1080
 coverage: false, headless: true, selenium remote: false
 db_dev: demo_dev 583 21549
 db_tst: demo_tst 583 21552
 db_sqls:
  no sql files
```

Running `Unit` tests:
```shell
$ site test
Started with run options --seed 65307

BuildingPurposeInProjectCreationTest
  test_has_and_belongs_to_many_building_kinds                     PASS (0.29s)
  test_validates_the_absence_of_building_purpose                  PASS (0.01s)
  test_validates_presence_of_building_purpose                     PASS (0.03s)
  test_validates_the_uniqueness_of_building_purpose               PASS (2.58s)
  test_belongs_to_building_purpose                                PASS (0.03s)

UserTest
  test_has_an_invalid_cpf                                         PASS (0.20s)
  test_has_a_valid_factory                                        PASS (0.01s)

Finished in 3.16327s
7 tests, 9 assertions, 0 failures, 0 errors, 0 skips
```

Running `System` tests:
```
$ site test:system
Started with run options --seed 43391

BuildingPurposeInProjectCreationsTest
  test_create_model                                               PASS (40.11s)
  test_deactivate/activate_model                                  PASS (13.02s)
  test_edit_model                                                 PASS (13.38s)
  test_check_login                                                PASS (7.12s)
  test_create_model_test_validation                               PASS (19.10s)

UserRegistersTest
  test_register_user                                              SKIP (0.01s)

UserAccessesTest
  test_access_Gestão_Operacional                                  PASS (4.25s)
  test_access_Tributario                                          PASS (3.54s)
  test_change_Demo_access_to_Gestão_InMov                         PASS (5.62s)
  test_access_Analista_Inicial                                    PASS (3.68s)
  test_access_Demo_with_email                                     PASS (3.27s)
  test_access_Visualização_Pública                                PASS (3.57s)
  test_access_Analista_Final                                      PASS (2.97s)
  test_access_Deferementista                                      PASS (3.07s)
  test_access_Gestão_Empresas                                     PASS (3.24s)
  test_access_Protocolo                                           PASS (3.24s)
  test_access_Tesouraria                                          PASS (3.10s)
  test_access_Lançadoria                                          PASS (3.53s)
  test_access_Parecerista                                         PASS (3.24s)
  test_access_Gestão_InMov                                        PASS (3.30s)
  test_access_Gestão_de_Contrato                                  PASS (3.35s)
  test_access_Demo_with_cpf                                       PASS (3.37s)
  test_access_Auditor                                             PASS (2.80s)
  test_access_Cadastro_de_Legislação                              PASS (3.30s)
  test_access_Cadastro_de_Despachos                               PASS (3.20s)
  test_access_Solicitante                                         PASS (3.30s)
  test_access_Gestão_de_Tesouraria                                PASS (3.14s)
  test_access_Gestão_Tributária                                   PASS (3.21s)
  test_access_Gestão_de_Configuração                              PASS (3.36s)
  test_access_Gestão_de_Usuário                                   PASS (3.63s)

ProjectCreationTypesTest
  test_edit_model                                                 PASS (9.16s)
  test_check_login                                                PASS (3.21s)
  test_create_model                                               PASS (11.84s)

Finished in 199.26141s
33 tests, 73 assertions, 0 failures, 0 errors, 1 skips
```

If you want to debug you have to set env `headless`. The same if you want run with coverage, you have to set env `coverage`.
```
$ site unset headless
$ site set coverage

$ site
site: demo
rvm : ruby-2.6.5@rails-6.0.2.1
env : development
rails server: http://localhost:3013 25380
mailcatcher : http://localhost:1080
test  : {coverage: true, headless: false}
db_dev: demo_dev 583 21027
db_tst: demo_tst 583 21455
db_sqls:
 no sql files
```
