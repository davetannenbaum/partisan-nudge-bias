* =============================================================
* This file: Study 4 cleanup script
* Format: Stata 13 do-file
* Author: David Tannenbaum <david.tannenbaum@utah.edu>
* =============================================================

* Calling data
* -------------------------------------------------------------
version 13.1
cd "~/Github/partisan-nudge-bias/study4/"
import delimited "raw data.csv", varnames(1) case(preserve) clear

* Renaming variables and general cleanup
* -------------------------------------------------------------
destring oppose party age, force replace
rename party polparty
rename prompt cond
rename wing pogen
rename promptfeel attitude
replace oppose = 6 - oppose
replace manip = 6 - manip
replace coerce = 6 - coerce
replace pogen = 8 - pogen
alpha support oppose manip coerce, gen(dv)
replace cond = 1 - cond 
label define condl 0 "safe sex" 1 "intel design"
label val cond condl
label define polpartyl 0 "Republican" 1 "Democrat" 2 "Neither"
label val polparty polpartyl

* Pruning data set
* -------------------------------------------------------------
keep cond dv pogen polparty attitude gender age
order cond dv pogen polparty attitude gender age

* Saving data
* -------------------------------------------------------------
save "final data.dta", replace
