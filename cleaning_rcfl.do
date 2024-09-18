clear
set more off

cd "C:\Users\satya\OneDrive\WORKBENCH\Personal Study\Complex Systems\assignment\raw\"

forval year = 2022/2024{
	import delimited "RCFL_Microdati_`year'_Primo_trimestre.txt", clear

	keep if regmcr == 3

	keep cletas sesso coef_ccp tistud cond3
	
	renvars cletas sesso coef_ccp tistud cond3 / age gender weight educ empstat

		forval x = 1/17{
			gen agegroup_`x' = age == `x'	
		}
		
	gen gender_m = gender == 1
	gen gender_f = gender == 2
	
	drop age gender
	
	save `year'_clean, replace
	export delimited "`year'_clean.csv", replace
}