# 1.0.0 (open source release \o/)

- NO CHANGES

# 0.11.0

- Allow writing a point with a custom timestamp

# 0.10.3

- Cast boolean values for influx configs

# 0.10.2

- Cast numeric values for influx configs

# 0.10.1

- Fix periodic gauge base plugin

# 0.10.0

- Create a periodic gauge base plugin
- Switch built-in plugins inheritance from Base to PeriodicGauge
  - Now it's easier to test the plugins
- Remove `Metrux::Plugins::Base`
- Change notice error command to save error message as a field to avoid big
  indexes

# 0.9.0

- Remove the need of having a config file, it can be configured only with env
  vars
  - Add fallback of non existant config file to return an empty hash
- Change `Configuration` setup
- Change influx db configuration defaults
- Allow to force setting STDOUT through env var or config file
- Remove the need of having `config/metrux.yml` to run the test suite

# 0.8.0

- Change built-in plugins
  - Each plugin will register only one gauge with all info
  - Change its measurement key

# 0.7.0

**We encourage that you use this version or higher to avoid big database indexes
issues**

- Remove `uniq` tag on writing
  - To ensure that we can write "duplicate" points, we are switching the tag
    `uniq` with the timestamp in nanoseconds because it was increasing the
    indexes of all databases, letting them very slow.

# 0.6.3

- Remove i18n issues due to `String#parameterize`

# 0.6.2

- Setup metrux's configuration lazily
- Fix async specs

# 0.6.1

- Fix test issues

# 0.6.0

- Remove spaces and non-ascii chars from prefix

# 0.5.0

- Fix prefix fetching on base command
- Add puma worker number on program name

# 0.4.1

- Add logging on plugin registering

# 0.4.0

- Add `env` tag on writing
- Add `app_name` prefix on measurement key
- Remove prefix option from plugins

# 0.3.0

- Add `program_name` tag on writing
- Create built-in plugins
  - `Metrux::Plugins::Trhead`
  - `Metrux::Plugins::Gc`
  - `Metrux::Plugins::Process`
  - `Metrux::Plugins::Yarv`
- Create a plugin register

# 0.2.0

- Load and parse configuration file with ERB templating

# 0.1.0

- First release
  - Write command
  - Gauge command
  - Timer command
  - Meter command
  - Notice error command
  - Periodic gauge command
