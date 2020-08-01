# paper-anr-mobility-india

Replication and Data Repository for "[Intergenerational Mobility in India: New Methods and Estimates Across Time, Space, and Communities](https://www.dartmouth.edu/~novosad/anr-mobility.pdf)," Asher, Novosad Rafkin (2020) or ANR 2020

This repository contains:

- Local upward mobility estimates for India at district, subdistrict, and town levels.

- Code for generating bottom half mobility and other CEF-based measures of intergenerational mobility from interval-censored rank data (e.g. education levels/ranks).

- Replication code for results in the paper (currently incomplete)

The replication data can be found in [this Dropbox folder](https://www.dropbox.com/sh/bk0d3jbweoailzw/AACj1XIP-5Vzt5iYpXXq4y3ia?dl=0). (So far, you will find the local mobility estimates but not replication data.)

## Local Upward Mobility Estimates

| CSV/DTA files            | Description                      |
|--------------------------|----------------------------------|
| `mobility_dist_rural`    | Rural district-level mobility    |
| `mobility_dist_urban`    | Urban district-level mobility    |
| `mobility_subdist_rural` | Rural subdistrict-level mobility |
| `mobility_town`          | Town-level mobility              |

Each data file contains the following fields:

| Variable      | Description                                          |
|---------------|------------------------------------------------------|
| `pc*_id`      | Location identifier matching 2011 Population Census  |
| `mu_0_50_lb`  | Lower bound on bottom half mobility (mu-0-50)        |
| `mu_0_50_ub`  | Upper bound on bottom half mobility (mu-0-50)        |
| `mu_0_50_mid` | Midpoint of bounds on bottom half mobility (mu-0-50) |
| `n_obs`       | Number of parent-child links used to measure mu-0-50 |

The data and calculations underlying these measures are described in sections 4 and 5.3 of [the paper](https://www.dartmouth.edu/~novosad/anr-mobility.pdf).

Bottom half mobility is the expected education rank of a son born to a father in the bottom 50% of the father education distribution (of the son's birth cohort). As described in more detail in the paper, the sample consists of sons aged 20-23 recorded in the 2011-12 Socioeconomic and Caste Census.

## Calculating measures of mobility using ANR2020 (Stata)

This package calculates the following measures in data with interval-censored ranks:

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

## Replication Code and Data for ANR2020

This section is incomplete. Analysis replication files are here (updated July 2020) but they cannot be run without the underlying data. We are working on this release.

The stata program `make_mobility.do` will run the entire data build and analysis. The dofiles for the build are in `b/` (not there yet) and for analysis in `a/`. The following globals need to be set for the code to run:

| global    | description                       |
|-----------|-----------------------------------|
| `$out`      | path for output graphs and tables |
| `$mobcode`  | path to root folder of this repo  |
| `$mobility` | root data folder                  |
| `$bs`       | Number of bootstraps (try 1000)   |
