* RRF 2024 - Analyzing Data Template	
*-------------------------------------------------------------------------------	
* Load data
*------------------------------------------------------------------------------- 
	
	*load analysis data 
	use  "${data}/Final/TZA_CCT_analysis.dta", clear

*-------------------------------------------------------------------------------	
* Summary stats
*------------------------------------------------------------------------------- 

	* defining globals with variables used for summary
	global sumvars 	nonfood_cons_usd_w food_cons_usd_w area_acre_w read sick days_sick treat_cost_usd
	
	* Summary table - overall and by districts
	eststo all: 	estpost sum $sumvars
	eststo district_1: sum $sumvars if district == 1
	eststo district_2: sum $sumvars if district == 2
	eststo district_3: sum $sumvars if district == 3
	
	
	* Exporting table in csv
	//local Outputs "C:\Users\wb612454\Downloads\RRF 2024\RRF_Training_Georga_Fixed\Stata\Outputs"
	esttab 	all district_1 district_2 district_3 ///
			using "${outputs}/summary.csv", replace ///
			label ///
			main(mean %6.2f) aux(sd) ///
			refcat(hh_size "HH characteristics" drought_flood "shocks", nolabel) ///
			mtitle("full sample" "kibaha" "Bagamoyos" "Chamwino") ///
			nonotes addn(Mean with standard deviations in parentheses)
	
	* Also export in tex for latex
	esttab all district_1 district_2 district_3 ///
	using "${outputs}/summary.tex", replace ///
	label ///
	main(mean %6.2f) aux(sd) ///
	refcat(hh_size "HH characteristics" drought_flood "shocks", nolabel) ///
			mtitle("full sample" "kibaha" "Bagamoyos" "Chamwino") ///
			nonotes addn(Mean with standard deviations in parentheses) ///
			
*-------------------------------------------------------------------------------	
* Balance tables
*------------------------------------------------------------------------------- 	
	
	* Balance (if they purchased cows or not)
	iebaltab 	$sumvars, ///
				grpvar(treatment) ///
				rowvarlabels	///
				format(%12.3f)	///
				savecsv("${outputs}/balance") ///
				savetex("${outputs}/balance") ///
				nonote addnote("Significance: ***=.o1, **=.05, *=.1") replace 			

				
*-------------------------------------------------------------------------------	
* Regressions
*------------------------------------------------------------------------------- 				
				
	* Model 1: Regress of food consumption value on treatment
	regress food_cons_usd_w treatment
	eststo model1		// store regression results
	
	estadd local clustering "No"
	
	* Model 2: Add controls
	regress food_cons_usd_w treatment crop_damage drought_flood
	eststo model2

	estadd local clustering "No"
	
	* Model 3: Add clustering by village
	regress food_cons_usd_w treatment crop_damage drought_flood, vce(cluster vid)
	eststo model3
	
	estadd local clustering "Yes"
	
	* Export results in tex
	esttab 	model1 model2 model3 ///
			using "$outputs/regressions.tex" , ///
			label ///
			b(%9.3f) se(%9.3f) ///
			nomtitles ///
			mgroup("Annual food consumption(USD)", pattern(1 0 0 ) span) ///
			scalars("clustering Clustering") ///
			replace
			
*-------------------------------------------------------------------------------			
* Graphs 
*-------------------------------------------------------------------------------	

	* Bar graph by treatment for all districts 
	gr bar area_acre_w, ///
	over(treatment) ///
	by(district, row(1) note ("") ///
		legend(pos(6)) ///
		title ("Area cultivated by treatment assignment across districts")) ///
	asy /// 	
	legend(rows(1) order(0 "Assigment:" 1 "Control" 2 "Treatment")) ///
	subtitle(,pos(6) bcolor(none)) ///
	blabel(total, format(%9.1f)) ///
	ytitle("Average area cultivated (Acre)") name(g1, replace)
	
	gr export "$outputs/fig1.png", replace	///	
	
*asy keeps the bars in different colours for treatment vs control
*need to make sure that everything for the graph is included as one so no brackets breaking the flow or comments.

	* Distribution of non food consumption by female headed hhs with means

	twoway (kdensity nonfood_cons_usd_w if female_head == 0, color(gray)) ///
       (kdensity nonfood_cons_usd_w if female_head == 1, color(red)) , ///
       xline(`mean_1', lcolor(purple) lpattern(dash)) ///
       xline(`mean_0', lcolor(gs12) lpattern(dash)) ///
       legend(order(0 "Household Head:" 1 "Female" 2 "Male") row(1) pos(6)) ///
       xtitle("Non-food consumption value (USD)") ///
       ytitle("Density") ///
       title("Distribution of non-food consumption") ///
       note("Dashed line represents the average non-food consumption")


gr export "$outputs/fig2.png", replace

			
			
*-------------------------------------------------------------------------------			
* Graphs: Secondary data
*-------------------------------------------------------------------------------			
			
	use "${data}/Final/TZA_amenity_analysis.dta", clear
	
	* create a variable to highlight the districts in sample
	gen in_sample = inlist(district, 1, 3, 6)
	
	* Separate indicators by sample
	separate n_school, by(in_sample)
	separate n_medical, by(in_sample)
	
	* Graph bar for number of schools by districts
	gr hbar n_school0 n_school1, ///
       nofill ///
       over(district, sort(n_school)) ///
       legend(order(0 "Not in Sample" 1 "In Sample") row(1) pos(6)) ///
	   ytitle("Number of Schools") ///
				name(g1, replace)
				
	* Graph bar for number of medical facilities by districts				
	gr hbar 	n_medical0 n_medical1, ///
				nofill ///
				over(district, sort(n_medical)) ///
				legend(off) ///
				ytitle("Number of Medical Facilities") ///
				name(g2, replace)
				
	grc1leg2 	g1 g2, ///
				row(1) legend(g1) ///
				ycommon xcommon ///
				title("Access to Amenities: By Districts", size())
			
	
	gr export "$outputs/fig3.png", replace			

****************************************************************************end!
	
