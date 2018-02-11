# NAME

macaliaser.pl - a script to create aliases for applications on OSX / MacOS

# SYNOPSIS

    # Generate aliases in /Applications directory
    $ macaliaser.pl -i /Applications

    # Generate aliases in /Applications directory and Applications directory in users home directory
    $ macaliaser.pl -i /Applications $HOME/Applications

    # help
    $ macaliaser.pl -h

    # Serialize the generated aliases to a file in you home directory
    $ macaliaser.pl -i /Applications > ~/.aliases

    # List know aliases in aliases file
    $ cat ~/.aliases

    # List know aliases in aliases file and find Mail.app alias
    $ cat ~/.aliases | grep Mail.app

# DESCRIPTION

This script creates aliases from all the application in the directories you ask it to scan.

The recommended usage is to put the aliases in a separate file and use
the from you preferred shell.

I have the following line in my `.bash_profile`

    source "$HOME/.aliases"

So the script can proces the file with out disturbing my other bash
settings, apart from the `.bash_profile` change, I have added the
following line to my `crontab`

    0 12 * * 1 $HOME/bin/macaliaser.pl -i /Applications/ \
    /Developer/Applications/ > $HOME/.aliases

## OPTIONS

- -i (index)

    This indexes the directories listed after `--` or provided as argument

- -v (verbosity)

    This outputs informative messages to `STDERR`

# FUNCTIONS

## is\_app

This checks whether a file has a name in the format:

&lt;name>.app

If this is true it processes the entry further SEE **suggest**.

## suggest

**suggest** suggest different aliases for you application, each
suggestion is tested for existance by **is\_cmd**, so we do not overrule
any existing commands (like `mail`).

The tries are done in the following order:

1. lowercase, name without .app extension
2. lowercase, name with .app extension
3. uppercased first letter with .app extension
4. the original name

## cmd\_exist

**cmd\_exists** check whether there already is a command with the
suggested alias in path.

## create\_alias

**create\_alias** is used to create the actual alias.

# AUTHOR

- jonasbn <jonasbn@cpan.org>

# COPYRIGHT

macaliaser.pl is (C) 2004-2018 Jonas B. Nielsen (jonasbn)
<jonasbn@cpan.org>

# LICENSE

macaliaser.pl is free software and is released under the Artistic
License 2.0.
