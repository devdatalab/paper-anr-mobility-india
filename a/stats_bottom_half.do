/* ------ cell: characteristics of people in the bottom half ------ */
use $mobility/ihds/ihds_mobility.dta, clear

/* outcomes of interest:
individual:
  p(earns wages)
  wage if non-zero
  p(rural)
  mean years of education
  p(sc)
  p(muslim)
  p(st)
household:
  ln_mpce = mean per capita expenditure
  ln_hh_income */

global member_vlist any_wage ln_wage rural child_ed muslim sc st
global hh_vlist ln_hh_income ln_mpce

/* drop if can't observe child ed --- can't tell if in bottom half */
drop if mi(child_ed) | !inlist(male, 0, 1)

/* only focus on men, since the paper only focuses on fathers */
keep if male == 1

/* retag with this sample */
drop htag
tag hhid

/* create bottom half indicators for different age groups */
gen bottom_half = 0
replace bottom_half = 1 if child_ed <= 8 & inrange(age, 20, 29)
replace bottom_half = 1 if child_ed <= 5 & inrange(age, 50, 59)

/* create the new summary variables that we want */
gen any_wage = wage > 0 & !mi(wage)
gen rural = inlist(urban4_2011, 2, 3)
gen ln_wage = ln(wage)
winsorize hh_income 1 99, centile replace
gen ln_hh_income = ln(hh_income)

/* tabstat individual characteristics for ages 20-29, by(bottom_half) */
foreach var in $member_vlist {

  /* calculate individual characteristic mean */
  mean `var' [aw=wt] if inrange(age, 20, 29), over(bottom_half)
  
  /* store top and bottom half means and sds in locals */
  local `var'_top_half_20_29 = e(b)[1, 1]
  local `var'_bot_half_20_29 = e(b)[1, 2]
  local `var'_top_half_20_29_sd = e(sd)[1, 1]
  local `var'_bot_half_20_29_sd = e(sd)[1, 2]

  /* insert the entries into a csv */
  insert_into_file using $tmp/bottom_half_stats.csv, key(`var'_top_half_20_29) value(``var'_top_half_20_29') format(%12.3f)
  insert_into_file using $tmp/bottom_half_stats.csv, key(`var'_bot_half_20_29) value(``var'_bot_half_20_29') format(%12.3f)
  insert_into_file using $tmp/bottom_half_stats.csv, key(`var'_top_half_20_29_sd) value(``var'_top_half_20_29_sd') format(%12.3f)
  insert_into_file using $tmp/bottom_half_stats.csv, key(`var'_bot_half_20_29_sd) value(``var'_bot_half_20_29_sd') format(%12.3f)

}

foreach var in $hh_vlist {
  
  /* calculate household characteristic mean */
  mean `var' [aw=wt] if htag & inrange(age, 20, 29), over(bottom_half)

  /* store means in locals */
  local `var'_top_half_20_29 = e(b)[1, 1]
  local `var'_bot_half_20_29 = e(b)[1, 2]
  local `var'_top_half_20_29_sd = e(sd)[1, 1]
  local `var'_bot_half_20_29_sd = e(sd)[1, 2]

  /* insert means into file */
  insert_into_file using $tmp/bottom_half_stats.csv, key(`var'_top_half_20_29) value(``var'_top_half_20_29') format(%12.3f)
  insert_into_file using $tmp/bottom_half_stats.csv, key(`var'_bot_half_20_29) value(``var'_bot_half_20_29') format(%12.3f)
  insert_into_file using $tmp/bottom_half_stats.csv, key(`var'_top_half_20_29_sd) value(``var'_top_half_20_29_sd') format(%12.3f)
  insert_into_file using $tmp/bottom_half_stats.csv, key(`var'_bot_half_20_29_sd) value(``var'_bot_half_20_29_sd') format(%12.3f)
}

/* tabstat individual characteristics for ages 50-59, by(bottom_half) */
foreach var in $member_vlist {

  /* calculate individual characteristic mean */
  mean `var' [aw=wt] if inrange(age, 50, 59), over(bottom_half)
  
  /* store means and sds in locals */
  local `var'_top_half_50_59 = e(b)[1, 1]
  local `var'_bot_half_50_59 = e(b)[1, 2]
  local `var'_top_half_50_59_sd = e(sd)[1, 1]
  local `var'_bot_half_50_59_sd = e(sd)[1, 2]

  /* insert means into file */
  insert_into_file using $tmp/bottom_half_stats.csv, key(`var'_top_half_50_59) value(``var'_top_half_50_59') format(%12.3f)
  insert_into_file using $tmp/bottom_half_stats.csv, key(`var'_bot_half_50_59) value(``var'_bot_half_50_59') format(%12.3f)
  insert_into_file using $tmp/bottom_half_stats.csv, key(`var'_top_half_50_59_sd) value(``var'_top_half_50_59_sd') format(%12.3f)
  insert_into_file using $tmp/bottom_half_stats.csv, key(`var'_bot_half_50_59_sd) value(``var'_bot_half_50_59_sd') format(%12.3f)

}

foreach var in $hh_vlist {
  
  /* calculate household characteristic mean */
  mean `var' [aw=wt] if htag & inrange(age, 50, 59), over(bottom_half)
  
  /* store means in locals */
  local `var'_top_half_50_59 = e(b)[1, 1]
  local `var'_bot_half_50_59 = e(b)[1, 2]

  /* store SDs */
  local `var'_top_half_50_59_sd = e(sd)[1, 1]
  local `var'_bot_half_50_59_sd = e(sd)[1, 2]

  /* insert all these into file */
  insert_into_file using $tmp/bottom_half_stats.csv, key(`var'_top_half_50_59) value(``var'_top_half_50_59') format(%12.3f)
  insert_into_file using $tmp/bottom_half_stats.csv, key(`var'_bot_half_50_59) value(``var'_bot_half_50_59') format(%12.3f)
  insert_into_file using $tmp/bottom_half_stats.csv, key(`var'_top_half_50_59_sd) value(``var'_top_half_50_59_sd') format(%12.3f)
  insert_into_file using $tmp/bottom_half_stats.csv, key(`var'_bot_half_50_59_sd) value(``var'_bot_half_50_59_sd') format(%12.3f)
}

/* create a tex table with outputs */
table_from_tpl, t($mobcode/a/bottom_half_stats.tpl) r($tmp/bottom_half_stats.csv) o($out/bottom_half_stats.tex)
