clear all

/* set the following globals:
$out: path for output files to be created
$mobility: path to data folder [raw data is under mdata/raw/ and intermediate files
will be put into mdata/int/] */

global out /scratch/pn/mobility/out
global tmp /scratch/pn/mobility/tmp
global mobility /scratch/pn/mobility
global mobcode .

if mi("$out") | mi("$tmp") | mi("$mobility") | mi("$mobcode") {
  display as error "Globals 'out', 'tmp', and 'mobility' must be set for this to run."
  error 1
}

/* set some subpaths */
global nss $mobility
global ihds $mobility

/* create the subpaths that will be need */
cap mkdir $out
cap mkdir $tmp
cap mkdir $mobility

/* load Stata programs */
qui do masala-merge/masala_merge
qui do stata-tex/stata-tex
qui do tools.do

/* add ado folder to adopath */
adopath + ado

cap log close
log using $out/anr-mobility.log, text replace


