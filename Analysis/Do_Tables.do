use all_subjects_qu

*Table 2: Summary Statistics
sum age logic profit if Period==21
tab female if Period==21
tab major gametheory if Period==1
sum profit

*Stage 1: 
sum coop if Period<11 & randic==0
sum coop if Period<11 & randic==1
reg coop randic if Period<11, vce(cluster group)

*Figure 3: Cooperation Rates - Stages 1 and 3
bysort Period: egen coop_sum_rand = sum(coop) if randic==1
gen coop_share_rand = (coop_sum_rand/140)*100 if randic==1
bysort Period: egen coop_sum_mod_rand = sum(coop) if game==1 & Period >10 & Period<21 & randic==1
gen coop_share_mod_rand = (coop_sum_mod_rand/84)*100 if randic==1
label variable coop_share_mod_rand "cooperation rate under modified payoffs"
bysort Period: egen coop_sum_not_rand = sum(coop) if game==0 & Period >10 & Period<21  & randic==1  
gen coop_share_not_rand = (coop_sum_not_rand/56)*100 if randic==1
label variable coop_share_not_rand "cooperation rate under unmodified payoffs"
bysort Period: egen coop_sum_remd = sum(coop) if randic==0
gen coop_share_remd = (coop_sum_remd/140)*100 if randic==0
bysort Period: egen coop_sum_mod_remd = sum(coop) if game==1 & Period >10 & Period<21 & randic==0
gen coop_share_mod_remd = (coop_sum_mod_remd/80)*100 if randic==0
label variable coop_share_mod_remd "cooperation rate under modified payoffs"
bysort Period: egen coop_sum_not_remd = sum(coop) if game==0 & Period >10 & Period<21  & randic==0  
gen coop_share_not_remd = (coop_sum_not_remd/60)*100 if randic==0
label variable coop_share_not_remd "cooperation rate under unmodified payoffs"
line coop_share_rand coop_share_remd Period if Period<11, xlabel(1(1)10) ylabel(0(10)100) ytitle(Cooperation Percentage) legend(ring(0) pos(7) order(1 "Random Dictator (RD)" 2 "Representative Democracy (ID)")) saving(gs1, replace) 
line coop_share_not_remd coop_share_mod_remd coop_share_not_rand coop_share_mod_rand Period if Period>=11 & Period<=20, xlabel(11(1)20) ylabel(0(10)100) legend(ring(0) pos(7) order(2 "Coordination Game - ID" 4 "Coordination Game - RD"  1 "Prisoners' Dilemma - ID" 3 "Prisoners' Dilemma - RD" ))  saving(gs3, replace)
gr combine gs1.gph gs3.gph, ycommon

*Vote Stage:
sum modification if Period==10 & randic==0
sum modification if Period==10 & randic==1
ranksum modification if Period==10, by(randic)

*Table 3: determinants of modification preference
reg modification totalcoop1 ocoop_0 if Period ==10  ,vce(cluster group)
reg modification totalcoop1 ocoop_0 logic randic female age econ if Period ==10 & female>=0, vce(cluster group)
probit modification totalcoop1 ocoop_0 if Period ==10,vce(cluster group)
margins, dydx(totalcoop1 ocoop_0)
probit modification totalcoop1 ocoop_0 logic randic female age econ if Period ==10 & female>=0,vce(cluster group)
margins, dydx(totalcoop1 ocoop_0 logic randic female age econ)

*Result 2: Elected representatives are not more cooperative than other subjects.
sum totalcoop1 if Period==10 & randic==0 & speaker==0
sum totalcoop1 if Period==10 & randic==0 & speaker==1
ranksum totalcoop1 if Period==10 & randic==0, by(speaker)
ranksum modification if Period==11 & randic==0, by(speaker)
ranksum totalcoop2 if Period==10 & randic==0, by(speaker)

*Result 3: Elected representatives are not more cooperative than randomly appointed group leaders.
sum totalcoop2 if Period==10 & randic==0 & speaker==1
sum totalcoop2 if Period==10 & randic==1 & speaker==1
ranksum totalcoop2 if Period==10 & speaker==1, by(randic)

*"cooperation rates in both treatments are higher in the coordination game than in the prisoners' dilemma"
reg coop game if Period>10 & randic==0
reg coop game if Period>10 & randic==1

*Table 4: Cooperation Rates By Vote Outcome
tab modification votestage if Period==11 & randic==0
table modification votestage if Period==11 & randic==0, c(mean coop)
table votestage if Period==11 & randic==0, c(mean coop)
tab modification votestage if Period==11 & randic==1
table modification votestage if Period==11 & randic==1, c(mean coop)
table votestage if Period==11 & randic==1, c(mean coop)


*Tables 5 an 6: Significance of the effect of democracy
* column (1)
reg coop endomod endonot exomod exonot if Period==11 & randic==0, noconstant
test endonot=exonot
test endomod=exomod
test endomod=endonot
test exomod=exonot
* column (2)
reg coop endomod endonot exomod exonot if Period==11 & randic==1, noconstant
test endonot=exonot
test endomod=exomod
test endomod=endonot
test exomod=exonot
* column (3)
reg coop endomody endonoty exomody exonoty endomodn endonotn exomodn exonotn if Period==11 & randic==0, noconstant
test endonoty=exonoty
test endomody=exomody
test endomody=endonoty
test exomody=exonoty
test endonotn=exonotn
test endomodn=exomodn
test endomodn=endonotn
test exomodn=exonotn
* column (4)
reg coop endomodn endonotn exomodn exonotn endomody endonoty exomody exonoty if Period==11 & randic==1, noconstant
test endonotn=exonotn
test endomodn=exomodn
test endomodn=endonotn
test exomodn=exonotn
test endonoty=exonoty
test endomody=exomody
test endomody=endonoty
test exomody=exonoty

*for sharpened q-values: run do-file https://are.berkeley.edu/~mlanderson/downloads/fdr_sharpened_qvalues.do.zip separately and insert p-values from above

*Table 7: Democracy Premium
*for ID
keep if randic==0 & Period==11
reg coop endomody endonoty exomody exonoty endomodn endonotn exomodn exonotn, noconstant
*total policy effect
lincom ((34/48) *_b[endomody]+ (14/48) * _b[endomodn] - (11/24) * _b[endonoty] - (13/24) * _b[endonotn]), level(90)
*selection effect
lincom (_b[endonotn]*((14/48)-(13/24))+_b[endonoty]*((34/48)-(11/24)) ), level(90)
*exogenous treatment effect
lincom ((34/48)*(exomody-exonoty)+(14/48)*(exomodn-exonotn)), level(90)
*democracy premium
lincom((34/48) *_b[endomody]+ (14/48) * _b[endomodn] - (11/24) * _b[endonoty] - (13/24) * _b[endonotn] - ( _b[endonotn]*((14/48)-(13/24))+_b[endonoty]*((34/48)-(11/24))) - ((34/48)*(exomody-exonoty)+(14/48)*(exomodn-exonotn))  ), level(90)

*for RD
clear
use all_subjects_qu
keep if randic==1 & Period==11
reg coop endomody endonoty exomody exonoty endomodn endonotn exomodn exonotn, noconstant
*total policy effect
lincom ((30/40) *_b[endomody]+ (10/40) * _b[endomodn] - (9/12) * _b[endonotn] - (3/12) * _b[endonoty]), level(90)
*selection effect
lincom (_b[endonotn]*((10/40)-(9/12))+_b[endonoty]*((30/40)-(3/12)) ), level(90)
*exogenous treatment effect
lincom ((30/40)*(exomody-exonoty)+(10/40)*(exomodn-exonotn)), level(90)
*democracy premium
lincom((30/40) *_b[endomody]+ (10/40) * _b[endomodn] - (9/12) * _b[endonotn] - (3/12) * _b[endonoty]) - ( _b[endonotn]*((10/40)-(9/12))+_b[endonoty]*((30/40)-(3/12))) - ((30/40)*(exomody-exonoty)+(10/40)*(exomodn-exonotn))  , level(90)

clear
use all_subjects_qu
*Table 8:
****ID, modification:

keep if Period==11 & randic==0
keep if (exomod==1) | (endo==1)

gen weighty=0.6324
gen weightn=1-0.6324 

egen averageYes=mean(coop) if endomod==1 & modification==1 & Period==11
egen averageY=min(averageYes) 
egen averageNo=mean(coop) if endomod==1 & modification==0 & Period==11
egen averageN=min(averageNo) 

drop averageNo averageYes
cap drop waverage
gen waverage=weighty*averageY+weightn*averageN

cap drop justaverage
egen justaverage=mean(coop) if Period==11 & exomod==1
egen javerage=min(justaverage) 

gen democ=waverage-javerage
tab democ

gen art=cond(exomod==1,1,0)/100

gen var2=waverage
replace var2=coop if Period==11 & exomod==1

bootstrap, reps(10000) seed(1): reg var2 art


* no modification:
clear
use all_subjects_qu
gen weighty=0.6324
gen weightn=1-0.6324 
keep if Period==11 & randic==0
keep if (exonot==1) | (endonot==1)
egen averageYes=mean(coop) if endonot==1 & modification==1 & Period==11
egen averageY=min(averageYes) 
egen averageNo=mean(coop) if endonot==1 & modification==0 & Period==11
egen averageN=min(averageNo) 
drop averageNo averageYes
cap drop waverage
gen waverage=weighty*averageY+weightn*averageN
cap drop justaverage
egen justaverage=mean(coop) if Period==11 & exonot==1
egen javerage=min(justaverage) 
gen democ=waverage-javerage
tab democ
gen art=cond(exonot==1,1,0)/100
gen var2=waverage
replace var2=coop if  Period==11 & exonot==1
bootstrap, reps(10000) seed(1): reg var2 art


****RD, modification:
clear
use all_subjects_qu
keep if Period==11 & randic==1
keep if (exomod==1) | (endo==1)

gen weighty=0.6324
gen weightn=1-0.6324 

egen averageYes=mean(coop) if endomod==1 & modification==1 & Period==11
egen averageY=min(averageYes) 
egen averageNo=mean(coop) if endomod==1 & modification==0 & Period==11
egen averageN=min(averageNo) 

drop averageNo averageYes
cap drop waverage
gen waverage=weighty*averageY+weightn*averageN

cap drop justaverage
egen justaverage=mean(coop) if Period==11 & exomod==1
egen javerage=min(justaverage) 
gen democ=waverage-javerage
tab democ
gen art=cond(exomod==1,1,0)/100
gen var2=waverage
replace var2=coop if Period==11 & exomod==1
bootstrap, reps(10000) seed(1): reg var2 art


****RD, no modification:
clear
use all_subjects_qu
keep if Period==11 & randic==1
keep if (exonot==1) | (endonot==1)
gen weighty=0.6324
gen weightn=1-0.6324 
egen averageYes=mean(coop) if endonot==1 & modification==1 & Period==11
egen averageY=min(averageYes) 
egen averageNo=mean(coop) if endonot==1 & modification==0 & Period==11
egen averageN=min(averageNo) 
drop averageNo averageYes
cap drop waverage
gen waverage=weighty*averageY+weightn*averageN
cap drop justaverage
egen justaverage=mean(coop) if Period==11 & exonot==1
egen javerage=min(justaverage) 
gen democ=waverage-javerage
tab democ
gen art=cond(exonot==1,1,0)/100
gen var2=waverage
replace var2=coop if Period==11 & exonot==1
bootstrap, reps(10000) seed(1): reg var2 art


*Figures 4 & 5
clear
use all_subjects_qu
gen endomod_c=coop if endomod==1
gen endonot_c=coop if endonot==1
gen exomod_c=coop if exomod==1
gen exonot_c=coop if exonot==1 
keep if randic==1
collapse endomod_c endonot_c exomod_c exonot_c if Period<21, by (Period modification)
twoway (line endomod_c Period if modification==1, lwidth(medthick) title(Wanted modification) graphregion(color(white)) xline(10.5) xtitle("Round") xscale(range(1 20)) xlabel(#20) ytitle("Cooperation") yscale(range(0 1)) ylabel(#6) scale(.6) ) (line endonot_c Period if modification==1, lpattern("_..") lwidth(medthick)) (line exomod_c Period if modification==1, lpattern(dash) lwidth(medthick)) (line exonot_c Period if modification==1, lpattern(dash_dot) lwidth(medthick)  legend(label(1 "EndoMod") label(2 "EndoNot") label(3 "ExoMod") label(4 "ExoNot"))), xscale(off) saving(graphvm1_randic,replace)
twoway (line endomod_c Period if modification==0, lwidth(medthick) title(Did not want modification) graphregion(color(white)) xline(10.5) xtitle("Round") xscale(range(1 20)) xlabel(#20) ytitle("Cooperation") yscale(range(0 1)) ylabel(#6) scale(.6) ) (line endonot_c Period if modification==0, lpattern("_..") lwidth(medthick)) (line exomod_c Period if modification==0, lpattern(dash) lwidth(medthick)) (line exonot_c Period if modification==0, lpattern(dash_dot) lwidth(medthick) legend(label(1 "EndoMod") label(2 "EndoNot") label(3 "ExoMod") label(4 "ExoNot"))) , saving(graphvm0_randic,replace)
graph combine "graphvm1_randic" "graphvm0_randic"  , cols(1) graphregion(color(white)) saving(Graph_col_randic,replace) 

clear
use all_subjects_qu
gen endomod_c=coop if endomod==1
gen endonot_c=coop if endonot==1
gen exomod_c=coop if exomod==1
gen exonot_c=coop if exonot==1 
keep if randic==0
collapse endomod_c endonot_c exomod_c exonot_c if Period<21, by (Period modification)
twoway (line endomod_c Period if modification==1, lwidth(medthick) title(Wanted modification) graphregion(color(white)) xline(10.5) xtitle("Round") xscale(range(1 20)) xlabel(#20) ytitle("Cooperation") yscale(range(0 1)) ylabel(#6) scale(.6) ) (line endonot_c Period if modification==1, lpattern("_..") lwidth(medthick)) (line exomod_c Period if modification==1, lpattern(dash) lwidth(medthick)) (line exonot_c Period if modification==1, lpattern(dash_dot) lwidth(medthick)  legend(label(1 "EndoMod") label(2 "EndoNot") label(3 "ExoMod") label(4 "ExoNot"))), xscale(off) saving(graphvm1,replace)
twoway (line endomod_c Period if modification==0, lwidth(medthick) title(Did not want modification) graphregion(color(white)) xline(10.5) xtitle("Round") xscale(range(1 20)) xlabel(#20) ytitle("Cooperation") yscale(range(0 1)) ylabel(#6) scale(.6) ) (line endonot_c Period if modification==0, lpattern("_..") lwidth(medthick)) (line exomod_c Period if modification==0, lpattern(dash) lwidth(medthick)) (line exonot_c Period if modification==0, lpattern(dash_dot) lwidth(medthick) legend(label(1 "EndoMod") label(2 "EndoNot") label(3 "ExoMod") label(4 "ExoNot"))) , saving(graphvm0,replace)
graph combine "graphvm1" "graphvm0"  , cols(1) graphregion(color(white)) saving(Graph_col,replace) 
clear

use all_subjects_qu

*cooperation in entire third stage:
ranksum coop if Period>=11 & game==1 & randic==0, by (endo)
ranksum coop if Period>=11 & game==1 & randic==1, by (endo)

*comparison between treatments:
reg coop randic if Period>=11 & game==1 & endo==1

*Table 9

bysort subject: gen align0 = 1 if speakerchoice==finalwinner
replace align0=0 if speakerchoice!=finalwinner
bysort subject: egen align = max(align0) if Period>10 & Period<21
drop align0
reg coop modification##align##endo if game==1 & Period>10 & Period<21 & randic==0, vce (cluster group)
 reg coop modification##align##endo if game==0 & Period>10 & Period<21 & randic==0, vce (cluster group)

 *Welfare Implications
 *Table 10
 
sum Punkte if randic==0 & Period>10 & Period<21 & game==0
sum Punkte if randic==0 & Period>10 & Period<21 & game==1
sum Punkte if randic==1 & Period>10 & Period<21 & game==0
sum Punkte if randic==1 & Period>10 & Period<21 & game==1

sum Punkte if randic==0 & Period>10 & Period<21 & endomod==1
sum Punkte if randic==0 & Period>10 & Period<21 & endonot==1
sum Punkte if randic==0 & Period>10 & Period<21 & exomod==1
sum Punkte if randic==0 & Period>10 & Period<21 & exonot==1

sum Punkte if randic==1 & Period>10 & Period<21 & endomod==1
sum Punkte if randic==1 & Period>10 & Period<21 & endonot==1
sum Punkte if randic==1 & Period>10 & Period<21 & exomod==1
sum Punkte if randic==1 & Period>10 & Period<21 & exonot==1
 
 *Appendix:
 *Table 11:
 
drop if totalcoop1==0 | totalcoop1==10
tab totalcoop1 randic if Period==20
reg totalcoop2 endomod endonot exonot modification totalcoop1 if Period==11 & randic==0, vce(cluster group)
reg totalcoop2 endomod endonot exonot modification totalcoop1 if Period==11 & randic==1, vce(cluster group)

*************************************************
















