# VSCode2Go

VSCode2Go is an enhanced implementation of [code-server](https://github.com/cdr/code-server/) that allows you to easily launch VS Code in a browser with pre-installed extensions, custom fonts, user settings, Git, and a custom domain with HTTPS configured using an nginx reverse proxy and Let's Encrypt.

Essentially, it's a low-fuss option for running VS Code on a remote server and accessing it in browser (e.g. when coding on an iPad Pro, etc.), but in a way that allows you to emulate your typical desktop VS Code set-up as closely as you'd like to.

## Installation

**Assumptions for local installation:**

- You have [Docker for Mac](https://docs.docker.com/docker-for-mac/install/) or [Docker for Windows](https://docs.docker.com/docker-for-windows/install/) installed on your system

**Assumptions for remote installation:**

- You have a basic Linux server up and running (I have tested this on [Ubuntu 18.04 with Digital Ocean](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-18-04))
- Your remote computing environment has at least 2GB of memory available (so you'll need at least a \$10 droplet on Digital Ocean)
- You have [Docker](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04#step-1-%E2%80%94-installing-docker) on your server installed
- You have [Docker Compose](https://www.digitalocean.com/community/tutorials/how-to-install-docker-compose-on-ubuntu-18-04#step-1-%E2%80%94-installing-docker-compose) installed on your server

Once you've decided whether you want to run VSCode2Go locally or remotely and you have installed all of the prerequisite dependencies, then you can clone this repo somewhere sensible on your system:

```bash
$ git clone https://github.com/mandiwise/vscode2go.git
```

## Set-up

There are a few configuration steps to follow, but you should be up-and-running with VSCode2Go in about 10 minutes.

The production version of VSCode2Go is meant to be used with a custom domain (Let's Encrypt will not work with IP addresses), so first, you need to configure an A record for that domain to point to your server's IP address.

And if you've configured a firewall with [UFW](https://help.ubuntu.com/community/UFW) you'll need to make sure you open up ports 80 and 443 too:

```bash
$ sudo ufw allow proto tcp from any to any port 80,443
```

Next, you'll need to configure a few things so that VS Code launches exactly as you like it. These instructions apply for both local/development and remote/production installations, with exceptions noted.

### Add an `.env` file (required)

First, create a `.env` file in the root of the repo and add these variables with appropriate values:

```
DOMAIN=mydomain.com
GIT_EMAIL=bob@email.com
GIT_NAME=Bob Smith
PASSWORD=someHARDpwd789!
```

_Important! Do not wrap your string variables in quotes._

Note that if you are only running VSCode2Go locally, you do not need to add the `DOMAIN` or `PASSWORD` variables.

### Add fonts (optional)

Add any fonts you'd like to use in your editor into the `config/fonts` directory. You can organize font files into sub-directories inside the `fonts` directory if you prefer.

### Add an Extensionsfile (optional)

If you want to pre-install extensions in VS Code before it launches, add an `Extensionsfile` to the `config` directory and list each of the extensions by their unique identifiers on separate lines. For example:

```
2gua.rainbow-brackets
dustinsanders.an-old-hope-theme-vscode
esbenp.prettier-vscode
ionutvmi.path-autocomplete
PKief.material-icon-theme
```

Creating an `Extensionsfile` is also a great way to install extensions directly from the official VS Code Marketplace, rather than from the [custom marketplace](https://github.com/cdr/code-server#extensions) supported out-of-the-box by code-server.

To get a list of the extensions you currently have installed in your desktop VS Code app, simply run `code --list-extensions` on that computer and copy/paste into your `Extensionsfile`.

### Add user settings (required)

You must create a `settings.json` file.

At a minimum add an empty `{}` into this file, even if you don't want any other user settings specified. Otherwise, your `settings.json` file may look something like this:

```json
{
  "editor.fontFamily": "'Operator Mono', 'Courier New', monospace",
  "editor.fontSize": 12,
  "editor.tabSize": 2,
  "workbench.colorTheme": "An Old Hope",
  "workbench.iconTheme": "material-icon-theme",
  "editor.formatOnPaste": true,
  "editor.formatOnType": false
}
```

### Configure TLS (required for remote set-up only)

This repo comes with a bash script to automatically request certificates from Let's Encrypt. Run the following commands from the root of this repo, and pass in appropriate arguments:

```bash
$ chmod +x scripts/init-letsencrypt.sh
$ ./scripts/init-letsencrypt.sh mydomain.com bob@email.com
```

This script will take a few moments to run because it will have to create your `nginx` container (and it's `codeserver` container dependency) in order for the certificate validation to work in the `certbot` container.

## Usage

You're now ready to `docker-compose up`! To start the project in production mode, run:

`$ PROJECT_DIR="../myapp" docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d`

This command assumes that you have a `myapp` directory at the same level in your filesystem as your `vscode2go` repo, and you want to open that project directory in VSCode2Go for editing.

To start the project locally, run:

```bash
$ PROJECT_DIR="../myapp" docker-compose up -d
```

Please note that if you are running VSCode2Go locally (with the above command) the `no-auth` option is configured with code-server for convenience sake. **Do not do this on remote server!**

When you want to open up a new project, simply run:

```bash
$ docker container stop certbot codeserver nginx
$ PROJECT_DIR="../myapp2" docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

Happy coding! 🚀

## References

These repos were helpful reference points while creating VSCode2Go:

- [jmahc/codeserver](https://github.com/jmahc/codeserver)
- [monostream/code-server](https://github.com/monostream/code-server/blob/develop/Dockerfile)
- [wmnnd/nginx-certbot](https://github.com/wmnnd/nginx-certbot) (and the [related blog post](https://medium.com/@pentacent/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71))

## License

[MIT](https://github.com/cdr/code-server/blob/master/LICENSE)
