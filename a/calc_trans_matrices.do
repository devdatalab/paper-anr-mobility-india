/**********************************************************/
/* This do-file generates transition matrices on the data */
/* for each cohort.                                       */
/**********************************************************/

/* age is the age group on which you want to generate */
/* you can further limit the population by inserting some conditional expression
using the option conditional */
/* csvname is required and is the name of the csv you want exported to your output folder */

cap prog drop transition_matrix
cap prog def transition_matrix
{
  syntax, decade(string) csvname(string) [conditional(string)]
  
  /* initialize the matrix */
  clear
  gen son_less_prim = . 
  tempfile matrix
  save `matrix'

  /* load mobility data */ 
  use $mobility/ihds/ihds_mobility, clear
  keep if bc == `decade'

  /* drop if missing son education -- these will be daughters */
  drop if mi(son_ed)
  
  /* generate dummy variables for the cdfs */
  capdrop *prim *mid *sec *hs *college *no_ed *uni son_ed_rank
  foreach person in son father {

    gen `person'_no_ed = `person'_ed == 0
    gen `person'_less_prim = `person'_ed == 2
    gen `person'_prim =`person'_ed == 5
    gen `person'_mid = `person'_ed == 8
    gen `person'_sec = `person'_ed == 10
    gen `person'_hs = `person'_ed == 12
    gen `person'_college = `person'_ed == 14

    /* close loop over son and father */
  }

  if "`conditional'" != "" {
    keep if "`conditional'"
  }

  foreach father_level in  no_ed less_prim prim mid sec hs college {
    sum father_`father_level' [aw=wt]
    local father_`father_level'_mean = round(`r(mean)' * 100,1)

    sum son_`father_level' [aw=wt]
    local son_`father_level'_mean = round(`r(mean)' * 100,1)
  }

  foreach father_level in no_ed less_prim prim mid sec hs college {

    preserve
    keep if father_`father_level' == 1 

    collapse (mean) son_no_ed son_less_prim son_prim son_mid son_sec son_hs son_college [aw=wt]

    /* write a variable that is the father's education */        
    gen father_level = "`father_level'"
    
    /* append the data */
    tempfile append
    save `append'

    use `matrix'
    append using `append'
    save `matrix', replace 

    /* reload */
    restore

    /* close person loop  */
  }

  use `matrix', clear
  order father_level
  replace father_level = "$<$2 yrs. (`father_no_ed_mean'\%)" if father_level == "no_ed"
  replace father_level = "2-4 yrs. (`father_less_prim_mean'\%)" if father_level == "less_prim"
  replace father_level = "Primary (`father_prim_mean'\%)" if father_level == "prim" 
  replace father_level = "Middle (`father_mid_mean'\%)" if father_level == "mid" 
  replace father_level = "Secondary (`father_sec_mean'\%)" if father_level == "sec" 
  replace father_level = "Sr. secondary (`father_hs_mean'\%)" if father_level == "hs"
  replace father_level = "Any higher ed (`father_college_mean'\%)" if father_level == "college"

  /* round */
  foreach var in son_no_ed son_less_prim son_prim son_mid son_sec son_hs son_college {
    replace `var' = round(`var', .01)
    format `var' %5.2f
    tostring `var', replace usedisplayformat force
  }

  order father_level son_no_e son_less_prim son_prim son_mid son_sec son_hs son_college
  list

  export delimited using $out/`csvname'.tex, replace novarnames 

  /* convert to a tex */
  !sed -i 's/\,/ \& /g' $out/`csvname'.tex
  !sed -i 's/$/ \\\\ /g' $out/`csvname'.tex
  !sed -i 's/father_level/ /g' $out/`csvname'.tex
  
  capture file close fh 
  file open fh using $out/firstrow_`csvname'.tex,  write replace
  file write fh " & $<$ 2 yrs. & 2-4 yrs. & Primary & Middle & Sec. & Sr. sec. & Any higher \\"

  file write fh "Father ed attained & (`son_no_ed_mean'\%) &  (`son_less_prim_mean'\%) & (`son_prim_mean'\%) &"
  file write fh " (`son_mid_mean'\%) &  (`son_sec_mean'\%) &  (`son_hs_mean'\%) &  (`son_college_mean'\%) \\"
  file close fh
}
end 

transition_matrix, decade(1980) csvname(1980_tm_full)
transition_matrix, decade(1970) csvname(1970_tm_full) 
transition_matrix, decade(1960) csvname(1960_tm_full) 
transition_matrix, decade(1950) csvname(1950_tm_full) 



