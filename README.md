# paper-anr-mobility-india

Replication and Data Repository for "[Intergenerational Mobility in India: New Measures and Estimates Across Time and Social groups](https://www.dartmouth.edu/~novosad/anr-mobility.pdf)," Asher, Novosad Rafkin (2022) or ANR 2022

This repository contains:

- Code for generating bottom half mobility and other CEF-based measures of intergenerational mobility from interval-censored rank data (e.g. education levels/ranks).

- Replication code for results in the paper

Bottom half mobility is the expected education rank of a son born to a father in the bottom 50% of the father education distribution (of the son's birth cohort).

Replication data can be found at this [dropbox link](https://www.dropbox.com/sh/bk0d3jbweoailzw/AACj1XIP-5Vzt5iYpXXq4y3ia?dl=0); [replication instructions](https://github.com/devdatalab/paper-anr-mobility-india/tree/repl#replication-instructions-for-asher-novosad-and-rafkin-2022) are at the bottom of this document.

## Calculating measures of mobility using ANR2020 (Stata)

The code here can calculate the following measures (among others) in data with interval-censored ranks:

| Measure                    | Definition                                                                                                                                    |
|----------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| Upward mobility (mu-0-50)  | The expected outcome of a child born to a parent in the bottom half of the parent education distribution, also called *bottom half mobility*. |
| mu-a-b                     | The expected outcome of a child born to a parent between percentiles $a$ and $b$ in the parent education distribution.                        |
| E(Y > 80&#124;X in [0,20]) | The probability that a child born to a parent in the bottom quintile makes it to the top quintile. (Substitute any other rank boundaries)     |
| p_25 = E(Y&#124;X=25)      | Absolute upward mobility (from Chetty et al. QJE 2014)                                                                                        |
| p_i = E(Y&#124;X=i)        | Absolute mobility at rank *i*                                                                                                                 |

In Stata, use `bound_mobility()` in `mobility_programs.do`.

| Required parameters | Description                        | 
|---------------------|------------------------------------|
| xvar                | parent socioeconomic rank variable | 
| yvar                | child socioeconomic rank variable  | 

| Optional parameters | Description                                                 |
|---------------------|-------------------------------------------------------------|
| [aw&#124;pw]        | Standard weights                                            |
| s                   | bottom of parent rank interval (0 for bottom half mobility) |
| t                   | top of parent rank interval (50 for bottom half mobility)   |
| quiet               | run quietly                                                 |
| verbose             | run noisily                                                 |

### Examples

The examples below use the Stata file `mobility_sample.dta` in the repo root.

Calculate bottom half mobility (mu-0-50) from fathers to sons:

    use mobility_sample.dta
    bound_mobility [aw=wt], xvar(father_ed_rank) yvar(son_ed_rank) forcemono

Calculate mu-0-20 (expected son rank given parent in bottom 20%):

    use mobility_sample.dta
    bound_mobility [aw=wt], xvar(father_ed_rank) yvar(son_ed_rank) s(0) t(20)

Calculate p-25 (expected son rank given parent at 25th percentile):

    use mobility_sample.dta
    bound_mobility [aw=wt], xvar(father_ed_rank) yvar(son_ed_rank) s(25) t(25)

Calculate probability son from bottom quintile father ends up in top quintile:

    use mobility_sample.dta
    gen son_top20 = (son_ed_rank > 80) * 100 if !mi(son_ed_rank)
    bound_mobility [aw=wt], xvar(father_ed_rank) yvar(son_top20) s(0) t(20)

Probability son completes high school given parent in bottom 50%, and in top 50%:

    use mobility_sample.dta
    bound_mobility [aw=wt], xvar(father_ed_rank) yvar(son_hs) s(0) t(50)
    bound_mobility [aw=wt], xvar(father_ed_rank) yvar(son_hs) s(50) t(100)
    
Report quintile transition matrix for fathers/sons - this one is possibly buggy but basically consists of running 16 versions of the command above for each cell of the transition matrix:

    use mobility_sample.dta
    calc_transition_matrix, parent(father_ed_rank) child(son_ed_rank) weight(wt)

In each case, bounds are displayed to the screen and returned in the local macros `r(mu_lb)` and `r(mu_ub)` for programmatic use.

This program bounds the conditional expectation function of a child outcome (y) given parent rank (x), under the assumption that E(y|x) is monotonically non-decreasing in x. In data with very small bins, non-monotonicity may arise due to statistical error. For example, if there are only a handful of individuals with exactly 11 years of education, there is no guarantee the raw data will be monotonic around 11 years. In cases like this, `bound_mobility` can pool neighboring bins until monotonicity is restored, which can be done by adding the `force_mono` option to `bound_mobility`. This option should be used with caution and only after visually inspecting the data. Blind application of `force_mono` may yield unpredictable or incorrect results.

## Calculating mobility measures under more complex structural assumptions (Matlab)

The Matlab code generates arbitrary bounds on the CEF E(y|x), where *x* is a parent socioeconomic (usually educadtion) rank.

This code employs a numerical solver (`fmincon`) to calculate bounds on the CEF or functions of the CEF under arbitrary assumptions. The example cases impose monotonicity and a curvature constraint on the CEF. The curvature constraint takes the form of a maximal value for the numerical second derivative of the function. We include the optimization structure and several example functions to make this easier to use:

* `minimal_mob_example.m` -- Sample code to calculate a full CEF and some mobility statistics. This is a good place to start to understand how to use this code.

* `get_mob_bounds.m`: Returns bounds on a full mobility CEF, given an input CSV. The CSV should consist only of the parent rank bin means and the expected child rank in each parent bin, i.e. grouped data, not individual data.

* `bound_reg_coef.m`: Bounds the rank-rank regression coefficient, from an input CSV with parent-child grouped rank data.

* `bound_generic_fun.m`: Bounds a generic function of the CEF, like p25 or mu-0-50.

* `get_cef_bounds.m` -- Numerically calculate bounds on E(y|x) given interval censored data on x, under a monotonicity and smoothness restriction.

The other Matlab functions in the folder are helper functions used by the above.

The Matlab code can be readily modified to impose any kind of structural constraint on the CEF, or to calculate a different statistic from the outcome distribution, such as a conditional median or percentile.

# Replication Instructions for Asher, Novosad and Rafkin (2022)

## Data Availability

The primary data source for this project is the [India Human Development Survey II](https://ihds.umd.edu/data/ihds-2). The replication data repo includes some files from IHDS; visit the [IHDS site](https://ihds.umd.edu/data/ihds-2) for more information and data from IHDS. The data are open to the public. All data sources used in the paper are available in the paper's data packet. Ancillary analyses use data from NSS 68 and the U.S. Census.

## Dataset list

| Data file    | Source               | Provided                        |
|--------------|----------------------|---------------------------------|
| `clean/nss*` | NSS                  | Yes, modules used in paper only |
| `jati/*`     | Census of India 2001 | Yes, modules used in paper only |
| `raw/*`      | IHDS                 | Yes, modules used in paper only |
| `us/*`       | US Census 2010       | Yes, modules used in paper only |

## Computational Requirements

This package is designed to be run on a *nix system with Python 3.2+, Matlab 2019+, and Stata 16+ installed. Data and code folders for the replication must not include spaces. This package may require modification to run on Windows due to the use of some Unix shell commands. This package was tested on a system with about 30 GB of memory.

## Description of programs / code

The file `make_mobility.do` describes the build and analysis process in detail.

## Instructions to Replicators

To regenerate the tables and figures from the paper, take the
following steps:

1. Download and unzip the replication data package `mobility-packet.zip` from this [Google Drive Folder TBD](http://test.com)
   
2. Clone this repo.

3. Open the do file `config_mobility.do`, and set the globals `out`,
   `mobility`, and `tmp`.  
   * `$out` is the target folder for all outputs, such as tables
   and graphs. 
   * `$mobility` is the folder where you unzipped and saved the
     replication data package.
   * intermediate files will be placed in both `$tmp` and `$mobility`.

4. FIXFIX Open `matlab/set_basepaths.m` and set `base_path` to the same path as `$mobility`.

5. Run the do file `make_mobility.do`.  This will run through all the
   other do files to regenerate all of the results in `$out/`. The do file runs matlab from shell commands in several locations. Your local machine may need additional configuration to be able to run Matlab from Stata. Alternatively, you can run these Matlab programs separately when you get there.
   
## Replication Notes

To compile `mobility_paper.tex`, You may need to change `\mobilitypath` in `mobility_paper.tex` to an absolute path. The relative path to `exhibits/` seems to work on some Latex compilers and not others.

This code was tested using Stata 16.0 and Matlab R2019a. The estimated run time on our server is about 4 hours (the last 2 for the Matlab component).

The mapping of results output names to tables and figures is as follows:

Figure 1

| Exhibit   | Filename                           |
|-----------|------------------------------------|
| Figure 1  | scatter-smooth-t-50-[12]-[12].pdf  |
| Figure 2  | intuit_[a-d].png                   |
| Figure 3  | mort_cef.pdf                       |
| Figure 4  | naive-5-women-50-t-[12].pdf        |
| Figure 5  | trend-smooth-mon-step-t-sex-50.pdf |
| Figure 6  | changes-total-[12]-[12].pdf        |
| Figure 7  | changes-nod-[12]-[12].pdf          |
| Table 1   | table_mort_stats_1992.tex          |
|           | table_mort_stats_2016.tex          |
| Table 2   | age_adjusted_all_cause.tex         |
| Table A1  | icd_causes.tex                     |
| Table A2  | all_cause_std.tex                  |
| Figure A1 | std_mort_perc_total.pdf            |
| Figure A2 | naive-1-women-50-t-[12].pdf        |
|           | naive-1-men-50-t-[12].pdf          |
| Figure C1 | polyspline__50_[MF]_2012-2014.pdf  |
| Table D1  | semimon_bounds.tex                 |
| Figure D1 | f1992_semimon_[0520100].pdf        |
| Figure D2 | causes-1992-2-1.pdf                |
|           | causes-racesex-2-1.pdf             |
|           | causes-mon-step-2-1.pdf            |
|           | causes-nof-2-1.pdf                 |
| Figure D3 | mean_within_rank_50_[12]_comb.pdf  |
| Figure D4 | total_pops.pdf                     |
| Figure D5 | hisp_shift_[12].pdf                |
| Figure D6 | cps_pred_all_dropout.pdf           |
| Figure D7 | cps_pred_all_hs.pdf                |
| Figure D8 | ests_yline.pdf                     |
| Figure D9 | lowess_sex_both.pdf                |





