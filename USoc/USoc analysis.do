log using "\04 results - impute.smcl", replace

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// MI estimate weighted proportions and regressions 
//
//		Last updated: Mar 2025 by JD
//
///////////////////////////////////////////////////////////////////////////////////////////////////

cd ".../01 data/usoc"

// Impute (separate imputed datasets saved for GHQ continuous and GHQ case)
use a_indresp.dta, clear 

mi set mlong
 mi xtset, clear
 mi stset, clear

*set data for imputation, use cross-sectional adult main interview weight - set as survey data using weight, psu and strata
mi svyset a_psu [pw=a_indinus_xw], strata(a_strata) singleunit(centered) 

*regster all variables that will be included in your imputation 
mi register imputed a_sex a_agegroup5 a_cohort a_ethnic a_country a_region a_imd5 a_ghq_case
mi impute chained (logit) a_ghq_case (mlogit) a_ethnic (ologit) a_imd5 = a_sex a_agegroup5 a_cohort a_country a_region, add(5) rseed(333) augment noisily 

 local vlist  a b c d e f g h i j k 
foreach var of local vlist {

use `var'_indresp.dta, clear 
keep `var'_psu `var'_weight `var'_strata `var'_sex `var'_agegroup5 `var'_cohort `var'_ethnic `var'_country `var'_region `var'_imd5 `var'_ghq_case

replace `var'_imd5=0 if `var'_country!=1
drop if `var'_region==. 

mi set mlong
 mi xtset, clear
 mi stset, clear

*set data for imputation, use cross-sectional adult main interview weight - set as survey data using weight, psu and strata
mi svyset `var'_psu [pw=`var'_weight], strata(`var'_strata) singleunit(centered) 


*regster all variables that will be included in your imputation 
mi register imputed `var'_sex `var'_agegroup5 `var'_cohort `var'_ethnic `var'_country `var'_region `var'_imd5 `var'_ghq_case

mi impute chained (logit) `var'_ghq_case (mlogit) `var'_ethnic (ologit) `var'_imd5 = `var'_sex `var'_agegroup5 `var'_cohort `var'_country  `var'_region [pw=`var'_weight], add(50) rseed(333) augment noisily 

save `var'_impute_case.dta, replace
}    



// Primary outcome - Continuous - mean GHQ score 		
local vlist a b c d e f g h i j 
foreach var of local vlist {
	use `var'_impute.dta , clear
	
	tab `var'_cohort

mi estimate: svy: mean `var'_ghq

mi estimate: svy: mean `var'_ghq, over(`var'_sex)
mi estimate: svy: mean `var'_ghq, over(`var'_agegroup5)
mi estimate: svy: mean `var'_ghq, over(`var'_cohort)
mi estimate: svy: mean `var'_ghq, over(`var'_ethnic)
mi estimate: svy: mean `var'_ghq, over(`var'_country)
mi estimate: svy: mean `var'_ghq, over(`var'_region)
mi estimate: svy: mean `var'_ghq, over(`var'_imd)

}




 
*Manually calculate the ratio of means and the variance using delta method 
mi estimate: svy: regress a_ghq if a_sex==2 //females
mi estimate: svy: regress a_ghq if a_sex == 1

* Calculate the ratio of means
scalar ratio = 11.11872 / 9.847761

* Calculate the variance of the ratio using the Delta Method
scalar var_ratio = (0.0830756 / 9.847761)^2 + (11.11872 * 0.0925565 /  9.847761^2)^2

* Calculate the standard error of the ratio
scalar se_ratio = sqrt(var_ratio)

* Calculate the 95% confidence interval
scalar lower_CI = ratio - 1.96 * se_ratio
scalar upper_CI = ratio + 1.96 * se_ratio

* Display the results
display "Ratio: " ratio
display "95% CI: [" lower_CI ", " upper_CI "]" 
 
 
 


 *Age
*0,1,2(ref),3,4

*ref regression 
mi estimate: svy: regress a_ghq if a_agegroup5 == 2


*Ratio to 16-19 (agegroup 0)
mi estimate: svy: regress a_ghq if a_agegroup5 == 0

* Calculate the ratio of means
scalar ratio = mean / mean_ref

* Calculate the variance of the ratio using the Delta Method
scalar var_ratio = (se_1 / mean_ref)^2 + (mean * se_ref /  mean_ref)^2

* Calculate the standard error of the ratio
scalar se_ratio = sqrt(var_ratio)

* Calculate the 95% confidence interval
scalar lower_CI = ratio - 1.96 * se_ratio
scalar upper_CI = ratio + 1.96 * se_ratio

* Display the results
display "Ratio: " ratio
display "95% CI: [" lower_CI ", " upper_CI "]" 
  
 

 
 


// Secondary outcome - GHQ case

 local vlist a b c d e f g h i j k
foreach var of local vlist {
	use `var'_impute_case.dta , clear
*Unimputed weighted proportions using cross sectional adult weight 
tab `var'_ghq_case, m 	
	proportion 	`var'_ghq_case [pweight=`var'_weight]
tab `var'_sex
	proportion 	`var'_ghq_case [pweight=`var'_weight], over(`var'_sex)

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
}


 local vlist  a b c d e f g h i j k
foreach var of local vlist {
	use `var'_impute_case.dta , clear
	
*Imputed weighted proportions using cross sectional adult weight 
mi estimate: svy: proportion `var'_ghq_case 

mi estimate: svy: proportion `var'_ghq_case , over(`var'_sex)

mi estimate: svy: proportion 	`var'_ghq_case, over(`var'_agegroup5)
mi estimate: svy: proportion 	`var'_ghq_case, over(`var'_cohort)
mi estimate: svy: proportion 	`var'_ghq_case, over(`var'_ethnic)
mi estimate: svy: proportion 	`var'_ghq_case, over(`var'_country)
mi estimate: svy: proportion 	`var'_ghq_case, over(`var'_region)
mi estimate: svy: proportion 	`var'_ghq_case, over(`var'_imd5)

}

 local vlist a b c d e f g h i j  
foreach var of local vlist {
	use `var'_impute.dta , clear

mi estimate: svy: logit `var'_ghq_case i.`var'_sex 
mi estimate: svy: logit `var'_ghq_case ib1.`var'_agegroup5 
mi estimate: svy: logit `var'_ghq_case ib4.`var'_cohort
mi estimate: svy: logit `var'_ghq_case i.`var'_ethnic
mi estimate: svy: logit `var'_ghq_case i.`var'_country
mi estimate: svy: logit `var'_ghq_case ib7.`var'_region
 
}


log close

