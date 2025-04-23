
log using "...\04_cprd_results.smcl"

///////////////////////////////////////////////////////////////////////////////
// CMD in Young people 
// 
// CPRD analysis 
// Updated March 2025
// J Dykxhoorn 
///////////////////////////////////////////////////////////////////////////////


cd "... data\cprd"
use "cprd_analytic_v3.dta", clear


///////////////////////////////////////////////////////////////////////////////
// Descriptives

// Additional information for manuscript text 
*unique patients 
bysort patid: gen n=_n
tab n 
 
* Generate "never_cmd" variable
egen never_cmd = min(cmd), by(patid)
	replace never_cmd = 1 - never_cmd
	tab never_cmd if n==1

* Generate total number of times cmd==1 by patient ID
egen cmd_count = total(cmd==1), by(patid)
	tab cmd_count
	tab cmd_count if n==1
 
* Generate total follow-up time by patient ID
tabstat pyears, stat(sum min max iqr) format(%9.0f)

egen total_followup = total(pyears), by(patid)
	tabstat total_followup,  stat(sum min max iqr)

	
// Descriptives - Table 1
	
forvalues i=2009/2019 {
	
tab cmd if year==`i', m
	tabstat pyears if year==`i', stat(sum min max)
tab sex cmd if year==`i', m row
	bysort sex: tabstat pyears if year==`i', stat(sum min max)
tab agegroup5 cmd if year==`i'
	 bysort agegroup5: tabstat pyears if year==`i', stat(sum min max)
tab cohort cmd if year==`i'
	 bysort cohort: tabstat pyears if year==`i', stat(sum min max)
tab ethnicity cmd if year==`i'
	bysort ethnicity: tabstat pyears if year==`i', stat(sum min max) 
tab country cmd if year==`i'
	bysort country: tabstat pyears if year==`i', stat(sum min max)
tab region cmd if year==`i'
	 bysort region: tabstat pyears if year==`i', stat(sum min max)
tab prac_imd cmd if year==`i'
	bysort prac_imd: tabstat pyears if year==`i', stat(sum min max)
	}
	
	
///////////////////////////////////////////////////////////////////////////////
// Incidence rates
stset time_out, id(patid) fail(cmd) origin(time_in) enter(time_in) scale(365.23)

//Total cases and person-years
stptime, per(1000)

//Overall
stptime, per(1000) by(year) dd(2)

//Sex
bysort sex: stptime, per(1000) by(year) dd(2)


//Age
 bysort agegroup5: stptime, per(1000) by(year) dd(2)

//Cohort 
bysort cohort: stptime, per(1000) by(year) dd(2)

//Ethnicity
bysort ethnicity: stptime, per(1000) by(year) dd(2)

// Country 
bysort country: stptime, per(1000) by(year) dd(2)

//Region
bysort region: stptime, per(1000) by(year) dd(2)

//Area deprivation
bysort prac_imd: stptime, per(1000) by(year) dd(2)


*Testing for trend over time 
stcox year 
stcox i.year

bysort sex: stcox year 
bysort agegroup5: stcox year
bysort cohort: stcox year
bysort ethnicity: stcox year
bysort country: stcox year
bysort region: stcox year
bysort prac_imd: stcox year




// Test interaction terms
stset time_out, id(patid) fail(cmd) origin(time_in) enter(time_in) scale(365.23)



stcox year##i.sex 
testparm year#i.sex 

stcox c.year##i.sex 
	testparm c.year#i.sex 
	display %25.20f r(p)
		 
stcox year##i.agegroup5 
	testparm year#i.agegroup5
	display %25.20f r(p)

stcox year##i.cohort
	testparm year#i.cohort
	display %25.20f r(p)

stcox year##i.ethnicity
	testparm year#i.ethnicity
	display %25.20f r(p)

stcox year##i.country 
	testparm year#i.country 
	display %25.20f r(p)

stcox year##i.region 
	testparm year#i.region 
	display %25.20f r(p)

stcox year##i.prac_imd 
	testparm year#i.prac_imd 
	display %25.20f r(p)

stcox year##i.sex, vce(cluster patid)
	testparm year#i.sex 

stcox year##i.agegroup5,  vce(cluster patid)
	testparm year#i.agegroup5

stcox year##i.cohort,  vce(cluster patid)
	testparm year#i.cohort

stcox year##i.ethnicity,  vce(cluster patid)
	testparm year#i.ethnicity

stcox year##i.country,  vce(cluster patid)
	testparm year#i.country 

stcox year##i.region,  vce(cluster patid) 
	testparm year#i.region 

stcox year##i.prac_imd,  vce(cluster patid) 
	testparm year#i.prac_imd 



*Annual IRR within each group
*create dummy variables - dont' save into analytic master
//IRR sex
gen sex2 = .
	replace sex2=1 if sex==2 // Males (ref)
	replace sex2=2 if sex==1
stir sex2, strata(year)
//IRR age 
gen age2=.
	replace age2=1 if agegroup5==2
	replace age2=2 if agegroup5==0
stir age2, strata(year)

gen age3=.
	replace age3=1 if agegroup5==2
	replace age3=2 if agegroup5==1
stir age3, strata(year)

gen age4=.
	replace age4=1 if agegroup5==2
	replace age4=2 if agegroup5==3
stir age4, strata(year)

gen age5=.
	replace age5=1 if agegroup5==2
	replace age5=2 if agegroup5==4
stir age5, strata(year)

//Cohort
tab cohort, nolab
gen cohort2=. 
	replace cohort2=1 if cohort==4
	replace cohort2=2 if cohort==5
stir cohort2, strata(year)

gen cohort3=. 
	replace cohort3=1 if cohort==4
	replace cohort3=2 if cohort==6
stir cohort3, strata(year)

gen cohort4=. 
	replace cohort4=1 if cohort==4
	replace cohort4=2 if cohort==7
stir cohort4, strata(year)

gen cohort5=. 
	replace cohort5=1 if cohort==4
	replace cohort5=2 if cohort==8
stir cohort5, strata(year)

//Ethnicity
tab ethnicity_m, nolab 
gen ethnicity2=. 
	replace ethnicity2=1 if ethnicity_m==1 //Asain
	replace ethnicity2=2 if ethnicity_m==2 //Black
stir ethnicity2, strata(year)

gen ethnicity3=. 
	replace ethnicity3=1 if ethnicity_m==1 //Asain
	replace ethnicity3=2 if ethnicity_m==3 //Mixed
stir ethnicity3, strata(year)

gen ethnicity4=. 
	replace ethnicity4=1 if ethnicity_m==1 //Asain
	replace ethnicity4=2 if ethnicity_m==5 //Other
stir ethnicity4, strata(year)

gen ethnicity5=. 
	replace ethnicity5=1 if ethnicity_m==1 //Asain
	replace ethnicity5=2 if ethnicity_m==7 //White
stir ethnicity5, strata(year)

gen ethnicity6=. 
	replace ethnicity6=1 if ethnicity_m==1 //Asain
	replace ethnicity6=2 if ethnicity_m==99 //Unknown
stir ethnicity6, strata(year)

// rerun with White as reference 
//Ethnicity
tab ethnicity_m, nolab 
gen ethnicity2=. 
	replace ethnicity2=1 if ethnicity_m==7 //White (ref)
	replace ethnicity2=2 if ethnicity_m==1 //Asian
stir ethnicity2, strata(year)

*gen ethnicity3=. 
	replace ethnicity3=1 if ethnicity_m==7 //White ref
	replace ethnicity3=2 if ethnicity_m==2 //Black
stir ethnicity3, strata(year)

*gen ethnicity4=. 
	replace ethnicity4=1 if ethnicity_m==7 //White ref
	replace ethnicity4=2 if ethnicity_m==3 //Mixed
stir ethnicity4, strata(year)

*gen ethnicity5=. 
	replace ethnicity5=1 if ethnicity_m==7 //White ref
	replace ethnicity5=2 if ethnicity_m==5 //other
stir ethnicity5, strata(year)

gen ethnicity6=. 
	replace ethnicity6=1 if ethnicity_m==7 //white
	replace ethnicity6=2 if ethnicity_m==99 //Unknown
stir ethnicity6, strata(year)


tab ethnicity_m, nolab 
	replace ethnicity2=2 if ethnicity_m==7 //White (ref)
	replace ethnicity2=1 if ethnicity_m==1 //Asian
stir ethnicity2, strata(year)

	replace ethnicity3=2 if ethnicity_m==7 //White ref
	replace ethnicity3=1 if ethnicity_m==2 //Black
stir ethnicity3, strata(year)

	replace ethnicity4=2 if ethnicity_m==7 //White ref
	replace ethnicity4=1 if ethnicity_m==3 //Mixed
stir ethnicity4, strata(year)

	replace ethnicity5=2 if ethnicity_m==7 //White ref
	replace ethnicity5=1 if ethnicity_m==5 //other
stir ethnicity5, strata(year)

	replace ethnicity6=2 if ethnicity_m==7 //white
	replace ethnicity6=1 if ethnicity_m==99 //Unknown
stir ethnicity6, strata(year)


// Country
tab country, nolab
tab country

gen country2=. 
	replace country2=1 if country==1 // Eng
	replace country2=2 if country==2 // Scot
stir country2, strata(year)

gen country3=. 
	replace country3=1 if country==1 // Eng
	replace country3=2 if country==3 // NI
stir country3, strata(year)

gen country4=. 
	replace country4=1 if country==1 // Eng
	replace country4=2 if country==4 // Wales
stir country4, strata(year)

// IRR region
tab region 
tab region, nolab

gen region1=.
	replace region1=1 if region==7 // London 
	replace region1=2 if region==1 // NE
stir region1, strata(year)

gen region2=.
	replace region2=1 if region==7 // London 
	replace region2=2 if region==2 // NW
stir region2, strata(year)

gen region3=.
	replace region3=1 if region==7 // London 
	replace region3=2 if region==3 // York 
stir region3, strata(year)

gen region4=.
	replace region4=1 if region==7 // London 
	replace region4=2 if region==4 // EM
stir region4, strata(year)

gen region5=.
	replace region5=1 if region==7 // London 
	replace region5=2 if region==5 // WM 
stir region5, strata(year)

gen region6=.
	replace region6=1 if region==7 // London 
	replace region6=2 if region==6 // east  
stir region6, strata(year)

gen region8=.
	replace region8=1 if region==7 // London 
	replace region8=2 if region==8 // SE
stir region8, strata(year)

gen region9=.
	replace region9=1 if region==7 // London 
	replace region9=2 if region==9 // SW 
stir region9, strata(year)


// IRR deprivation 
tab prac_imd

gen imd2=. 
	replace imd2=1 if prac_imd==1 //q1 ref 
	replace imd2=2 if prac_imd==2 //q2
stir imd2, strata(year)

gen imd3=. 
	replace imd3=1 if prac_imd==1 //q1 ref
	replace imd3=2 if prac_imd==3 //q3
stir imd3, strata(year)

gen imd4=.
	replace imd4=1 if prac_imd==1 // q1 ref
	replace imd4=2 if prac_imd==4 //q4
stir imd4, strata(year)

gen imd5=.
	replace imd5=1 if prac_imd==1 //q1 ref
	replace imd5=2 if prac_imd==5 //q5
stir imd5, strata(year)
	



*IRR comparing 2009 and 2019
use  "..._analytic_v3.dta", clear

stset time_out, id(patid) fail(cmd) origin(time_in) enter(time_in) scale(365.23)
keep if year==2009 | year==2014 

stptime, per(1000) by(year) dd(1)
	stir year 
	stir year, strata(sex) 
	stir year, strata(agegroup5)
	stir year, strata(cohort)
	stir year, strata(ethnicity)
	stir year, strata(country)
	stir year, strata(region)
	stir year, strata(prac_imd) 

	
*2009 to 2014 
use  "..._analytic_v3.dta", clear

stset time_out, id(patid) fail(cmd) origin(time_in) enter(time_in) scale(365.23)
keep if year==2009 | year==2014 
**MAKE SURE YOU DONT SAVE!
	stir year 
	stir year, strata(sex) 
	stir year, strata(agegroup5)
	stir year, strata(cohort)
	stir year, strata(ethnicity)
	stir year, strata(country)
	stir year, strata(region)
	stir year, strata(prac_imd) 

	
*2014 to 2019	keep if year==2014 | year==2019 
use  "..._analytic_v3.dta", clear

stset time_out, id(patid) fail(cmd) origin(time_in) enter(time_in) scale(365.23)
keep if year==2014 | year==2019 

stptime, per(1000) by(year) dd(1)
	stir year 
	stir year, strata(sex) 
	stir year, strata(agegroup5)
	stir year, strata(cohort)
	stir year, strata(ethnicity)
	stir year, strata(country)
	stir year, strata(region)
	stir year, strata(prac_imd) 
	

	
log close

