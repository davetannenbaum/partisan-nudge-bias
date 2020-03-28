* =============================================================
* This file: Study 2 analysis script
* Format: Stata 13 do-file
* Author: David Tannenbaum <david.tannenbaum@utah.edu>
* =============================================================

* Calling data
* -------------------------------------------------------------
version 13.1
cd "~/Github/partisan-nudge-bias/study2/"
use "final data.dta", clear

* Descriptive statistics of sample
* -------------------------------------------------------------
tabulate gender
summarize age

* Basic analysis
* -------------------------------------------------------------
preserve
drop if cond == 3
replace cond = (cond == 1) // recoding to 0 = Obama admin, 1 = Bush admin
summarize dv
local y = r(sd)
regress dv i.cond##c.pogen, robust
quietly margins, dydx(cond) at(pogen = (1(1)7)) post // generating standardized bias scores across range of political orientation
forvalues i = 1/7 {
	display "bias score when pogen == `i': " _b[1.cond:`i'._at]/`y'
}
restore

* Graphs
* -------------------------------------------------------------
cd "~/Github/partisan-nudge-bias/study2/graphs/"

preserve
drop if cond == 3
graph twoway scatter dv pogen if cond == 2, jitter(2) msymbol(circle_hollow) mcolor(navy) mlwidth(thin) || scatter dv pogen if cond == 1, jitter(2) msymbol(circle_hollow) mcolor(cranberry) mlwidth(thin) || lfit dv pogen if cond == 2, lcolor(navy) lwidth(thick)|| lfit dv pogen if cond == 1, lcolor(cranberry) lwidth(thick) legend(off) ysize(4) xsize(2.5) graphregion(color(white)) bgcolor(white) ylab(1(1)5, nogrid) xtitle("") ytitle("") xlab(1(1)7, nogrid) plotregion(lstyle(p1 p1)) plotregion(lwidth(thin))
graph export study2.pdf, replace
restore