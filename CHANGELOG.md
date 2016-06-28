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
