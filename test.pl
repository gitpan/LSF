# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..7\n"; }
END {print "not ok 1\n" unless $loaded;}
use LSF PRINT => 1;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

use strict;

my $group = LSF::JobGroup->new('test');
$group->delete();

$group->add() ? print "ok 2\n" : print "not ok 2\n";

$group->hold() ? print "ok 3\n" : print "not ok 3\n";

my $job = LSF::Job->submit(-J=>"/$group/test1",'sleep 1');
$job ? print "ok 4\n" : print "not ok 4\n";

my $job2 = LSF::Job->submit(-w=>"done($job)",'echo hello world');
$job ? print "ok 4\n" : print "not ok 4\n";

if( $job2->delete(-n=>1) ){ # isn't a repetitive job, just has a dependancy
    print "ok 5\n"; 
}else{
    print "not ok 5\n";
}

$group->release() ? print "ok 6\n" : print "not ok 6\n";

print "this last test may be long running...\n";
while(1){
        my $info = $job2->info();
        last if  $info->{Status} =~ /(Done)|(Exit)/i;
        sleep 5;
}
print "ok 7\n";
