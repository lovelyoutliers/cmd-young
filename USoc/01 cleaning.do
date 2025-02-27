//////////////////////////////////////////////////////////////////////////////
// USoc - CMD in CYP
// 01 cleaning
//
//
// Updated Feb 2025
// J Dykxhoorn
//////////////////////////////////////////////////////////////////////////////


	
clear
set more off 	

cd "C:\Users\uctvjld\OneDrive - University College London\00 My publications\202x Dykxhoorn - CMD in CYP\01 data\usoc"


*Data stored in shared drive 
cd "/Volumes/ritd-ag-project-rd0153-alazz24/0 USoc/04 projects/2024 cmd in cyp/usoc"


*Log files in Onedrive folder
log using "/Users/jen/Library/CloudStorage/OneDrive-UniversityCollegeLondon/00 My publications/1 Dykxhoorn - CMD in CYP/03 log/usoc/01 cleaning.smcl"



// Open original USoc files and save an analytic version
*drop those born before 1980
*drop proxy respondents
*always run local list right before the loop 	

local vlist a b c d e f g h i j k
foreach var of local vlist {
cd "/Volumes/ritd-ag-project-rd0153-alazz24/0 USoc/00 original data/USoc 1-13/ukhls"
use `var'_indresp, clear
	tab `var'_ioutcome, m
		drop if `var'_ioutcome==13
	tab `var'_doby_dv,m
		drop if `var'_doby_dv<1980
		drop if `var'_birthy<1980
	
cd "/Volumes/ritd-ag-project-rd0153-alazz24/0 USoc/04 projects/2024 cmd in cyp/usoc"
	save `var'_indresp.dta, replace	
	
	}
	


// Data cleaning	
cd "/Volumes/ritd-ag-project-rd0153-alazz24/0 USoc/04 projects/2024 cmd in cyp/usoc"


local vlist a b c d e f g h i j k 
foreach var of local vlist {	
	use `var'_indresp.dta , clear

*GHQ continuous	
	sum `var'_scghq1_dv
	gen `var'_ghq= `var'_scghq1_dv
		recode `var'_ghq -9=. -8=. -7=.
	
		lab var `var'_ghq "CMD continuous score 0=no symptoms 36=highest distress"
		tab `var'_ghq,m
		
*GHQ binary
	gen `var'_ghq_case=.
		replace `var'_ghq_case=0 if `var'_ghq<14
		replace `var'_ghq_case=1 if `var'_ghq>13
		replace `var'_ghq_case=. if `var'_ghq==.

	tab `var'_ghq_case, m
			lab var `var'_ghq_case "CMD Case =1 if score 14 or more on GHQ"

	save, replace
}

			

*get annual estimates 
local vlist a b c d e f g h i j k
foreach var of local vlist {
	use `var'_indresp.dta , clear
	
	tab `var'_ghq_case, m
	sum `var'_ghq, detail 
}
	
	
*creating stratum variables 


//Sex 
 	local vlist a b c d e f g h i j k
foreach var of local vlist {
	cd "/Volumes/ritd-ag-project-rd0153-alazz24/0 USoc/04 projects/2024 cmd in cyp/usoc"
	
	use `var'_indresp.dta , clear

	*sex missing for one person in Wave F, G, and K - use xwave which has a dv for sex
	replace `var'_sex=. if `var'_sex<0

	merge 1:1 pidp using "/Volumes/ritd-ag-project-rd0153-alazz24/0 USoc/00 original data/USoc 1-13/ukhls/xwavedat.dta", keepusing (sex_dv)
	drop if _m==2
	drop _m 
	
	replace `var'_sex = sex_dv if `var'_sex==.
		drop sex_dv
		
		drop if 
		save, replace
}


	local vlist a b c d e f g h i j  k
foreach var of local vlist {
	use `var'_indresp.dta , clear
		
*age group
lab def	agegroup 1 "16-24" 2 "25-34" 3 "35-44" 4 "45-54"
	drop if `var'_dvage>54
gen `var'_agegroup=.
	replace `var'_agegroup=1 if `var'_dvage>15 & `var'_dvage<25
	replace `var'_agegroup=2 if `var'_dvage>24 & `var'_dvage<35
	replace `var'_agegroup=3 if `var'_dvage>34 & `var'_dvage<45
	replace `var'_agegroup=4 if `var'_dvage>44 & `var'_dvage<55
		lab val `var'_agegroup agegroup 
	tab `var'_dvage `var'_agegroup , m
		drop if `var'_agegroup==.
		drop if `var'_agegroup==4
	
*Age group - 5 year intervals
	*drop `var'_agegroup5
egen `var'_agegroup5=cut(`var'_dvage), at (16, 20, 25,30, 35,40,45, 50,55,200) icodes
		lab def agegroup5 0"16-19" 1"20-24" 2"25-29" 3"30-34" 4"35-39" 5"40-44" 6"45-49"7"50-54" 8 "55+",replace
		lab val `var'_agegroup5 agegroup5
	tab `var'_dvage `var'_agegroup5 , m
		
*cohort
	lab def  cohort 1"1965-1969" 2"1970-1974" 3"1975-1979" 4"1980-1984" 5"1985-1989" 6"1990-1994" 7"1995-1999" 8"2000-2004", replace

	gen `var'_cohort=`var'_birthy
		recode `var'_cohort (1965/1969=1) (1970/1974=2) (1975/1979=3) (1980/1984=4) (1985/1989=5) (1990/1994=6) (1995/1999=7) (2000/2004=8)
			lab val `var'_cohort cohort
		tab `var'_cohort
			lab val `var'_cohort cohort 
			drop if `var'_cohort<4	

			
*ethnicity 
 tab `var'_ethn_dv
	 lab def ethnic 1 "Asian" 2 "Black" 3"Mixed" 4"Other" 5 "White" 6"Unknown"
 gen `var'_ethnic=`var'_ethn_dv
	recode `var'_ethnic (1/4 = 5) (5/8=3) (9/13=1)(14/16=2) (17/97=4) (-9=6)
		lab val `var'_ethnic ethnic 
	replace `var'_ethnic = . if `var'_ethnic==6
		
*country
replace `var'_country=. if `var'_country<0
	
*region
replace `var'_gor_dv=. if `var'_gor_dv<0
	rename `var'_gor_dv `var'_region
		
save, replace
	
}

* IMD and LSOA 
	*imported IMD from open data scores and lsoa info from special license files
	local vlist a b c d e f g h i j 
foreach var of local vlist {
	cd "/Volumes/ritd-ag-project-rd0153-alazz24/0 USoc/04 projects/2024 cmd in cyp/usoc"
	
	use `var'_indresp.dta , clear
	
	merge m:1 `var'_hidp using "/Users/jen/Library/CloudStorage/OneDrive-UniversityCollegeLondon/02 UK data/USoc/00 data/special license/lsoa/original/`var'_lsoa11_protect.dta"
	drop if _m==2
	drop _merge
	
merge m:1 `var'_hidp using "/Volumes/ritd-ag-project-rd0153-alazz24/0 USoc/00 original data/special license/lsoa/`var'_lsoa_imd.dta"
	drop if _m==2
	drop _m
	
save, replace

	}
	
	local vlist k 
foreach var of local vlist {
	cd "/Volumes/ritd-ag-project-rd0153-alazz24/0 USoc/04 projects/2024 cmd in cyp/usoc"
	
	use `var'_indresp.dta , clear

	merge m:1 `var'_hidp using "/Users/jen/Library/CloudStorage/OneDrive-UniversityCollegeLondon/02 UK data/USoc/00 data/special license/lsoa/original/`var'_lsoa11_protect.dta"
	drop if _m==2
	drop _merge
	
	gen lsoa = k_lsoa11
merge m:1 lsoa using "/Volumes/ritd-ag-project-rd0153-alazz24/0 USoc/00 original data/special license/lsoa/k_lsoa_imd.dta"

	drop if _m==2
	drop _m
	
save, replace

	}

local vlist  a b c 
foreach var of local vlist {
cd "/Volumes/ritd-ag-project-rd0153-alazz24/0 USoc/04 projects/2024 cmd in cyp/usoc"
	
use `var'_indresp.dta , clear

gen `var'_imd5=. 
	replace `var'_imd5=imd2010_5 if `var'_imd5==.
tab `var'_imd5, m 


save, replace
	
}
	
local vlist d e f g h 
foreach var of local vlist {
	cd "/Volumes/ritd-ag-project-rd0153-alazz24/0 USoc/04 projects/2024 cmd in cyp/usoc"
	
use `var'_indresp.dta , clear

gen `var'_imd5=. 
	replace `var'_imd5=imd2015_5 if `var'_imd5==.
tab `var'_imd5, m 

save, replace
	
}


local vlist i j k 
foreach var of local vlist {
	cd "/Volumes/ritd-ag-project-rd0153-alazz24/0 USoc/04 projects/2024 cmd in cyp/usoc"
	
use `var'_indresp.dta , clear

gen `var'_imd5=. 
	replace `var'_imd5=imd2019_5 if `var'_imd5==.
tab `var'_imd5, m 

save, replace
	
}



////////////////////////////////////////////////////////////////////////////
// Check for data errors and oddities
////////////////////////////////////////////////////////////////////////////
	local vlist a b c d e f g h i j k
foreach var of local vlist {
	cd "/Volumes/ritd-ag-project-rd0153-alazz24/0 USoc/04 projects/2024 cmd in cyp/usoc"
	
	use `var'_indresp.dta , clear
tab `var'_sex, m 
tab `var'_agegroup5, m 
tab `var'_cohort, m 
tab `var'_country, m
tab `var'_region, m 
tab `var'_imd5, m 
}


local vlist  b c d e f g h i j k
foreach var of local vlist {
	cd "/Volumes/ritd-ag-project-rd0153-alazz24/0 USoc/04 projects/2024 cmd in cyp/usoc"
	
	use `var'_indresp.dta , clear

drop `var'_disd* 


save, replace
}

	local vlist a b c d e f g h i j k
foreach var of local vlist {
	cd "/Volumes/ritd-ag-project-rd0153-alazz24/0 USoc/04 projects/2024 cmd in cyp/usoc"
	
	use `var'_indresp.dta , clear
		replace `var'_country=2 if `var'_region==10
		replace `var'_country=3 if `var'_region==11
		replace `var'_country=4 if `var'_region==12 

		save, replace

}


/////////////////////////////////////////////////////
// WEIGHTS
*get annual estimates 
local vlist a b 
foreach var of local vlist {
	use `var'_indresp.dta , clear
		gen `var'_weight=`var'_indinus_xw
	save `var'_indresp.dta, replace
}

local vlist  c d e  
foreach var of local vlist {
	use `var'_indresp.dta , clear
	gen `var'_weight=`var'_indinub_xw
save `var'_indresp.dta, replace
}

* BHPS+UKHLS+IEMB cross sectional adult main interview weight
local vlist f g h i j k
foreach var of local vlist {
	use `var'_indresp.dta , clear
	gen `var'_weight=`var'_indinui_xw
	save `var'_indresp.dta, replace
}


// Deleting those who have a zero-weight in the cross-sectional wave 
*not sure why, but choosing to believe. 
* also deleting those who have no country, after country is fed forward from previous wave 
 *decided to delete the <5 people who are missing country, because putting country and region in (which are collinear) made them all fall apart.
 
	local vlist  a b c d e f g h i j k
foreach var of local vlist {
	use `var'_indresp.dta , clear
		drop if `var'_weight==0
		drop if `var'_country==.
save `var'_indresp.dta, replace
}


// Weighted proportions 
*Cross-sectional adult main interview weight - create a weight variable using the appropriate weight, which changes slightly between some waves 

ssc inst _gwtmean
	*need to install this user writen package to generate weighted means

///////////////////////////////////////////////////////////////////////////
cd "C:\Users\uctvjld\OneDrive - University College London\00 My publications\202x Dykxhoorn - CMD in CYP\01 data\usoc"

// Descriptives - weighted proportions and score means
	*calculating weighted mean for the continuous score 

local vlist a b c d e f g h i j k
foreach var of local vlist {
	use `var'_indresp.dta , clear
	
	
	*weighted proportions using cross sectional adult weight 
tab `var'_ghq_case, m 	
	proportion 	`var'_ghq_case [pweight=`var'_weight]
tab `var'_sex
	proportion 	`var'_ghq_case [pweight=`var'_weight], over(`var'_sex)
tab `var'_agegroup
	proportion 	`var'_ghq_case [pweight=`var'_weight], over(`var'_agegroup)
tab `var'_agegroup5
	proportion 	`var'_ghq_case [pweight=`var'_weight], over(`var'_agegroup5)
tab `var'_cohort 
	proportion 	`var'_ghq_case [pweight=`var'_weight], over(`var'_cohort)
tab `var'_ethnic
	proportion 	`var'_ghq_case [pweight=`var'_weight], over(`var'_ethnic)
tab `var'_country 
	proportion 	`var'_ghq_case [pweight=`var'_weight], over(`var'_country)
tab `var'_region 
	proportion 	`var'_ghq_case [pweight=`var'_weight], over(`var'_region)
tab `var'_imd5 
	proportion 	`var'_ghq_case [pweight=`var'_weight], over(`var'_imd5)
	
* weighted means
	egen `var'_mean = wtmean(`var'_ghq), weight(`var'_weight)
		tab `var'_mean
		
		bysort `var'_sex: egen `var'_mean_sex= wtmean(`var'_ghq), weight(`var'_weight)
			tab `var'_mean_sex
		bysort `var'_agegroup: egen `var'_mean_agegroup= wtmean(`var'_ghq), weight(`var'_weight)
				tab `var'_mean_agegroup
		bysort `var'_agegroup5: egen `var'_mean_agegroup5= wtmean(`var'_ghq), weight(`var'_weight)
				tab `var'_mean_agegroup5		
		bysort `var'_cohort: egen `var'_mean_cohort= wtmean(`var'_ghq), weight(`var'_weight)
			tab `var'_mean_cohort
		bysort `var'_ethnic: egen `var'_mean_ethnic= wtmean(`var'_ghq), weight(`var'_weight)
			tab `var'_mean_ethnic
		bysort `var'_country: egen `var'_mean_country= wtmean(`var'_ghq), weight(`var'_weight)
			tab `var'_mean_country
		bysort `var'_region: egen `var'_mean_region= wtmean(`var'_ghq), weight(`var'_weight)
			tab `var'_mean_region
		bysort `var'_imd5: egen `var'_mean_imd5= wtmean(`var'_ghq), weight(`var'_weight)
			tab `var'_mean_imd5

}

	
log close






/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////








