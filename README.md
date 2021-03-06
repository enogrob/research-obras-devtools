```
Roberto Nogueira  
BSd EE, MSd CE
Solution Integrator Experienced - Certified by Ericsson
```
# Research Obras DevTools

![project image](images/research.png)

**About**

This in order to improve the Obras Development Process, developing utilities and support for [**Foreman**](https://github.com/ddollar/foreman), [**Docker**](https://www.docker.com/) and  editors [**VsCode**](https://code.visualstudio.com/) and [**Rubymine**](https://www.jetbrains.com/ruby/). 

**Advantages:**

![project image](images/screenshot3.png)

* Development Flux and Environment seamlessly Integrated with **Docker**
* Automatic **db** update
* Live **db, servers, testing** information
* **Progress bars** and **spinners** for long tasks duration
* Supports for OSX and Linux
* Supports [**NGrok**](https://ngrok.com/), [**Foreman**](https://github.com/ddollar/foreman), [**mycli**](https://github.com/dbcli/mycli) and [**iredis**](https://iredis.io/)
* Extends use of [**chromeapps-for-eicon**](https://github.com/enogrob/chromeapps-eicon)
* Configurations support for [**Rubymine**](https://www.jetbrains.com/ruby/) and [**Vscode**](https://code.visualstudio.com/)

**Refs:**

* [1] [**Project Obras Devtools** in Github](https://github.com/enogrob/research-obras-devtools)
* [2] [**Pipe Viewer**](http://www.ivarch.com/programs/pv.shtml)
* [3] [**Library Ansi**](https://github.com/fidian/ansi)
* [4] [**Revolver**](https://github.com/molovo/revolver)
* [5] [**Z shell**](http://zsh.sourceforge.net/)

## Requirements

In order to install `DevTools`, it is required that the following has been installed already:

* [Mysql](https://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/#apt-repo-fresh-install)
* [Redis](https://redis.io/topics/quickstart)
* [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* [RVM](https://rvm.io/rvm/install)
* [Docker](https://docs.docker.com/get-docker/)

It is required that it is generated a new RSA key with the more secure encryption format with
the following command:

```shell
$ ssh-keygen -o -t rsa -b 4096 -C "email@example.com"
```

Also the `SSH` keys has to be setup in [Github](https://github.com/settings/keys), [Gitlab](https://gitlab.tecnogroup.com.br/profile/keys) and [Engine Yard](https://cloud.engineyard.com/keypairs).


## Installation

**1.** Clone the `DevTools` repository

```shell
$ git clone git@github.com:enogrob/research-obras-devtools.git
```

**2.** Go to into `research-obras-devtools` directory.

```shell
$ cd research-obras-devtools
```

**3.** Define temporarily two enviroment variables specifying wwhere `obras` and `obras_old` is, for example:
Obs: As nowadays all sites are at same level, specify same location for both.  

* `obras` is the most actual location for the mainly project. 
* `obras_old` is the project folder for sites in older revision.

```shell
$ OBRAS=~/Projects/obras
$ OBRAS_OLD=~/Projects/obras
```

**4.** Run `install.sh` in order to install `DevTools` for `obras`:

```shell
$ ./install.sh obras_dir $OBRAS $OBRAS_OLD
$ ./install.sh obras
```

**5.** If you have not specify yet the `gemset` in the `obras` directories do it:
Obs: The underlying ruby has to be installed before, do `rvm list` in order to check. As nowadays the location are the same does just for one.
Obs: This requires in Linux `rvm`, `redis-server`, `mysql-server` and `nodejs` installed.

```shell
$ cd $OBRAS
$ rvm use ruby-2.6.5
$ rvm gemset create rails-6.0.2.1
$ rvm gemset list
$ rvm use --ruby-version ruby-2.6.5@rails-6.0.2.1
$ rvm current
$ gem list
$ gem install rails -v '6.0.2.1'
```

**6.** reload the shell in order to take effect.

```shell
$ source ~/.bashrc
```

**7.** Below is a example to to prepare a site for use.

obs: Remember to register the `ssh` keys in **Engine Yard** in order to be able to download the dumps automatically.

```shell
$ santoandre
$ site db update
:
```

![](images/screenshot1.png)

```
:
$ site start
```

In other shell. Check that is running.

```shell
$ site
:
```

![](images/screenshot2.png)

**8.** In order to update from previous versions that does not contain `obras_utils` function does the following:

```shell
$ obras
$ test -f .fobras_utils.sh && rm -rf .fobras_utils.sh
$ wget https://raw.githubusercontent.com/enogrob/research-obras-devtools/master/obras/.fobras_utils.sh
$ source .fobras_utils.sh
$ fobras_utils update
```

**For further help:**

```shell
$ site --help

Crafted (c) 2013~2020 by InMov - Intelligence in Movement
Obras Utils 1.5.11
::
site[sitename || flags || set/unset flag|| env development/test]
site[check/ls || start/stop [sitename/all] || console || test/test:system || rspec]
site[mysql/ngrok/redis/mailcatcher/sidekiq start/stop/restart/status]
site[dumps [activate dumpfile]]
site[db/mysql/redis conn/connect]
site[conn/connect]
site[stats]
site[rubycritic/rubocop [files]]
site[db:drop || db:create || db:migrate db:migrate:status || db:seed]

$ site db/dbs --help
Crafted (c) 2013~2020 by InMov - Intelligence in Movement
Obras Utils 1.5.11
::
db[set sitename || ls || init || preptest || drop [all] || create || migrate migrate:status || seed]
db[backups || download [filenumber] || import [backupfile] || update [all]]
db[tables || databases || socket || connect]
db[api [dump/export || import]]

$ site services --help
Crafted (c) 2013~2020 by InMov - Intelligence in Movement
Obras Utils 1.5.11
::
services[ls/check]
services[start/stop/restart/status mysql/ngrok/redis/sidekiq/mailcatcher || [all]]
services[enable/disable ngrok/sidekiq/mailcatcher]
services[conn/connect mysql/db/redis]

obs:redis and mysql are not involved when all is specified

$ obras_utils --help
Crafted (c) 2013~2020 by InMov - Intelligence in Movement
Obras Utils 1.5.11
::
obras_utils[version/update/check]
```

## Obras Utils

Changes log

* **1.5.11** General improvements.
* **1.5.10** Remove  `rvm use` in `site.init` command.
* **1.5.09** Correct  `README.md` file.
* **1.5.08** Option  `preptest` now valid for other sites than `demo`.
* **1.5.07** Correct `site` command without parameter after command `obras`.
* **1.5.06** Correct `tmp/devtools` no such file or directory and when a service is started alone.
* **1.5.05** Correct `__pid` function for Linux.
* **1.5.04** Replace `lsof` by `netstat` in order to get the pid process. 
* **1.5.03** New aliases commands such as `site db:drop`, `site db:create`, `site db:migrate`, `site db:migrate:status` and `site db:seed`. 
* **1.5.02** New command `site db migrate:status` in order to check and act on migration status.
* **1.5.01** Correct `site services start/stop`, for `ngrok`
* **1.5.00** Improve `site services start/stop`, now will start and stop `all` as well.
* **1.4.99** General Refactoring.
* **1.4.98** Add `function __gitignore()` and correct `site rubycritic` and `site rubocop`.
* **1.4.97** Integrate `rubocop` and improve `rubycritic`.
* **1.4.96** New command `site stats` in order to give rails statistics.
* **1.4.95** Improve again `backups` and `services` management.
* **1.4.94** Improve `backups` management.
* **1.4.93** New command `site conn/connect` in order to access via ssh the homolog site.
* **1.4.92** Improve `flags.print_ups` in flags.
* **1.4.91** Integrate `tmp/rubycritic/overview.html` in flags.
* **1.4.90** Integrate `coverage/index.html` in flags.
* **1.4.89** Improve "Improve `install.sh` and `obras_utils update`."
* **1.4.88** Improve `site services enable/disable [services]` now it can specify more than one service.
* **1.4.87** Correct `site services enable/disable [service]`.
* **1.4.86** Implemented `site services enable/disable [service]`.
* **1.4.85** Improve more the `site services` management. 
* **1.4.84** Improve the `site services` management. 
* **1.4.83** Correct `__db print_db` and `__db current` connection error.
* **1.4.82** Correct `mycli` or `iredis` connection error.
* **1.4.81** Correct `unexpected end of file` error.
* **1.4.80** Improve the `services` management. 
* **1.4.79** Improve the `services` management. 
* **1.4.78** Services `redis` and `mysql` are now managed.
* **1.4.77** Services `mailcatcher` and `sidekiq` are now managed.
* **1.4.76** Current `sites()` shall get from **Procfile** instead from env **$SITES**.
* **1.4.75** Command `site db init` init env from **seeds**, and `site db preptest` does both envs.
* **1.4.74** Correct `Error bad site` for `site` command.
* **1.4.73** Correct `site db download` for **Rio Claro**.
* **1.4.72** Correct `RAILS_VERSION` checking. New parameter `[all]` in `site db drop`.
* **1.4.71** Correct `install.sh` script.
* **1.4.70** Correct dump messages.
* **1.4.69** Correct the **IFS** problem.
* **1.4.68** Command `site` command is now faster.
* **1.4.67** New parameter `[filenumber]` in `site db download` to specify the required downloaded file.
* **1.4.66** New command `site db backups` in order to list the backups files in **Engine Yard**.
* **1.4.65** Update README.md and command `site set docker`.
* **1.4.64** Improve **Docker** interaction.
* **1.4.63** utility **mycli** becomes accessible from a Docker container.
* **1.4.62** Improve the **mysql cli** with **mycli**. 
* **1.4.61** New command  `site db connect` to connect to **db**.
* **1.4.60** This release is due to that `rioclaro` has been updated to **ruby-2.6.5@rails-6.0.2.1.**.
* **1.4.59** New command `obras_utils` that can checks if there is a new release in github.

Changes Required

* **1.6.00** Review `Docker` for the latest changes.

