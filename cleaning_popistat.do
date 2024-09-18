clear
set more off

cd "C:\Users\satya\OneDrive\WORKBENCH\Personal Study\Complex Systems\assignment\raw"

import delimited "population_lombardiaprov_age_gender.csv", clear

reshape long pop_, i(gender age year) j(region) s

order region year gender age
sort year region gender age

replace gender = "1" if gender == "males"
replace gender = "2" if gender == "females"

drop if gender == "total"

replace age = substr(age, 1, 1) if strlen(age) == 7
replace age = substr(age, 1, 2) if strlen(age) == 8
replace age = substr(age, 1, 3) if strlen(age) >= 8

drop if age == "total"

destring age, replace

gen agegroup = .
	replace agegroup = 1 if inrange(age,0,2)
	replace agegroup = 2 if inrange(age,3,5)
	replace agegroup = 3	if inrange(age,6,10)
	replace agegroup = 4 if inrange(age,11,14)
	replace agegroup = 5 if inrange(age,15,19)
	replace agegroup = 6 if inrange(age,20,24)
	replace agegroup = 7 if inrange(age,25,29)
	replace agegroup = 8 if inrange(age,30,34)
	replace agegroup = 9 if inrange(age,35,39)
	replace agegroup = 10 if inrange(age,40,44)
	replace agegroup = 11 if inrange(age,45,49)
	replace agegroup = 12 if inrange(age,50,54)
	replace agegroup = 13 if inrange(age,55,59)
	replace agegroup = 14 if inrange(age,60,64)
	replace agegroup = 15 if inrange(age,65,69)
	replace agegroup = 16 if inrange(age,70,74)
	replace agegroup = 17 if inrange(age,75,.)
	
	drop age
	destring gender, replace
	
// 	replace agegroup = "0-2" if inrange(age,0,2)
// 	replace agegroup = "3-5" if inrange(age,3,5)
// 	replace agegroup = "6-10" if inrange(age,6,10)
// 	replace agegroup = "11-14" if inrange(age,11,14)
// 	replace agegroup = "15-19" if inrange(age,15,19)
// 	replace agegroup = "20-24" if inrange(age,20,24)
// 	replace agegroup = "25-29" if inrange(age,25,29)
// 	replace agegroup = "30-34" if inrange(age,30,34)
// 	replace agegroup = "35-39" if inrange(age,35,39)
// 	replace agegroup = "40-44" if inrange(age,40,44)
// 	replace agegroup = "45-49" if inrange(age,45,49)
// 	replace agegroup = "50-54" if inrange(age,50,54)
// 	replace agegroup = "55-59" if inrange(age,55,59)
// 	replace agegroup = "60-64" if inrange(age,60,64)
// 	replace agegroup = "65-69" if inrange(age,65,69)
// 	replace agegroup = "70-74" if inrange(age,70,74)
// 	replace agegroup = ">75" if inrange(age,75,.)	
	
	preserve 
	
	collapse (sum) pop_, by(region year agegroup)
	reshape wide pop_, i(region year) j(agegroup)
	
	renvars pop_*, presub(pop_ agegroup_)
	
	tempfile ag
	save `ag'

	restore

	collapse (sum) pop_, by(region year gender)
	reshape wide pop_, i(region year) j(gender)
	
	renvars pop_1 pop_2 / gender_m gender_f
	
	merge 1:1 region year using `ag', nogen

	preserve
	
forval year = 2022/2024{
	
	restore, preserve

	keep if year == `year'
	
	save pop_`year', replace
	export delimited "pop_`year'.csv", replace

}	


***************

/*
use "C:\Users\satya\OneDrive\WORKBENCH\Personal Study\Complex Systems\assignment\raw\pop_2022.dta", clear

egen gender_total = rowtotal(gender*)
egen agegroup_total = rowtotal(agegroup*)

assert gender_total == agegroup_total
*/

// TOTAL CHECK VALID