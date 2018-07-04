# Running the playbook

This playbook is designed to be idempotent. It can be run multiple times without changing the state of an already modified system. You can use this to quickly pinpoint irregularities within the system or 🤞unbreak your server🤞 if things degrade to that.

The playbook must always be run as root. It can be located under `/usr/local/apnscp/resources/playbooks`. 

```bash
ansible-playbook bootstrap.yml
```

## Viewing changes

To view only tasks that have changed, specify `actionable` as your callback plugin either in [ansible.cfg](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#ansible-configuration-settings-locations) or `ANSIBLE_STDOUT_CALLBACK`. It's easy from the command-line:

```bash
env ANSIBLE_STDOUT_CALLBACK=actionable ansible-playbook bootstrap.yml
```

# Playbook examples

The following examples cover tweaking installation from apnscp's [Bootstrapper](https://github.com/apisnetworks/apnscp-bootstrapper), `bootstrap.yml`.

A second master playbook, `migration.yml`, is used internally to update a server to apnscp's mainline release. These playbooks are run automatically whenever apnscp updates itself and should not be used.

## Rebuild PHP for apnscp

apnscp uses a separate PHP distribution. It may be rebuilt to a specific version by passing `php_version` 

```shell
ansible-playbook --tags=apnscp/build-php --extra-vars 'php_version=7.1.18' bootstrap.yml
```

## Build new PHP for server

Similar to building a PHP distribution for apnscp, the primary PHP interpreter may be rebuilt. Additional configure-time flags are passed via `extra_flags`. The patch level may be omitted to build the best available version for that given release, e.g. "7.2" will build "7.2.9" assuming 7.2.9 is the maximal release of 7.2.

```shell
ansible-playbook --tags=php/install --extra-vars 'php_version=7.2 extra_flags="--with-recode --with-pcre-jit"' bootstrap.yml
```

## Installing PECL modules

apnscp supports installing PECL modules from pecl.php.net, archives, and GitHub. As with building PHP, `extra_flags` is a supported option to pass additional configure-time flags.

```shell
ansible-playbook --tags=php/install-pecl-module --extra-vars 'pecl_extensions="igbinary"' bootstrap.yml
```

A list may also be used,

```shell
ansible-playbook --tags=php/install-pecl-module --extra-vars 'pecl_extensions=["mailparse","https://github.com/php-memcached-dev/php-memcached.git","https://pecl.php.net/get/inotify-2.0.0.tgz"]' bootstrap.yml
```

apnscp will attempt to install the module if it does not already exist. To overwrite or update a module, supply `force=1` to `--extra-vars`:

```shell
ansible-playbook --tags=php/install-pecl-module --extra-vars 'pecl_extensions=https://pecl.php.net/get/inotify-2.0.0.tgz' --extra-vars 'force=1' bootstrap.yml 
```

## Updating fail2ban whitelist

apnscp will whitelist the connected IP address when initially provisioned. If your IP address changes, run `fail2ban/whitelist-self` to whitelist the presently connected SSH IP address. Further, if you accidentally block yourself with repeated invalid logins and apnscp is run behind a [reverse proxy](https://github.com/apisnetworks/cp-proxy), it is possible to unblock yourself within the control panel by opening a JavaScript console as admin and running `apnscp.cmd("rampart_unban","your-ip-address", {async: false});`. `rampart_unban` is the low-level API command; it is also accessible from [Beacon](https://github.com/apisnetworks/beacon).

```shell
ansible-playbook --tags=fail2ban/whitelist-self bootstrap.yml
```

## Toggling headless mode

apnscp can run in headless mode, that is to say without a front-end UI. This can further save on memory requirements and keep your site secure.

```bash
ansible-playbook bootstrap.yml  --tags=network/setup-firewall,apnscp/bootstrap --extra-vars="panel_headless=true"
```

You'll be limited to using the [CLI helpers](http://docs.apnscp.com/admin/managing-accounts/#command-line-interface) - `cpcmd`, `AddDomain`, `EditDomain`, `DeleteDomain` in headless mode. Fear not though! Anything that can be done through the panel can be done from CLI as the [API](http://api.apnscp.com/namespace-none.html) is 100% reflected.

# Contributing

apnscp Playbooks are released under the [MIT License](LICENSE). Feel free to use and contribute.
