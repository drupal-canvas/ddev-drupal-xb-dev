# DDEV Drupal Canvas Development Environment

This creates and configures a DDEV project for local [Drupal Canvas](https://www.drupal.org/project/canvas) module development. Specifically, it creates a Drupal site, clones and installs the module, sets up the front-end dependencies, and provides specialized development and testing tools.

>  **Notice:** This add-on is experimental. See [Support & community](#support--community) below.

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Updating](#updating)
- [Automatic tests](#automatic-tests)
  - [PHPUnit tests](#phpunit)
  - [Cypress](#cypress)
    - [Setup](#setup)
    - [Running Cypress tests](#running-cypress-tests)
- [Support \& community](#support--community)
- [FAQ \& known issues](#faq--known-issues)
  - [Can I use Cypress on Linux or Windows?](#can-i-use-cypress-on-linux-or-windows)
  - [What if Cypress fails to start?](#what-if-cypress-fails-to-start)
  - [What if I get an HTTPS error?](#what-if-i-get-an-https-error)

## Requirements

Obviously, this requires a working [DDEV](https://ddev.com/) installation. It has been successfully tested with [Orbstack](https://orbstack.dev/), [Lima](https://lima-vm.io/), [Colima](https://github.com/abiosoft/colima), [Rancher Desktop](https://rancherdesktop.io/), and [Docker Desktop](https://www.docker.com/products/docker-desktop/). Others should work fine, as well.

## Installation

```shell
# Create a new directory for your new DDEV project.
# This can be any place you like. For example:
mkdir ~/Sites/xb-dev
cd ~/Sites/xb-dev

# Configure the new DDEV project.
ddev config --project-type=drupal11 --docroot=web

# Create the Drupal project.
ddev composer create-project drupal/recommended-project:11.x@dev --no-install

# Install the add-on.
ddev add-on get drupal-canvas/ddev-drupal-xb-dev

# Perform one-time setup operations.
ddev xb-setup

# Optionally add some convenience extras for development.
ddev xb-dev-extras

# Optionally configure the environment for Workspaces development. Note: This can be
# a little volatile due to upstream Workspaces changes. Be aware that it can fail
# and leave your site in a non-working state requiring you to set it up again from scratch.
ddev xb-workspaces-dev
```

## Usage

The resulting DDEV project is just like any other one. Interact with it using the [the built-in commands](https://ddev.readthedocs.io/en/stable/users/usage/commands/), e.g., `ddev launch` to browse the site.

The installation process clones [the Drupal Canvas module](https://www.drupal.org/project/canvas) into `web/modules/contrib/canvas`. Develop and contribute from either location like you would any other Git repo for a normal Drupal project.

Any time you update the Drupal Canvas module or modify its front-end code, be sure to rebuild the UI app assets:

```shell
ddev xb-ui-build
```

When developing the React app, make sure to use the HTTPS URL of your DDEV project, then run:

```shell
ddev xb-ui-dev
```

To completely reinstall Drupal and the Drupal Canvas module, run:

```shell
ddev xb-site-install
```

For the full list of available Drupal Canvas commands, run this:

```shell
ddev | grep xb-
```

## Updating

Update the Drupal Canvas module clone just like you would any other Git repo. No tools are currently provided for updating Core.

## Automatic tests

### PHPUnit

For PHPUnit based tests (`Unit`, `Kernel`, `Functional`, and `FunctionalJavascript`), the `xb-phpunit` command is provided.
The test file must be passed relative to the canvas module root.

```shell
ddev xb-phpunit tests/src/Functional/CanvasConfigEntityHttpApiTest.php
```

Whatever extra argument `phpunit` accepts can be used:

```shell
ddev xb-phpunit tests/src/Functional/CanvasConfigEntityHttpApiTest.php --filter testJavascriptComponent

```

### Cypress

Drupal Canvas uses [Cypress](https://www.cypress.io/) for front-end testing. It is currently only supported on macOS.
Linux and Windows with WSL2 might work with the instructions below.

#### Setup

##### macOS

> Carefully follow the below XQuartz configuration steps after installing it. Failure to do so will result in frustrating, difficult to debug problems.

Install XQuartz using Homebrew. See also https://www.xquartz.org/.

```shell
brew install xquartz
```

Configure XQuartz to allow connections from the host:

- Open XQuartz.
- Open Preferences ("XQuartz" > "Settings..." from the menu or `⌘,`).
- Go to the "Security" tab.
- Check the "Allow connections from network clients" checkbox.
- Log out and back in or restart your machine for the change to take effect.

![XQuartz Preferences dialog](resources/xquartz-settings.png)

##### Windows

> **Note:** This is experimental and officially unsupported. Members of the community who use Windows may be able to provide unofficial support. See [Support \& community](#support--community). Be sure to thank them. They're giving up their personal time to help you.

Install [VcXsrv Windows X Server](https://sourceforge.net/projects/vcxsrv) in the default "C:/Program Files" location.
You might need to restart your system afterwards.

##### Linux

> **Note:** This is experimental and officially unsupported. Members of the community who use Linux may be able to provide unofficial support. See [Support \& community](#support--community). Be sure to thank them. They're giving up their personal time to help you.

This configuration depends on what type of desktop environment you are using,
and the X server session it uses.

To know if you are using x11 or wayland, run:

```shell
echo $XDG_SESSION_TYPE
```

First, create a docker-compose file at .ddev:

```shell
touch .ddev/docker-compose.xb-cypress.yml
```

Edit the docker-compose file adding the configuration depending on your XDG session type:

**If you use X11**

```yaml
services:
  web:
    environment:
      - DISPLAY=:0
    volumes:
      - /tmp/.X11-unix:/tmp/.X11-unix
```

**If you use Wayland**

```yaml
services:
  web:
    environment:
      - WAYLAND_DISPLAY=$WAYLAND_DISPLAY
      - XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR
      - DISPLAY=$DISPLAY
      - XAUTHORITY=/tmp/.Xauthority
    volumes:
      - $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/tmp/wayland-0
      - /tmp/.X11-unix:/tmp/.X11-unix
      - /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket
      - ${XAUTHORITY:-$HOME/.Xauthority}:/tmp/.Xauthority
```

After adding the configuration, restart DDEV:

```shell
ddev restart
```

#### Running Cypress tests

Run Cypress tests interactively:

```shell
ddev cypress open
```

Run them headlessly:

```shell
ddev cypress run
```

Run component/unit tests:

```shell
ddev cypress component
```

## Support & community

- [Drupal Canvas](https://www.drupal.org/project/canvas) module
- [#experience-builder](https://drupal.slack.com/archives/C072JMEPUS1) Drupal Slack channel
- Background on this add-on: [DDEV support for Cypress tests [#3458369] | Drupal.org](https://www.drupal.org/project/canvas/issues/3458369)

## FAQ & known issues

### Can I use Cypress on Windows or Linux?

Windows and Linux are not officially supported, however, some people have reported it working on Windows + WSL2. See [Windows setup](#windows), and Linux. By all means, see [Support & community](#support--community) to share your experience so we can improve these docs.

### What if Cypress fails to start?

If you get an error like the below when attempting to run Cypress on macOS...

- Confirm that you have carefully followed _all_ the instructions under [Cypress](#cypress).
- See if your [Docker provider](#docker-provider) above requires any special configuration.

If these don't resolve the issue, see [Support & community](#support--community) above.

```
Cypress failed to start.

This may be due to a missing library or dependency. https://on.cypress.io/required-dependencies

Please refer to the error below for more details.

----------

[2536:0808/191430.352014:ERROR:bus.cc(407)] Failed to connect to the bus: Failed to connect to socket /run/dbus/system_bus_socket: No such file or directory
[2536:0808/191431.055343:ERROR:ozone_platform_x11.cc(240)] Missing X server or $DISPLAY
[2536:0808/191431.055373:ERROR:env.cc(255)] The platform failed to initialize.  Exiting.

----------

Platform: linux-arm64 (Debian - 12)
Cypress Version: 13.12.0
Failed to execute command node_modules/.bin/cypress open --browser electron --project .: exit status 1
Failed to run xb-cypress-open ; error=exit status 1
```

### What if I get an HTTPS error?

If this is your first time using DDEV, you may get an error like the following when you try to visit your site. If so, you need to configure your OS and browser to trust the root certificate authority that DDEV uses. See [DDEV Installation](https://ddev.readthedocs.io/en/stable/users/install/ddev-installation/).

```
This site can't be reached

The webpage at https://xb-dev.ddev.site/ might be temporarily down or it may have moved permanently to a new web address.

ERR_SSL_UNRECOGNIZED_NAME_ALERT
```
