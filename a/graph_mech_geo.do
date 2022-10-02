
/**********************************************/
/* X-GROUP MOBILITY AFTER STATE FIXED EFFECTS */
/**********************************************/
use $mobility/ihds/ihds_mobility, clear

/* pool 1980-89 data for more power within districts */
replace bc = 1980 if bc == 1985
keep if bc == 1980
rerank

/* take state effects out of education rank */
group stateid
group stateid distid

/* generate state and district residuals */
foreach v in son daughter {
  qui reg `v'_ed_rank i.sgroup [aw=wt] 
  predict `v'_ed_rank_sresid, resid
  qui reg `v'_ed_rank i.sdgroup [aw=wt] 
  predict `v'_ed_rank_dresid, resid
}

/* create an estimates file for result storage */
global f $tmp/mob_resids.csv
cap erase $f
app $f, s(lb,ub,group,type)

/* CALCULATE BOUNDS UNDER ALL FIXED EFFECTS */

/* for each type, get national mu-0-50, and subset for each group */
disp_nice "unadjusted"
bound_param [aw=wt] , s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank) forcemono
app $f, s("`r(mu_lb)',`r(mu_ub)',0,unadjusted")
forval g = 1/4 {
  bound_param [aw=wt] if group == `g', s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank) forcemono
  app $f, s("`r(mu_lb)',`r(mu_ub)',`g',unadjusted")
}

disp_nice "state f.e. residuals"
bound_param [aw=wt] , s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank_sresid)  forcemono
app $f, s("`r(mu_lb)',`r(mu_ub)',0,state-resid")
forval g = 1/4 {
  bound_param [aw=wt] if group == `g', s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank_sresid) forcemono
  app $f, s("`r(mu_lb)',`r(mu_ub)',`g',state-resid")
}

disp_nice "district f.e. residuals"
bound_param [aw=wt] , s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank_dresid) forcemono
app $f, s("`r(mu_lb)',`r(mu_ub)',0,dist-resid")
forval g = 1/4 {
  bound_param [aw=wt] if group == `g', s(0) t(50) xvar(father_ed_rank_s) yvar(son_ed_rank_dresid) forcemono
  app $f, s("`r(mu_lb)',`r(mu_ub)',`g',dist-resid")
}

/* IMPORT AND GRAPH RESULTS */
import delimited $f, clear
egen mob = rowmean(lb ub)
drop lb ub

/* reshape to get groups in wide */
reshape wide mob, j(group) i(type) 

/* sort */
gen s = 1 if type == "unadjusted"
replace s = 2 if type == "state-resid"
replace s = 3 if type == "dist-resid"
sort s

/* relabel strings for a clear graph */
replace type = "Residual of State F.E." if type == "state-resid"
replace type = "Residual of District F.E." if type == "dist-resid"
replace type = "Unadjusted" if type == "unadjusted"

/* generate gaps for marginalized groups relative to forwards / others */
forval i = 2/4 {
  gen mob_diff`i' = mob`i' - mob1
}

/* show diffs for first group only */
/* create empty slots for new groups */
count
local n = `r(N)'
local new_n = `r(N)' + 2
set obs `new_n'
replace type = "Residual of State F.E." if _n == `n' + 1
replace type = "Residual of District F.E." if _n == `n' + 2
replace s = 2 if _n == `n' + 1
replace s = 3 if _n == `n' + 2
tab s if (s == 1 | _n > `n')
graph bar mob_diff2 mob_diff3 mob_diff4 if (s == 1 | _n > `n'), over(type, sort(s)) blabel(total, format(%5.1f) color(black)) ///
    legend(lab(1 Muslims) lab(2 Scheduled Castes) lab(3 Scheduled Tribes)) ytitle("Upward Mobility Gap with Forwards/Others") ///
    title("Upward Mobility Gaps to Forward/Others, By Group")
graphout mob_gaps_unadjusted, pdf

/* cut the placeholder observations */
drop if _n > `n'

/* graph the gaps */
graph bar mob_diff2 mob_diff3 mob_diff4, ///
    over(type, sort(s)) blabel(total, format(%5.1f) color(black) size(small)) ///
    legend(pos(4) ring(0) rows(3) lab(1 Muslims) lab(2 Scheduled Castes) lab(3 Scheduled Tribes)) ///
    ytitle("Upward Mobility Gap with Forwards/Others") ///
    bar(1, color("150 150 255")) bar(2, color("252 46 24")) bar(3, color("190 210 160"))
graphout mob_gaps_sd_resids, pdf

