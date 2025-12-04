# paper-anr-mobility-india

Replication and Data Repository for "[Intergenerational Mobility in India: New Measures and Estimates Across Time and Social groups](https://www.dartmouth.edu/~novosad/anr-mobility.pdf)," Asher, Novosad Rafkin (2022) or ANR 2022

This repository contains:

- Code for generating bottom half mobility and other CEF-based measures of intergenerational mobility from interval-censored rank data (e.g. education levels/ranks).

- Replication code for results in the paper

Bottom half mobility is the expected education rank of a son born to a father in the bottom 50% of the father education distribution (of the son's birth cohort).

Replication data can be found at this [Google Drive link](https://drive.google.com/file/d/1LE7ozFGZwkIk0V38iwIDqH5SAi56T1A8/view?usp=sharing); [replication instructions](https://github.com/devdatalab/paper-anr-mobility-india/tree/repl#replication-instructions-for-asher-novosad-and-rafkin-2022) are at the bottom of this document.

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

All data sources used in the paper are available in the paper's data packet. 

The primary data source is the [India Human Development Survey II](https://ihds.umd.edu/data/ihds-2). The replication data repo includes some files from IHDS; the full IHDS can currently be downloaded from [this link](https://www.icpsr.umich.edu/web/DSDR/studies/36151/datadocumentation). 

Ancillary analyses use data from NSS 68 and the U.S. Census. As of July 2024, the NSS is hosted at the [National Data Archive](https://microdata.gov.in/nada43/index.php/catalog/126); create an account to download it.

Data from the Indian Census can be accessed via the [SHRUG](https://www.devdatalab.org/shrug_download/).

U.S. transition matrices by race were obtained from Chetty et al. (2020), accessed at the Opportunity Insights web site [here](https://opportunityinsights.org/data/?geographic_level=0&topic=0&paper_id=992#resource-listing) in 2020.

The authors have legitimate access to and permission to use the data used in this manuscript. The data for the project have been deposited into openICPSR (openicpsr-184504).

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

The file `make_mobility.do` describes the build and analysis process in detail. We use the Stata packages `coefplot`, `grc1leg2`, `outreg2`, `reghdfe`, and the DevDataLab packages `stata-tex` and `masala-merge`.

## Instructions to Replicators

To regenerate the tables and figures from the paper, take the
following steps:

1. Download and unzip the replication data package `mobility-packet.zip` from this [Google Drive Folder](https://drive.google.com/file/d/1LE7ozFGZwkIk0V38iwIDqH5SAi56T1A8/view?usp=sharing)
   
2. Clone this repo (github) or copy all the code into a folder (icpsr)

3. Open the do file `config_mobility.do`, and set the globals `out`,
   `mobility`, and `tmp`.  
   * `$out` is the target folder for all outputs, such as tables
   and graphs. 
   * `$mobility` is the folder where you unzipped and saved the
     replication data package.
   * intermediate files will be placed in both `$tmp` and `$mobility`.

4. Switch to the base code folder and run the do file `make_mobility.do`.  This will run through all the other do files to regenerate all of the results in `$out/`. The do file runs matlab from shell commands in several locations. Your local machine may need additional configuration to be able to run Matlab from Stata. Alternatively, you can run these Matlab programs separately when you get there.
   
## Replication Notes

To compile `mobility_paper.tex`, You may need to change `\mobilitypath` in `mobility_paper.tex` to an absolute path. The relative path to `exhibits/` seems to work on some Latex compilers and not others.

This code was tested using Stata 16.0 and Matlab R2019a. The estimated run time on our server is about 4 hours (the last 2 for the Matlab component).

The mapping of results output names to tables and figures is as follows:

| Exhibit   | Filename                               |
|-----------|----------------------------------------|
| Figure 1  | moments_1960_1985.png                  |
|           | fig_example_cef_1960.png               |
|           | fig_time_1960_25000.png                |
| Figure 2  | \mobilitypath/example_ihds[2-5].pdf    |
| Figure 3  | [daughter/son]_ed_time.pdf             |
| Figure 4  | gradient_60_85                         |
|           | p25_60_85                              |
|           | mu50_60_85                             |
| Figure 5  | ihds_mob_time_f[sd]                    |
|           | ihds_mob_time_hs_[mf]                  |
| Figure 6  | ihds_mob_group_time_p[27]5_[mf]        |
| Figure 7  | jati_cohort_mob                        |
| Table 1   | table_change_time_son.tex              |
|           | table_change_time_daughter.tex         |
| Table 2   | table_group_diff.tex                   |
| Table 3   | mech_cassan[_women]                    |
| Figure A1 | cores_age                              |
| Figure A2 | cores_bias_upward_[mf]                 |
| Figure A3 | scatter_[father/mother]_[son/daughter] |
| Figure A4 | ihds_mob_time_m[sd]                    |
| Figure A5 | ihds_mob_group_time_p25_[prim/hs]_[mf] |
| Figure A6 | aa_time_series_[boy/girl]              |
| Figure A7 | mob_gaps_sd_resids                     |
|           | mincerian_returns_pooled_4             |
|           | has_business_ts                        |
|           | mob_by_own_business                    |
| Table A1  | [firstrow]_19[5-8]0_tm_full.tex        |
| Table A2  | app_table_validate_eds.tex             |
| Table A3  | bottom_half_stats.tex                  |
| Table A4  | table_gran[_binned].tex                |
| Table A5  | mech_fertility.tex                     |
| Figure C1 | sc_mus_father_[years/ranks]            |
|           | mpce_[rank_]low_line                   |
| Figure C2 | ihds_mob_group_[across/within]_mu[57]0 |
| Table C1  | sim_moments.tex                        |
| Table C2  | sim_param_ranks.tex                    |

## District level mobility estimates

District-level estimates and mapping resources are available in this [Google Drive folder](https://drive.google.com/drive/folders/1DYxSHV8V7osTrhvDabwlkpteWNDC2f0V). The folder contains the following files:

- `secc_mobility_dist_both.dta`: Stata file with district-level bottom-half mobility estimates. Key variables are `pc11_state_id`/`pc11_district_id` (2011 Census IDs), `p25_lb`/`p25_ub` (lower/upper bounds for mu-0-50), `sample_size` (father-son pairs), and `is_mon` (indicator that bins were collapsed to enforce monotonicity).
- `pc11-district-simplified.zip`: Census 2011 district shapefiles (DBF/PRJ/SHP/SHX) that match the IDs in the mobility estimates. The zip contains the full shapefile set; unzip locally before use.
- `explore_mob.py`: Helper script used to generate the district mobility maps.

These resources can be combined to visualize or analyze district-level mobility across India.
