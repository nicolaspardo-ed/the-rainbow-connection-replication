/*
Reproducable do file for The Rainbow Connection 

Data are free to access with a data use agreement from 
https://uasdata.usc.edu/

To run this file: 
-change local to your working directory in line 22
-within your working directory create 2 folders "output" and "data"
-download waves 615, 567, 396, 479, 331, 207, 199, and 197

-Main variables come from 615, 567, and 396. 

*/
**# Packages

//ssc install egenmore
//ssc install estout, replace

**# Section 1: SETUP
	clear all
	local wd "your working directory"
	set seed 89740220 

	glo output "`wd'\output"
	glo data "`wd'\data"
	
	
*1a Create polid3 

use "${data}\uas567", clear 
keep uasid party_affil lean_affil
rename *affil =_567

merge 1:1 uasid using "${data}\uas479", keepusing(*affil)
rename *affil =_479
drop _merge 

merge 1:1 uasid using "${data}\uas331", keepusing(*affil)
rename *affil =_331
drop _merge

merge 1:1 uasid using "${data}\uas207",keepusing(cf003 cf003a)
rename cf003 cf003_207
rename cf003a cf003a_207
drop _merge

merge 1:1 uasid using "${data}\uas199",keepusing(cf003 cf003a)
rename cf003 cf003_199
rename cf003a cf003a_199
drop _merge

merge 1:1 uasid using "${data}\uas197",keepusing(cf003 cf003a)
rename cf003 cf003_197
rename cf003a cf003a_197
drop _merge

*keeping most recent affiliation
* Generate polid3
gen polid3 = .
lab var polid3 "Political ID"
lab def pol 0 "Democrat/lean Democrat" 1 "Republican/Lean Rep." 2 "Independent"
lab values polid3 pol

* Helper program: apply party + lean pair to polid3 where still missing
* For each wave, first use party var, then lean var to fill remaining missing

* Wave 567
replace polid3 = 0 if missing(polid3) & party_affil_567 == 1
replace polid3 = 1 if missing(polid3) & party_affil_567 == 2
replace polid3 = 2 if missing(polid3) & inlist(party_affil_567, 3,4,5,6,7)
replace polid3 = 0 if missing(polid3) & lean_affil_567 == 1
replace polid3 = 1 if missing(polid3) & lean_affil_567 == 2
replace polid3 = 2 if missing(polid3) & lean_affil_567 == 3

* Wave 479
replace polid3 = 0 if missing(polid3) & party_affil_479 == 1
replace polid3 = 1 if missing(polid3) & party_affil_479 == 2
replace polid3 = 2 if missing(polid3) & inlist(party_affil_479, 3,4,5,6,7)
replace polid3 = 0 if missing(polid3) & lean_affil_479 == 1
replace polid3 = 1 if missing(polid3) & lean_affil_479 == 2
replace polid3 = 2 if missing(polid3) & lean_affil_479 == 3

* Wave 331
replace polid3 = 0 if missing(polid3) & party_affil_331 == 1
replace polid3 = 1 if missing(polid3) & party_affil_331 == 2
replace polid3 = 2 if missing(polid3) & inlist(party_affil_331, 3,4,5,6,7)
replace polid3 = 0 if missing(polid3) & lean_affil_331 == 1
replace polid3 = 1 if missing(polid3) & lean_affil_331 == 2
replace polid3 = 2 if missing(polid3) & lean_affil_331 == 3

* Wave 318 (via wave 331 variables)
replace polid3 = 0 if missing(polid3) & uas318_party_affil_331 == 1
replace polid3 = 1 if missing(polid3) & uas318_party_affil_331 == 2
replace polid3 = 2 if missing(polid3) & inlist(uas318_party_affil_331, 3,4,5,6,7)
replace polid3 = 0 if missing(polid3) & uas318_lean_affil_331 == 1
replace polid3 = 1 if missing(polid3) & uas318_lean_affil_331 == 2
replace polid3 = 2 if missing(polid3) & uas318_lean_affil_331 == 3

* Wave 207
replace polid3 = 0 if missing(polid3) & cf003_207 == 1
replace polid3 = 1 if missing(polid3) & cf003_207 == 2
replace polid3 = 2 if missing(polid3) & inlist(cf003_207, 3,4,5,6,7)
replace polid3 = 0 if missing(polid3) & cf003a_207 == 1
replace polid3 = 1 if missing(polid3) & cf003a_207 == 2
replace polid3 = 2 if missing(polid3) & cf003a_207 == 3

* Wave 199
replace polid3 = 0 if missing(polid3) & cf003_199 == 1
replace polid3 = 1 if missing(polid3) & cf003_199 == 2
replace polid3 = 2 if missing(polid3) & inlist(cf003_199, 3,4,5,6,7)
replace polid3 = 0 if missing(polid3) & cf003a_199 == 1
replace polid3 = 1 if missing(polid3) & cf003a_199 == 2
replace polid3 = 2 if missing(polid3) & cf003a_199 == 3

* Wave 197
replace polid3 = 0 if missing(polid3) & cf003_197 == 1
replace polid3 = 1 if missing(polid3) & cf003_197 == 2
replace polid3 = 2 if missing(polid3) & inlist(cf003_197, 3,4,5,6,7)
replace polid3 = 0 if missing(polid3) & cf003a_197 == 1
replace polid3 = 1 if missing(polid3) & cf003a_197 == 2
replace polid3 = 2 if missing(polid3) & cf003a_197 == 3

tab polid3, missing

save "${data}/polid3_data", replace

*1b Merge waves

use "${data}\uas615", clear
	rename final_weight final_weight34
	missings dropvars, force
	svyset uasid [pweight=final_weight34]

	gen wave = 34
	
	*merge opinions
merge m:1 uasid using "${data}\uas567"
	drop _merge
	
	*merge religion 
merge m:1 uasid using "${data}\uas396", keepusing(b050_ b082_)
drop if _merge == 2
drop _merge
	
	*merge polid3
merge 1:1 uasid using "${data}\polid3_data", keepusing(polid3)

tab wave, miss
replace wave = 32 if wave == . 

*uas581 is oct 2023 replace LGBT self IDvariables on older ersion if missing 


*fill in identity
replace qb09 = uas581_qb09 if missing(qb09) & !missing(uas581_qb09)
replace qb11 = uas581_qb11 if missing(qb11) & !missing(uas581_qb11)


**# Section 2: INITIAL VARIABLE CONSTRUCTION

*social circle indicators 
	g nonhet_self = qb09!=3 if !missing(qb09)
		g het_self = nonhet_self==0 if !missing(nonhet_self)
	g nonhet_spouse = lgb_1==1 if !missing(lgb_1)
		g het_spouse = nonhet_spouse==0 if !missing(nonhet_spouse)
	g nonhet_fam = lgb_2==1 if !missing(lgb_2)
		g het_fam = nonhet_fam==0 if !missing(nonhet_fam)
	g nonhet_friend = lbg_3==1 if !missing(lbg_3)
		g het_friend = nonhet_friend==0 if !missing(nonhet_friend)
	g nonhet_soccirc = lgb_4==1 if !missing(lgb_4)
		g het_soccirc = nonhet_soccirc==0 if !missing(nonhet_soccirc)
	g noncis_self = qb11==1 if !missing(qb11)
		g cis_self = noncis_self==0 if !missing(noncis_self)
	g noncis_spouse = tg_soc1==1 if !missing(tg_soc1)
		g cis_spouse = noncis_spouse==0 if !missing(noncis_spouse)
	g noncis_fam = tg_soc2==1 if !missing(tg_soc2)
		g cis_fam = noncis_fam==0 if !missing(noncis_fam)
	g noncis_friend = tg_soc3==1 if !missing(tg_soc3)
		g cis_friend = noncis_friend==0 if !missing(noncis_friend)
	g noncis_soccirc = tg_soc4==1 if !missing(tg_soc4)
		g cis_soccirc = noncis_soccirc==0 if !missing(noncis_soccirc)

*Additional variables
gen lgbtself = 0 if het_self == 1 | cis_self == 1
replace lgbtself = 1 if nonhet_self == 1 | noncis_self == 1
label variable lgbtself "LGBT self"
lab def lgself 0 "non-LGBT" 1 "LGBT"
lab values lgbtself lgself

egen numlgbt = rowtotal(nonhet_soccirc nonhet_friend nonhet_fam nonhet_spouse noncis_soccirc noncis_fam noncis_friend noncis_spouse), missing
gen anylgbt = numlgbt
replace anylgbt = 1 if numlgbt > 0 & numlgbt != .

//simplifying education
gen educ = .
replace educ = 1 if education <= 8
replace educ = 2 if education > 8 & education < 13
replace educ = 3 if education >= 13 & !missing(education)
label define ed 1 "Less than hs" 2 "HS grad to some assoc." 3 "College+"
label val educ ed
lab var educ "Education"

//relabel race
lab def racealt 1 "White" 2 "Black" 3 "AIAN" 4 "Asian" 5 "Hawaiian/PI" 6 "Multiracial"
lab values race racealt

lab def hisp 0 "non-Latino" 1 "Latino"
lab values hisplatino hisp

//simplifying hhincome
gen hhincome2 = .
replace hhincome2 = 1 if hhincome >= 1 & hhincome <10
replace hhincome2 = 2 if hhincome >= 10 & hhincome <13
replace hhincome2 = 3 if hhincome >= 13 & !missing(hhincome)
lab var hhincome2 "Household Income"
label define income 1 "<30k" 2 "30 to 59k" 3 ">60k"
label values hhincome2 income

//more indicators
egen numlgb = rowtotal(nonhet_soccirc nonhet_friend nonhet_fam nonhet_spouse), missing
gen anylgb = numlgb
replace anylgb = 1 if numlgb >0 & !missing(numlgb)

egen numtrans = rowtotal(noncis_soccirc noncis_fam noncis_friend noncis_spouse), missing
gen anytrans = numtrans
replace anytrans = 1 if numtrans >0  & !missing(numtrans)


egen dem_kids518 = rcount(hhmemberage_*), cond(@>4 & @<19 & !missing(@))
la var dem_kids518 "Count of school-aged children in HH"


egen lgbt_spouse = rowmax(nonhet_spouse noncis_spouse)
egen lgbt_fam = rowmax(nonhet_fam noncis_fam)
egen lgbt_friend = rowmax(nonhet_friend noncis_friend)
egen lgbt_soccirc = rowmax(nonhet_soccirc noncis_soccirc)

*More labels
lab var gender "Gender"

foreach var of varlist lgbt_*{
	loc lbl = substr("`var'", 6, .)
	label var `var' "LBGT `lbl'"
}

label def uslab 0 "Born not US" 1 "US Born"
label values bornus uslab

label def citlab 0 "not US citizen" 1 "US Citizen"
label values citizenus citlab

label def partisan  0 "Dem or lean D" 1 "Rep. or lean R" 2 "Indep."
label values polid3 partisan

label var anylgbt "Any LGBT network"
lab def algbt 0 "No LGBT network" 1 "LGBT network"
lab values anylgbt algbt
label var anytrans "Any Transgender network"
lab def atrans 0 "No Transgender network" 1 "Transgender network"
lab values anytrans atrans
label var anylgb "Any LGB network"

lab def algb 0 "No LGB network" 1 "LGB network"
lab values anylgb algb

lab var hisplatino "Ethnicity"

gen religiosity = .
replace religiosity = 0 if b082_ == 5
replace religiosity = 1 if b082_ == 4
replace religiosity = 2 if b082_ == 3
replace religiosity = 3 if b082_ == 2
replace religiosity = 4 if b082_ == 1

label var religiosity "Religiousity based on freq. of relig attend"
lab def relig 0 "No services" 1 "Annual" 2 "Monthly" 3 "Weekly" 4 "More than weekly"
label values religiosity relig


**# Section 3: RQ1 DESCRIPTIVE BLOCK 
// What proportion of Americans have an LGBT person in their social circle and how does this vary by subgroup?


**#descriptives social circle
*36 rows: 1 overall + ~35 demographic subcategories; 21 cols: 7 network outcomes x 3 (proportion, SE, p-value)
mat def crosstabs_bmat = J(36,21,.)

loc colnum 1
foreach y in anylgbt anylgb anytrans lgbt_soccirc lgbt_friend lgbt_fam lgbt_spouse{
    loc row 1
    svy: mean `y'
    mat temp = r(table)
    mat crosstabs_bmat[`row',`colnum'] = round(temp[1,1] *100,0.01)
    mat crosstabs_bmat[`row',`colnum'+1] = round(temp[2,1] *100,0.01)

    loc row 2
    foreach x in lgbtself polid3 gender hhincome2 bornus citizenus religiosity educ race hisplatino{
        levelsof `x'
        loc b 1
        foreach n of numlist `r(levels)' {
            quietly svy: mean `y' if `x' == `n'
            mat temp = r(table)
            mat crosstabs_bmat[`row',`colnum'] = round(temp[1,1] *100, 0.01)
            mat crosstabs_bmat[`row',`colnum'+1] = round(temp[2,1] *100, 0.01)
            loc ++row
            loc ++b
        }
    }
    loc ++colnum
    loc ++colnum
    loc ++colnum
}
mat list crosstabs_bmat

mat colnames crosstabs_bmat = "LGBT network" "se" "pval" "LGB network" "se" "pval" "Transgender network" "se" "pval" "Broader Network contains LGBT" "se" "pval" "Friend contains LGBT" "se" "pval" "Family contains LGBT" "se" "pval" "Spouse is LGBT" "se" "pval"

*second pass: fill p-value col (every 3rd col) using omnibus F-test across all levels of each predictor
loc c 3
local predictor lgbtself polid3 gender hhincome2 bornus citizenus religiosity educ race hisplatino

foreach y in anylgbt anylgb anytrans lgbt_soccirc lgbt_friend lgbt_fam lgbt_spouse {
    loc r 2
    foreach pred of local predictor {
        qui svy: reg `y' ib0.`pred'
        qui levelsof(`pred')
        loc lvls: word count `r(levels)'
        loc hlvl: word `lvls' of `r(levels)'
        loc first: word 1 of `r(levels)'
        loc scnd: word 2 of `r(levels)'
        local totest
        loc totest "`first'.`pred'"
        forval i = `scnd'/`hlvl' {
            loc totest "`totest' = `i'.`pred'"
        }
        di "`totest'"
        test "`totest'"
        loc pval: di %5.4f `r(p)'

        levelsof `pred'
        forvalues i = 1/`r(r)' {
            mat crosstabs_bmat[`r',`c'] = `pval'
            loc ++r
        }
    }
    loc ++c
    loc ++c
    loc ++c
}
mat list crosstabs_bmat
putexcel set "${output}/crosstab_b",replace
putexcel A2 = "Overall"

loc row 3
foreach var of varlist lgbtself polid3 gender hhincome2 bornus citizenus religiosity educ race hisplatino{
    local varlab : variable label `var'
    putexcel A`row' = "`varlab'"
    levelsof `var'
    foreach n of numlist `r(levels)' {
        local vallab: label (`var') `n'
        putexcel B`row' = "`vallab'"
        loc ++row
    }
}

putexcel C1 = matrix(crosstabs_bmat), colnames


**#Whole sample demographics
putexcel set "${output}/sampledemog", replace
matrix demog = J(100,40,.)

loc rownum 1
foreach var of varlist lgbtself polid3 gender hhincome2 bornus citizenus religiosity educ race hisplatino{

	svy: prop `var'
	mat temp  = r(table)
	mat demog [`rownum',3] = e(_N)
	levelsof `var'
	loc b 1
	foreach n of numlist `r(levels)'{
		mat demog [`rownum',1] = temp[1,`b']
		mat demog [`rownum',2] = temp[2,`b']
		loc ++rownum
		loc ++b

		sleep 10
	}
}

matrix colnames demog = "prop" "se" "n" "propb" "seb" "nb"

loc row 2
foreach var of varlist lgbtself polid3 gender hhincome2 bornus citizenus religiosity educ race hisplatino{
	local varlab : variable label `var'
	putexcel A`row' = "`varlab'"
	levelsof `var'
	foreach n of numlist `r(levels)'{
		local vallab: label (`var') `n'
		putexcel B`row' = "`vallab'"
		loc ++row
	}
}

//Additional descriptives (in text)
gen trans_only = (anytrans == 1 & anylgb == 0)
gen lgb_only   = (anytrans == 0 & anylgb == 1)

svy: mean trans_only lgb_only


**# Section 4: IRT ITEM CLEANUP & SCALE GLOBALS

* recoding for polytomous irt
foreach var of varlist lg0*{
	g agree`var' = .
	replace agree`var' = `var' if `var' < 5
}


//Dropping invalid items
svy: mean lg001k
svy: mean lg001w

ttest agreelg001k == agreelg001w, unpair
ttest agreelg002k == agreelg002w, unpair

drop agreelg001w agreelg001k

drop agreelg00?a
drop agreelg00?c
drop agreelg00?m
drop agreelg00?k

*vars needed

label variable lgbtself "LGBT self"
lab def lself 0 "non-LGBT" 1 "LGBT"
lab values lgbtself lself

lab def genl 0 "Female" 1 "Male"
lab values gender genl

capture drop agreelg00?a agreelg00?c agreelg00?k agreelg00?m  agreelg001w    //make sure dropped all final invalid items

glo lgb_scale agreelg001b agreelg002b agreelg001d agreelg002d agreelg001e agreelg002e agreelg001g agreelg002g agreelg001i agreelg002i agreelg001n agreelg002n agreelg001o agreelg002o agreelg001q agreelg002q agreelg001r agreelg002r agreelg002w agreelg00?p

glo trans_scale agreelg001f agreelg002f agreelg001h agreelg002h agreelg001j agreelg002j agreelg001l agreelg002l agreelg001s agreelg002s agreelg002u agreelg001v agreelg002v agreelg001x agreelg002x

glo lgbt_scale agreelg00?b agreelg00?d  agreelg00?e agreelg00?g agreelg00?i agreelg00?n agreelg00?o agreelg00?q agreelg00?r agreelg00?t agreelg00?w agreelg00?f agreelg00?h agreelg00?j agreelg00?l agreelg00?s agreelg00?u agreelg00?x

svyset uasid [pweight=final_weight] //now from the lgbt topic (567) wave

**# Social circle

lab var lgb_only "LGB network only"
lab var anylgbt "LGBT network"
lab var anylgb "Any LGB network"
lab var anytrans "Any transgender network"

egen meanscore = rowmean(${lgbt_scale})
egen meanscorelg = rowmean(${lgb_scale})
egen meanscoret = rowmean(${trans_scale})
**# Section 5: COMPLETE CASE SUBSAMPLE

drop if final_weight == .

egen TODROP = rowmiss(lgbtself polid3 gender hhincome2 bornus citizenus religiosity educ race hisplatino age anylgbt anytrans lgbt_spouse lgbt_fam lgbt_friend lgbt_soccirc)
tab TODROP

drop if TODROP > 0 & TODROP != .
count


**# Section 6: IRT MODEL FITTING

quietly irt grm ${lgbt_scale}
eststo grmlgbt
quietly predict theta_lgbt, latent

quietly irt grm ${lgb_scale}
eststo grmlgb
predict theta_lgb, latent

quietly irt grm ${trans_scale}
eststo grmtrans
predict theta_trans, latent


**# Section 7: SUBSAMPLE DEMOGRAPHICS

putexcel set "${output}/sampledemog", modify

loc rownum 1
foreach var of varlist lgbtself polid3 gender hhincome2 bornus citizenus religiosity educ race{

	svy: prop `var'
	mat temp  = r(table)
	mat demog [`rownum',6] = e(_N)
	levelsof `var'
	loc b 1
	foreach n of numlist `r(levels)'{
		mat demog [`rownum',4] = temp[1,`b']
		mat demog [`rownum',5] = temp[2,`b']
		loc ++rownum
		loc ++b
	}
}

putexcel C1 = matrix(demog), colnames
mat list demog

**# Section 8: FIGURES

gr tw (scatter meanscore theta_lgbt, msize(tiny) mcolor(grey)) , xline(-1, lpattern(dash)) xline(1, lpattern(dash)) xtitle("Predicted Theta") ylabel(#10) xlabel(#10) ytitle("Mean item approval")
gr export "${output}/figure2_mean_vs_theta.eps", replace


gr tw (kdensity theta_lgbt) (kdensity theta_trans) (kdensity theta_lgb), xtitle("Predicted Theta") ytitle("Density") ///
  legend(order(1 "LGBT scale" 2 "Trans scale" 3 "LGB Scale") position(2) col(1) ring(0))

gr export "${output}/figure1_theta_distribution.eps", replace


**# Section 9: PRIMARY REGRESSION MODELS

loc X1 gender age lgbtself i.religiosity i.citizenus i.bornus i.educ i.race i.hisplatino i.hhincome2 i.anylgbt i.polid3 //RQ2

loc X3 gender age lgbtself i.religiosity i.citizenus i.bornus i.educ i.race i.hisplatino i.hhincome2 lgbt_* i.polid3 //RQ3
loc X4 gender age lgbtself i.religiosity i.citizenus i.bornus i.educ i.race i.hisplatino i.hhincome2 i.polid3 anytrans lgb_only //RQ4

loc Y theta_lgb theta_trans theta_lgbt

svyset uasid [pweight=final_weight]

egen analyticsample = rowmiss(gender age lgbtself religiosity citizenus bornus educ race hisplatino hhincome2 polid3)

svy: reg theta_lgbt i.anylgbt if analyticsample == 0
eststo bivar

*i=1 is RQ2 (any LGBT network), i=3 is RQ3 (network type), i=4 is RQ4 (LGB vs trans)
foreach y of loc Y{
	loc regname = substr("`y'", 7, .)
	foreach i in 1 3 4{
		if ("`regname'"=="trans" & `i' == 4){
			loc X4 gender age lgbtself i.religiosity i.citizenus i.bornus i.educ i.race i.hisplatino i.hhincome2 i.polid3 anytrans lgb_only
		}
svy: reg  `y' `X`i''
eststo `regname'`i'
	}
}

//Creating mutually exclusive indicators for alternative reference category
egen non_spouseb = rowmax(lgbt_friend lgbt_soccirc lgbt_fam)
egen non_famb = rowmax(lgbt_friend lgbt_soccirc lgbt_spouse)
egen non_friendb = rowmax(lgbt_fam lgbt_soccirc lgbt_spouse)
egen non_soccircb = rowmax(lgbt_friend lgbt_fam lgbt_spouse)

gen non_spouse = (non_spouseb == 1 & lgbt_spouse == 0)
gen non_fam = (non_famb == 1 & lgbt_fam == 0)
gen non_friend = (non_friendb == 1 & lgbt_friend == 0)
gen non_soccirc = (non_soccircb == 1 & lgbt_soccirc == 0)

lab def n1 0 "nnn" 1 "non-spouse LGBT network"
lab def n2 0 "nnn" 1 "non-family LGBT network"
lab def n3 0 "nnn" 1 "non-friend LGBT network"
lab def n4 0 "nnn" 1 "non-broader LGBT network"

lab values non_spouse n1
lab values non_fam n2
lab values non_friend n3
lab values non_soccirc n4

*RQ3 with with non focal control
foreach v in lgbt_fam lgbt_spouse lgbt_friend lgbt_soccirc{
	if ("`v'"=="lgbt_spouse"){
		loc v2 non_spouse
		}
	if ("`v'"=="lgbt_fam"){
		loc v2 non_fam
		}
	if ("`v'"=="lgbt_friend"){
		loc v2 non_friend
		}
	if ("`v'"=="lgbt_soccirc"){
		loc v2 non_soccirc
		}

	svy: reg theta_lgbt `v2' `v' gender age lgbtself i.religiosity i.citizenus i.bornus i.educ i.race i.hisplatino i.hhincome2 i.polid3
	eststo a_3`v'
}
suest a_3*
eststo a_sysm

test ([a_3lgbt_spouse]lgbt_spouse = [a_3lgbt_fam]lgbt_fam) ([a_3lgbt_friend]lgbt_friend = [a_3lgbt_fam]lgbt_fam) ([a_3lgbt_friend]lgbt_friend = [a_3lgbt_soccirc]lgbt_soccirc), mtest(b)

//labeling
label var theta_lgbt "LGBT Approval"
label var theta_lgb "LGB Approval"
label var theta_trans "Transgender Approval"

lab var lgbt_fam "LGBT family"
lab var lgbt_soccirc "LGBT broader network"

foreach var of varlist lgbt_spouse lgbt_friend{
	loc lbl = substr("`var'", 6, .)
	label var `var' "LGBT `lbl'"
}


**# Section 10: PRIMARY OUTPUT TABLES

esttab lgbt1 bivar using "${output}\table2_rq2_lgbt_main", se(3) star l depvars wide replace compress csv noeqlines nobaselevels nonumber nogaps scalars(N) order(1.anylgbt) addnotes("Omitted reference values for categorical variables are: White, Democrat/Lean Democrat, Education Less than HS(highschool)  and Less than annual religious services. AIAN is American Indian or Alaska Native. PI is Pacific Islander")

esttab a_sysm using "${output}\table3_rq3_network_type", se(3) star label depvars wide replace csv nobaselevels  noeqlines compress nonumber nogaps unstack scalars(N) order(lgbt_fam non_fam lgbt_spouse non_spouse lgbt_friend non_friend lgbt_soccirc non_soccirc lgbtself) addnotes("Omitted reference values for categorical variables are: White, Democrat/Lean Democrat, Education Less than HS(highschool) and Less than annual religious services. AIAN is American Indian or Alaska Native. PI is Pacific Islander")

esttab *4 using "${output}\table4_rq4_lgb_v_trans", se(3) star l depvars wide replace csv nobaselevels  compress noeqlines nonumber nogaps scalars(N) order(lgb_only anytrans) addnotes("Omitted reference values for categorical variables are: White, Democrat/Lean Democrat, Education Less than HS(highschool) and Less than annual religious services. AIAN is American Indian or Alaska Native. PI is Pacific Islander")

**# Wald tests for LGB/trans var (RQ4)
est rest trans4
test lgb_only=anytrans

est rest lgb4
test lgb_only=anytrans

est rest lgbt4
test lgb_only=anytrans

**# Wald tests for family, friend etc (RQ3)
foreach v in lgbt lgb trans{
est rest `v'3
test (lgbt_fam = lgbt_friend) (lgbt_friend = lgbt_soccirc) (lgbt_fam = lgbt_soccirc),  mtest(holm)
}


**# Section 11: ROBUSTNESS — KONFOUND
*assessing sensitivity to confounders in the main regression
loc X1 gender age lgbtself i.religiosity i.citizenus i.bornus i.educ i.race i.hisplatino i.hhincome2 anylgbt i.polid3

svy: reg theta_lgbt `X1'
konfound anylgbt


**# Section 12: ROBUSTNESS — AIPW

* Generate division number based on state FIPS code
gen region_num = .

* Division 1: New England
replace region_num = 1 if inlist(statereside, 9,23,25,33,44,50)

* Division 2: Middle Atlantic
replace region_num = 2 if inlist(statereside, 34,36,42)

* Division 3: East North Central
replace region_num = 3 if inlist(statereside, 17,18,26,39,55)

* Division 4: West North Central
replace region_num = 4 if inlist(statereside, 19,20,27,29,31,38,46)

* Division 5: South Atlantic
replace region_num = 5 if inlist(statereside, 10,11,12,13,24,37,45,51,54)

* Division 6: East South Central
replace region_num = 6 if inlist(statereside, 1,21,28,47)

* Division 7: West South Central
replace region_num = 7 if inlist(statereside, 5,22,40,48)

* Division 8: Mountain
replace region_num = 8 if inlist(statereside, 4,8,16,30,32,35,49,56)

* Division 9: Pacific
replace region_num = 9 if inlist(statereside, 2,6,15,41,53)

* Generate division names
gen str20 region_name = ""
replace region_name = "New England"         if region_num == 1
replace region_name = "Middle Atlantic"     if region_num == 2
replace region_name = "East North Central"  if region_num == 3
replace region_name = "West North Central"  if region_num == 4
replace region_name = "South Atlantic"      if region_num == 5
replace region_name = "East South Central"  if region_num == 6
replace region_name = "West South Central"  if region_num == 7
replace region_name = "Mountain"            if region_num == 8
replace region_name = "Pacific"             if region_num == 9

labmask region_num, values(region_name)

loc X1 gender age lgbtself i.religiosity i.citizenus i.bornus i.educ i.race i.hisplatino i.hhincome2  i.polid3  //outcome covariates

loc X2 gender c.age##c.age lgbtself i.religiosity i.citizenus i.bornus i.education i.race i.hisplatino i.hhincome i.polid3 i.region_num i.maritalstatus dem_kids518 //propensity score covar
loc W anylgbt
loc Y theta_lgbt

*first pass: identify out-of-support obs; second pass drops them and re-estimates
capture teffects aipw (`Y' `X1', linear) (`W' `X2') , osample(outsupport2)

preserve

drop if outsupport2 == 1

loc X1 gender age lgbtself i.religiosity i.citizenus i.bornus i.educ i.race i.hisplatino i.hhincome2  i.polid3

loc X2 gender c.age##c.age lgbtself i.religiosity i.citizenus i.bornus i.education i.race i.hisplatino i.hhincome i.polid3 i.region_num i.maritalstatus dem_kids518
loc W anylgbt
loc Y theta_lgbt

*sample regression
reg theta_lgbt `W' `X1', vce(robust) 
eststo r1_sample
esttab r1_sample using "${output}/table6b_sampleols", se(3) star l depvars replace compress wide csv nobaselevels nogaps scalars(N)

teffects aipw (`Y' `X1', linear) (`W' `X2'), vce(robust)
//teffects aipw (`Y' `X1', linear) (`W' `X2'), vce(robust) pomeans aequations

eststo r1aipw
esttab r1aipw using "${output}/table6_sampleaipw", se(3) star l depvars replace compress csv noeqlines nobaselevels nonumber nogaps unstack scalars(N)

teoverlap

tebalance summarize gender age lgbtself i.hhincome2 i.polid3 i.educ i.race i.region_num
matrix size = r(size)
matrix balance_stats = r(table)

esttab m(balance_stats) using "${output}/tableC1_balance",  l depvars replace compress csv  nogaps

restore


**# Section 13: ROBUSTNESS — MEAN SCORE MODELS

loc X1 gender age lgbtself i.religiosity i.citizenus i.bornus i.educ i.race i.hisplatino i.hhincome2 i.anylgbt i.polid3

loc X2 gender age lgbtself i.religiosity i.citizenus i.bornus i.educ i.race i.hisplatino i.hhincome2 i.polid3 anytrans lgb_only

*RQ2
svy: reg meanscore `X1'
eststo r1_mean

*RQ4
svy: reg meanscore `X2'
eststo r2_mean

*RQ3 with non-focal control (mean score)
foreach v in lgbt_fam lgbt_spouse lgbt_friend lgbt_soccirc{
	if ("`v'"=="lgbt_spouse"){
		loc v2 non_spouse
		}
	if ("`v'"=="lgbt_fam"){
		loc v2 non_fam
		}
	if ("`v'"=="lgbt_friend"){
		loc v2 non_friend
		}
	if ("`v'"=="lgbt_soccirc"){
		loc v2 non_soccirc
		}
	svy: reg meanscore `v2' `v' gender age lgbtself i.religiosity i.citizenus i.bornus i.educ i.race i.hisplatino i.hhincome2 i.polid3
	eststo m`v'_mean
}
suest m*_mean
eststo m_sysm

lab var meanscore "Mean LGBT item score"

esttab r1_mean r2_mean using "${output}/tableD1_rq2", se(3) star l wide depvars replace compress csv noeqlines nobaselevels nonumber nogaps scalars(N) order(*lgbt lgb* *trans) addnotes("Omitted reference values for categorical variables are: White, Democrat/Lean Democrat, Education Less than HS(highschool)  and Less than annual religious services. AIAN is American Indian or Alaska Native. PI is Pacific Islander")

esttab m_sysm using "${output}/tableD2_rq3", se(3) wide star l depvars replace compress csv noeqlines nobaselevels nonumber nogaps unstack scalars(N) order(lgbt_fam non_fam lgbt_spouse non_spouse lgbt_friend non_friend lgbt_soccirc non_soccirc lgbtself) addnotes("Omitted reference values for categorical variables are: White, Democrat/Lean Democrat, Education Less than HS(highschool)  and Less than annual religious services. AIAN is American Indian or Alaska Native. PI is Pacific Islander")


**# Section 14: ROBUSTNESS — UNIFIED NETWORK TYPES

loc X3 gender age lgbtself i.religiosity i.citizenus i.bornus i.educ i.race i.hisplatino i.hhincome2 lgbt_* i.polid3

svy: reg theta_lgbt `X3'

test lgbt_fam = lgbt_friend = lgbt_spouse = lgbt_soccirc, mtest(holm)

margins,dydx( lgbt_spouse lgbt_fam lgbt_friend lgbt_soccirc)

eststo networks

esttab networks using "${output}/table5_unified_networktype", se(3) star l wide depvars replace compress csv noeqlines nobaselevels nonumber nogaps scalars(N) order(lgb* ) addnotes("Omitted reference values for categorical variables are: White, Democrat/Lean Democrat, Education Less than HS(highschool)  and Less than annual religious services. AIAN is American Indian or Alaska Native. PI is Pacific Islander")



**# Section 14: DEMOGRAPHICS COMPARISON & CROSSTABS CLEANUP

preserve
import excel "${output}/sampledemog", first clear

keep A-nb

//filling in the ns
replace n = n[_n - 1] if n == .
replace nb = nb[_n - 1] if nb == .

drop if _n > 26
//manually implementing independent samples t test

gen num = prop - propb
gen denom = sqrt((se*se)+(seb*seb))

gen t = num /denom
gen df = (((se^2/n)+(seb^2/nb))^2)/((se^4)/((n^2)*(n-1))+(seb^4)/((nb^2)*(nb-1)))
gen pval = 2 *ttail(df, abs(t))

//Need to manually add to the table the national dems
gen nationaldemo = .

*Source: Race/ethnicity: https://www.census.gov/quickfacts/fact/table/US/INC110223
replace nationaldemo = 50.5 if B == "0 Female"
replace nationaldemo = 45.5 if B == "1 Male"

replace nationaldemo = 75.3 if B == "White"
replace nationaldemo = 13.7 if B == "Black"
replace nationaldemo = 6.4 if B == "Asian"
replace nationaldemo = 1.3 if B == "AIAN"
replace nationaldemo = 0.3 if B == "Hawaiian/PI"
replace nationaldemo = 3.1 if B == "Multiracial"

*source: https://data.census.gov/table?q=education
replace nationaldemo = 10.2 if B == "Less than hs"
replace nationaldemo = 53.6 if B == "HS grad to some assoc."
replace nationaldemo = 36.2 if B == "College+"

gen source = "Note - Summary statistics are survey weighted. Source for gender/race: https://www.census.gov/quickfacts/fact/table/US/INC110223, Source for Education: https://data.census.gov/table?q=education" if _n ==1

drop se* num denom

replace prop = round(prop * 100, .1)
replace propb = round(propb * 100, .1)

drop t df
lab var prop "Whole Sample %"
lab var propb "Subsample %"
lab var nationaldemo "National %"
lab var nb "n"
lab var pval "Significance of independent sample t-test"

export excel "${output}/tableB1_sample_comparisons", firstrow(varlabel) replace
restore

// Import crosstab, recode p-values to asterisks, export
import excel "${output}/crosstab_b", firstrow clear

foreach v of varlist pval H K N Q T W {
    tempvar `v'copy
    gen ``v'copy' = `v'

    tostring `v', replace
    replace `v' = "-" if ``v'copy' == .
    replace `v' = "*" if ``v'copy' < 0.05
    replace `v' = "**" if ``v'copy' < 0.01
    replace `v' = "***" if ``v'copy' < 0.001
    replace `v' = "ns" if ``v'copy' > 0.05 & ``v'copy' != .
}

export excel "${output}/table1_crosstabs", firstrow(varia) replace
