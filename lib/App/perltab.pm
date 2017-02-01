package App::perltab;

=head1  SYNOPSIS

    Usage: perl -h       #Start here!
           
           perl -e 'SCRIPT'  InputFile.tsv



=head1  SUMMARY

perltab could be thought of as an extension to perl autosplit mode for handling tabular data.  I developed perltab while working with a bioinformatics dataset with quite a few features (columns), many with missing values, which made the data inconvenient to directly handle with something like perl autosplit mode.  With perl autosplit mode it is easy to output the nth column.

  % perl -F'\t' -anE 'say $F[1]   heightWeight.tsv

perltab makes this slightly easier:

  % perltab -e 'say $F[1]  heightWeight.tsv`

But it also allows for using named columns (and allows for abbreviation):

  % perltab -e 'say F(hei)'  heightWeight.tsv

This is convenient, but when numerical computation and missing values come to play perltab is particularly helpful.

For example the minimum value of a column can be output in this way:

  % perltab -d 'bemin $m, F(hei)' -z 'say $m'

or, as long as the column labels do not look like numbers, this will also work:

  % perltab -e 'bemin $m, F(hei)' -z 'say $m'

Many more examples are available with:

  % perl -h

Enjoy.


=head1  AUTHOR

The perltab program and this documentation was written by Paul Horton.


=head1  LICENSE

Copyright 2016,2017 Paul B. Horton <paulh@iscb.org>.  perltab may be used, modified or redistributed under the GNU Public License GPLv3.  For possible use under others licenses, please contact the author.
