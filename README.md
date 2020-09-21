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

* Development Flux and Environment seamlessly Integrated with **Docker**
* Automatic **db** update
* Live **db, servers, testing** information
* **Progress bars** and **spinners** for long tasks duration
* Supports for OSX and Linux
* Supports [**NGrok**](https://ngrok.com/), [**Foreman**](https://github.com/ddollar/foreman), [**mycli**](https://github.com/dbcli/mycli) ans [**iredis**](https://iredis.io/)
* Extends use of [**chromeapps-for-eicon**](https://github.com/enogrob/chromeapps-eicon)
* Configurations support for [**Rubymine**](https://www.jetbrains.com/ruby/) and [**Vscode**](https://code.visualstudio.com/)

**Refs:**

* [1] [**Project Obras Devtools** in Github](https://github.com/enogrob/research-obras-devtools)
* [2] [**Pipe Viewer**](http://www.ivarch.com/programs/pv.shtml)
* [3] [**Library Ansi**](https://github.com/fidian/ansi)
* [4] [**Revolver**](https://github.com/molovo/revolver)
* [5] [**Z shell**](http://zsh.sourceforge.net/)

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

```shell
$ cd $OBRAS
$ rvm use ruby-2.6.5
$ rvm gemset create rails-6.0.2.1
$ rvm gemset list
$ rvm use --ruby-version ruby-2.6.5@rails-6.0.2.1
$ rvm current
$ gem list
$ rvm install rails -v '6.0.2.1'
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
Obras Utils 1.4.79
::
site [sitename || flags || set/unset flag|| env development/test]
site [check/ls || start/stop [sitename/all] || console || test/test:system || rspec]
site [mysql/ngrok/redis/mailcatcher/sidekiq start/stop/restart/status]
site [db/mysql/redis conn/connect]

$ site db --help
Crafted (c) 2013~2020 by InMov - Intelligence in Movement
Obras Utils 1.4.79
::
db [set sitename || ls || init || preptest || drop [all] || create || migrate || seed]
db [ls || backups || download [filenumber] || import [backupfile] || update [all]]
db [tables || databases || socket]
db [api [dump/export || import]]

$ site services --help
Crafted (c) 2013~2020 by InMov - Intelligence in Movement
Obras Utils 1.4.79
::
services [start/stop/restart/status mysql/ngrok|redis/sidekiq/mailcatcher || all]
services [conn/connect mysql/db/redis

obs: redis and mysql are not involved when all is specified

$ obras_utils --help
Crafted (c) 2013~2020 by InMov - Intelligence in Movement
Obras Utils 1.4.79
::
obras_utils [version/update/check]
```

## Obras Utils

Changes log

* **1.4.79** Improve the 'services' management. 
* **1.4.78** Services `redis` and `mysql` are now managed.
* **1.4.77** Services `mailcatcher` and `sidekiq` are now managed.
* **1.4.76** Current `sites()` shall get from **Procfile** instead from env **$SITES**
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
* **1.4.60** This release is due to that `rioclaro` has been updated to **ruby-2.6.5@rails-6.0.2.1.**
* **1.4.59** New command `obras_utils` that can checks if there is a new release in github.

Changes Required

* **1.4.80** Improve the **redis cli** with **iredis**. 
* **1.4.81** Review `Docker` for the latest changes.

