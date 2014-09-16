#!/usr/bin/perl -w
####################################################
#
# Perl source file for project deltadays 
# Purpose:
# Method:
#
#<one line to give the program's name and a brief idea of what it does.>
#    Copyright (C) 2013  Andrew Nisbet
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301, USA.
#
# Author:  Andrew Nisbet, Edmonton Public Library
# Created: Tue Sep 16 08:48:25 MDT 2014
# Rev: 
#          0.2 - Used printf instead of sprintf. 
#          0.1 - Initial release. 
#          0.0 - Dev. 
#
####################################################

use strict;
use warnings;
use vars qw/ %opt /;
use Getopt::Std;
use Time::Local;

my $VERSION         = qq{0.2};
my $SECONDS_PER_DAY = 60 * 60 * 24;
#
# Message about this program and how to use it.
#
sub usage()
{
    print STDERR << "EOF";

	usage: $0 [-xda<ANSI>] [-b<ANSI>]
Returns the number of days between the two argument dates. If only one date is provided the alternate 
date is assumed to be today. Order of the dates is not important, but warning about future dates. 
The order of the dates is imaterial by way of 'abs(date_two - date_one)' which
will provide '1' as a result if you asked how many days ago was tomorrow or $0 -a[tomorrow].

 -a: First date (required).
 -b: Second date (optional).
 -d: Debug messages printed to STDERR.
 -x: This (help) message.

example: $0 -x
example: $0 20140513 20140621
  Computes the number of days between May 13, 2014 and June 21, 2014.
example: $0 20270101
  produces a negative date that is the number of days from today to January 1, 2027.
Version: $VERSION
EOF
    exit;
}

# Kicks off the setting of various switches.
# param:  
# return: 
sub init
{
    my $opt_string = 'a:b:dx';
    getopts( "$opt_string", \%opt ) or usage();
    usage() if ( $opt{'x'} );
	if ( ! defined $opt{'a'} )
	{
		print STDERR "**Error: you must provide at least one date in YYYYMMDD format.\n";
		usage();
	}
}

# Parses various date strings into Unix epoch values which are 
# the number of seconds since January 01 1970.
# param:  date string, may include hours minutes or seconds.
# return: -1 if the date passed could not be parsed and the 
#         seconds since epoch otherwise.
sub parseDate
{ 
	my( $s ) = @_;
	my( $year, $month, $day, $hour, $minute, $second );
	$hour   = "0";
	$minute = "0";
	$second = "0";
	# if( $s =~ m{^\s*(\d{1,4})\W*0*(\d{1,2})\W*0*(\d{1,2})\W*0*
		 # (\d{0,2})\W*0*(\d{0,2})\W*0*(\d{0,2})}x) 
	if( $s =~ m/^\s*(\d{1,4})(\d{1,2})(\d{1,2})/)
	{
		$year = $1;  $month = $2;   $day = $3;
		$year = ($year<100 ? ($year<70 ? 2000+$year : 1900+$year) : $year);
		return timelocal($second,$minute,$hour,$day,$month-1,$year);  
	}
	print STDERR "**Error: invalid date format.\n";
	usage();
	return -1;
}

init();

my ( $firstDate, $secondDate );

if ( $opt{'b'} )
{
	$secondDate = $opt{'b'};
}
else
{
	chomp( $secondDate = `date +%Y%m%d` );
}
$secondDate = parseDate( $secondDate );

if ( defined $opt{'a'} )
{
	$firstDate = parseDate( $opt{'a'} );
}

print "first date: $firstDate      second date: $secondDate\n" if ( $opt{'d'} );
printf( "%.0f\n", abs( $secondDate - $firstDate ) / $SECONDS_PER_DAY );

# EOF
