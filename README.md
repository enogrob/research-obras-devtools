```
Roberto Nogueira  
BSd EE, MSd CE
Solution Integrator Experienced - Certified by Ericsson
```
# Research Obras DevTools

![project image](images/research.png)

**About**

This in order to improve the Obras Development Process, developing utilities and support for `Foreman`, `Docker` and  editors `VsCode` and `Rubymine`. 

**Advantages:**

* Development Flux and Environment seamlessly Integrated with **Docker**
* Automatic **db** update
* Live **db, servers, testing** information
* **Progress bars** and **spinners** for long tasks duration
* Supports for OSX and Linux
* Supports **NGrok** and **Foreman**
* Extends use of [https://trello.com/c/sIcQXzig/116-chromeapps-for-eicon](https://trello.com/c/sIcQXzig/116-chromeapps-for-eicon)
* Configurations support for **Rubymine** and **Vscode**

**Refs:**

* [1] [**Project Obras Devtools** in Github](https://github.com/enogrob/research-obras-devtools)
* [2] [**Pipe Viewer**](http://www.ivarch.com/programs/pv.shtml)
* [3] [**Library Ansi**](https://github.com/fidian/ansi)
* [4] [**Revolver**](https://github.com/molovo/revolver)
* [5] [**Z shell**](http://zsh.sourceforge.net/)

## Installation

1. Clone the `DevTools` repository

```shell
$ git clone git@github.com:enogrob/research-obras-devtools.git
```

2. Go to into `research-obras-devtools` directory.

```shell
$ cd research-obras-devtools
```

3. Define temporarily two enviroment variables specifying wwhere `obras` and `obras_old` is, for example:
Obs: 

* `obras` is the mainly project folder for sites `olimpia`, `santoandre` e `suzano`. 
* `obras_old` is the project folder for site `rioclaro`.

```shell
$ OBRAS=~/Projects/obras
$ OBRAS_OLD=~/Projects/obras_old
```

4. Run `install.sh` in order to install `DevTools` for `obras`:

```shell
$ ./install.sh obras_dir $OBRAS $OBRAS_OLD
$ ./install.sh obras
```

5. If you have not specify yet the `gemset` in the `obras` directories do it:
Obs: The underlying ruby has to be installed before, do `rvm list` in order to check.

```shell
$ cd $OBRAS
$ rvm use ruby-2.6.5
$ rvm gemset create rails-6.0.2.1
$ rvm gemset list
$ rvm use --ruby-version ruby-2.6.5@rails-6.0.2.1
$ rvm current
$ gem list
$ rvm install rails -v '6.0.2.1'

$ cd $OBRAS_OLD
$ rvm use ruby-2.3.8
$ rvm gemset create rails-4.2.8
$ rvm gemset list
$ rvm use --ruby-version ruby-2.3.8@rails-4.2.8
$ rvm current
$ gem list
$ rvm install rails -v '4.2.8'
```

6. reload the shell in order to take effect.

```shell
$ source ~/.bashrc
```

7. Below is a example to to prepare a site for use.

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

![](images/screenshot2.png)

For further help:

```shell
$ site --help
Crafted (c) 2013~2020 by InMov - Intelligence in Movement
::
site[sitename || flags || set/unset flag|| env development/test]
site[check/ls || start/stop [sitename/all] || console || test || rspec]
site[ngrok || mailcatcher start/stop]

$ site db --help
Crafted (c) 2013~2020 by InMov - Intelligence in Movement
::
db[set sitename || ls || preptest || drop || create || migrate || seed || import [dbfile] || download || update [all]]
db[status || start || stop || restart || tables || databases || socket]
db[api [dump || import]]
```
