package LSF; $VERSION = 0.3;

use IPC::Run qw( run );

sub BEGIN {
    my ($out,$err);
    run ['lsid','-V'],\undef,\$out,\$err;
    if($?){
        $@ = $err;
        die $@; # there should be no error at this point. Can we even call the executable?
    }else{
        die "Cannot determine LSF version" unless $err =~ /^LSF ([^,]+)/m;
        $LSF::LSF_VERSION = $1;
    }
}

# sugar to preload all the LSF modules
sub import {
    shift;
    my %params = @_;
    my @modules = qw(Job JobInfo JobGroup Queue JobManager);
    my @code = map { my $code = "use LSF::$_";
                     exists $params{PRINT} ? $code .= " PRINT => $params{PRINT};\n"
                                           : $code .= ";\n"
                    } @modules;
    eval join( '', @code );
    die $@ if $@;
}

sub version { $LSF::LSF_VERSION }

# A method within each subclass to control whether LSF output/error is printed.
sub print {
    my $self = shift;
    my $class = ref($self) || $self;
    my $varname = $class . '::PRINT';
    no strict 'refs';
    $$varname = shift if @_;
    return $$varname;
}

# calls a  LSF command. This is the form that we use when we don't care about
# the output of the command. Just whether or not it actually worked.
# The usual format is the command name, followed by parameters passed through
# to it and then the LSF job id as the last parameter
sub do_it {
    my $self = shift;
    my(@cmd) = @_;
    my ($out,$err);
    run \@cmd,\undef,\$out,\$err;
    if($?){
        $@ = $err;
        warn $@ if $self->print;
    }else{
        if($out){ print $out if $self->print; }
        else{     print $err if $self->print; }
    }
    $? ? 0 : 1;
}

1;

__END__

=head1 NAME

LSF - load various LSF modules

=head1 SYNOPSIS

    use LSF;
    use LSF PRINT => 1;

=head1 DESCRIPTION

C<LSF> provides a simple mechanism to load some of the LSF modules at one time.
Currently this includes:

      LSF::Job
      LSF::JobInfo
      LSF::JobGroup
      LSF::Queue
      LSF::JobManager

Turning on or off the printing of LSF command line output can be controlled
globally via the 'PRINT' directive to the LSF module. Otherwise it can be set 
individually in each of the LSF modules by using its 'PRINT' directive or by 
calling its 'print' class method

For more information on any of these modules, please see its respective
documentation.

NOTE: FOR THESE MODULES TO WORK IT IS ESSENTIAL THAT YOU INCLUDE THE LSF 
COMMANDS IN YOUR PATH.

=head1 HISTORY

The LSF::Batch module on cpan didn't compile easily on all platforms i wanted.
The LSF API didn't seem very perlish either. As a quick fix I knocked these
modules together which wrap the LSF command line interface. It was enough for
my simple usage. Hopefully they work in a much more perly manner.

=head1 AUTHOR

Mark Southern (mark_southern@merck.com)

=head1 COPYRIGHT

Copyright (c) 2002, Merck & Co. Inc. All Rights Reserved.
This module is free software. It may be used, redistributed
and/or modified under the terms of the Perl Artistic License
(see http://www.perl.com/perl/misc/Artistic.html)

=cut
