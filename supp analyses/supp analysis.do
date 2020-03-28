* =============================================================
* This file: additional analyses.do
* Format: Stata 13 do-file
* Author: David Tannenbaum <david.tannenbaum@utah.edu>
* =============================================================

* Correlation between attitudes about policy objectives 
* and attitudes about nudges (Studies 1-4)
* -------------------------------------------------------------
// combining data
version 13.1
cd "~/Github/partisan-nudge-bias/"
use "study1/final data.dta", clear
rename example cond
keep cond dv attitude
drop if attitude == .
generate study = 1
append using "study2/final data.dta", gen(study2) keep(cond dv attitude)
replace study = 2 if study2 == 1
append using "study3/final data.dta", gen(study3) keep(cond dv attitude)
replace study = 3 if study3 == 1
append using "study4/final data.dta", gen(study4) keep(cond dv attitude)
replace study = 4 if study4 == 1
drop study2-study4

// sample-weighted mean correlation from Hunter & Schmidt 2004 "Methods of Meta-Analysis." 
// Study-level variance is calculated using eq 3.2: N_i * (corr_i - avg_correlation)^2 / N_total
preserve
statsby corr = r(rho) n=r(N), by(study) clear nodots: corr dv attitude
summarize corr [fweight=n]
local rhat = r(mean)
generate diff = (corr - `rhat')^2
summarize diff [fweight=n]
local sd = sqrt(r(mean))
local stderr = `sd'/sqrt(4)
display "weighted correlation = " `rhat' ", p-value = " normal(-`rhat'/`stderr') * 2
restore

// alternative version of Hunter-Schmidt method using `metan' command
preserve
statsby corr = r(rho) n = r(N), by(study) clear nodots: corr dv attitude
summarize corr [aweight=n]
generate rhat = r(mean)
generate sd = sqrt((`rhat' - corr)^2)
generate se = sd/sqrt(n)
metan corr se, wgt(n) nograph
restore

* Examining partisan attitudes in control condition (Study 1)
* -------------------------------------------------------------
// sample-weighted mean correlation from Hunter & Schmidt 2004
preserve
use "study1/final data.dta", clear
keep if example == 1
statsby corr=r(rho) n=r(N), by(policy) clear nodots: corr dv pogen
summarize corr [fweight=n]
local rhat = r(mean)
generate diff = (corr - `rhat')^2
summarize diff [fweight=n]
local sd = sqrt(r(mean))
local stderr = `sd'/sqrt(5)
display "weighted correlation = " `rhat' ", p-value = " normal(`rhat'/`stderr') * 2
restore

// alternative version of Hunter-Schmidt method using `metan' command
preserve
use "study1/final data.dta", clear
keep if example == 1
statsby corr=r(rho) n=r(N), by(policy) clear nodots: corr dv pogen
summarize corr [aweight=n]
generate rhat = r(mean)
generate sd = sqrt((`rhat' - corr)^2)
generate se = sd/sqrt(n)
metan corr se, wgt(n) nograph
restore

* Examining partisan attitudes in control condition (Study 2)
* -------------------------------------------------------------
preserve
use "study2/final data.dta", clear
keep if cond == 3
pwcorr dv pogen, sig
restore

* Examining libertarian attitudes in control condition (Study 1)
* -------------------------------------------------------------
// sample-weighted mean correlation from Hunter & Schmidt 2004
preserve
use "study1/final data.dta", clear
keep if example == 1
statsby corr=r(rho) n=r(N), by(policy) clear nodots: corr dv libertarian
summarize corr [fweight=n]
local rhat = r(mean)
generate diff = (`rhat' - corr)^2
summarize diff [fweight=n]
local sd = sqrt(r(mean))
local stderr = `sd'/sqrt(5)
display "weighted correlation = " `rhat' ", p-value = " normal(`rhat'/`stderr') * 2
restore

// alternative version of Hunter-Schmidt method using `metan' command
preserve
use "study1/final data.dta", clear
keep if example == 1
statsby corr=r(rho) n=r(N), by(policy) clear nodots: corr dv libertarian
summarize corr [aweight=n]
generate rhat = r(mean)
generate sd = sqrt((`rhat' - corr)^2)
generate se = sd/sqrt(n)
metan corr se, wgt(n) nograph
restore

* Comparing libertarianism to partisan nudge bias (Study 1)
* -------------------------------------------------------------
// comparing sample-weighted mean correlations (from Hunter & Schmidt 2004)
preserve
use "study1/final data.dta", clear
drop if example == 1
statsby r_pnb=el(r(C),1,2) r_lib=el(r(C),1,3) n=r(N), by(policy) clear nodots: corr dv attitude libertarian
summarize r_pnb [fweight=n]
local rhat_pnb = r(mean)
generate diff_pnb = (r_pnb - `rhat_pnb')^2
summarize diff_pnb [fweight=n]
local sd_pnb = sqrt(r(mean))
local stderr_pnb = `sd_pnb'/sqrt(4)
summarize r_lib [fweight=n]
local rhat_lib = r(mean)
generate diff_lib = (r_lib - `rhat_lib')^2
summarize diff_lib [fweight=n]
local sd_lib = sqrt(r(mean))
local stderr_lib = `sd_lib'/sqrt(4)
display "PNB weighted correlation = " `rhat_pnb' ", p-value = " normal(-`rhat_pnb'/`stderr_pnb') * 2
display "libertarian weighted correlation = " `rhat_lib' ", p-value = " normal(`rhat_lib'/`stderr_pnb') * 2
restore

// comparing sample-weighted mean correlations (alternative version of Hunter-Schmidt method using `metan' command)
preserve
use "study1/final data.dta", clear
drop if example == 1
statsby r_pnb=el(r(C),1,2) r_lib=el(r(C),1,3) n=r(N), by(policy) clear nodots: corr dv attitude libertarian
summarize r_pnb [aweight=n]
generate rhat_pnb = r(mean)
generate sd_pnb = sqrt((`rhat_pnb' - r_pnb)^2)
generate se_pnb = sd_pnb/sqrt(n)
summarize r_lib [aweight=n]
generate rhat_lib = r(mean)
generate sd_lib = sqrt((`rhat_lib' - r_lib)^2)
generate se_lib = sd_lib/sqrt(n)
metan r_pnb se_pnb, wgt(n) nograph
metan r_lib se_lib, wgt(n) nograph
restore

// comparing standardized regression weights
preserve
use "study1/final data.dta", clear
drop if example == 1
regress dv i.example i.policy c.attitude c.libertarian, cluster(id)
regress dv i.example i.policy c.attitude c.libertarian, beta
restore

* Evaluation of nudges in control conditions (Study 1)
* -------------------------------------------------------------
preserve
use "study1/final data.dta", clear
keep if example == 1
table policy, c(mean dv sd dv n dv) format(%9.2f)
bysort policy: ttest dv == 3
restore