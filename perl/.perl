#!/usr/bin/env perl
 
use strict;
use warnings;
 
use Encode qw( decode );
use Getopt::Long;
use LWP::UserAgent;
use URI;
use URI::QueryParam;
 
my $license_key = 'YOUR_LICENSE_KEY';
my $ip_address  = '24.24.24.24';
 
GetOptions(
    'license:s' => \$license_key,
    'ip:s'      => \$ip_address,
);
 
my $uri = URI->new('https://minfraud.maxmind.com/app/ipauth_http');
$uri->query_param( l => $license_key );
$uri->query_param( i => $ip_address );
 
my $ua = LWP::UserAgent->new( timeout => 5 );
my $response = $ua->get($uri);
 
die 'Request failed with status ' . $response->code()
    unless $response->is_success();
 
my %proxy = map { split /=/, $_ } split /;/, $response->content();
 
if ( defined $proxy{err} && length $proxy{err} ) {
    die "MaxMind returned an error code for the request: $proxy{err}\n";
}
else {
    print "\nMaxMind Proxy data for $ip_address\n\n";
    for my $field ( sort keys %proxy ) {
        print sprintf( "  %-20s  %s\n", $field, $proxy{$field} );
    }
    print "\n";
}
