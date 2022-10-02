/******************************************************************/
/* cycle through all bootstrapped IHDS samples and construct      */
/* mu estimates, saving to a csv

* options:
* bcs: the birth cohorts you want
* name: name of output csv (excluding path)
* sample: which dataset you want to bootstrap over
* N: how many bootstrap draws */ 
/******************************************************************/

/* set samples of interest */
global plist 25 40 75
global childlist s d
global parentlist mother father

/* TEMP: Create fast sample of stuff we want right away */
global plist 25 75
// global childlist s d
// global parentlist mother father

cap prog drop gen_bootstrap_mus
cap prog define gen_bootstrap_mus

syntax, bcs(string) name(string) sample(string) [bs(int 5)] 

global f $mobility/bootstrap_bounds/`name'_`bs'.csv
cap erase $f
append_to_file using $f, s(lb, ub, bc, mu, y, parent, sex, group, bootstrap)

/* loop over set number of bootstraps */ 
forv bootstrap = 1/`bs' { 

  /********* loop over sample ********/

  qui {
    noisily di "sample `bootstrap' of `bs' at `c(current_time)' " 
    use $mobility/ihds/bootstrap/`sample'_`bootstrap'.dta, clear

    /* We want to loop over groups, and do all groups combined. To do this,
       duplicate the dataset and set group to 0 for the duplicates. */
    assert !mi(group)
    expand 2, gen(new)
    replace group = 0 if new == 1
    drop new
    
    /* cycle through all subgroups for mobility calculation */
    /* loop over birth cohorts */
    foreach bc in `bcs' {

      /* loop over upward/downward mob.
      p notation is shorthand -- these aren't chetty's ps.
      p25->mu-0-50. p75->mu-50-100. p40->mu-0-80 */

      foreach p in $plist {
        local s = `p' - 25
        local t = `p' + 25
        if `p' == 40 {
          local s = 0
          local t = 80
        }

        /* loop over child gender */
        foreach csex in $childlist {
          local csexs son
          local csexd daughter

          /* loop over mother / father */
          foreach parent in $parentlist {

            di "`bc'-`s'-`parent'-`csex`csex''..."

            /* loop over all subgroups (where 0 = everyone) */
            forval group = 0/4 {

              /* do group 0 only for moms */
              if "`parent'" == "mother" & `group' > 0 continue
              
              /* calculate mobility, y = ed_rank */
              count if bc == `bc' & group == `group' & !mi(`parent'_ed_rank_`csex') & !mi(`csex`csex''_ed_rank)
              if (`r(N)' < 10) continue

              bound_param [aw=wt] if bc == `bc' & group == `group', s(`s') t(`t') xvar(`parent'_ed_rank_`csex') yvar(`csex`csex''_ed_rank) forcemono qui
              append_to_file using $f, s(`r(mu_lb)',`r(mu_ub)',`bc',p`p',rank,`parent',`csex`csex'',`group',`bootstrap')

            }
          }
        }
      }
    }
  }
}

end

gen_bootstrap_mus, bcs(1960 1980) name("decadal_ihds_mob_bootstrap_mus") bs(1000) sample(decadal_sample)
// gen_bootstrap_mus, bcs(1960 1985) name("ihds_mob_bootstrap_mus")  bs(1000) sample(sample)



