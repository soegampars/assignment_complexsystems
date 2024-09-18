clear
set more off

import delimited "C:\Users\satya\OneDrive\WORKBENCH\Personal Study\Complex Systems\assignment\cleanarchive\sample100\simulated_2022.csv", clear

rename weight weight_0

// assert weight_0 == weight_7
// assertion is false karena INGAT bahwa yang diambil untuk sampel reweighting hanya 100 teratas, bukan keseluruhan 15 ribu sampel
drop weight_0

tempfile base
save `base'

forval x = 1/13{
	
	use `base', clear
	
	keep empstat educ agegroup_* gender_* weight_`x'
	
	rename weight_`x' weight
	
	gen region = `x'
	
	tempfile subset`x'
	save `subset`x''
	
}

forval x = 1/12{
	
	append using `subset`x''
	
}

gen region_name = ""
	replace region_name = "bergamo" if region ==  1
	replace region_name = "brescia" if region ==  2
	replace region_name = "como" if region ==  3
	replace region_name = "cremona" if region ==  4
	replace region_name = "lecco" if region ==  5
	replace region_name = "lodi" if region ==  6
	replace region_name = "lombardia" if region ==  7
	replace region_name = "mantova" if region ==  8
	replace region_name = "milano" if region ==  9
	replace region_name = "monzabrianza" if region ==  10
	replace region_name = "pavia" if region ==  11
	replace region_name = "sondrio" if region ==  12
	replace region_name = "varese" if region ==  13

destring educ, force replace

gen workage = 0
forval x = 5/15{
	
	replace workage = agegroup_`x' == 1 //referring to legal working age and pension age in Italy 16-67 y.o.
	
}

gen rate_employed = empstat == 1 & workage == 1
	replace rate_employed = . if workage == 0
	
gen rate_lfhigheduc = inrange(educ,6,8)
	replace rate_lfhigheduc = . if workage == 0

gen rate_fempop = gender_f == 1

gen rate_femprod = gender_f == 1 & workage == 1
	replace rate_femprod = . if gender_m == 1
	
gen rate_feminattivi = rate_femprod == 1 & empstat == 3
	replace rate_feminattivi = . if gender_m == 1
	// caveat: representativeness problem - no female of productive age in search for jobs
	
gen rate_femlf = workage == 1 & gender_f == 1 & inlist(empstat,1,2)
	replace rate_femlf = . if gender_m == 1

assert rate_femprod == rate_feminattivi // ASSERTION IS TRUE; means that all working age female in reweighted sample are inactive
	
collapse (mean) rate_employed rate_lfhigheduc rate_fempop rate_femprod rate_feminattivi rate_femlf [fw=weight], by(region region_name)

la var rate_employed 		"Share of employed persons in the working age population"
la var rate_lfhigheduc 		"Share of persons with higher education in the working age population"
la var rate_fempop 			"Share of female in the population"
la var rate_femprod 		"Share of working age female in female population"
la var rate_feminattivi 	"Share of inactive female in female population"

drop if region_name == "lombardia"

replace region_name = "Bergamo" if region_name == "bergamo"
replace region_name = "Brescia" if region_name == "brescia"
replace region_name = "Como" if region_name == "como"
replace region_name = "Cremona" if region_name == "cremona"
replace region_name = "Lecco" if region_name == "lecco"
replace region_name = "Lodi" if region_name == "lodi"
replace region_name = "Mantua" if region_name == "mantova"
replace region_name = "Milano" if region_name == "milano"
replace region_name = "Monza and Brianza" if region_name == "monzabrianza"
replace region_name = "Pavia" if region_name == "pavia"
replace region_name = "Sondrio" if region_name == "sondrio"
replace region_name = "Varese" if region_name == "varese"

export delimited "C:\Users\satya\OneDrive\WORKBENCH\Personal Study\Complex Systems\assignment\clean\collapsed_lombardia_2022.csv", replace

/*
known problems: 
1. representativeness problem - no female of productive age in search for jobs; 'rate_femprod' has the same value as 'rate_feminattivi'

possible improvements
1. improved representativeness of female population; more sample to be reweighted
2. better granularity; depending on the availability of a finer disaggregation summary statistics

x. longer observation period for in-sample and out-sample prediction test
*/