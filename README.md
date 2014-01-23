# Winter

[![Gem Version](https://badge.fury.io/rb/winter.png)](http://badge.fury.io/rb/winter)

Winter is a system for maintaining the configuration of java web applications with a specific focus on the Felix OSGi container. Simply create a `Winterfile` and describe the configuration of your application with the Winter DSL. You can then use the `winter` CLI tool to `winter build` the application. This will download all the necessary dependencies for your application. When the build is complete, you can run it with `winter start`.

## Installation from Rubygems

    $ gem install winter

## Installation from source

    $ git clone git@github.com:liveops/winter.git && cd winter
    $ gem build winter.gemspec
    $ gem install winter*.gem

## Installation with bundler

Add this line to your application's Gemfile:

    gem 'winter'

And then execute:

    $ bundle install

    (If you use `rbenv`, this would be a good time for an `rbenv rehash`)

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

## Example

1. Create a 'Winterfile' in a new directory called 'sample'.

    $ mkdir sample && touch Winterfile

2. Describe your application with the DSL. Put this in the `Winterfile`:

    ```Ruby
    name "sample_app"
    lib 'org.apache.felix', 'org.apache.felix.shell',         '1.4.3'
    lib 'org.apache.felix', 'org.apache.felix.shell.remote',  '1.1.2'
    lib 'org.apache.felix', 'org.apache.felix.log',           '1.0.1'
    ```
    
3. Build the application to download all the dependencies.

    $ winter build
   
4. Run the sample application

    $ winter start

5. Check to see that the app is running

    $ winter status

6. Turn off the application

    $ winter stop

## CLI Usage

All commands that need a `Winterfile` will use the default filename 'Winterfile' by default. This can be overridden by specifying a different filename in its place e.g. `winter validate someOtherFilename`.

```bash
$ winter
Commands:
  winter build [Winterfile]                      # Build a service from a Win...
  winter fetch <URL|GROUP> [artifact] [version]  # Download the Winterfile an...
  winter help [COMMAND]                          # Describe available command...
  winter start [Winterfile]                      # Start the services in [Win...
  winter status                                  # Show status of available s...
  winter stop [Winterfile]                       # Stop the services in [Wint...
  winter validate [Winterfile]                   # (optional) Check the confi...
  winter version                                 # Display version information.

```

#### Build

Build a service from a Winterfile

    Usage:
      winter build [Winterfile]

    Options:
      [--group=GROUP]      # Config group
      [--verbose=VERBOSE]  # Verbose maven output
      [--debug=DEBUG]      # Set log level to debug.
      [--local=LOCAL]      # Resolve dependencies only from local repository

#### Fetch

    Download the Winterfile and configuration from a URL.

    Usage:
      winter fetch <URL|GROUP> [artifact] [version]

    Options:
          [--debug=DEBUG]                     # Set log level to debug.
      --repos, [--repositories=REPOSITORIES]  # Comma separated list of repositories to search.

#### Start

Start the services in [Winterfile] 

    Usage:
      winter start [Winterfile]

    Options:
      [--group=GROUP]         # Config group
      [--debug=DEBUG]         # Set log level to debug.
  --con, [--console=CONSOLE]  # Send console output to [file]
                              # Default: /dev/null

#### Status

Show status of available services

    Usage:
      winter status

#### Stop

Stop the services in [Winterfile]

    Usage:
      winter stop [Winterfile]

    Options:
      [--group=GROUP]  # Config group

#### Validate

Check the configuration files

    Usage:
      winter validate [Winterfile]

    Options:
      [--group=GROUP]  # Config group
      [--debug=DEBUG]  # Set log level to debug.

#### Version

Display version information.

    Usage:
      winter version


## Winterfile DSL

####bundle (group, artifact, [version], [{}])
  Specify an application bundle to deploy into the OSGi container. If `version` is not speicfied, it will default to `LATEST`. The 4th parameter is a block that can be used to specify the packaging type (defaults to 'jar'). For example, if the bundle is packaged as a war file, the block can read `{:package => 'war'}`. Bundles added the Winterfile will be downoaded and placed in the './run/{name}/bundles' directory (relative to the Winterfile) when `winter build` is performed.

####conf (directory)
  The contents of this directory tree is read and any file ending in '*.erb' is parsed as a template. The result of the template is placed in './run/{name}/conf' (relative to the Winterfile) and will overwrite any files that already exist there.

####directive (key, [value])
  Add a directive to the java invocation. `directive 'com.example.logger', 'true'` is translated to ` -D com.example.logger=true`.

####felix (group, artifact, [version])
  Specify the felix version to use. If none is specified, felix version 3.0.6 is added by default.

####group (Symbol)
  Multiple configuration groups may be specified in a Winterfile, and they may be nested. Any number of other commands may be placed in a group permitting changes in configuration, bundles, libraries and even Felix version changes. For Example:

```Ruby
info "This is the default group"
group :groupName do 
  info "This is inside the group groupName"
  group :nestedGroup do
    info "This is inside the group nestedName"
  end
end
```

The groups are then accessed from the command line as a comma separated list:
  $ winter validate --group=groupName,groupName::nestedGroup
    This is the default group
    This is inside the group groupName
    This is inside the group nestedGroup

####info (String)
  Print a statment to STDOUT as the DSL is parsed. Useful for debugging.

####lib (group, artifact, [version])
  Specify an application library or dependency. If `version` is not speicfied, it will default to `LATEST`. Libraries listed in the Winterfile will be downoaded and placed in the './run/{name}/libs' directory (relative to the Winterfile) when `winter build` is performed. This directory is added to the classpath at runtime.

####name (String)
  (*REQUIRED*) Give a name to this configuration group. This is used to describe a running instance when viewing `winter status` information, and allows a developer to create discrete configuration groups. The purpose of creating configuration groups is to allow for multiple containers to run on the same machine e.g. clustered applications.

####pom (file | url)
  The pom file is parsed and any dependencies listed as `<scope>provided</scope>` are added as application dependencies. When `winter build` is executed, these dependencies are downloaded and placed in './run/{name}/libs' relative to the Winterfile. A local file may be specified (relative to the Winterfile) or if a URL is specified it is fetched and parsed.

####read (file)
  The 'read' verb is used to import json configuration files relative to the Winterfile. The json structure is parsed and merged with the @config variable, overwriting existing values. Several 'read' directives may be specified in a single Winterfile. For example:

```Ruby
read 'conf/default.json'
group :dev do 
  read 'conf/dev_config.json'
end
```

####repository (directory | url)
  Add repositories to the maven search path when downloading bundles, libs and felix versions. Generally a URL is specified, but an ~/.m2 style directory will also work.
  (aliased as 'repo' for your convienience)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License and Copyright

Copyright 2013 LiveOps, Inc.

Right to Use this Documentation: This material is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0) License.  You may not exercise any rights in this material except under the terms of the CC BY-SA 3.0 License, a copy of which may be found at: 

     http://creativecommons.org/licenses/by-sa/3.0/

Right to Use the Software Referenced Herein: Unless otherwise provided for a specific file, the product(s) and files referenced herein are licensed under the Apache License, Version 2.0 (the "License"); you may not use such files except in compliance with the License.  You may obtain a copy of the License at:

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

