# perltab -- Manipulate data in tabular form from the command line in a perl one-liner style.


## Getting started
`% perltab -h`

## Running regression tests
`% perl t/perltabCommandsOutputMatchExpected.t`


## Summary
perltab could be thought of as an extension to perl autosplit mode for handling tabular data.  I developed perltab while working with a bioinformatics dataset that had quite a few features (columns), many of them had missing values, which made the data inconvenient to directly handle with something like perl autosplit mode.  With perl autosplit mode it is easy to output the nth column.

`% perl -F'\t' -anE 'say $F[1]'   heightWeight.tsv`

perltab makes this slightly easier:<BR>
`% perltab -e 'say $F[1]'  heightWeight.tsv`

But it also allows for using named columns (and allows for abbreviation).<BR>
`% perltab -e 'say F(hei)'  heightWeight.tsv`

This is convenient, but when numerical computation and missing values come to play perltab is particularly helpful.

For example the minimum value of a column can be output in this way:<BR>
`% perltab -d 'bemin $m, F(hei)' -z 'say $m'`<BR>
where the script following the -d option is run on all input lines EXCEPT the initial header line holding the colum names, and the -z option script is run once at the end.

or, as long as the column labels do not look like numbers, this will also work:<BR>
`% perltab -e 'bemin $m, F(hei)' -z 'say $m'`


To do that on the command line without perltab is quite difficult without a *LOT* of typing, mostly because non-numerical values must be silently skipped but also because $m needs to be initialized properly (for example zero won't work if negative values are present in the data).  perltab defines several reasonably mnenmonic functions to handle issues like that transparently.


The perltab documention `% perltab -h` has close to 50 examples of using perltab and all of these are represented in the regression test suite.


### Caveats.
Runs on a linux box under Perl v5.18.2, v5.28.1.  Untested elsewhere.


### Examples

* Output columns 'height' and 'weight'.<BR>
`% perltab -e 'say F(qw(height weight))'  heightWeight.tsv`

* Or more succinctly by letting perltab add the qw for you (see -h qw).<BR>
`% perltab -e 'say F(height weight)'  heightWeight.tsv`

* Or even more succinctly,<BR>
`% perltab -e 'say F(hei wei)'  heightWeight.tsv`

* Any unique prefix of the desired column labels will work (see -h label).  Here we assume no other headers starts with 'h' or 'w'.<BR>
`% perltab -e 'say F(h w)'`

* Swap first and final field.<BR>
`% perltab -pe 'swap 0, -1'  input.tsv`

* Swapping columns can also be done (more efficiently) by directly accessing @F.<BR>
`% perltab -e 'say  @F[-1, 1..$#F-1, 0]'  input.tsv`

* Swap fields labeled 'height' and 'weight'.<BR>
`% perltab -pe 'swap qw(height weight)'  heightWeight.tsv`

* Swapping columns by label can also be done (more efficiently) by using N() to access @F directly.<BR>
`% perltab -pe '@I= N(height weight); @F[@I]= @F[reverse @I]'  heightWeight.tsv`

* Move column 'ID' to directly after column 'weight'.<BR>
`% perltab -pe 'movaft qw(weight ID)'  heightWeight.tsv`

* Manually move column 'ID' to directly after column 'weight', assuming column ID comes before column weight in the input.<BR>
`% perltab -e '($x,$y)= N(ID weight);  say @F[0..$x-1,$x+1..$y,$x,$y+1..$#F]'   heightWeight.tsv`

* Delete columns starting in 'c', 'd' or 'e'.<BR>
`% perltab -pe 'del grep /^[cde]/, @H'  animals.tsv`

* Echo input file, skipping data lines with any missing (empty string) values.<BR>
`% perltab -e 'speak @F'  heightWeight.tsv`

* Output BMI (Body Mass Index) from rows in which both height and weight have values.<BR>
`% perltab -e '@V= nextNum F(height weight);  say 10000*$V[1]/$V[0]**2'   heightWeight.tsv`

* Add BMI (Body Mass Index) column to table in heightWeight.tsv, skipping missing (empty string) values.<BR>
`% perltab -pe 'insAft "weight", "BMI"=>doNum{10000*$_[1]/$_**2} F(height weight)'  heightWeight.tsv`

* Reformat numbers in field 'BMI'.<BR>
`% perltab -pe 'reform "%.2f", F(BMI)'  heightWeightBMI.tsv`

* Extract data fields 1,2 for rows in which both have a numerical value.<BR>
`% perltab -d 'donum {say @_} @F[1,2]'  heightWeight.tsv`

* Display column labels with their numbers.<BR>
`% perltab -H 'say $_,$H[$_] for 0..$#H' input.tsv`

* Remove column named 'height'.<BR>
`% perltab -pe 'del "height"' heightWeight.tsv`

* or,<BR>
`% perltab -e 'say F( grep {!/^height$/} @H )' heightWeight.tsv `

* Select rows from heightWeight.tsv matching ids listed in file 'ids.txt' (holding one id per line).<BR>
`% perltab -b 'SNset %S, "ids.txt"'  -ge '$S{ F(ID)}'  heightWeight.tsv   > selected.tsv`

* After selecting those rows, sort them so that the ids are in the same order as in "/tmp/ids".<BR>
`% perltab -b 'SNset %S, "ids.txt"' -s '$S{ F(ID) }' selected.tsv`

* Print minimum value of column 'banana', quietly ignoring non-numerical values.<BR>
`% perltab -e 'bemin $m, F(banana)' -z 'say $m'`

* Linearly normalize numbers in column 'banana' to be in range [0,1].<BR>
`% perltab -p -e 'beminmax $min, $max, F(banana)'   -e2 'donum  sub{ $_= ($_-$min) / ($max-$min)}, F(banana)'   fruit.tsv`

* Print column labels containing 'eight'.<BR>
`% perltab  -H 'say  grep /eight/, @H'`

* Remove any data columns with non-numerical entries.<BR>
`% perltab -gd 'allnum @F'`

* Average all columns in a file (Non-numeric data treated as 0).<BR>
`% perltab  -d '$s[$_]+= num0 $F[$_] for 0..$#F'  -z 'say map {$_/(NR-1)} @s'`

* Sort heightWeight.tsv so that IDs found in file age.tsv come first, in the same order as they appear in age.tsv.<BR>
`% perltab -e '$R{ F(ID)}= NR'  -s201U '$R{ F(ID)}'   age.tsv  -in2 heightWeight.tsv`

* Same as above but with the block of common ids at the end.<BR>
`% perltab -e '$R{ F(ID)}= NR'  -s2U01 '$R{ F(ID)}'   age.tsv  -in2 heightWeight.tsv`

* Same as above but sorted in place, i.e. sort the common IDs to mirror their order in age.tsv, but do not move them as a block to the top or bottom.<BR>
`% perltab -e '$R{ F(ID)}= NR' -s201 '$R{ F(ID)}'  age.tsv  -in2 heightWeight.tsv`

* or one can use the default sort spec 'AB01NM'<BR>
`% perltab -e '$R{ F(ID)}= NR'  -s2 '$R{ F(ID)}'  age.tsv -in2 heightWeight.tsv`

* Add a Japanese Heisei fiscal year column 'FY', with entries like "H27" to a file with YYYYMMDD format column 'Date'.<BR>
`% perltab -pe 'insaft qw(Date FY), sub{ ($y,$m)= unpack "a4a2", F(Date);  "H". (($m>3)+ $y-1989)}   YYYYMMDD.tsv`

* Transpose rows and columns.  'chop' removes trailing tab characters.<BR>
`% perltab -e '$T[$_] .= "$F[$_]\t" for 0..$#F'   -z 'chop, say  for @T'  input.tsv`

* Prepend row number column to each row.<BR>
`% perltab -e 'say NR,@F'  input.tsv`

* Lexically sort rows by label, except for the first.  Comment lines are also output by -p.<BR>
`% perltab -pe '@F= F($H[0], sort @H[1..$#H])'  fruit.tsv`

* Similar to the above, but skipping comment lines.<BR>
`% perltab -e 'say F($H[0], sort @H[1..$#H])'  fruit.tsv`

* Output the rows with the maximum height value among rows in two files.<BR>
`% perltab -d 'bemax $m, F(hei)' -gd2 'donum {$m==$_} F(hei)'  heightWeight.tsv more_heightWeight.tsv
          -in2 heightWeight.tsv more_heightWeight.tsv`

* or if there are no missing values, more simply:<BR>
`% perltab -d 'bemax $m, F(hei)' -gd2 '$m==F(hei)'  heightWeight.tsv more_heightWeight.tsv  -in2 heightWeight.tsv more_heightWeight.tsv`


### See Also
fastapl


### Author
Paul Horton.  Copyright 2016,2017.
