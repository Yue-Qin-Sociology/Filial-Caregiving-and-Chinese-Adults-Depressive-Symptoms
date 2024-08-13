************************************************************
**Filial Caregiving and Chinese Adults' Depressive Symptoms
**Yue Qin 08.12.2024
************************************************************

//download 2011, 2013, 2014, 2018, and the harmonized (2011-2018) CHARLS data from the official website 
**https://charls.pku.edu.cn/en/

*****Step 1: Get caregiving information from family-level data 

*****2011

//check whether parents are household members in 2011 
//because family-level data are reported by one household member, so we need to know both parents'and parents in law's information before copying parents in law's information to the spouse's cells 
use CHARLS2011\household_roster.dta, clear
gen hmemfa11 = 1 if a006_1_ ==2 | a006_2_ == 2 | a006_3_ ==2 | a006_4_ ==2 | a006_5_ ==2 | a006_6_ ==2 | a006_7_ ==2 | a006_8_ ==2 | a006_9_ == 2
//father 
gen hmemmo11 = 1 if a006_1_ ==1 | a006_2_ == 1 | a006_3_ ==1 | a006_4_ ==1 | a006_5_ ==1 | a006_6_ ==1 | a006_7_ ==1 | a006_8_ ==1 | a006_15_ == 1
//mother 
gen hmemfa12 = 1 if a006_1_ ==4 | a006_2_ == 4 | a006_3_ ==4 | a006_4_ ==4 | a006_5_ ==4 | a006_6_ ==4 | a006_7_ ==4 | a006_8_ ==4 | a006_9_ ==4 | a006_10_ ==4 | a006_11_ ==4
//father in law
gen hmemmo12 = 1 if a006_1_ ==3 | a006_2_ == 3 | a006_3_ ==3 | a006_4_ ==3 | a006_5_ ==3 | a006_6_ ==3 | a006_7_ ==3 | a006_8_ ==3 | a006_9_ ==3 | a006_10_ ==3 | a006_11_ ==3
//mother in law 

//change householdID and ID to merge with other waves later 
replace householdID = householdID + "0"
replace ID = householdID + substr(ID,-2,2)
keep ID householdID hmemfa11 hmemmo11 hmemfa12 hmemmo12
save roster1.dta

//2011 family-level data 
use "CHARLS2011\family_information.dta", clear
merge 1:1 ID using CCHARLS2011\family_transfer.dta
drop _merge

//whether live with parents: father, mother, father in law, and mother in law
rename ca016_1_ faresi11
rename ca016_2_ moresi11
rename ca016_3_ faresi12
rename ca016_4_ moresi12

//parents' health at the baseline: father, mother, father in law, and mother in law
rename ca013_1_ fhealthb11
rename ca013_2_ mhealthb11
rename ca013_3_ fhealthb12
rename ca013_4_ mhealthb12

//caregiving time
//cf005*: respondents' caregiving time, and cf006*: the spouse's caregiving time 
//some values are larger than the maximum possible, so I top-code them
for var cf005_1 cf005_3 cf005_5 cf005_7: replace X = 52 if X > 52 & X < .
//unit: weeks 
for var cf005_2 cf005_4 cf005_6 cf005_8: replace X = 140 if X > 140 & X <.
//hours in each week 
for var cf006_1 cf006_3 cf006_5 cf006_7: replace X = 52 if X > 52 & X < .
for var cf006_2 cf006_4 cf006_6 cf006_8: replace X = 140 if X > 140 & X <.

//caregiving time 
gen carehfa11 = 0 if cf004 == 2
replace carehfa11 = 0 if cf005_1 == 0
replace carehfa11 = 0 if cf005_2 == 0
replace carehfa11 = cf005_1 * cf005_2 if cf005_1 >0 & cf005_2 > 0 & cf005_1 <. & cf005_2 <.
//weeks * hours per week 
tab carehfa11,m 
//1034 missing values; 10.14% 
//To figure out why there are so many missing values:
tab cf004,m
//1315 replied yes 
sum cf005_1
//only 405 answered 
sum cf005_2
//only 396 answered 
//cf004 asked whether respondent or the spouse provided any care to parents, while cf005_1 and cf005_2 are only about respondent's caregiving to father. So, I assume that missing values in cf005_1 and cf005_2 are mainly because when respondents replied yes in cf004, they mean respondents' caregiving to mother or their spouses' caregiving to parents (i.e. they skipped cf005_1 and cf005_2 and answered other caregiving-time-to-parent questions after replying yes under cf004)

//Therefore, I impute missing values in carehfa11 using the following strategy: 
replace carehfa11 = 0 if carehfa11 >=. & cf004 ==1
//925 missing cases were imputed. the remaining missing values are hard to impute because we do not know their answers to cf004 
//a few missing values were because of the unbalanced answers between cf005_1 and cf005_2

//the same logic above for respondents' caregiving time to mother 
gen carehmo11 = 0 if cf004 == 2
replace carehmo11 = 0 if cf005_3 == 0
replace carehmo11 = 0 if cf005_4 == 0
replace carehmo11 = cf005_3 * cf005_4 if cf005_3 >0 & cf005_4 > 0 & cf005_3 <. & cf005_4 <.

replace carehmo11 = 0 if carehmo11 >=. & cf004 ==1

//the same logic above for the spouse's caregiving time to respondents' father in law 
gen carehfa12 = 0 if cf004 == 2
replace carehfa12 = 0 if cf006_5 == 0
replace carehfa12 = 0 if cf005_6 == 0
replace carehfa12 = cf006_5 * cf006_6 if cf006_5 >0 & cf006_6 > 0 & cf006_5 <. & cf006_6 <.

replace carehfa12 = 0 if carehfa12 >=. & cf004 ==1

//the same logic above for the spouse' caregiving time to respondents' mother in law 
gen carehmo12 = 0 if cf004 == 2
replace carehmo12 = 0 if cf006_7 == 0
replace carehmo12 = 0 if cf006_8 == 0
replace carehmo12 = cf006_7 * cf006_8 if cf006_7 >0 & cf006_8 > 0 & cf006_7 <. & cf006_8 <.

replace carehmo12 = 0 if carehmo12 >=. & cf004 ==1

//change householdID and ID to merge with other waves later
replace householdID = householdID + "0"
replace ID = householdID + substr(ID,-2,2)

merge 1:1 ID using roster1.dta
drop _merge

//faresi11-moresi12 coding: 1=adjacent dwelling, 2= another household in the same neighborhood, 3=another neighborhood in the same county/city, 4=another county/city in the same province, and 5=another province. 
//I add a new category 0=household member (living together)
replace faresi11 = 0 if hmemfa11 ==1
replace moresi11 = 0 if hmemmo11 ==1
replace faresi12 = 0 if hmemfa12 ==1
replace moresi12 = 0 if hmemmo12 ==1

keep ID householdID faresi11 faresi12 moresi11 moresi12 carehfa11 carehfa12 carehmo11 carehmo12 fhealthb11 mhealthb11 fhealthb12 mhealthb12

//merge with harmonized CHARLS data (2011-2018)
merge 1:1 ID using H_CHARLS_D_Data.dta, keepusing(ID householdID r1famr inw1)
keep if inw1 == 1
//only keep those in the 2011 CHARLS 
drop _merge
bysort householdID: gen x =_n
tab x
drop x

sort householdID

//as only one respondent in the household answered the family-level questions, I need to copy the information to the cells of the spouse 
for var faresi11 faresi12 moresi11 moresi12 carehfa11 carehfa12 carehmo11 carehmo12 fhealthb11 mhealthb11 fhealthb12 mhealthb12: replace X= X[_n+1] if r1famr==0 & householdID==householdID[_n+1]
for var faresi11 faresi12 moresi11 moresi12 carehfa11 carehfa12 carehmo11 carehmo12 fhealthb11 mhealthb11 fhealthb12 mhealthb12: replace X= X[_n-1] if r1famr==0 & householdID==householdID[_n-1]

//get each respondent's caregiving time to their own father and mother based on whether they participated in the family survey 
gen faresi1 = faresi11 if r1famr==1
replace faresi1 = faresi12 if r1famr==0
gen moresi1 = moresi11 if r1famr==1
replace moresi1 = moresi12 if r1famr==0

gen carehfa1 = carehfa11 if r1famr==1
replace carehfa1 = carehfa12 if r1famr==0
gen carehmo1 = carehmo11 if r1famr==1
replace carehmo1 = carehmo12 if r1famr==0

//get each respondent's parents' health at baseline based on whether they participated in the family survey 
gen fhealthb = fhealthb11 if r1famr ==1
replace fhealthb = fhealthb12 if r1famr ==0
gen mhealthb = mhealthb11 if r1famr ==1
replace mhealthb = mhealthb12 if r1famr ==0

save 2011care.dta

//now we can check missingness
merge 1:1 ID using H_CHARLS_D_Data.dta, keepusing(inw1 r1dadliv r1momliv)
tab inw1 _merge
drop if _merge == 2
drop _merge
misschk carehfa1 if r1dadliv==1
misschk carehmo1 if r1momliv==1
//now missingness is smaller than 10%
clear 


//repeat the logics above to the 2013 and 2018 waves 


//2013
use "CHARLS2013\Family_Information.dta", clear
merge 1:1 ID using CHARLS2013\Family_Transfer.dta
drop _merge

//co-residence with parents 
rename ca016_1_ faresi21
rename ca016_2_ moresi21
rename ca016_3_ faresi22
rename ca016_4_ moresi22

//top-coding
for var cf005_1 cf005_3 cf005_5 cf005_7: replace X = 52 if X > 52 & X < .
for var cf005_2 cf005_4 cf005_6 cf005_8: replace X = 140 if X > 140 & X <.
for var cf006_1 cf006_3 cf006_5 cf006_7: replace X = 52 if X > 52 & X < .
for var cf006_2 cf006_4 cf006_6 cf006_8: replace X = 140 if X > 140 & X <.

//caregiving time to father 
gen carehfa21 = 0 if cf004 == 2
replace carehfa21 = 0 if cf005_1 == 0
replace carehfa21 = 0 if cf005_2 == 0
replace carehfa21 = cf005_1 * cf005_2 if cf005_1 >0 & cf005_2 > 0 & cf005_1 <. & cf005_2 <.
//impute the missin values
replace carehfa21 = 0 if carehfa21 >=. & cf004 ==1

//caregiving time to mother 
gen carehmo21 = 0 if cf004 == 2
replace carehmo21 = 0 if cf005_3 == 0
replace carehmo21 = 0 if cf005_4 == 0
replace carehmo21 = cf005_3 * cf005_4 if cf005_3 >0 & cf005_4 > 0 & cf005_3 <. & cf005_4 <.

replace carehmo21 = 0 if carehmo21 >=. & cf004 ==1

//the spouse's caregiving time to father 
gen carehfa22 = 0 if cf004 == 2
replace carehfa22 = 0 if cf006_5 == 0
replace carehfa22 = 0 if cf005_6 == 0
replace carehfa22 = cf006_5 * cf006_6 if cf006_5 >0 & cf006_6 > 0 & cf006_5 <. & cf006_6 <.

replace carehfa22 = 0 if carehfa22 >=. & cf004 ==1

//the spouse's caregiving time to mother 
gen carehmo22 = 0 if cf004 == 2
replace carehmo22 = 0 if cf006_7 == 0
replace carehmo22 = 0 if cf006_8 == 0
replace carehmo22 = cf006_7 * cf006_8 if cf006_7 >0 & cf006_8 > 0 & cf006_7 <. & cf006_8 <.

replace carehmo22 = 0 if carehmo22 >=. & cf004 ==1

keep ID householdID faresi21 faresi22 moresi21 moresi22 carehfa21 carehfa22 carehmo21 carehmo22

//merge with harmonized CHARLS data (2011-2018) 
merge 1:1 ID using H_CHARLS_D_Data.dta, keepusing(ID householdID r2famr inw2)
keep if inw2 == 1
//in 2013 CHARLS 
drop _merge
bysort householdID: gen x =_n
tab x
drop x

sort householdID

//copy information to the spouse 
for var faresi21 faresi22 moresi21 moresi22 carehfa21 carehfa22 carehmo21 carehmo22: replace X= X[_n+1] if r2famr==0 & householdID==householdID[_n+1]
for var faresi21 faresi22 moresi21 moresi22 carehfa21 carehfa22 carehmo21 carehmo22: replace X= X[_n-1] if r2famr==0 & householdID==householdID[_n-1]

//get each respondent's caregiving time to their parents based on their participation status in the family survey 
gen faresi2 = faresi21 if r2famr==1
replace faresi2 = faresi22 if r2famr==0

gen moresi2 = moresi21 if r2famr==1
replace moresi2 = moresi22 if r2famr==0

gen carehfa2 = carehfa21 if r2famr==1
replace carehfa2 = carehfa22 if r2famr==0
gen carehmo2 = carehmo21 if r2famr==1
replace carehmo2 = carehmo22 if r2famr==0

save 2013care.dta


//now we can check missingness
merge 1:1 ID using H_CHARLS_D_Data.dta, keepusing(inw2 r2dadliv r2momliv)
tab inw2 _merge
drop if _merge == 2
drop _merge
misschk carehfa2 if r2dadliv==1
misschk carehmo2 if r2momliv==1
//now missingness is smaller than 10%
clear 



//2018 CHARLS 
use CHARLS2018\Family_Information.dta, clear
merge 1:1 ID using CHARLS2018\Family_Transfer.dta
drop _merge

//generate an indicator of living with parents(including adoptive parents)
gen faresi41 = ca016_1_
replace faresi41 = ca016_3_ if ca016_3_ <.

gen moresi41 = ca016_2_
replace moresi41 = ca016_4_ if ca016_4_ <.

gen faresi42 = ca016_5_
replace faresi42 = ca016_7_ if ca016_7_ <.

gen moresi42 = ca016_6_
replace moresi42 = ca016_8_ if ca016_8_ <.

//check the missingness of caregiving
egen rowmiss = rowmiss(cf004_w4_1_ cf004_w4_2_ cf004_w4_3_ cf004_w4_4_ cf004_w4_5_ cf004_w4_6_ cf004_w4_7_ cf004_w4_8_)
tab rowmiss
//6985 missing on all questions possibly because their parents passed away

//caregiving time to father 
gen carehfa41 = 0 if cf004_w4_1_ == 2
replace carehfa41 = 0 if cf004_w4_3_ == 2
replace carehfa41 = 0 if cf005_w4_1_1_ == 0 
replace carehfa41 = 0 if cf005_w4_1_3_ == 0
replace carehfa41 = cf005_w4_1_1_ * cf005_w4_2_1_ if cf005_w4_1_1_ >0 & cf005_w4_2_1_ >0 & cf005_w4_1_1_ <. & cf005_w4_2_1_ <.
replace carehfa41 = cf005_w4_1_3_ * cf005_w4_2_3_ if cf005_w4_1_3_ >0 & cf005_w4_2_3_ >0 & cf005_w4_1_3_ <. & cf005_w4_2_3_ <.

replace carehfa41 = 0 if carehfa41 >=. & cf004_w4_1_ ==1
replace carehfa41 = 0 if carehfa41 >=. & cf004_w4_3_ ==1

//caregiving time to mother 
gen carehmo41 = 0 if cf004_w4_2_ == 2
replace carehmo41 = 0 if cf004_w4_4_ == 2 
replace carehmo41 = 0 if cf005_w4_1_2_ == 0 
replace carehmo41 = 0 if cf005_w4_1_4_ == 0 
replace carehmo41 = cf005_w4_1_2_ * cf005_w4_2_2_ if cf005_w4_1_2_ >0 & cf005_w4_2_2_ >0 & cf005_w4_1_2_ <. & cf005_w4_2_2_ <.
replace carehmo41 = cf005_w4_1_4_ * cf005_w4_2_4_ if cf005_w4_1_4_ >0 & cf005_w4_2_4_ >0 & cf005_w4_1_4_ <. & cf005_w4_2_4_ <.

replace carehmo41 = 0 if carehmo41 >=. & cf004_w4_2_ ==1
replace carehmo41 = 0 if carehmo41 >=. & cf004_w4_4_ ==1

//the spouse's caregiving time to his/her father 
gen carehfa42 = 0 if cf004_w4_5_ == 2
replace carehfa42 = 0 if cf004_w4_7_ == 2
replace carehfa42 = 0 if cf006_w4_1_5_ == 0 
replace carehfa42 = 0 if cf006_w4_1_7_ == 0
replace carehfa42 = cf006_w4_1_5_ * cf006_w4_2_5_ if cf006_w4_1_5_ >0 & cf006_w4_2_5_ >0 & cf006_w4_1_5_ <. & cf006_w4_2_5_ <.
replace carehfa42 = cf006_w4_1_7_ * cf006_w4_2_7_ if cf006_w4_1_7_ >0 & cf006_w4_2_7_ >0 & cf006_w4_1_7_ <. & cf006_w4_2_7_ <.

replace carehfa42 = 0 if carehfa42 >=. & cf004_w4_5_ ==1
replace carehfa42 = 0 if carehfa42 >=. & cf004_w4_7_ ==1

//the spouse's caregiving time to his/her father 
gen carehmo42 = 0 if cf004_w4_6_ == 2
replace carehmo42 = 0 if cf004_w4_8_ == 2 
replace carehmo42 = 0 if cf006_w4_1_6_ == 0 
replace carehmo42 = 0 if cf006_w4_1_8_ == 0 
replace carehmo42 = cf006_w4_1_6_ * cf006_w4_2_6_ if cf006_w4_1_6_ >0 & cf006_w4_2_6_ >0 & cf006_w4_1_6_ <. & cf006_w4_2_6_ <.
replace carehmo42 = cf006_w4_1_8_ * cf006_w4_2_8_ if cf006_w4_1_8_ >0 & cf006_w4_2_8_ >0 & cf006_w4_1_8_ <. & cf006_w4_2_8_ <.

replace carehmo42 = 0 if carehmo42 >=. & cf004_w4_6_ ==1
replace carehmo42 = 0 if carehmo42 >=. & cf004_w4_8_ ==1


keep ID householdID faresi41 faresi42 moresi41 moresi42 carehfa41 carehfa42 carehmo41 carehmo42

//merge with harmonized CHARLS data 
merge 1:1 ID using H_CHARLS_D_Data.dta, keepusing(ID householdID r4famr inw4)
keep if inw4 == 1
//in the 2018 wave 
drop _merge
bysort householdID: gen x =_n
tab x
drop x

sort householdID

//copy information to the spouse's cells 
for var faresi41 faresi42 moresi41 moresi42 carehfa41 carehfa42 carehmo41 carehmo42: replace X= X[_n+1] if r4famr==0 & householdID==householdID[_n+1]
for var faresi41 faresi42 moresi41 moresi42 carehfa41 carehfa42 carehmo41 carehmo42: replace X= X[_n-1] if r4famr==0 & householdID==householdID[_n-1]

//get each respondent's caregiving time to their own father and mother based on whether they participated in the family survey 
gen faresi4 = faresi41 if r4famr==1
replace faresi4 = faresi42 if r4famr==0

gen moresi4 = moresi41 if r4famr==1
replace moresi4 = moresi42 if r4famr==0

gen carehfa4 = carehfa41 if r4famr==1
replace carehfa4 = carehfa42 if r4famr==0

gen carehmo4 = carehmo41 if r4famr==1
replace carehmo4 = carehmo42 if r4famr==0

save 2018care.dta


//we can check missingness of caregiving
merge 1:1 ID using H_CHARLS_D_Data.dta, keepusing(inw4 r4dadliv r4momliv)
tab inw4 _merge
drop if _merge == 2
drop _merge
misschk carehfa4 if r4dadliv==1
misschk carehmo4 if r4momliv==1
//now missing values are not larger than 10%.
clear 


//merge caregiving information from 2011, 2013, and 2018 waves 

use 2018care.dta
merge 1:1 ID using 2013care.dta
drop _merge

merge 1:1 ID using 2011care.dta
drop _merge

save 2011-2018care.dta



************Step 2: use the main dataset for estimation 
//open the harmonized CHARLS data (2011-2018) 
use H_CHARLS_D_Data.dta

//merge family information from the 2014 CHARLS Life History Survey 
merge 1:1 ID using CHARLS_Life_History_Data\Family_Information.dta
drop if _merge ==2
drop _merge

//merge childhood health information from the 2014 CHARLS Life History Survey
merge 1:1 ID using CHARLS_Life_History_Data\Health_History.dta
drop if _merge ==2
drop _merge

gen childhealth = 0 if hs002 == 4 | hs002 == 5
replace childhealth = 1 if hs002 == 3
replace childhealth = 2 if hs002 < 3

//we also need to control for social engagement in each wave  
//in each wave, we use the following code to get social engagement
//first, open the Health_Status_and_Functioning.dta in each wave  
//egen social = rowmin( da057_1_ da057_2_ da057_3_ da057_4_ da057_5_ da057_6_ da057_7_ da057_8_ da057_9_ da057_10_ da057_11_)
//tab social
//replace social = 4 if da056s12 == 12
//recode social (1=0)(2=1)(3=2)(4=3)
//then rename social in each wave into r1social, r2social, and r4social, and save them
//save socialize.dta

merge 1:1 ID using socialize.dta
drop if _merge ==2
drop _merge

//get participation status in 2014 (the Life History Survey)
rename inw3 inw2015
merge 1:1 ID using H_CHARLS_C_Data.dta, keepusing(inw3)
drop if _merge == 2
drop _merge
rename inw3 inwlh
rename inw2015 inw3
 
keep ID householdID communityID rabyear ragender raeduc_c rafeduc_c rameduc_c inw1 inw2 inw4 r1cesd10 r2cesd10 r4cesd10 r1hukou r2hukou r4hukou r1work r2work r4work r1momliv r2momliv r4momliv r1dadliv r2dadliv r4dadliv childhealth r1mstat r2mstat r4mstat r1work r2work r4work r1wtrespb r2wtrespb r4wtrespb social1 social2 social4 a4a a4b j1_a j1_b k1_a k1_b r1livsib r2livsib r4livsib inwlh r1wthha r2wthha r4wthha


merge 1:1 ID using 2011-2018care.dta, keepusing(carehfa1 carehfa2 carehfa4 carehmo1 carehmo2 carehmo4 faresi1 faresi2 faresi4 moresi1 moresi2 moresi4 fhealthb mhealthb)
drop if _merge ==2
drop _merge

//we also need information on respondents' self-rated health in each wave. I did not use r1shlt-r4shlt because they have more missing values than the variables from the original datasets of the 2011-2018 CHARLS 
//for 2011 and 2013 CHARLS, first, open the Health_Status_and_Functioning.dta in each wave 
//then:
//gen health = da001
//recode health (1 2 3=2)(4=1)(5=0)
//replace health = 2 if da002 <3
//replace health = 1 if da002 == 3
//replace health = 0 if da002 == 4 | da002 == 5
//for 2018 CHARLS, simply use da002 
//gen health = da002 
//recode health (1 2=2)(3=1)(4 5=0)
//replace health =. if health >5
//then, rename self-rated health in each wave: r1health, r2health, and r4health, and save them
//save health2011-2018.dta


merge 1:1 ID using health2011-2018.dta, keepusing(r1health r2health r4health)
drop if _merge ==2
drop _merge


//get analytic sample step by step  
//start from 25586

//those who were aged 45+ in 2011 (2011-45=1966)
keep if rabyear <= 1966
//21246 remain 

gen paliv1 = 1 if r1dadliv == 1 | r1momliv ==1
gen paliv2 = 1 if r2dadliv == 1 | r2momliv ==1
gen paliv4 = 1 if r4dadliv == 1 | r4momliv ==1

//those whose parents were alive in any one wave 
keep if paliv1 == 1 | paliv2 ==1 | paliv4 ==1
//7292 remain 

//those who partipated in the life history survey 
keep if inwlh ==1
//5870 remain 

//rename age in different waves 
gen age1 = 2011 - rabyear
gen age2 = 2013 - rabyear
gen age4 = 2018 - rabyear

//rename gender 
recode ragender (1=0)(2=1)
rename ragender female

//rename cesd(depressive symptoms) in different waves 
rename r1cesd10 cesd1
rename r2cesd10 cesd2
rename r4cesd10 cesd4

//rename marital status in different waves 
for var r1mstat r2mstat r4mstat: recode X (4 5 7 8=0)(1 3=1)
rename r1mstat marri1
rename r2mstat marri2
rename r4mstat marri4

//rename hukou in different waves 
for var r1hukou r2hukou r4hukou: recode X (2 3 4=0)
rename r1hukou hukou1
rename r2hukou hukou2
rename r4hukou hukou4

//rename health in different waves 
rename r1health health1
rename r2health health2
rename r4health health4

//rename childhood SES/parental highest education 
egen childses = rowmax(rameduc_c rafeduc_c)
recode childses (1=0)(2 3 4=1)(5 6 7 8 9 10=2)

//rename work status in different waves 
rename r1work work1
rename r2work work2
rename r4work work4

//rename education 
gen edu = raeduc_c
recode edu (1=0)(2 3 4=1)(5 6 7 8 9 10=2)


//rename mother's living status in different waves 
rename r1momliv momliv1
rename r2momliv momliv2
rename r4momliv momliv4

//rename father's living status in different waves 
rename r4dadliv dadliv4
rename r2dadliv dadliv2
rename r1dadliv dadliv1

//rename number of living siblings in different waves 
rename r1livsib livsib1
rename r2livsib livsib2
rename r4livsib livsib4

//rename weights in different waves 
gen weight1 = r1wtrespb
gen weight2 = r2wtrespb
gen weight4 = r4wtrespb

//not raised up by mother 
gen a4ano = 1 if a4a == 4 | a4a ==5
//not raised up by father 
gen a4bno = 1 if a4b == 4 | a4b ==5
//drop those who were not raised up by parents 
drop if a4ano == 1 & a4bno == 1
////5800 cases

**********the code here is not for the main analysis********
//if we want to check how many respondents quit later because of their parents died
//there are two methods
//method 1: create indicators of parents' living status in all waves based on data from other waves:
//gen mliv1 = momliv1
//replace mliv1 = 1 if momliv2 ==1 & mliv1 >=.
//replace mliv1 = 1 if momliv4 ==1 & mliv1 >=.
//the logic here is that if the mother is alive in 2018, it must be alive in 2011 and 2013

//gen mliv2 = momliv2
//replace mliv2 = 1 if momliv4 ==1 & mliv2 >=.
//replace mliv2 = 0 if mliv1 == 0 & mliv2 >=.
//the logic here is that if the mother is dead in 2011, it must be dead in 2013. 

//gen mliv4 = momliv4
//replace mliv4 = 0 if mliv1 == 0 & mliv4 >=.
//replace mliv4 = 0 if mliv2 == 0 & mliv4 >=.

//tab mliv1 
//note here mliv1=1 has 4793 observations
//a little different from 4781 observations in the mother sample
//possibly because not all respondents participated in the 2011 survey
//and we have not excluded all a4a=4 | a4a=5
//but it does not vary too much
//and we only care about proportions here. 
//tab mliv2
//tab mliv4

//count if mliv4==1
//2408/4793 = 50%
//count if mliv1 == 1 & mliv2 ==0 
//768/4793 = 16%
//count if mliv2 ==1 & mliv4==0
//1098/4793 = 23%

//method 2: 
//count if momliv4==1
//2408/4781 = 50%
//count if momliv1 == 1 & momliv2 ==0
//758/ 4781 = 16%
//count if momliv2 == 1 & momliv4 ==0
//1097/4781 = 23% 
//these proportions do not add up to 100% possibly because of missingness
//in any waves.
//but method 1 and method 2 get similar results about how many people quit because of their mothers' death. 16% in 2013 and 23% in 2018. 

//then we can try these two methods for the father sample
//gen fliv1 = dadliv1
//replace fliv1 = 1 if dadliv2 ==1 & fliv1 >=.
//replace fliv1 = 1 if dadliv4 ==1 & fliv1 >=.

//gen fliv2 = dadliv2
//replace fliv2 = 1 if dadliv4 ==1 & fliv2 >=.
//replace fliv2 = 0 if fliv1 == 0 & fliv2 >=.

//gen fliv4 = dadliv4
//replace fliv4 = 0 if fliv1 == 0 & fliv4 >=.
//replace fliv4 = 0 if fliv2 == 0 & fliv4 >=.

//tab fliv1
//2709 lived in 2011
//different from 2710 in the analytic sample

//count if fliv4==1
//1188/2709 = 44%
//count if fliv1 == 1 & fliv2 ==0 
// 587/2709 = 22%
//count if fliv2 ==1 & fliv4==0
//676 / 2709 = 25%

//count if dadliv4==1
//1188/2710 = 44%
//count if dadliv1 == 1 & dadliv2 ==0
//584/ 2710 = 22%
//count if dadliv2 == 1 & dadliv4 ==0
//676/2710 = 25% 

//so the two methods also generate similar results. 22% in 2013 and 25% in 2018. 

**********end**************************
//reshape dataset from the wide format to the long format 
reshape long work@ social@ paresi@ palivimp@ paliv@ moresi@ momliv@ marri@ livsib@ inw@ hukou@ health@ faresi@ dadliv@ cesd@ carepa@ carehpa@ carehmo@ carehfa@ age@ bsocial@ weight@, i(ID) j(wave)

drop if inw==0

label values wave .
keep if paliv == 1
//keep observations in which parents were alive

//if I want to calclulate how many waves were completed by individuals
bysort ID: gen x=_n
tab x
//2046 individuals completed 3 waves 
//4096-2046=2050 individuals completed 2 waves 
//5800-4096=1704 individuals completed 1 wave

//if I want to calclulate how many waves were completed by households
preserve
bysort ID: gen x=_n
tab x
keep if x==3
bysort householdID: gen hh = _n ==1
tab hh
//1784 households completed 3 waves in the total sample 
restore
preserve
bysort ID: gen x=_n
gen x2=x
replace x2= x2[_n+1] if x2[_n+1]==3 & ID==ID[_n+1]
replace x2= x2[_n-1] if x2[_n-1]==3 & ID==ID[_n-1]
list ID x x2 in 1/20
keep if x2==2
bysort householdID: gen hh2 = _n ==1
tab hh2
//1885 households completed 2 waves 
restore
preserve 
bysort ID: gen x=_n
gen x2=x
drop if x2==3
list ID x x2 in 1/20
replace x2= x2[_n+1] if x2[_n+1]==2 & ID==ID[_n+1]
replace x2= x2[_n-1] if x2[_n-1]==2 & ID==ID[_n-1]
keep if x2==1
tab x2
bysort householdID: gen hh = _n ==1
tab hh
//1555 households completed 1 wave 
restore 
*******


//count how many respondents appear in both subsamples
preserve 
gen msub = 1 if momliv ==1 & a4a !=4 & a4a !=5
gen fsub = 1 if dadliv ==1 & a4b !=4 & a4b !=5

keep if msub ==1 & fsub ==1
bysort ID: gen xxxx=_n
tab xxxx
//1721
restore 


**********************below are subsample analysis
//for caregiving to mother

keep if momliv == 1

drop if a4a == 4 | a4a == 5
//55 dropped

//here we have two options about whether we should keep
//those who lived with their parents.
//we can try both samples
//first, let's try keeping all respondents

drop x
bysort ID: gen x=_n
tab x
//4781 cases--size of this subsample 

//whether care mother in each wave 
gen caremo = 1 if carehmo > 0 & carehmo <.
replace caremo = 0 if carehmo == 0

sum carehmo, detail
tab caremo
tab caremo if x==1
//about 4/5 respondents reported 0 hour

gen logcare = log(carehmo + 0.1)
//log transform caregiving time because of its right skewness  

tab j1_a
//recode it so that a higher value indicates a better relationship with mother in childhood 
recode j1_a (1=5)(2=4)(3=3)(4=2)(5=1)
label values j1_a .


tab k1_a
//recode it so that a higher value indicates more frequent childhood abuse from mother 
recode k1_a (1=4)(2=3)(3=2)(4=1)
label values k1_a .


gen relation = j1_a
recode relation (1 2=1)(3=2)(4=3)(5=4)
//few people reported "poor," so merge it with "fair"
gen abuse = k1_a
recode abuse ( 4=3)
//few people reported "often," so merge it with "somewhat"


replace childses=. if childses >.
replace work =. if work >.
replace bsocial =. if bsocial >.
replace dadliv =. if dadliv >.
replace hukou =. if hukou >.
replace livsib = . if livsib >.
replace mhealthb=. if mhealthb >.
replace cesd =. if cesd >.
replace moresi =. if moresi>.

tab moresi
gen moresi_c = moresi
recode moresi_c (0 1=1)(2 3 4 5 6=0)
//living in the same household/courtyard 

sum age
gen agemc = age - r(mean)
gen agemc2 = agemc * agemc


gen mhealthb_t = mhealthb
recode mhealthb_t (1 2=2)(3=1)(4 5=0)
//mother's health at baseline 

//check missing values 
misschk logcare hukou health social childses cesd marri rabyear female edu work livsib dadliv abuse relation childhealth mhealthb moresi

//mixed effects before multiple imputation 
mixed cesd c.logcare##i.relation c.logcare##i.abuse agemc agemc2 marri hukou i.work i.health i.social i.dadliv i.moresi_c livsib female i.edu i.childhealth i.childses i.mhealthb_t || householdID: || ID:
mixed cesd c.logcare i.relation i.abuse agemc agemc2 marri hukou i.work i.health i.social i.dadliv i.moresi_c livsib female i.edu i.childhealth i.childses i.mhealthb_t || householdID: || ID:

//multiple impurtation to deal with missing values 
mi set wide
mi register regular age female edu marri
mi register imputed hukou social work cesd childhealth health childses carehmo relation abuse dadliv livsib mhealthb_t moresi_c
mi impute chained (reg) cesd carehmo livsib (logit)hukou work dadliv moresi_c(mlogit) mhealthb_t social relation abuse childhealth health childses = age edu female marri, rseed(1) add(20) dots

mi passive: gen cesds = cesd
mi passive: replace cesds = 0 if cesds <0
//the largest value is 30 in all imputed datasets

mi passive: gen carehmot = carehmo
mi passive: replace carehmot = 0 if carehmo <0
//the largest value is 7280 in all imputed datasets


mi passive: gen logcarei = log(carehmot + 0.1)

mi passive: gen livsibn = livsib
mi passive: replace livsibn = 0 if livsibn <0
//it seems that all imputed values are integer


mi estimate, cmdok dots post: mixed cesds c.logcarei##i.relation c.logcarei##i.abuse agemc agemc2 marri hukou i.work i.health i.social i.dadliv i.moresi_c livsibn female i.edu i.childhealth i.childses i.mhealthb_t || householdID: || ID:
esttab using models.rtf, b(2) star(* 0.05 ** 0.01 *** 0.001) se(2)
mi estimate, cmdok dots post: mixed cesds c.logcarei i.relation i.abuse agemc agemc2 marri hukou i.work i.health i.social i.dadliv i.moresi_c livsibn female i.edu i.childhealth i.childses i.mhealthb_t || householdID: || ID:


//if we use caremo, a binary independent variable, for sensitivity analysis 
//mi passive: gen caremob = 0 if carehmot==0
//mi passive: replace caremob = 1 if carehmot >0
//mi estimate, cmdok dots post: mixed cesds i.caremob##i.relation i.caremob##i.abuse agemc agemc2 marri hukou i.work i.health i.social i.dadliv i.moresi_c livsibn female i.edu i.childhealth i.childses i.mhealthb_t || householdID: || ID:
//mi estimate, cmdok dots post: mixed cesds i.caremob i.relation i.abuse agemc agemc2 marri hukou i.work i.health i.social i.dadliv i.moresi_c livsibn female i.edu i.childhealth i.childses i.mhealthb_t || householdID: || ID:

//if we trim the top 1% and bottom 1% carehmo
//preserve 
//sum logcarei
//mi passive: gen keep = 1 if inrange(logcarei, r(p1), r(p99))
//keep if keep ==1
//mi estimate, cmdok dots post: mixed cesds c.logcarei##i.relation c.logcarei##i.abuse agemc agemc2 marri hukou i.work i.health i.social i.dadliv i.moresi_c livsibn female i.edu i.childhealth i.childses i.mhealthb_t || householdID: || ID:
//mi estimate, cmdok dots post: mixed cesds c.logcarei i.relation i.abuse agemc agemc2 marri hukou i.work i.health i.social i.dadliv i.moresi_c livsibn female i.edu i.childhealth i.childses i.mhealthb_t || householdID: || ID:
//restore 

//since adding weights have a convergence issue, we tried the following codes for sensitivity analysis
//mi estimate, cmdok dots post: mixed cesd c.logcare##i.relation c.logcare##i.abuse agemc agemc2 marri hukou i.work i.health i.social i.dadliv i.moresi_c livsib female i.edu i.childhealth i.childses i.mhealthb_t [pweight= weight ] || ID:, pweight( r1wtrespb ) pwscale(size) vce(cluster householdID)
//mi estimate, cmdok dots post: mixed cesds c.logcarei##i.relation c.logcarei##i.abuse agemc agemc2 marri hukou i.work i.health i.social i.dadliv livsibn female i.edu i.childhealth i.childses i.mhealthb_t weight || householdID: || ID:
//mixed cesd c.logcare##i.relation c.logcare##i.abuse agemc agemc2 marri hukou i.work i.health i.social i.dadliv i.moresi_c livsib female i.edu i.childhealth i.childses i.mhealthb_t [pweight= weight ] || ID:, pweight( r1wtrespb ) pwscale(size) vce(cluster householdID)
//or
//mixed cesd c.logcare##i.relation c.logcare##i.abuse agemc agemc2 marri hukou i.work i.health i.social i.dadliv i.moresi_c livsib female i.edu i.childhealth i.childses i.mhealthb_t [pweight=obserw] || ID:, pweight( r1indiw ) pwscale(gk) vce(cluster householdID)


***descriptive analysis
sum cesd
sum carehmo
sum age
tab marri
tab hukou
tab work
tab health
tab social
tab dadliv
tab moresi_c
sum livsib
tab relation
tab abuse
tab female
tab edu
tab childhealth
tab childses
tab mhealthb_t

//descriptive statistics by wave
tab wave
sum cesd if wave ==1
sum cesd if wave ==2
sum cesd if wave ==4
sum carehmo if wave ==1
sum carehmo if wave ==2
sum carehmo if wave ==4
sum age if wave ==1
sum age if wave ==2
sum age if wave ==4
tab marri if wave ==1
tab marri if wave ==2
tab marri if wave ==4
tab hukou if wave ==1
tab hukou if wave ==2
tab hukou if wave ==4
tab work if wave ==1
tab work if wave ==2
tab work if wave ==4
tab health if wave ==1
tab health if wave ==2
tab health if wave ==4
tab social if wave ==1
tab social if wave ==2
tab social if wave ==4
tab dadliv if wave ==1
tab dadliv if wave ==2
tab dadliv if wave ==4
tab moresi_c if wave==1
tab moresi_c if wave==2
tab moresi_c if wave==4
sum livsib if wave ==1
sum livsib if wave ==2
sum livsib if wave ==4



//now, let's try dropping those living with their parents
tab moresi,m
drop if moresi <2
bysort ID: gen xxx=_n
tab xxx
//4371 individuals remain 

mi estimate, cmdok dots post: mixed cesds c.logcarei##i.relation c.logcarei##i.abuse agemc agemc2 marri hukou i.work i.health i.social i.dadliv i.moresi_c livsibn female i.edu i.childhealth i.childses i.mhealthb_t || householdID: || ID:
esttab using models.rtf, b(2) star(* 0.05 ** 0.01 *** 0.001) se(2)
mi estimate, cmdok dots post: mixed cesds c.logcarei i.relation i.abuse agemc agemc2 marri hukou i.work i.health i.social i.dadliv i.moresi_c livsibn female i.edu i.childhealth i.childses i.mhealthb_t || householdID: || ID:



*********
//for caregiving to father 

keep if dadliv == 1

drop if a4b == 4 | a4b == 5

bysort ID: gen x=_n
tab x
//2710

//whether care father in each wave 
gen carefa = 1 if carehfa > 0 & carehfa <.
replace carefa = 0 if carehfa == 0


sum carehfa, detail
tab carefa
tab carefa if x==1
//about 4/5 respondents reported 0 hour

//log transform caregiving time because of its right skewness 
gen logcare = log(carehfa + 0.1)


tab j1_b
//recode it so that a higher value indicates better relationship with father in childhood 
recode j1_b (1=5)(2=4)(3=3)(4=2)(5=1)
label values j1_b .

tab k1_b
//recode it so that a higher value indicates more frequent childhood abuse by father
recode k1_b (1=4)(2=3)(3=2)(4=1)
label values k1_b .


gen relation = j1_b
recode relation (1 2=1)(3=2)(4=3)(5=4)
//few people reported "poor," so combine it with "fair" 
gen abuse = k1_b
recode abuse ( 4=3)
//few people reported "often," so combine it with "somewhat"


replace childses=. if childses >.
replace work =. if work >.
replace social =. if social >.
replace momliv =. if momliv >.
replace hukou =. if hukou >.
replace livsib = . if livsib >.
replace fhealthb=. if fhealthb >.
replace cesd =. if cesd >.
replace faresi =. if faresi >.

//whether live with father 
tab faresi
gen faresi_c = faresi
recode faresi_c (0 1=1)(2 3 4 5 6=0)

sum age
gen agemc = age - r(mean)
gen agemc2 = agemc * agemc

//baseline health of father 
gen fhealthb_t = fhealthb
recode fhealthb_t (1 2=2)(3=1)(4 5=0)


misschk logcare hukou health social childses cesd marri rabyear female edu work livsib momliv abuse relation childhealth fhealthb faresi

//mixed effects before multiple imputation 
mixed cesd c.logcare##i.relation c.logcare##i.abuse agemc agemc2 marri hukou i.work i.health i.social i.momliv i.faresi_c livsib female i.edu i.childhealth i.childses i.fhealthb_t || householdID: || ID:
mixed cesd c.logcare i.relation i.abuse agemc agemc2 marri hukou i.work i.health i.social i.momliv i.faresi_c livsib female i.edu i.childhealth i.childses i.fhealthb_t || householdID: || ID:

//multiple imputation with chained equations 
mi set wide
mi register regular age female edu marri
mi register imputed hukou social work cesd childhealth health childses carehfa relation abuse momliv livsib fhealthb_t faresi_c
mi impute chained (reg) cesd carehfa livsib (logit)hukou work momliv faresi_c(mlogit) fhealthb_t social relation abuse childhealth health childses = age edu female marri, rseed(1) add(20) dots

mi passive: gen cesds = cesd
mi passive: replace cesds = 0 if cesds <0
mi passive: replace cesds = 30 if cesds >30


mi passive: gen carehfat = carehfa
mi passive: replace carehfat = 0 if carehfa <0
//it seems that the largested imputed values are 7280

mi passive: gen logcarei = log(carehfat + 0.1)

mi passive: gen livsibn = livsib
mi passive: replace livsibn = 0 if livsibn <0


mi estimate, cmdok dots post: mixed cesds c.logcarei##i.relation c.logcarei##i.abuse agemc agemc2 marri hukou i.work i.health i.social i.momliv i.faresi_c livsibn female i.edu i.childhealth i.childses i.fhealthb_t || householdID: || ID:
esttab using models.rtf, b(2) star(* 0.05 ** 0.01 *** 0.001) se(2) append
mi estimate, cmdok dots post: mixed cesds c.logcarei i.relation i.abuse agemc agemc2 marri hukou i.work i.health i.social i.momliv i.faresi_c livsibn female i.edu i.childhealth i.childses i.fhealthb_t || householdID: || ID:


//if we use carefab, a binary independent variable
//mi passive: gen carefab = 0 if carehfat==0
//mi passive: replace carefab = 1 if carehfat >0
//mi estimate, cmdok dots post: mixed cesds i.carefab##i.relation i.carefab##i.abuse agemc agemc2 marri hukou i.work i.health i.social i.momliv i.faresi_c livsibn female i.edu i.childhealth i.childses i.fhealthb_t || householdID: || ID:
//mi estimate, cmdok dots post: mixed cesds i.carefab i.relation i.abuse agemc agemc2 marri hukou i.work i.health i.social i.momliv i.faresi_c livsibn female i.edu i.childhealth i.childses i.fhealthb_t || householdID: || ID:

//if we trim the top 1% and bottom 1% of carehfa 
//preserve 
//sum logcarei
//mi passive: gen keep = 1 if inrange(logcarei, r(p1), r(p99))
//keep if keep == 1
//mi estimate, cmdok dots post: mixed cesds c.logcarei##i.relation c.logcarei##i.abuse agemc agemc2 marri hukou i.work i.health i.social i.momliv i.faresi_c livsibn female i.edu i.childhealth i.childses i.fhealthb_t || householdID: || ID:
//mi estimate, cmdok dots post: mixed cesds c.logcarei i.relation i.abuse agemc agemc2 marri hukou i.work i.health i.social i.momliv i.faresi_c livsibn female i.edu i.childhealth i.childses i.fhealthb_t || householdID: || ID:
//restore 


//descriptive
sum cesd
sum carehfa
sum age
tab marri
tab hukou
tab work
tab health
tab social
tab momliv
tab faresi_c
sum livsib
tab relation
tab abuse
tab female
tab edu
tab childhealth
tab childses
tab fhealthb_t

tab wave
sum cesd if wave ==1
sum cesd if wave ==2
sum cesd if wave ==4
sum carehfa if wave ==1
sum carehfa if wave ==2
sum carehfa if wave ==4
sum age if wave ==1
sum age if wave ==2
sum age if wave ==4
tab marri if wave ==1
tab marri if wave ==2
tab marri if wave ==4
tab hukou if wave ==1
tab hukou if wave ==2
tab hukou if wave ==4
tab work if wave ==1
tab work if wave ==2
tab work if wave ==4
tab health if wave ==1
tab health if wave ==2
tab health if wave ==4
tab social if wave ==1
tab social if wave ==2
tab social if wave ==4
tab momliv if wave ==1
tab momliv if wave ==2
tab momliv if wave ==4
tab faresi_c if wave ==1
tab faresi_c if wave ==2
tab faresi_c if wave ==4
sum livsib if wave ==1
sum livsib if wave ==2
sum livsib if wave ==4


//now exclude those coresding with fathers
drop if faresi_c ==1
drop x
bysort ID: gen x=_n
tab x
//2533 individuals remain 
mi estimate, cmdok dots post: mixed cesds c.logcarei##i.relation c.logcarei##i.abuse agemc agemc2 marri hukou i.work i.health i.social i.momliv i.faresi_c livsibn female i.edu i.childhealth i.childses i.fhealthb_t || householdID: || ID:
esttab using models.rtf, b(2) star(* 0.05 ** 0.01 *** 0.001) se(2) append
mi estimate, cmdok dots post: mixed cesds c.logcarei i.relation i.abuse agemc agemc2 marri hukou i.work i.health i.social i.momliv i.faresi_c livsibn female i.edu i.childhealth i.childses i.fhealthb_t || householdID: || ID:















