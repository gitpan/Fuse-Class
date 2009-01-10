#
# Fuse::Class
#
# For implementation using class.
#

package Fuse::Class;

use warnings;
use strict;

=head1 NAME

Fuse::Class - Base clsas for Fuse module implementation using class.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Fuse::Class is just a abstract class. First, you must write subclass
overriding methods like named 'getattr'. (callbacks defined in Fuse)

Subclass will be written like following:

    package SampleFS;

    use base qw(Fuse::Class);

    sub getattr {
        my $self = shift; # instance or class is passed as first argment.
        my ($fname) = @_; # same as Fuse.
    
        ...

        return @attr; # same as Fuse.
    }
        ...

To mount your filesystem:

   use SampleFS;

   my $fuse = SampleFS->new("your", "parameters", "here");
   $fuse->main(mountpoint => '/mnt/sample', mountopts => "allow_other");


=head1 DESCRIPTION

This module supports writing Fuse callback as method.
Method name is same as Fuse callback, but first argment is object.

This is a small change for Fuse, but you can use power of OO like
inheritance, encapsulation, ...

Exception handling:

Return value will be treated as errno in Fuse way, but you can use
exception, too.
If exception is thrown in your method (die is called), $! will be used
as errno to notify error to Fuse. 


=head1 EXPORT

Nothing.

=head1 FUNCTIONS

=cut

use Fuse;
use Errno;

# instance calling main
use vars qw($_Module);

my @callback;

=head2 main

Same as defined in Fuse::main.

=cut

sub main {
    my $class = shift;
    my %attr = @_;

    my @args;
    for my $opt (qw(debug mountpoint mountopts)) {
	push(@args, $opt, $attr{$opt}) if (defined($attr{$opt}));
    }

    local $_Module = $class;

    Fuse::main(@args,
	       map {$_ => __PACKAGE__ . "::_$_"} @callback);
}

BEGIN {
    @callback = qw (getattr readlink getdir mknod mkdir unlink
		    rmdir symlink rename link chmod chown truncate
		    utime open read write statfs flush release fsync
		    setxattr getxattr listxattr removexattr);

    no strict "refs";
    for my $m (@callback) {
	my $method = __PACKAGE__ . "::_$m";

	*$method = sub {
	    my $method_name = $m;

	    if ($_Module->can($method_name)) {
		my @ret = eval {
		    $_Module->$m(@_);
		};
		if ($@) {
		  return $! ? -$! : -Errno::EPERM();
		}
		else {
		  return (wantarray() ? @ret : $ret[0]);
		}
	    }
	    else {
		return -Errno::EPERM();
	    }
	}
    }
}


=head2 new

Create a new instance.

=cut

#
# for your convenience.
#
sub new {
    my $class = shift;
    bless {}, $class;
}

=head2 getattr

Same as Fuse.

=head2 readlink

Same as Fuse. By Default implementation, returns -ENOENT.
You can leave this method if your FS does not have symlink.

=cut

sub readlink {
    return -Errno::ENOENT();
}

=head2 getdir

Same as Fuse.

=head2 mknod

Same as Fuse.

=head2 mkdir

Same as Fuse.

=head2 unlink

Same as Fuse.

=head2 rmdir

Same as Fuse.

=head2 symlink

Same as Fuse.

=head2 rename

Same as Fuse.

=head2 statfs

Same as Fuse. By default implementation, returns -ENOANO.
You can leave this method if your FS does not have statfs.

=cut

sub statfs {
    return -Errno::ENOANO();
}


=head2 flush

Same as Fuse. By default implementation, returns 0.
You can leave this method if your FS does not have flush.

=cut

sub flush {
    return 0;
}

=head2 release

Same as Fuse. By default implementation, returns 0.
You can leave this method if your FS does not need anything when releaing.

=cut

sub release {
    return 0;
}

=head2 fsync

Same as Fuse. By default implementation, returns 0.
You can leave this method if your FS does not have fsync.

=cut

sub fsync {
    return 0;
}

=head2 getxattr

Same as Fuse. By default implementation, returns 0.
You can leave this method if your FS does not have any extended attrs.

=cut

sub getxattr {
    return 0;
}

=head2 listxattr

Same as Fuse. By default implementation, returns 0.
You can leave this method if your FS does not have any extended attrs.

=cut

sub listxattr {
    return 0;
}

=head2 removexattr

Same as Fuse. By default implementation, returns 0.
You can leave this method if your FS does not have any extended attrs.

=cut

sub removexattr {
    return 0;
}

=head2 setxattr

Same as Fuse. By default implementation, returns -ENOATTR.
You can leave this method if your FS does not have any extended attrs.

=cut

sub setxattr {
    return -Errno::EOPNOTSUPP();
}


=head1 AUTHOR

Toshimitsu FUJIWARA, C<< <tttfjw at gmail.com> >>

=head1 BUGS

Threading is not tested.

=head1 COPYRIGHT & LICENSE

Copyright 2008 Toshimitsu FUJIWARA, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 SEE ALSO

Fuse

=cut

1; # End of xxx
