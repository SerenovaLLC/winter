# Winter

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'winter'

And then execute:

    $ bundle

To make running this easier, add this to your `~/.bash_profile`
```bash
# bundle exec stuff
function be {
  CUR=$PWD
  LAST=
  until [ "$CUR" == "$LAST" ]; do
    if [ -e "$CUR/Gemfile" ]; then
      bundle exec "$@"
      return
    fi
    LAST=$CUR
    CUR=$(dirname $CUR)
  done
  "$@"
}
alias winter='be winter'
```


Or install it yourself as:

    $ gem install winter

## Usage

```bash
$ winter
Commands:
  winter build <manifest>       # Build a service from a manifest (optional)
  winter help [COMMAND]         # Describe available commands or one specific...
  winter list                   # List available services
  winter start [service]        # Start the named service
  winter status                 # Show status of available services
  winter stop [service]         # Stop the named service
  winter validate <Winterfile>  # (optional) Check the configuration files
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
