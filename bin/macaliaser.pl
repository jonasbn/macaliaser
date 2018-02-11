#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Std;
use File::Which qw(which);
use File::Find qw(find);
use vars qw(%opts $VERSION);
use Env qw($HOME);

$VERSION = '0.02';

getopts( 'hvi', \%opts );

my %aliases;
my $blacklist;
my $verbose = 0;

$verbose = 1 if $opts{v};

if ( $opts{h} or not( keys %opts ) ) {
    &help();
}

if ( $opts{i} ) {
    my @directories_to_search = @ARGV;

    $blacklist = init_blacklist();

    find( \&is_app, @directories_to_search );
}

exit(0);

sub help {
    print STDERR "Usage: $0 [options]\n";
    print STDERR "\toptions:\n";
    print STDERR "\t-h : this help message\n";
    print STDERR "\t-v : verbose output to STDERR\n";
    print STDERR "\t-i <path> : the path to search for applications\n";

    exit(0);
}

sub init_blacklist {
    my @blacklist = ();

    my $blacklist_path = "$HOME/.config/macaliaser/blacklist";

    if (-e $blacklist_path) {
        open (BLACKLIST, '<', $blacklist_path);
        while (<BLACKLIST>) {
            chomp;
            push @blacklist, $_;
        }
        close BLACKLIST;
    }

    return \@blacklist;
}

sub is_blacklisted {
    my $path = shift;

    if (grep /^$path$/, @{$blacklist}) {
        return 1;
    } else {
        return 0;
    }
}

sub is_app {

    if (m/^(.*\.app)$/) {
        my $app = $1;

        print STDERR "located: $app\n" if $verbose;

        if (is_blacklisted($File::Find::name)) {
            print STDERR "ignored: $app (blacklisted)\n" if $verbose;
            return;
        }

        my $try = 0;
        for ( 1 .. 3 ) {
            my $alias = &suggest( $app, $try++ );
            if ( &cmd_exists($alias) ) {
                next;
            }
            else {
                &create_alias( $alias, $File::Find::name, \%aliases );
                last;
            }
        }
    }
}

sub suggest {
    my ( $name, $try ) = @_;

    if ( $try == 0 ) {
        $name =~ tr/[A-Z]/[a-z]/;      #lower casing
        $name =~ s/^(.*)\.app$/$1/;    #extracting short name
                                       #trying shortname
    }
    elsif ( $try == 1 ) {
        $name =~ tr/[A-Z]/[a-z]/;      #lower casing
                                       #trying fullname
    }
    elsif ( $try == 1 ) {
        $name = ucfirst($name);        #upper casing 1st letter
                                       #trying with 1st letter uc
    }
    else {
        #nothing to do (yet)       #trying with original name
    }
    $name =~ s/\W+//g;

    print STDERR "suggesting $name ($try)\n" if $verbose;

    return $name;
}

sub cmd_exists {
    my $suggestion = shift;

    my $rv = which($suggestion);

    return $rv;
}

sub create_alias {
    my ( $alias, $app, $list ) = @_;

    print STDERR "Creating alias $alias\n" if $verbose;

    $app =~ s/( )/\\$1/g;
    $app =~ s/(')/\\$1/g;

    $list->{$alias} = $app;

    print "alias $alias=\"open -a $app\"\n";

    return 1;
}

__END__

=head1 NAME

macaliaser.pl - a script to create aliases for applications on OSX / MacOS

=head1 SYNOPSIS

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

=head1 DESCRIPTION

This script creates aliases from all the application in the directories you ask it to scan.

The recommended usage is to put the aliases in a separate file and use
the from you preferred shell.

I have the following line in my C<.bash_profile>

    source "$HOME/.aliases"

So the script can proces the file with out disturbing my other bash
settings, apart from the C<.bash_profile> change, I have added the
following line to my C<crontab>

    0 12 * * 1 $HOME/bin/macaliaser.pl -i /Applications/ \
    /Developer/Applications/ > $HOME/.aliases

=head2 OPTIONS

=over 4

=item -i (index)

This indexes the directories listed after C<--> or provided as argument

=item -v (verbosity)

This outputs informative messages to C<STDERR>

=back

=head1 FUNCTIONS

=head2 is_app

This checks whether a file has a name in the format:

<name>.app

If this is true it processes the entry further SEE B<suggest>.

=head2 suggest

B<suggest> suggest different aliases for you application, each
suggestion is tested for existance by B<is_cmd>, so we do not overrule
any existing commands (like C<mail>).

The tries are done in the following order:

=over 4

=item 1.

lowercase, name without .app extension

=item 2.

lowercase, name with .app extension

=item 3.

uppercased first letter with .app extension

=item 4.

the original name

=back

=head2 cmd_exist

B<cmd_exists> check whether there already is a command with the
suggested alias in path.

=head2 create_alias

B<create_alias> is used to create the actual alias.

=head1 AUTHOR

=over

=item jonasbn E<lt>jonasbn@cpan.orgE<gt>

=back

=head1 COPYRIGHT

macaliaser.pl is (C) 2004-2018 Jonas B. Nielsen (jonasbn)
E<lt>jonasbn@cpan.orgE<gt>

=head1 LICENSE

macaliaser.pl is free software and is released under the Artistic
License 2.0.

=cut
