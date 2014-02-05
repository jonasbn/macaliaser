#!/usr/bin/perl -w

# $Id: macaliaser.pl 1303 2004-05-12 18:21:02Z jonasbn $

use strict;
use Getopt::Std;
use File::Which qw(which);
use File::Find qw(find);
use vars qw(%opts $VERSION);

$VERSION = '0.01';

getopts('hvil:', \%opts);

my %aliases;
my $verbose = 0;

$verbose = 1 if $opts{v};

if ($opts{h} or not (keys %opts)) {
	&help();
}

if ($opts{i}) {
	my @directories_to_search = @ARGV;
	find(\&is_app, @directories_to_search);
} elsif ($opts{l}) {
	open(FIN, "<$opts{l}")
		or die ("Unable to open file: $opts{l} - $!");
	while (<FIN>) {
        if (m[^alias (\w+).*/(.*\.app)'$]) {
                print "$1 -> $2\n";
        }
    }
	close(FIN);
}

exit(0);

sub help {
	print STDERR "Usage: $0 [options]\n";
	print STDERR "\toptions:\n";
	print STDERR "\t-h : this help message\n";
	print STDERR "\t-i <path> : the path to search for applications\n";
	print STDERR "\t-l <aliases file> : the file which contains your aliases\n";
	print STDERR "\tthe option prints a simple report, showing existing aliases\n";

	exit(0);
}

sub is_app {
		 
	if (m/^(.*\.app)$/) {		
		my $app = $1;
		
		print STDERR "located: $app\n" if $verbose;

		my $try = 0;
		for(1 .. 3) {
			my $alias = &suggest($app, $try++);
			if (&cmd_exists($alias)) {
				next;
			} else {
				&create_alias($alias, $File::Find::name, \%aliases);
				last;
			}
		}
	}
}

sub suggest {
	my ($name, $try) = @_;

	if ($try == 0) {
		$name =~ tr/[A-Z]/[a-z]/;  #lower casing
		$name =~ s/^(.*)\.app$/$1/; #extracting short name
		                           #trying shortname
	} elsif ($try == 1) {
		$name =~ tr/[A-Z]/[a-z]/;  #lower casing
							       #trying fullname
	} elsif ($try == 1) {
		$name = ucfirst($name);    #upper casing 1st letter
								   #trying with 1st letter uc
	} else {
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
	my ($alias, $app, $list) = @_;

	print STDERR "Creating alias $alias\n" if $verbose;
	
	$app =~ s/( )/\\$1/g;
	$app =~ s/(')/\\$1/g;
		
	$list->{$alias} = $app;

	print "alias $alias=\"open -a $app\"\n";
	
	return 1;
}

__END__

=head1 NAME

macaliaser.pl - a script to create aliases for applications on OS X

=head1 SYNOPSIS

	% macaliaser.pl -i /Applications

	% macaliaser.pl -i /Applications /Developer

	% macaliaser.pl -h

	% macaliaser.pl -i /Applications > ~/.aliases

	% macaliaser.pl -l ~/.aliases
	
	% macaliaser.pl -l ~/.aliases | grep Mail.app

=head1 DESCRIPTION

I have tried several of the OS X applications, which are supposed to
speed up access to your applications and I must admin I prefer to use
the terminal.app to everything. So this script creates aliases from all
the application in the directories you ask it to scan.

The recommended usage is to put the aliases in a separate file and use
the from you preferred shell.

I have the following line in my .bash_profile

	source "$HOME/.aliases"

So the script can proces the file with out disturbing my other bash
settings, apart from the .bach_profile change, I have added the
following line to my crontab

	0 12 * * 1 $HOME/bin/macaliaser.pl -i /Applications/ \
	/Developer/Applications/ > $HOME/.aliases

Further more I have created a single alias in my .bash_profile for 

	macaliaser.pl -l ~/.aliases
	
In the following way:

	alias aliases = 'macaliaser.pl -l ~/.aliases'

=head2 OPTIONS

=over 4

=item -i (index)

This indexes the directories listed after --

=item -l (list)

This lists the existing aliases

Useful when you have forgotten a specific alias

=back

=head1 FUNCTIONS

=head2 is_app

This checks whether a file has a name in the format:

<name>.app

If this is true it processes the entry further SEE B<suggest>.

=head2 suggest

B<suggest> suggest different aliases for you application, each
suggestion is tested for existance by B<is_cmd>, so we do not overrule
any existing commands (like mail).

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

=head2 create_alias - not yet implemented

B<create_alias> is used to create the actual alias.

=head1 TODO

=over 4

=item *

Need to be able to migrate the aliases so they can be used from bash.

=back

=head1 AUTHOR

jonasbn E<lt>jonasbn@cpan.orgE<gt>

=head1 COPYRIGHT

macaliaser.pl is free software and is released under the Artistic
License. See <http://www.perl.com/lan- guage/misc/Artistic.html> for
details.

macaliaser.pl is (C) 2004 Jonas B. Nielsen (jonasbn)
E<lt>jonasbn@cpan.orgE<gt>

=cut
