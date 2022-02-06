	
	
*set your working directory:
cd ""
	
*net from http://www.econ.hit-u.ac.jp/~kan/research/ztree2stata
*net install ztree2stata 

* load data from ztree
* I use the program ztree2stata by Kan Takeuchi
* start by loading the representative democracy treatment session files:

ztree2stata subjects using 1.xls , save replace 
clear
ztree2stata subjects using 2.xls , save replace
clear
ztree2stata subjects using 3.xls , save replace
clear

ztree2stata subjects using 161025_1022.xls , save replace 
clear
ztree2stata subjects using 161025_1245.xls , save replace
clear
ztree2stata subjects using 161026_1423.xls , save replace
clear

ztree2stata game using 1.xls , save replace
replace session="1"
gen Session = 1 if session=="1"
gen subject = (Session*100) + Subject
drop Subject session
save "/1-game.dta", replace
clear
ztree2stata game using 2.xls , save replace
replace session="2" if session=="160121_1424"
gen Session = 2 if session=="2"
gen subject = (Session*100) + Subject
drop Subject session
save "2-game.dta", replace
clear
ztree2stata game using 3.xls , save replace
replace session="3" if session=="160126_1030"
gen Session = 3 if session=="3"
gen subject = (Session*100) + Subject
drop Subject session
save "3-game.dta", replace
clear

ztree2stata game using 161025_1022.xls , save replace
replace session="4"
gen Session = 4 if session=="4"
gen subject = (Session*100) + Subject
drop Subject session
save "4-game.dta", replace
clear
ztree2stata game using 161025_1245.xls , save replace
replace session="5" if session=="161025_1245"
gen Session = 5 if session=="5"
gen subject = (Session*100) + Subject
drop Subject session
save "5-game.dta", replace
clear
ztree2stata game using 161026_1423.xls , save replace
replace session="6" if session=="161026_1423"
gen Session = 6 if session=="6"
gen subject = (Session*100) + Subject
drop Subject session
save "6-game.dta", replace
clear


*sessions 1-3:
append using  "1-subjects.dta" "2-subjects.dta" "3-subjects.dta" 
replace session="1" if session=="160121_0954"
replace session="2" if session=="160121_1424"
replace session="3" if session=="160126_1030"
gen Session = 1 if session=="1"
replace Session = 2 if session=="2"
replace Session = 3 if session=="3"
drop session
* make subjects and groups identifiable across sessions with three digit ID where first number is the session number
gen subject = Subject + (Session*100) 
gen group = Group + (Session*100) 
drop Subject Group control1 control2 control3 control4 control5
sum Session subject group if Period==1
save "id_subjects1.dta", replace
clear
use 1-game
append using 2-game
append using 3-game
save "game1.dta", replace
clear
use id_subjects1
merge m:1 subject using game1, nogen
bysort subject: egen game_2 = min(game)
drop game
rename game_2 game

save "id_subjects1.dta", replace
clear

*sessions 4-6:
append using   "161025_1022-subjects.dta"  "161025_1245-subjects.dta" "161026_1423-subjects.dta"
replace session="4" if session=="161025_1022"
replace session="5" if session=="161025_1245"
replace session="6" if session=="161026_1423"
gen Session = 4 if session=="4"
replace Session = 5 if session=="5"
replace Session = 6 if session=="6"
drop session
gen subject = Subject + (Session*100) 
gen group = Group + (Session*100) 
drop Subject Group control1 control2 control3 control4 control5
sum Session subject group
save "id_subjects2.dta", replace
clear

use 4-game
append using 5-game
append using 6-game
save "game2.dta", replace
clear
use id_subjects2
merge m:1 subject using game2, nogen
bysort subject: egen game_2 = min(game)
drop game
rename game_2 game
save "id_subjects2.dta", replace
clear

* import and merge the questionnaires
import excel using Questionnaires_coded_allsessions, firstrow 
save "qu1.dta",  replace
clear
use id_subjects1
merge m:1 subject using qu1 , nogen
drop if age==. 
* a bug in the ztree code caused problems in the first session, these observations are dropped
drop if subject<200 & group~=101 
replace game=1 if game==0
save "id_subjects_qu1.dta", replace
clear

import excel Questionnaire2_complete, firstrow
destring age subject income major semester gametheory experience gamereason votereason rememberspeaker remembergame logic, replace
drop if subject==.
save "qu2.dta", replace
clear

use id_subjects2
merge m:1 subject using qu2, nogen
drop TotalProfit TimeWeiterVoteOutcomeOK TimeWeiterProfitOK TimeWeiterProfit2OK TimeWeiterControl2OK TimeWeiterControl1OK TimeWeiterAuszahlungOK TimeOKVoteIOK TimeOKGameOK TimeOKGame2OK treatment modrand changerand randtie
save "id_subjects_qu2.dta", replace
append using  "id_subjects_qu1.dta" 
save "id_subjects_qu.dta", replace

*create variables:
replace decision = 0 if decision ==2
rename (decision) (coop) 
replace otherchoice = 0 if otherchoice==2
bysort subject: egen ocoop0 = sum(otherchoice) if Period<11
bysort subject: egen ocoop_0=min(ocoop0)
drop ocoop0
replace preference = . if preference==0
bysort subject: egen profit=sum(Profit)
drop Profit
gen econ=1 if major==1      
replace econ=0 if major~=1
bysort subject: egen modi_vote = min(preference)
gen modification = 1 if modi_vote == 2
replace modification = 0 if modi_vote ~= 2  
drop preference modi_vote
bysort subject: egen totalcoop=sum(coop)
bysort subject: egen totalcoop_1=sum(coop)if Period<11
bysort subject: egen totalcoop1= min(totalcoop_1)
drop totalcoop_1
bysort subject: egen totalcoop_2=sum(coop) if Period>10
bysort subject: egen totalcoop2= min(totalcoop_2)
drop totalcoop_2
bysort subject: gen av1_coop= (totalcoop1)/10 if Period<11
*replace game=1 if Period>=11 & game==0
*replace game=. if game==0
replace speakerconsider = . if Period~=11
bysort subject: egen endo=min(speakerconsider)
drop speakerconsider
replace endo = . if group<200
replace endo = 1 if group==101 
generate Endomod=1 if Period==11 & endo==1 & game==2
generate Exomod=1 if Period==11 & endo==0 & game==2
generate Exonot=1 if Period==11 & endo==0 & game==1
generate Endonot=1 if Period==11 & endo==1 & game==1
bysort subject: egen endomod=min(Endomod)
bysort subject: egen endonot=min(Endonot)
bysort subject: egen exomod=min(Exomod)
bysort subject: egen exonot=min(Exonot)
replace endomod=0 if endomod~=1
replace endonot=0 if endonot~=1
replace exomod=0 if exomod~=1
replace exonot=0 if exonot~=1
gen votestage=1 if endomod==1
replace votestage=2 if endonot==1
replace votestage=3 if exomod==1
replace votestage=4 if exonot==1
drop Endomod Endonot Exomod Exonot
gen endomody = (endomod*modification)
gen endonoty = (endonot*modification)
gen exomody = (exomod*modification)
gen exonoty = (exonot* modification)
gen endomodn = (endomod*(1-modification))
gen endonotn = (endonot*(1-modification))
gen exomodn = (exomod*(1-modification))
gen exonotn = (exonot* (1-modification))
replace modi=. if modi==0
bysort group: egen sp_modi=min(modi)
replace game=0 if game==1
replace game=1 if game==2
save "id_subjects_qu.dta", replace
clear

* RD treatment:

ztree2stata subjects using RD1.xls , save replace 
clear
ztree2stata subjects using RD2.xls , save replace
clear
ztree2stata subjects using RD3.xls , save replace
clear
ztree2stata subjects using RD4.xls , save replace
clear
ztree2stata subjects using RD5.xls , save replace
clear
ztree2stata subjects using RD6.xls , save replace
clear

append using  "RD1-subjects.dta" "RD2-subjects.dta" "RD3-subjects.dta" "RD4-subjects.dta" "RD5-subjects.dta" "RD6-subjects.dta"
replace session="1" if session=="190326_1142"
replace session="2" if session=="190326_1343"
replace session="3" if session=="190426_1538"
replace session="4" if session=="190507_0857"
replace session="5" if session=="191202_1219"
replace session="6" if session=="191202_1435"
gen Session = 1 if session=="1"
replace Session = 2 if session=="2"
replace Session = 3 if session=="3"
replace Session = 4 if session=="4"
replace Session = 5 if session=="5"
replace Session = 6 if session=="6"
drop session
gen subject = Subject + (Session*100) 
gen group = Group + (Session*100) 
drop Subject Group control1 control2 control3 control4 control5  
save  "RDall_sessions.dta", replace
clear



import excel "q1.xlsx", firstrow
gen session=1
gen subject = Subject + (session*100) 
drop Subject client income
save "q1.dta", replace
clear

import excel "q2.xlsx", firstrow
gen session=2
gen subject = Subject + (session*100) 
drop Subject client income
save "q2.dta", replace
clear

import excel "q3.xlsx", firstrow
gen session=3
gen subject = Subject + (session*100) 
drop Subject client income
save "q3.dta", replace
clear

import excel "q4.xlsx", firstrow
gen session=4
gen subject = Subject + (session*100) 
drop Subject client income
save "q4.dta", replace
clear

import excel "q5.xlsx", firstrow
gen session=5
gen subject = Subject + (session*100) 
drop Subject client income
save "q5.dta", replace
clear

import excel "q6.xlsx", firstrow
gen session=6
gen subject = Subject + (session*100) 
drop Subject client income
save "q6.dta", replace

append using "q1.dta" "q2.dta" "q3.dta" "q4.dta" "q5.dta"
gen female=1 if gender=="weiblich"
replace female = . if gender!="weiblich"
replace female = 0 if gender=="männlich"
gen econ= 1 if major == "ja, Volkswirtschaftslehre oder ein verwandtes Fach"
replace econ =0 if major != "ja, Volkswirtschaftslehre oder ein verwandtes Fach"
rename major studies
gen major=-1 if studies=="nein"
replace major=1 if studies=="ja, Volkswirtschaftslehre oder ein verwandtes Fach"
replace major=9 if studies=="ja, ein anderes Fach"
gen logic1 = 1 if rose ==47
replace logic1 = 0 if rose !=47
gen logic2 = 1 if machine == 5
replace logic2 = 0 if machine != 5
gen logic3 = 1 if ball == 5
replace logic3 = 0 if ball != 5
gen logic = logic1 + logic2 + logic3
save "RD_qu.dta", replace
clear

* merge the subjects table and the questionnaire
use RDall_sessions
merge m:1 subject using RD_qu.dta 
bysort subject: egen game = max(newgame)
label variable game  "0 = Spiel 1; 1 = Spiel 2"
label variable preference  "0 = Spiel 1; 1 = Spiel 2"
replace subject = subject+600
replace group = group+600
save "RD_subjects_qu.dta", replace

drop tables treatment TimeWeiterControl1OK TimeOKGameOK TimeWeiterProfitOK TimeWeiterControl2OK TimeOKVoteIOK TimeWeiterVoteOutcomeOK TimeOKGame2OK TimeWeiterProfit2OK TimeWeiterAuszahlungOK party rose machine ball 
replace Profit =. if Profit==0
replace decision = 0 if decision ==2
rename (decision) (coop) 
replace otherchoice = 0 if otherchoice==2
bysort subject: egen ocoop0 = sum(otherchoice) if Period<11
bysort subject: egen ocoop_0=min(ocoop0)
drop ocoop0
replace preference=. if Period ~=11
bysort subject: egen modification = min(preference)
 replace modi=. if Period ~=11
 bysort subject: egen smodi = min(modi)
bysort subject: egen totalcoop=sum(coop)
bysort subject: egen totalcoop_1=sum(coop)if Period<11
bysort subject: egen totalcoop1= min(totalcoop_1)
bysort subject: egen totalcoop_2=sum(coop) if Period>10
bysort subject: egen totalcoop2= min(totalcoop_2)
drop totalcoop_1 totalcoop_2
replace consider = . if Period~=11
bysort subject: egen endo=min(consider)
drop consider
generate Endomod=1 if Period==11 & endo==1 & game==1
generate Exomod=1 if Period==11 & endo==0 & game==1
generate Exonot=1 if Period==11 & endo==0 & game==0
generate Endonot=1 if Period==11 & endo==1 & game==0
bysort subject: egen endomod=min(Endomod)
bysort subject: egen endonot=min(Endonot)
bysort subject: egen exomod=min(Exomod)
bysort subject: egen exonot=min(Exonot)
replace endomod=0 if endomod~=1
replace endonot=0 if endonot~=1
replace exomod=0 if exomod~=1
replace exonot=0 if exonot~=1
gen votestage=1 if endomod==1
replace votestage=2 if endonot==1
replace votestage=3 if exomod==1
replace votestage=4 if exonot==1
label var votestage "1=endomod, 2=endonot, 3=exomod, 4= exonot"
drop Endomod Endonot Exomod Exonot
*bysort Period: egen coop_sum = sum(coop)
*gen coop_share = (coop_sum/140)*100
bysort Period: egen coop_sum_mod = sum(coop) if game==1 & Period >10 & Period<21  
gen coop_share_mod = (coop_sum_mod/84)*100 
label variable coop_share_mod "cooperation rate under modified payoffs"
bysort Period: egen coop_sum_not = sum(coop) if game==0 & Period >10 & Period<21    
gen coop_share_not = (coop_sum_not/58)*100 
drop coop_sum_not coop_sum_mod 
gen endomody = (endomod*modification)
gen endonoty = (endonot*modification)
gen exomody = (exomod*modification)
gen exonoty = (exonot* modification)
gen endomodn = (endomod*(1-modification))
gen endonotn = (endonot*(1-modification))
gen exomodn = (exomod*(1-modification))
gen exonotn = (exonot* (1-modification))
gen gamet=0 if gametheory=="nein" 
replace gamet=1 if gametheory=="ja"
drop gametheory
rename gamet gametheory

***append the data with ID treatment:
append using id_subjects_qu, force

drop modi TotalProfit TimeWeiterVoteOutcomeOK TimeWeiterProfitOK TimeWeiterProfit2OK TimeWeiterControl2OK TimeWeiterControl1OK TimeWeiterAuszahlungOK TimeOKVoteIOK TimeOKGameOK TimeOKGame2OK treatment modrand changerand randtie tables

replace gametheory = 0 if gametheory==.
replace major=-1 if major==.
replace female=-1 if female==.
gen randic=1 if subject > 700
replace randic=0 if randic==.
rename profit profit_
gen profit=profit_ if randic==0
replace profit=Profit if randic==1
drop profit_ Profit


bysort Period: egen coop_sum = sum(coop) 
gen coop_share = (coop_sum/280)*100  
bysort subject: replace speaker=10 if speaker==playerID & randic==1
replace speaker=0 if speaker~=10 & randic==1
replace speaker=1 if speaker>0 & randic==1

drop Participate playerID change points round1 round2 payout1 payout2 oprand rand pairing pair rank rando randommod newgame logic1 logic2 logic3 tiebreak
label variable winner "player(s) with most votes in their group"
label variable votestage "gives vote stage outcome: =1 for endomod, =2 for endonot, =3 for exomod, = 4 for exonot"
label variable voteplace "place a player made in the election for group speaker"
label variable totalcoop "number of rounds a subject cooperated in whole experiment"
label variable totalcoop1 "number of rounds a subject cooperated in part 1"
label variable totalcoop2 "number of rounds a subject cooperated in part 2"
label variable subject "unique player identification number"
label variable speaker "=1 if subject was speaker, 0 otherwise"
label variable profit "earnings in the experiment"
label variable otherchoice "action a subject's partner played in a given period; = 1 for X, =0 for Y"
label variable opponent "player with whom a subject is paired in a given period"
label variable ocoop_0 "number of rounds a subject's partners cooperate in part 1"
label variable modification "=1 if a player wanted to modify, 0 otherwise"
label variable group "group number, first number gives session"
label variable game "game in part 2, 0=prisoners' dilemma, 1=coordination game"
label variable exonoty "1= subject in exonot voted for modification, 0 otherwise"
label variable exonotn "1= subject in exonot voted against modification, 0 otherwise"
label variable exonot "1= for exonot condition, 0 otherwise"
label variable exomody "1= subject in exomod voted for modification, 0 otherwise"
label variable exomodn "1= subject in exomod voted against modification, 0 otherwise"
label variable exomod "1= for exomod condition, 0 otherwise"
label variable endonoty "1= subject in endonot voted for modification, 0 otherwise"
label variable endonotn "1= subject in endonot voted against modification, 0 otherwise"
label variable endonot "1= for endonot condition, 0 otherwise"
label variable endomody "1= subject in endomod voted for modification, 0 otherwise"
label variable endomodn "1= subject in endomod voted against modification, 0 otherwise"
label variable randic "treatment dummy, id=0, rd=1"
label variable endomod "1= for endomod condition, 0 otherwise"
label variable endo "=1 in endogenous condition, =0 in exogenous condition"
label variable gamereason "reason for (non-)modification: 0=prisoners dilemma for higher payoff, 1=coordination for fairness, 2=other, -1=no reason" 
label variable votereason "reason for voting for a player: 0=none, 1=was cooperative, 2=other"
label variable semester "number of semesters a subject has already studied"
label variable major "what a subject studies: -1=not a student, 1=Economics , 2=Humanities, 3=Natural Science, 4=Engineering, 5=Computer Science, 6=Psychology, 7=Pedagogy, 8=Languages, 9=other"
label variable econ " subject related to economics"
label variable experience " 1 = already participated in experiments"
label variable logic "how many questions a subject correctly answered"
label variable income "how much money a subject earns per month"
label variable female "1=female, 0=male, -1=other"

save "all_subjects_qu.dta", replace



