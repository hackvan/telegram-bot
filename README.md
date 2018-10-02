# Telegram Scrum Bot

A friendship Telegram's bot that connect a Repository on GitHub with a Scrum board on Trello.

## Setup

### From the Github Repository:
```bash
git clone https://github.com/hackvan/telegram-bot.git
```

For development you must be create the file `secrets.yml` inside the `config` directory and put the Telegram and Trello tokens information on this structure:

```yaml
telegram:
  token: 'TOKEN-INFO'
trello:
  key:   'KEY-INFO'
  token: 'TOKEN-INFO'
```

to start the bot's server application:

```bash
$ bundle install
$ bundle exec ruby lib/telegram-bot.rb
```

### From the [rubygems site](https://rubygems.org/gems/telegram-scrum-bot):

>https://rubygems.org/gems/telegram-scrum-bot

you must setup the required enviroment variables inside `.bashrc` or `.zshrc` depend of your terminal configuration:
```bash
# Enviroment variables from telegram-scrum-bot gem:
export API_TELEGRAM_TOKEN="TOKEN-INFO"
export API_TRELLO_KEY="KEY-INFO"
export API_TRELLO_TOKEN="TOKEN-INFO"
```

To install and execute the application:
```bash
$ gem install telegram-scrum-bot
$ telegram-scrum-bot
```

## Telegram Bot

* name: `scrum_hackathon_bot`
* username: `@scrum_hackathon_bot`
* url: [https://t.me/scrum_hackathon_bot](https://t.me/scrum_hackathon_bot)


**Telegram Bot Commands:**

Initial Commands:
```
/start - bienvenida
/setup - asistente de configuración del bot
/help  - ayuda con los comandos del bot
```

Configuration Commands:
```
/setgithubuser - establece la configuración del usuario de github
/setgithubrepository - establece la configuración del repositorio de github
```

```
/getgithubuser - obtiene la configuración del usuario de github
/getgithubrepository - obtiene la configuración del repositorio de github
```

Work Commands:
```
/issues - consultar el listado de Issues en el repositorio de Github
/trello - sincroniza los issues del repositorio en un tablero de Trello
```