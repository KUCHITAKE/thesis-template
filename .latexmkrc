#!/usr/bin/env perl

$do_cd = 1;

$pdf_mode = 3;
$latex = "texliveonfly -s always -c uplatex -a '-file-line-error -halt-on-error -shell-escape -interaction=nonstopmode %O' %S";
$dvipdf = 'dvipdfmx -v %O -o %D %S';
$max_repeat = 10;

# bibtex系
$bibtex_use=2;
$bibtex = 'upbibtex %O %S';
$biber = 'biber --bblencoding=utf8 -u -U --output_safechars %O %S';

# index
$makeindex = 'upmendex %O -o %D %S -s jpbase';