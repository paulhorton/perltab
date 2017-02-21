#!/usr/bin/perl -w
#  Author: Paul Horton
#  Organization: Computational Biology Research Center, AIST, Japan
#  Copyright (C) 2011, Paul Horton, All rights reserved.
#  Creation Date: 2011.1.8
#  Last Modification: $Date: 2013/10/20 09:09:37 $
#
#  regression tester for perltab.
#
use strict;
use feature qw(say);
use Hash::Util qw(lock_hash lock_keys);
use List::MoreUtils qw(any);
use Time::HiRes;

sub max{   $_[0] > $_[1]?  $_[0]  :  $_[1]   }

$ENV{LANG}= 'C';  #Some test output may contain locale dependent warnings.

my $usage=  "Usage: $0 [-atq] [num [num]]\n";


my %optSpec=(  a=>'abortOnErrorP',
               n=>'justPrintP',
               t=>'timeP',
               q=>'quietP');
lock_hash %optSpec;

my %opt=  map {$_=>undef}  values %optSpec;
lock_keys %opt;


#  ──────────  Declarations of ARGV related global variables.  ──────────
my @testNum;     #To hold test numbers in regression directory.
my $begTestNum;  #Begin testing with test number $begTestNum.
my $endTestNum;  #  End testing with test number $endTestNum.


{#  ──────────  Parse @ARGV  ──────────
    while(  @ARGV  &&  $ARGV[0]=~ s/^-//  ){
        my $arg=    join'',   sort  split'',  shift;
        if   (   $arg eq 'aqt'   ){
            unshift @ARGV, '-a', '-q', '-t';
        }
        elsif(   any  {$_ eq $arg}  qw(aq at qt)   ){
            unshift @ARGV,  map {"-$_"}  split '', $arg;
        }
        elsif(   exists $optSpec{$arg}   ){
            $opt{ $optSpec{$arg} }=  't';
        }
        else{
            die  "Unexpected command line option '$ARGV[0]'\n$usage\n";
        }
    }

    $begTestNum= shift @ARGV   //   last;
    $begTestNum =~ /^(\d+)$/    or   die $usage;
    ($begTestNum < 1000)   or   die  'maximum one-liner number is 999, but got "$begTestNum"';

    $endTestNum= shift @ARGV   //   $begTestNum;
    $endTestNum =~ /^(\d+)$/    or   die $usage;
    ($endTestNum < 1000)   or   die  'maximum one-liner number is 999, but got "$endTestNum"';

    lock_hash %opt;  undef @ARGV;
}#  ──────────  Parse @ARGV   ──────────



opendir  my $regressDir, 't/regression'   or
    die  "Could not open directory 't/regression'.\n"  .  (-d '../t/regression'? "Try running in parent directory.\n" : '');

    
@testNum=  sort  grep {/^\d\d\d$/}  readdir $regressDir;

@testNum   or   die  "no tests in directory '$regressDir'";

$begTestNum  //=  $testNum[0];
$endTestNum  //=  $testNum[-1];

$begTestNum >= $testNum[0]   or   die  "no test found for test number $begTestNum";


my %command;
my %expectedOutput;
my %title;

#  ──────────  Read in expected outputs  ──────────
for  my $testNum  (@testNum){
    my $path=  "t/regression/$testNum";
    -e $path   or   die  "File '$path' does not exist";
    -f $path   or   die  "Expected '$path' to be a plain file, but it is not";
    open  my $command_output_file, $path   or   die  "could not open file '$path'";

    my @line=  <$command_output_file>;
    chomp  for @line;

    @line > 3   or   die  "testNum:$testNum; expected at least 4 lines in file '$path', but only found ".@line;

    length $line[0]   or   die  "testNum:$testNum expected a non-empty title line";
    $title{$testNum}=  shift @line;

    shift @line   while $line[0]=~  /^[#] /x;
    @line  or  die   "Could not find 'perltab' line for test number '$testNum'";

    $line[0]=~ /^perltab/   or   die  "In file $path, expected command starting with 'perltab', but got '$line[0]'";
    $command{$testNum}=  shift @line;

    $expectedOutput{$testNum}=  \@line;  #Makes copy.
}

my $numTests=  my $numPassed=  0;
my $timeBefore=  Time::HiRes::time;

#  ──────────  Run scripts and compare output with expected  ──────────
for my $num(  $begTestNum..$endTestNum  ){
    my $numString=  sprintf '%03u', $num;
    my $command=  $command{$numString}   or    next;                 #LOOP FLOW

    if(  $opt{justPrintP}  ){
        say "$numString  $command";   next;                          #LOOP FLOW
    }

    my $testFailureMsg=  '';
    my @expectedOutput=  @{ $expectedOutput{$numString} };

    chomp(   my @actualOutput= `./$command 2>&1`   );

    #Check if actual output matches expected output and if not tell user where the first difference is.
    my $maxFin=  max $#expectedOutput, $#actualOutput;

    for my $i(  0..$maxFin  ){
        die  'actual output has no line #',    1+$i, "\nCommand $num was expecting: '$expectedOutput[$i]'."
            if  $i > $#actualOutput;
        die  'actual output has extra line #', 1+$i, ", '$actualOutput[$i]'."
            if  $i > $#expectedOutput;
        if(   $actualOutput[$i] ne $expectedOutput[$i]  ){
            $testFailureMsg=  "At line #$i; actual output below:\n$actualOutput[$i]\n$expectedOutput[$i]\nDid not match expected output above.";
            last;
        }
    }

    if(  $opt{quietP}  ){
        ++$numTests;
        if(  $testFailureMsg  ){
            say  "$num not ok";
            say  "#  $testFailureMsg";
            die  'aborting...'    if $opt{abortOnErrorP};}
        else{
            ++$numPassed;
            next;
        }
    }
    $command =~ s/^perltab --test/perltab/;
    printf(  "%s %d - %-40s\t%s\n",   ($testFailureMsg? 'not ok' : 'ok'),
             $num,  $title{$numString},  $command   );
    say    "#  $testFailureMsg\n#"                            if $testFailureMsg;
    die  'aborting...'                 if $opt{abortOnErrorP} && $testFailureMsg;
}# for (begTestNum..endTestNum)


printf  "#Total run time: %5.2fs\n",  Time::HiRes::time - $timeBefore   if $opt{timeP};
say     "$numPassed/$numTests tests passed"                             if $opt{quietP};
