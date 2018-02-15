# macaliaser

macaliaser - script to create aliases for applications on OSX / MacOS

# FEATURES

- generation of aliases MacOS applications for shell use
- black listing og applications for alias generation

# SYNOPSIS

    # Generate aliases in /Applications directory
    $ macaliaser -i /Applications

    # Generate aliases in /Applications directory and Applications directory in users home directory
    $ macaliaser -i /Applications $HOME/Applications

    # help message
    $ macaliaser -h

    # Serialize the generated aliases to a file in you home directory
    $ macaliaser -i /Applications > ~/.aliases

# DESCRIPTION

This script create aliases from all the applications in the directories you scan.

The recommended usage is to put the aliases in a separate file and use
the from you preferred shell.

I have the following line in my `.bash_profile`

    source "$HOME/.aliases"

So the script can proces the file with out conflicting with other `bash`
settings, apart from the `.bash_profile` change, I have added the
following line to my `crontab`

    0 12 * * 1 $HOME/bin/macaliaser -i /Applications/ \
    $HOME/Applications/ > $HOME/.aliases

### Black Listing

You can enable black listing of applications by adding a file named:
`blacklist` to `$HOME/.config/macaliaser/blacklist` like this example:

    /Users/jonasbn/Applications/Chrome Apps.localized/Default \
    pjkljhegncpnkpknbcohdijeoejaedia.app

Do note that the spaces are not escaped.

## OPTIONS

- -i (index)

    This indexes the directories listed after `--` or provided as arguments to `-i`

- -v (verbosity)

    This outputs informative messages to `STDERR` so you can filter it from the generated
    data, which is printed to `STDOUT`

# FUNCTIONS

## is\_app

This checks whether a file has a name in the format:

    «name».app

Do note that names can contain spaces and this is handled.

If this is true it processes the entry further SEE **suggest**.

## suggest

**suggest** suggest different aliases for your applications, each
suggestion is tested for existance by **is\_cmd**, which relies on [File::Which](https://metacpan.org/pod/File::Which),
so we do not overrule any existing commands (like `mail`).

The tries are done in the following order:

1. lowercase, name without .app extension, example: `imovie`
2. lowercase, name with .app extension, example: `mailapp`
3. uppercased first letter with .app extension
4. the original name

## cmd\_exist

**cmd\_exists** check whether there already is a command with the
suggested alias in path.

This uses [File::Which](https://metacpan.org/pod/File::Which)'s `which` subroutine, which works like the shell command &lt;which>

## create\_alias

**create\_alias** is used to create the actual alias, based on the suggestions
from **suggest**.

Alias are actually just strings in the form of:

    alias somealias="open -a /some/path/to/an/app"

# REFERENCES

- [MetaCPAN: File::Which](https://metacpan.org/pod/File::Which)
- [MacOS man page: open command](https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man1/open.1.html)
- [MacOS man page: bash, contains information on alias command](https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man1/bash.1.html)

# ISSUE REPORTING

# AUTHOR

- jonasbn <jonasbn@cpan.org>

# DEVELOPMENT

If you want to contribute to `macaliaser` please read the [Contribution guidelines](https://github.com/jonasbn/macaliaser/blob/master/CONTRIBUTING.md)
and follow [the pull request guidelines](https://github.com/jonasbn/macaliaser/blob/master/.github/PULL_TEMPLATE.md).

# COPYRIGHT

macaliaser is (C) 2004-2018 Jonas B. Nielsen (jonasbn)
<jonasbn@cpan.org>

Image used on \[website\](https://jonasbn.github.io/macaliaser/) is under copyright by \[Anthony Garand\]((https://unsplash.com/photos/5sT07dJl65s)

# LICENSE

macaliaser is free software and is released under the Artistic
License 2.0.
