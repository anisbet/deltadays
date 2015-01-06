#!/usr/bin/perl -w
#######################################################################
#
# Perl source file for project deltadays 
# Purpose:
# Method:
#
# Returns the number of days between the two argument dates.
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
#          0.5 - Add new switch to give ANSII date 'n' days in future based on -a date. 
#          0.4 - Added warning about '-a' usage. 
#          0.3 - Fixed incorrect usage() information about switches. 
#          0.2 - Used printf instead of sprintf. 
#          0.1 - Initial release. 
#          0.0 - Dev. 
#
########################################################################

use strict;
use warnings;
use vars qw/ %opt /;
use Getopt::Std;
use Time::Local;
use POSIX qw(strftime);

my $VERSION         = qq{0.5};
my $SECONDS_PER_DAY = 60 * 60 * 24;
my $PAST_FUTURE     = "future";
my $PF_DAYS_COUNT   = 0; # The number of days in the past or future if -D selected.
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
 -D<+/-n>: Reports the date 'n' days from now (+), or in the past (-) in ANSI format (yyyyMMdd).
 -b: Second date (optional).
 -d: Debug messages printed to STDERR.
 -x: This (help) message.

example: $0 -x
example: $0 -a 20140513 -b 20140621
  Computes the number of days between May 13, 2014 and June 21, 2014.
example: $0 -a"20270101"
  produces a negative date that is the number of days from today to January 1, 2027.
example: $0 -a"20141231" -D+26
  prints the date 26 days in the future from 20141231.
Version: $VERSION
EOF
    exit;
}

# Kicks off the setting of various switches.
# param:  
# return: 
sub init
{
    my $opt_string = 'a:b:dD:x';
    getopts( "$opt_string", \%opt ) or usage();
    usage() if ( $opt{'x'} );
	if ( ! defined $opt{'a'} )
	{
		print STDERR "**Error: you must provide a start date with '-a' in YYYYMMDD format.\n";
		usage();
	}
	if ( $opt{'D'} )
	{
		if ( $opt{'D'} =~ m/^\-/ )
		{
			# Days can come in form of days from now (+) or days past (-), so lets check if properly prefixed.
			$PAST_FUTURE = 'past';
			$PF_DAYS_COUNT = $';
			print STDERR "'-D' set to past " if ( $opt{'d'} );
		}
		elsif ( $opt{'D'} =~ m/^\+/ )
		{
			# Days can come in form of days from now (+) or days past (-), so lets check if properly prefixed.
			$PAST_FUTURE = 'future';
			$PF_DAYS_COUNT = $';
			print STDERR "'-D' set to future " if ( $opt{'d'} );
		}
		else
		{
			print STDERR "**Error: -D requires '+' for future date, or '-' for days in past.\n";
			usage();
		}
		if ( $PF_DAYS_COUNT !~ m/\d{1,}/ )
		{
			print STDERR "**Error: you must provide an integer number of days with '-D'.\n";
			usage();
		}
		print STDERR " := $PF_DAYS_COUNT.\n" if ( $opt{'d'} );
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
}

init();

my ( $firstDate, $secondDate );

if ( $opt{'D'} )
{
	$firstDate  = parseDate( $opt{'a'} );
	if ( $PAST_FUTURE eq 'future' )
	{
		$secondDate = $firstDate + $PF_DAYS_COUNT * $SECONDS_PER_DAY;
	}
	else
	{
		$secondDate = $firstDate - $PF_DAYS_COUNT * $SECONDS_PER_DAY;
	}
	print strftime( "%Y%m%d", localtime( $secondDate ) ) . "\n";
	exit;
}

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
