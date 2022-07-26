#!/usr/bin/env perl
# Description: Test reliability of open web proxies
#
# (c) 2020 Alexandr Savca, alexandr dot savca89 at gmail dot com

use strict;
use warnings;
use diagnostics;
use autodie;
use threads; no warnings 'threads';

use File::Basename;
use List::Util 'shuffle';
use Getopt::Long;
use HTTP::Tiny;

sub proxychk;
sub getmyip;

my $program = basename $0;
my $version = '0.1';
my $help    = <<"EOH";
$program - test reliability of open web proxies
usage: $program [options] STDIN

Options:
  -h, --help                  Show this help message and exit.
  -v, --version               Show version and exit.
  -u, --user-agent  STR|FILE  Set UA as user-agent.
  -t, --threads     NUMBER    Set NUMBER of connection threads.
  -W, --show-white            Show white proxies. Default is 0.
  -G, --show-gray   0|1       Show gray  proxies. Default is 1.
  -O, --show-other  0|1       Show proxies, whose IP addresses are
                              different from the proxy IP when
                              connecting. Default is 0.
  -B, --show-bad    0|1       Show proxies whose response is not 200.
                              Default is 0.

Examples:
  wget -qO- http://spys.me/proxy.txt | grep_ipaddr_port.sh > proxies.txt
  $program < proxies.txt | grep_ipaddr_port.sh

See also:
  http://www.google.com/search?q=+\":8080\" +\":3128\" +\":80\" filetype:txt
EOH

my @PROXIES;
my @THREADS;
my @UAS;
my $myIP;

# default options
my %OPTS = (
    ua               =>  'curl/7.37.0',
    threads          =>  10,
    showGray         =>  1,
    showWhite        =>  0,
    showOther        =>  0,
    showBad          =>  0,
);

GetOptions(
    'h|help!'        =>  \$OPTS{help},
    'v|version!'     =>  \$OPTS{version},
    'u|user-agent=s' =>  \$OPTS{ua},
    't|threads=i'    =>  \$OPTS{threads},
    'W|show-white=i' =>  \$OPTS{showWhite},
    'G|show-gray=i'  =>  \$OPTS{showGray},
    'O|show-other=i' =>  \$OPTS{showOther},
    'B|show-bad=i'   =>  \$OPTS{showBad},
);

print "$help\n"    and exit if $OPTS{help};
print "$version\n" and exit if $OPTS{version};

&getmyip;

if (-f $OPTS{ua}) {
    print "Found wordlist at $OPTS{ua}...\n";
    open(my $fh, $OPTS{ua});
    while (<$fh>) {
        chomp;
        push @UAS, $_;
    }
    close $fh;
} else {
    push @UAS, $OPTS{ua};
}

my $counter = 0;
while (<STDIN>) {
    chomp;
    if (++$counter == $OPTS{threads}) {
        # start threads
        $_->join() for @THREADS;

        # wait running threads done
        $_->is_running() && sleep 1 for @THREADS;

        $counter = 0;
        @THREADS = ();
    } else {
        push @THREADS, threads->create('proxychk', $_);
    }
}

print STDERR "Finishing remaining threads...\n";
$_->join() for @THREADS;
$_->is_running() && sleep(1) for @THREADS;

sub proxychk {
    my $proxy       = shift;
    my $proxyIP     = (split /:/, $proxy)[0];
    my $ua          = shuffle @UAS;

    my $http = HTTP::Tiny->new(agent    => $ua,
                               proxy    => "http://$proxy/",
                               timeout  => 6);

    my $r = $http->get('https://ipecho.net/plain');

    if ($r->{status} != 200) {
        print "$proxy $r->{status} -> bad\n" if $OPTS{showBad};
        return;
    }

    if ($r->{content} eq $myIP) {
        print "$proxy $r->{status} -> myip\n"
            if $OPTS{showWhite};
    } elsif ($r->{content} eq $proxyIP) {
        print "$proxy $r->{status} -> grey\n"
            if $OPTS{showGray};
    } else {
        print "$proxy $r->{status} -> $r->{content}\n"
            if $OPTS{showOther};
    }
}

sub getmyip {
    my $r = HTTP::Tiny->new->get('http://ipecho.net/plain');
    die "Fail to get wan ip address.\n" unless $r->{status} == 200;
    $myIP = $r->{content};
}

# vim:sw=4:ts=4:sts=4:et:tw=71:cc=72
# End of file.
