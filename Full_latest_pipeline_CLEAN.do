version 19
clear all
set more off
set linesize 255
cd "."

****************************************************
* Code for writing sample, which is also my extended
* essay during graduate study.
* Full clean pipeline
* Purpose: build the age <= 25 unbalanced CFPS panel
* and estimate the latest models described in the PDF.
*
* Notes:
* - This file is ASCII only to avoid encoding problems.
* - Run it from the data folder; cd "." keeps the current folder.
* - Output files are overwritten when the do-file is rerun.
****************************************************




****************************************************
* 1. Build child variables for 2016
* Source: 2016 family configuration file.
* Variables created:
*   nchild_total    total reported children
*   nchild_alive    reported children who are alive
*   has_child_alive indicator for at least one alive child
****************************************************
use ecfps2016famconf_201804.dta, clear

decode cfps2016_interv_p, gen(interv_p_txt)
keep if interv_p_txt == "Completed interview in 2016"

forvalues j = 1/10 {
    gen child_exist`j' = (pid_c`j' > 0)
    gen child_alive`j' = 0
    replace child_alive`j' = 1 if pid_c`j' > 0 & alive_a16_c`j' == 1
}

egen nchild_total = rowtotal(child_exist1-child_exist10)
egen nchild_alive = rowtotal(child_alive1-child_alive10)
gen has_child_alive = (nchild_alive > 0)

keep pid nchild_total nchild_alive has_child_alive
duplicates drop pid, force
save child2016_done.dta, replace

****************************************************
* 2. Prepare 2016 adult file
* Merge child variables into the adult file, harmonize key
* variables, restrict to age <= 25, and save a wave file.
****************************************************
use ecfps2016adult_201906.dta, clear

merge m:1 pid using child2016_done.dta
tab _merge
drop _merge

replace nchild_total = 0 if missing(nchild_total)
replace nchild_alive = 0 if missing(nchild_alive)
replace has_child_alive = 0 if missing(has_child_alive)

capture rename cfps_age age
capture rename cfps_gender gender
capture rename cfps2016edu edu

keep if age <= 25

capture rename urban16 urban
label variable urban "Urban area (census definition)"

gen year = 2016

capture drop releaseversion
save tmp2016_group1_done.dta, replace

****************************************************
* 3. Build child variables for 2018
****************************************************
use ecfps2018famconf_202008.dta, clear

forvalues j = 1/10 {
    gen child_exist`j' = (pid_a_c`j' > 0)
    gen child_alive`j' = 0
    replace child_alive`j' = 1 if pid_a_c`j' > 0 & alive_a18_c`j' == 1
}

egen nchild_total = rowtotal(child_exist1-child_exist10)
egen nchild_alive = rowtotal(child_alive1-child_alive10)
gen has_child_alive = (nchild_alive > 0)

keep pid nchild_total nchild_alive has_child_alive
duplicates drop pid, force
save child2018_done.dta, replace

****************************************************
* 4. Prepare 2018 person file
* Keep completed interviews, merge child variables, harmonize
* variable names, restrict to age <= 25, and save a wave file.
****************************************************
use ecfps2018person_202012.dta, clear
keep if iinterv == 1

merge 1:1 pid using child2018_done.dta
drop _merge

replace nchild_total = 0 if missing(nchild_total)
replace nchild_alive = 0 if missing(nchild_alive)
replace has_child_alive = 0 if missing(has_child_alive)

capture rename cfps2018edu edu

keep if age <= 25

capture rename urban18 urban
label variable urban "Urban area (census definition)"

gen year = 2018

capture drop releaseversion
save tmp2018_group1_done.dta, replace

****************************************************
* 5. Build child variables for 2020
****************************************************
use ecfps2020famconf_202306.dta, clear

forvalues j = 1/10 {
    gen child_exist`j' = (pid_a_c`j' > 0)
    gen child_alive`j' = 0
    replace child_alive`j' = 1 if pid_a_c`j' > 0 & alive_a20_c`j' == 1
}

egen nchild_total = rowtotal(child_exist1-child_exist10)
egen nchild_alive = rowtotal(child_alive1-child_alive10)
gen has_child_alive = (nchild_alive > 0)

keep pid nchild_total nchild_alive has_child_alive
duplicates drop pid, force
save child2020_done.dta, replace

****************************************************
* 6. Prepare 2020 person file
****************************************************
use ecfps2020person_202306.dta, clear
keep if iinterv == 1

merge 1:1 pid using child2020_done.dta
drop _merge

replace nchild_total = 0 if missing(nchild_total)
replace nchild_alive = 0 if missing(nchild_alive)
replace has_child_alive = 0 if missing(has_child_alive)

capture rename cfps2020edu edu
capture rename qq9010n qq9010

keep if age <= 25

capture rename urban20 urban
label variable urban "Urban area (census definition)"

gen year = 2020

capture drop releaseversion
save tmp2020_group1_done.dta, replace

****************************************************
* 7. Build child variables for 2022
* The child pid variables may use either pid_a_c# or pid_c#.
* The code checks which naming convention is present.
****************************************************
use ecfps2022famconf_202410.dta, clear

capture confirm variable pid_a_c1
if _rc == 0 {
    forvalues j = 1/10 {
        gen child_exist`j' = (pid_a_c`j' > 0)
        gen child_alive`j' = 0
        replace child_alive`j' = 1 if pid_a_c`j' > 0 & alive_a22_c`j' == 1
    }
}
else {
    forvalues j = 1/10 {
        gen child_exist`j' = (pid_c`j' > 0)
        gen child_alive`j' = 0
        replace child_alive`j' = 1 if pid_c`j' > 0 & alive_a22_c`j' == 1
    }
}

egen nchild_total = rowtotal(child_exist1-child_exist10)
egen nchild_alive = rowtotal(child_alive1-child_alive10)
gen has_child_alive = (nchild_alive > 0)

keep pid nchild_total nchild_alive has_child_alive
duplicates drop pid, force
save child2022_done.dta, replace

use ecfps2022person_202410.dta, clear
keep if iinterv == 1

merge 1:1 pid using child2022_done.dta
drop _merge

replace nchild_total = 0 if missing(nchild_total)
replace nchild_alive = 0 if missing(nchild_alive)
replace has_child_alive = 0 if missing(has_child_alive)

capture rename cfps2022edu edu
capture rename qq9010n qq9010

keep if age <= 25

capture rename urban22 urban
label variable urban "Urban area (census definition)"

gen year = 2022

capture drop releaseversion
save tmp2022_group1_done.dta, replace

****************************************************
* 8. Append the four waves
* The result is an unbalanced panel for respondents observed
* at age <= 25 in at least one wave.
****************************************************
use tmp2016_group1_done.dta, clear
append using tmp2018_group1_done.dta
append using tmp2020_group1_done.dta
append using tmp2022_group1_done.dta


****************************************************
* 9. Construct work experience and job tenure proxies
* exp_years_win sums unique months worked within the recall
* window using main and other jobs without double counting.
* tenure_years measures current or most recent main-job tenure.
****************************************************
foreach v of varlist ///
    cyear cmonth ///
    egc104y egc104m egc104c egc1052y egc1052m egc201 ///
    egc2012y_a_1-egc2012y_a_10 ///
    egc2012m_a_1-egc2012m_a_10 ///
    egc2013y_a_1-egc2013y_a_10 ///
    egc2013m_a_1-egc2013m_a_10 ///
    egc2013c_a_1-egc2013c_a_10 {
    
    capture confirm variable `v'
    if !_rc {
        replace `v' = . if `v' < 0
    }
}

gen interview_ym = ym(cyear, cmonth)
format interview_ym %tm

gen window_start_ym = .
replace window_start_ym = ym(2014, 1) if year == 2016
replace window_start_ym = ym(2016, 1) if year == 2018
replace window_start_ym = ym(2018, 1) if year == 2020
replace window_start_ym = ym(2020, 1) if year == 2022
format window_start_ym %tm

gen main_start_ym = ym(egc1052y, egc1052m)
format main_start_ym %tm

gen main_end_ym = .
replace main_end_ym = interview_ym if egc104c == 1
replace main_end_ym = ym(egc104y, egc104m) ///
    if missing(main_end_ym) & !missing(egc104y) & !missing(egc104m)
format main_end_ym %tm

gen main_start_clip = .
replace main_start_clip = max(main_start_ym, window_start_ym) ///
    if !missing(main_start_ym, window_start_ym)

gen main_end_clip = .
replace main_end_clip = min(main_end_ym, interview_ym) ///
    if !missing(main_end_ym, interview_ym)

format main_start_clip main_end_clip %tm

forvalues j = 1/10 {

    gen other_start_`j' = ym(egc2012y_a_`j', egc2012m_a_`j')
    format other_start_`j' %tm

    gen other_end_`j' = .
    replace other_end_`j' = interview_ym if egc2013c_a_`j' == 1
    replace other_end_`j' = ym(egc2013y_a_`j', egc2013m_a_`j') ///
        if missing(other_end_`j') & !missing(egc2013y_a_`j') & !missing(egc2013m_a_`j')
    format other_end_`j' %tm

    gen other_start_clip_`j' = .
    replace other_start_clip_`j' = max(other_start_`j', window_start_ym) ///
        if !missing(other_start_`j', window_start_ym)

    gen other_end_clip_`j' = .
    replace other_end_clip_`j' = min(other_end_`j', interview_ym) ///
        if !missing(other_end_`j', interview_ym)

    format other_start_clip_`j' other_end_clip_`j' %tm
}

gen tenure_months = .
replace tenure_months = main_end_clip - main_start_clip + 1 ///
    if !missing(main_start_clip, main_end_clip) ///
    & main_end_clip >= main_start_clip

replace tenure_months = . if tenure_months <= 0

gen tenure_years = tenure_months / 12 if !missing(tenure_months)

label var tenure_months "Current job tenure in months"
label var tenure_years  "Current job tenure in years"

summ interview_ym, meanonly
local maxym = r(max)
local minym = ym(2014,1)

forvalues t = `minym'/`maxym' {
    gen worked_`t' = 0

    replace worked_`t' = 1 if !missing(main_start_clip, main_end_clip) ///
        & inrange(`t', main_start_clip, main_end_clip)

    forvalues j = 1/10 {
        replace worked_`t' = 1 if !missing(other_start_clip_`j', other_end_clip_`j') ///
            & inrange(`t', other_start_clip_`j', other_end_clip_`j')
    }

    replace worked_`t' = . if `t' > interview_ym

    replace worked_`t' = . if `t' < window_start_ym
}

egen exp_months_win = rowtotal(worked_*)
gen exp_years_win = exp_months_win / 12 if !missing(exp_months_win)

label var exp_months_win "Observed cumulative months worked within recall window"
label var exp_years_win  "Observed cumulative years worked within recall window"

sum exp_months_win exp_years_win tenure_months tenure_years, detail
count if missing(exp_years_win)
list pid year cyear cmonth exp_months_win tenure_months in 1/20

drop main_start_ym main_end_ym main_start_clip main_end_clip interview_ym window_start_ym
forvalues j = 1/10 {
    drop other_start_`j' other_end_`j' other_start_clip_`j' other_end_clip_`j'
}
drop worked_*


****************************************************
* 10. Construct average daily housework hours
* If daily housework is directly available, use it.
* Otherwise use the weighted weekday/weekend average:
*   (5 * weekday hours + 2 * weekend hours) / 7
****************************************************
foreach v in qq9010 qq9011 qq9012 {
    capture confirm variable `v'
    if !_rc {
        replace `v' = . if `v' < 0
    }
}

gen housework_hours = .

replace housework_hours = qq9010 if !missing(qq9010)

replace housework_hours = (5*qq9011 + 2*qq9012)/7 ///
    if missing(housework_hours) & !missing(qq9011) & !missing(qq9012)

label var housework_hours "Average daily housework hours"

sum housework_hours, detail
count if missing(housework_hours)
tab year if !missing(housework_hours)
list pid year qq9010 qq9011 qq9012 housework_hours in 1/20


****************************************************
* 11. Construct establishment and job controls
* Z controls:
*   employer_type5, firmsize4, industry6
* Extended job controls:
*   jobclass_self, occ_egp
****************************************************
foreach v in qg1 qg2 qg16 {
    capture confirm variable `v'
    if !_rc {
        replace `v' = . if `v' < 0
    }
}

gen jobclass_self = .
replace jobclass_self = 1 if qg1 == 1
replace jobclass_self = 0 if qg1 == 5
label var jobclass_self "Self/family business"

gen employer_type5 = .

replace employer_type5 = 1 if inlist(qg2, 1, 2, 8)

replace employer_type5 = 2 if qg2 == 3

replace employer_type5 = 3 if inlist(qg2, 4, 7)

replace employer_type5 = 4 if qg2 == 5

replace employer_type5 = 5 if inlist(qg2, 6, 9)

replace employer_type5 = 5 if missing(employer_type5) & !missing(qg2)

label define employer_type5_lbl ///
    1 "Government/public institution" ///
    2 "State-owned/state-controlled enterprise" ///
    3 "Private/individual/family" ///
    4 "Foreign-invested enterprise" ///
    5 "Other/unclear"

label values employer_type5 employer_type5_lbl
label var employer_type5 "Type of employer (grouped)"

replace qg16 = . if qg16 < 0

gen firmsize4 = .
replace firmsize4 = 1 if qg16 < 10
replace firmsize4 = 2 if qg16 >= 10 & qg16 <= 49
replace firmsize4 = 3 if qg16 >= 50 & qg16 <= 99
replace firmsize4 = 4 if qg16 >= 100 & !missing(qg16)

label define firmsize4_lbl 1 "<10" 2 "10-49" 3 "50-99" 4 "100+"
label values firmsize4 firmsize4_lbl
label var firmsize4 "Firm size group"

gen ln_qg16 = ln(qg16) if qg16 > 0
label var ln_qg16 "Log number of employees"

tab qg2, missing
tab employer_type5, missing
tab firmsize4, missing
sum qg16 ln_qg16, detail


****************************************************
* 12. Construct industry and occupation controls
* industry6 groups detailed industry labels into broad sectors.
* occ_egp keeps the EGP occupational class.
****************************************************
capture confirm numeric variable qg303code_egp
if !_rc {
    replace qg303code_egp = . if qg303code_egp < 0
}

capture confirm string variable qg302code
if _rc {
    decode qg302code, gen(industry_raw)
}
else {
    gen industry_raw = qg302code
}

replace industry_raw = trim(industry_raw)
replace industry_raw = "Other" if industry_raw == "Other "

replace industry_raw = "" if inlist(industry_raw, ///
    "Missing", "Not applicable", "Refuse", "Unknown", "Unable to code")

gen industry6 = .

replace industry6 = 1 if industry_raw == "Agriculture, forestry, animal husbandry and fishery"

replace industry6 = 2 if inlist(industry_raw, ///
    "Manufacturing", ///
    "Construction", ///
    "Mining", ///
    "Production and supply of electricity, gas and water")

replace industry6 = 3 if inlist(industry_raw, ///
    "Wholesale and retail", ///
    "Transportation, storage, and postal service", ///
    "Hotel and catering service")

replace industry6 = 4 if inlist(industry_raw, ///
    "Information transmission, computer service and software", ///
    "Finance", ///
    "Real estate", ///
    "Rental and commercial service")

replace industry6 = 5 if inlist(industry_raw, ///
    "Education", ///
    "Health, social security and public welfare", ///
    "Public administration and social organization", ///
    "Scientific research, technical service and geological prospecting", ///
    "Water resource, environment and public facilities management")

replace industry6 = 6 if inlist(industry_raw, ///
    "Residential and other service industry", ///
    "Culture, sports and recreation", ///
    "Other industries")

label define industry6_lbl ///
    1 "Agriculture" ///
    2 "Industry/construction/utilities" ///
    3 "Commerce/transport/hotel" ///
    4 "IT/finance/real estate/business" ///
    5 "Public/social services" ///
    6 "Other services/culture"

label values industry6 industry6_lbl
label var industry6 "Industry group"

capture confirm numeric variable qg303code_egp
if !_rc {
    gen occ_egp = qg303code_egp
}
else {
    encode qg303code_egp, gen(occ_egp)
}

label var occ_egp "Occupation class (EGP)"

tab industry6, missing
tab occ_egp, missing
tab year industry6, missing


****************************************************
* 13. Construct mobility proxies
* Mobility is used as a robustness control only because it may
* be affected by gender and may therefore be an intermediate
* outcome rather than a clean exogenous control.
****************************************************
foreach v in egc103 egc201 {
    capture confirm variable `v'
    if !_rc {
        replace `v' = . if `v' < 0
    }
}

gen mainjob_changed = .
replace mainjob_changed = 0 if egc103 == 1
replace mainjob_changed = 1 if egc103 == 5
label var mainjob_changed "Main job changed within recall window"

gen otherjob_count = egc201 if !missing(egc201)
replace otherjob_count = 0 if missing(otherjob_count) & !missing(mainjob_changed)
label var otherjob_count "Number of other jobs within recall window"

gen mobility_count_win = .
replace mobility_count_win = otherjob_count + mainjob_changed ///
    if !missing(otherjob_count) & !missing(mainjob_changed)

label var mobility_count_win "Mobility count proxy within recall window"

gen mobility_any_win = .
replace mobility_any_win = 1 if mobility_count_win > 0 & !missing(mobility_count_win)
replace mobility_any_win = 0 if mobility_count_win == 0
label var mobility_any_win "Any mobility within recall window"

gen mobility_count_sq = mobility_count_win^2 if !missing(mobility_count_win)
label var mobility_count_sq "Squared mobility count proxy"

tab mainjob_changed, missing
tab mobility_any_win, missing
sum otherjob_count mobility_count_win mobility_count_sq, detail

****************************************************
* 14. Final panel setup and income variable
****************************************************
xtset pid year

gen lninc = ln(incomeb) if incomeb > 0

****************************************************
* 15. Marital status handling
* Missing marital status is grouped with never married to keep
* the sample size, following the PDF discussion.
****************************************************
gen marital = qea0
replace marital = . if inlist(marital, -8, -2, -1)

tab marital, missing
tab marital year, missing

gen marital2 = marital
replace marital2 = 9 if missing(marital)
replace marital2 = 1 if marital2 == 9

label define marlbl ///
    1 "Never married" ///
    2 "Married" ///
    3 "Cohabitation" ///
    4 "Divorced" ///
    5 "Widowed" ///
    9 "Missing", replace
label values marital2 marlbl

tab marital2, missing
tab marital2 year, missing

tab year, missing
count if missing(year)

bysort pid: egen n_waves = count(year)
tab n_waves

****************************************************
* 16. Save the constructed analysis panel
****************************************************
save group1_ageLE25_unbalanced.dta, replace
display "Saved: group1_ageLE25_unbalanced.dta"



****************************************************

****************************************************

****************************************************
* 17. Model section: conditional log-income approach
* This section is synchronized with Latest_models_CLEAN.do.
* The log-income regressions are conditional on incomeb > 0.
****************************************************

capture which esttab
local have_esttab = (_rc == 0)
capture which eststo
local have_eststo = (_rc == 0)
capture which estadd
local have_estadd = (_rc == 0)

if !`have_esttab' | !`have_eststo' | !`have_estadd' {
    display as error "estout commands are not all available. Install estout if LaTeX exports fail."
}

use "group1_ageLE25_unbalanced.dta", clear

* Core sample and outcome.
capture drop lninc
gen lninc = ln(incomeb) if incomeb > 0
keep if lninc < .

* Clean controls used in the PDF model.
foreach v in gender age urban edu qp201 qea0 {
    capture confirm numeric variable `v'
    if !_rc {
        replace `v' = . if `v' < 0
    }
}

foreach v in female health marital2 {
    capture drop `v'
}
gen female = .
replace female = 1 if gender == 0
replace female = 0 if gender == 1
label var female "Female"
label define female_lbl 0 "Men" 1 "Women", replace
label values female female_lbl

gen health = qp201
label var health "Self-rated health"

gen marital2 = qea0
replace marital2 = 1 if missing(marital2)
label var marital2 "Marital status, missing set to never married"

drop if missing(pid, year, female, age)
xtset pid year

* Variable blocks following the PDF.
local X_personal ///
    c.age i.edu i.marital2 i.health i.urban ///
    c.housework_hours c.exp_years_win c.nchild_alive

local Z_establishment ///
    i.employer_type5 i.firmsize4 i.industry6

local job_controls ///
    jobclass_self i.occ_egp

local M_any ///
    mobility_any_win

local M_count ///
    c.mobility_count_win c.mobility_count_sq

* Keep the squared mobility term only when it has non-collinear support in the estimation sample.
quietly summarize mobility_count_win if !missing(mobility_count_win)
if r(max) <= 1 {
    local M_count c.mobility_count_win
}

****************************************************
* 1. Baseline descriptive pooled OLS
****************************************************
eststo clear

reg lninc female i.year, vce(cluster pid)
eststo ols1

reg lninc female `X_personal' i.year, vce(cluster pid)
eststo ols2

reg lninc female `X_personal' `Z_establishment' i.year, vce(cluster pid)
eststo ols3

reg lninc female `X_personal' `Z_establishment' `job_controls' i.year, vce(cluster pid)
eststo ols4

if `have_esttab' {
    esttab ols1 ols2 ols3 ols4 using "latest_table1_pooled_ols.tex", ///
        replace se star(* 0.10 ** 0.05 *** 0.01) ///
        keep(female age housework_hours exp_years_win nchild_alive) ///
        label b(%9.3f) se(%9.3f) stats(N r2, labels("Observations" "R-squared")) ///
        title("Baseline pooled OLS estimates")
}

****************************************************
* 2. Robustness models with mobility and tenure
****************************************************
eststo clear

reg lninc female `X_personal' `Z_establishment' i.year, vce(cluster pid)
eststo rob1

reg lninc female `X_personal' `Z_establishment' `M_any' i.year, vce(cluster pid)
eststo rob2

reg lninc female `X_personal' `Z_establishment' `M_count' i.year, vce(cluster pid)
eststo rob3

reg lninc female ///
    c.age i.edu i.marital2 i.health i.urban ///
    c.housework_hours c.tenure_years c.nchild_alive ///
    `Z_establishment' i.year, vce(cluster pid)
eststo rob4

if `have_esttab' {
    esttab rob1 rob2 rob3 rob4 using "latest_table2_robustness.tex", ///
        replace se star(* 0.10 ** 0.05 *** 0.01) ///
        keep(female age housework_hours exp_years_win tenure_years nchild_alive mobility_any_win mobility_count_win mobility_count_sq) ///
        label b(%9.3f) se(%9.3f) stats(N r2, labels("Observations" "R-squared")) ///
        title("Robustness checks")
}

****************************************************
* 3. CRE / Mundlak preferred specification
****************************************************
preserve

keep if n_waves >= 2
xtset pid year

* Individual means for continuous time-varying regressors.
capture drop age_bar housework_bar exp_years_bar nchild_alive_bar urban_bar jobclass_self_bar mobility_count_bar
bys pid: egen age_bar = mean(age)
bys pid: egen housework_bar = mean(housework_hours)
bys pid: egen exp_years_bar = mean(exp_years_win)
bys pid: egen nchild_alive_bar = mean(nchild_alive)
bys pid: egen urban_bar = mean(urban)
bys pid: egen jobclass_self_bar = mean(jobclass_self)
bys pid: egen mobility_count_bar = mean(mobility_count_win)

local C_personal age_bar housework_bar exp_years_bar nchild_alive_bar urban_bar
local C_job jobclass_self_bar
local C_mobility mobility_count_bar

* Individual means for categorical controls. Including all category means is fine;
* Stata will omit collinear terms automatically.
foreach p in edu_ mar_ hlth_ emp_ size_ ind_ occdum_ {
    capture drop `p'*
}

tab edu, gen(edu_)
tab marital2, gen(mar_)
tab health, gen(hlth_)
tab employer_type5, gen(emp_)
tab firmsize4, gen(size_)
tab industry6, gen(ind_)
tab occ_egp, gen(occdum_)

local C_edu
foreach v of varlist edu_* {
    bys pid: egen `v'_bar = mean(`v')
    local C_edu `C_edu' `v'_bar
}

local C_mar
foreach v of varlist mar_* {
    bys pid: egen `v'_bar = mean(`v')
    local C_mar `C_mar' `v'_bar
}

local C_hlth
foreach v of varlist hlth_* {
    bys pid: egen `v'_bar = mean(`v')
    local C_hlth `C_hlth' `v'_bar
}

local C_emp
foreach v of varlist emp_* {
    bys pid: egen `v'_bar = mean(`v')
    local C_emp `C_emp' `v'_bar
}

local C_size
foreach v of varlist size_* {
    bys pid: egen `v'_bar = mean(`v')
    local C_size `C_size' `v'_bar
}

local C_ind
foreach v of varlist ind_* {
    bys pid: egen `v'_bar = mean(`v')
    local C_ind `C_ind' `v'_bar
}

local C_occ
foreach v of varlist occdum_* {
    bys pid: egen `v'_bar = mean(`v')
    local C_occ `C_occ' `v'_bar
}

local M_X `C_personal' `C_edu' `C_mar' `C_hlth'
local M_Z `C_emp' `C_size' `C_ind'
local M_JOB `C_job' `C_occ'
local M_M `C_mobility'

eststo clear

xtreg lninc female i.year, re vce(cluster pid)
eststo cre1
estadd scalar mundlak_p = .

xtreg lninc female `X_personal' i.year ///
    `M_X', re vce(cluster pid)
eststo cre2
test `M_X'
estadd scalar mundlak_p = r(p)

xtreg lninc female `X_personal' `Z_establishment' i.year ///
    `M_X' `M_Z', re vce(cluster pid)
eststo cre3
test `M_X' `M_Z'
estadd scalar mundlak_p = r(p)

xtreg lninc female `X_personal' `Z_establishment' `job_controls' i.year ///
    `M_X' `M_Z' `M_JOB', re vce(cluster pid)
eststo cre4
test `M_X' `M_Z' `M_JOB'
estadd scalar mundlak_p = r(p)

if `have_esttab' {
    esttab cre1 cre2 cre3 cre4 using "latest_table3_cre_mundlak.tex", ///
        replace se star(* 0.10 ** 0.05 *** 0.01) ///
        keep(female age housework_hours exp_years_win nchild_alive) ///
        label b(%9.3f) se(%9.3f) ///
        stats(N mundlak_p, labels("Observations" "p-value of Mundlak joint test") fmt(%9.0f %9.4f)) ///
        title("Correlated random effects (Mundlak) estimates")
}

****************************************************
* 4. CRE robustness with mobility as an extended control
****************************************************
xtreg lninc female `X_personal' `Z_establishment' `M_count' i.year ///
    `M_X' `M_Z' `M_M', re vce(cluster pid)
eststo cre_mobility
test `M_X' `M_Z' `M_M'
estadd scalar mundlak_p = r(p)

if `have_esttab' {
    esttab cre_mobility using "latest_table4_cre_mobility.tex", ///
        replace se star(* 0.10 ** 0.05 *** 0.01) ///
        keep(female age housework_hours exp_years_win nchild_alive mobility_count_win mobility_count_sq) ///
        label b(%9.3f) se(%9.3f) ///
        stats(N mundlak_p, labels("Observations" "p-value of Mundlak joint test") fmt(%9.0f %9.4f)) ///
        title("CRE robustness with mobility")
}

restore

****************************************************
* 5. Age-by-female interaction model from PDF section 3.2
****************************************************
eststo clear

reg lninc i.female##ib18.age ///
    i.edu i.marital2 i.health i.urban ///
    c.housework_hours c.exp_years_win c.nchild_alive ///
    `Z_establishment' i.year, vce(cluster pid)
eststo age_interaction
tempvar age_interaction_sample
gen byte `age_interaction_sample' = e(sample)

margins age, dydx(female) saving("latest_age_gender_gap_margins.dta", replace)

if `have_esttab' {
    esttab age_interaction using "latest_table5_age_interaction.tex", ///
        replace se star(* 0.10 ** 0.05 *** 0.01) ///
        keep(1.female *.female#*.age) ///
        label b(%9.3f) se(%9.3f) stats(N r2, labels("Observations" "R-squared")) ///
        title("Age-specific gender income gaps")
}

* Main figure: model-adjusted log-income lines by gender and age.
* The vertical distance between the two lines is the model-implied
* conditional gender income gap at each age.
margins female, over(age) saving("latest_age_gender_predicted_lninc.dta", replace)
marginsplot, xdimension(age) plotdimension(female) recast(line) noci ///
    title("Model-adjusted log primary-job income by age") ///
    ytitle("Model-adjusted log primary-job income") ///
    xtitle("Age") ///
    legend(order(1 "Men" 2 "Women") rows(1) position(6)) ///
    name(age_gender_lines, replace)
graph export "latest_age_gender_lines.png", replace width(2000)
graph save "latest_age_gender_lines.gph", replace

* Descriptive comparison: observed mean log-income by gender and age.
* This graph uses the same estimation sample as the interaction model,
* but it does not adjust for controls.
preserve
keep if `age_interaction_sample'
collapse (mean) mean_lninc=lninc (count) n=lninc, by(age female)
twoway ///
    (line mean_lninc age if female==0, sort lcolor(blue) lwidth(medthick)) ///
    (line mean_lninc age if female==1, sort lcolor(red) lwidth(medthick)), ///
    title("Observed mean log primary-job income by age") ///
    ytitle("Mean log primary-job income") ///
    xtitle("Age") ///
    legend(order(1 "Men" 2 "Women") rows(1) position(6)) ///
    name(age_gender_observed_lines, replace)
graph export "latest_age_gender_observed_lines.png", replace width(2000)
graph save "latest_age_gender_observed_lines.gph", replace
restore

* Auxiliary figure: direct plot of the female-male adjusted gap by age.
margins age, dydx(female)
marginsplot, recast(line) noci ///
    yline(0, lpattern(dash)) ///
    title("Model-adjusted female-male log-income gap by age") ///
    ytitle("Women - men log primary-job income") ///
    xtitle("Age") ///
    name(age_gender_gap, replace)
graph export "latest_age_gender_gap.png", replace width(2000)
graph save "latest_age_gender_gap.gph", replace
