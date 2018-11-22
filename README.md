# Running the playbook

This playbook is designed to be [idempotent](https://hq.apnscp.com/using-ansible-to-validate-your-server/). It can be run multiple times without changing the state of an already modified system. You can use this to quickly pinpoint irregularities within the system or 🤞unbreak your server🤞 if things degrade to that.

The playbook must always be run as root. It can be located under `/usr/local/apnscp/resources/playbooks`. 

```bash
ansible-playbook bootstrap.yml
```

[![asciicast](https://asciinema.org/a/196963.png)](https://asciinema.org/a/196963)

## Viewing changes

To view only tasks that have changed, specify `actionable` as your callback plugin either in [ansible.cfg](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#ansible-configuration-settings-locations) or `ANSIBLE_STDOUT_CALLBACK`. It's easy from the command-line:

```bash
env ANSIBLE_STDOUT_CALLBACK=actionable ansible-playbook bootstrap.yml
```

## Saving config changes

Bootstrapper will override defaults from /root/apnscp-vars.yml. Copy apnscp-vars.yml from resources/playbooks/ and make changes to that file to permanently override settings.
```bash
cd /usr/local/apnscp/resources/playbooks
cp apnscp-vars.yml /root
# Make change to /root/apnscp-vars.yml
env ANSIBLE_STDOUT_CALLBACK=actionable ansible-playbook bootstrap.yml
```

Alternatively, if installed using [Bootstrapper](https://github.com/apisnetworks/apnscp-bootstrapper), you'll have an option to copy this configuration over.

## Recommended configuration changes

Bootstrapper can run without any changes to `apnscp-vars.yml`. The following changes are recommended to make setup seamless:

- **apnscp_admin_email**: (email address) used to set besthe admin contact. Also notified when apnscp is installed (FQDN required). This email address is used as your Let's Encrypt admin contact.
- **ssl_hostnames**: (list or string) hostnames that resolve to this server that should be considered for Let's Encrypt SSL issuance. 
  - Examples: 
    - ['apnscp.com','hq.apnscp.com','nexus.apnscp.com'] 
    - apnscp.com

### Optional settings

- **has_low_memory**: (true/false) disables auxiliary services for 2 GB instances. See [low-memory mode](#user-content-low-memory-mode) below.
- **user_daemons**: (true/false) opens up ports 40000-49999/tcp + udp on the server for accounts that want to run a service. If you're running strictly PHP/Node/Python/Ruby services, turn this off for added security.
- **mail_enabled**: (true/false) if using GMail or a third-party email provider disables IMAP/POP3 + ESMTPA. Mail can still originate from the server (PHP [mail()](http://php.net/manual/en/function.mail.php)), but blocks ingress.
- **passenger_enabled**: (true/false) disable building Passenger + accompanying Ruby/Python interpreters if running a purely PHP mix. Node/npm/yarn is still available, but can't serve websites.
- **mysqld_per_account_innodb**: (true/false) places tables + data in an aggregate InnoDB pool for higher performance or per account for resource enforcement. An account over quota can cause a cyclic crash in MySQL/MariaDB 5.0+ on recovery. **You have been warned**. Ensure [Argos](https://hq.apnscp.com/monitoring-with-monit-argos/) is setup if enabled.
- **data_center_mode**: (true/false) ensure all resources that apnscp can account for are accounted. Also enables the pernicious bastard `mysqld_per_account_innodb`!

### Setting FQDN for SSL/Email

All servers should have a fully-qualified domain name ([FQDN](https://en.wikipedia.org/wiki/Fully_qualified_domain_name)). Failure to have one will cause email to fail, including the installation notice. Moreover, Let's Encrypt will fail issuance. A FQDN must at least contain 1 dot:

- ✅ apnscp.com
- ✅ cdn.bootstrap.org
- ✅ x.y.z.abc.co.uk
- ❌ centos-s-1vcpu-2gb-nyc1-01 (no period/dot)

Set your hostname with,

```bash
hostnamectl set-hostname MYHOSTNAME
```

Where *MYHOSTNAME* is your hostname for the machine. For consistency reasons, it is required that this hostname resolves to the IP address of the machine and vice-versa with [FCrDNS](https://en.wikipedia.org/wiki/Forward-confirmed_reverse_DNS). Check with your DNS provider to establish this relationship.

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

## Low-memory mode
Low-memory mode scrubs non-essential services. It combines headless mode with a single job worker (disables Laravel Horizon) and removes vscanner, 
which is a combination of mod_security + ClamAV to scrub uploads. This frees up ~700 MB of memory, perfect for smaller 2 GB instances.
```bash
env ANSIBLE_STDOUT_CALLBACK=actionable ansible-playbook bootstrap.yml  --extra-vars='has_low_memory=true' --extra-vars='panel_headless=true'
```

# Running tasks within apnscp
Bootstrapper provides an interface to run these tasks within apnscp. Change digests
are sent to the control panel owner (`cpcmd common_set_email x@y.com`).

*Bootstrapper::run(...tasks, array args)*

**Example:** open up port 3000 in the firewall,
```php
Opcenter\Admin\Bootstrapper::run('network/setup-firewall', ['rules' => [['port' => '3000/tcp', 'state' => 'disabled']]]);
```
Runtime configuration may be updated using Opcenter\Admin\Bootstrapper\Config,
```php
$config = new Opcenter\Admin\Bootstrapper\Config();
$config['panel_headless'] = true;
unset($config);
Opcenter\Admin\Bootstrapper::run('apnscp/bootstrap', 'network/setup-firewall', 'software/argos');
```
Variables are set in `/root/apnscp-vars-runtime.yml`, which takes precedence over `/root/apnscp-vars.yml`.

# Contributing

apnscp Playbooks are released under the [MIT License](LICENSE). Feel free to use and contribute.



# Further resources

- [Validating your hosting platform with Ansible](https://hq.apnscp.com/using-ansible-to-validate-your-server/) (hq.apnscp.com)
