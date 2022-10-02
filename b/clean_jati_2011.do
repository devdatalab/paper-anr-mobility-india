#delimit ;
clear ;
clear mata ;
set more off ;
qui creturn list ;
local os = c(os) ;

global raw $mobility/jati ;

********************************************************************************
				MACHINE CLEANING OF ALL CASTES USING CASSAN DATASET
******************************************************************************** ;

* cleaned dataset from Cassan with cleaned caste names ;
use "$raw/IAPR42FL_clean.DTA", clear ;

keep caste_clean sstate sh41 ;

** rename variables for use ;
rename caste_clean jati ;
decode sstate, gen(state) ;
rename sstate stateid_cassan ;
rename sh41 sc_st_cassan ;

** cleaning state names and making jatis lower case ;
replace jati = lower(jati) ;
replace state = "arunachal pradesh" if state == "arunachalpradesh" ;

keep jati state ;
duplicates drop ;

tempfile hold; 
save `hold', replace ;

** dataset with typos in district names ;
#d ;
use "$mobility/ihds/ihds_mobility", clear ;

** getting state names ;
decode stateid, gen(state) ;
gen len = strlen(state) - 3 ;
replace state = substr(state,1,len) ;
replace state = lower(state) ;

** preliminary cleaning of jatis ; 
gen jati = id12anm ;
replace jati = lower(jati) ;
replace jati = strtrim(jati) ;
replace jati = subinstr(jati, ".","", .) ;
replace jati = subinstr(jati, ".","", .) ;
replace jati = subinstr(jati, "]","", .) ;
replace jati = subinstr(jati, "[","", .) ;
replace jati = subinstr(jati, "'","", .) ;
replace jati = subinstr(jati, "-","", .) ;
replace jati = regexr(jati,"[0-9]+","") ;


** fix spellings ;
fix_spelling jati, src(`hold') group(state) replace ;

save "$tmp/ihds_2011_machine_cleaned.dta", replace ;

********************************************************************************
		MACHINE CLEANING OF SCHEDULED CASTES AND SCHEDULED TRIBES
******************************************************************************** ;

#d ;

** census dataset with cleaned SC names ;
foreach num of numlist 1/11 14/30 32/34 { ;
  di "Opening $raw/SC_ST_census/SC-`num'-PCA-A10-APPENDIX.xls..." ;
  import excel "$raw/SC_ST_census/SC-`num'-PCA-A10-APPENDIX.xls", firstrow clear ;
	
	keep AreaName SCName ;
	duplicates drop ;
	
	keep if regexm(AreaName, "STATE") == 1 ;
	drop if SCName == "All Schedule Castes" ;
	
	replace AreaName = substr(AreaName, 9, .) ;
	replace AreaName = regexr(AreaName," [0-9]+","") ;
	
	tempfile state`num' ;
	save `state`num'', replace ;
} ;

** appending ;
use `state1', clear ;
foreach num of numlist 2/11 14/30 32/34 { ;
	append using `state`num'' ;
} ;

rename AreaName state ;
rename SCName caste ;

** cleaning up caste names ;
replace caste =  regexr(caste, "\((.)+\)", "") ;
replace caste =  regexr(caste, "\[(.)+\]", "") ;

** converting each observation to caste level ;
split caste, parse(",") ;
gen count = _n ;
drop caste ;

reshape long caste, i(count) j(j) ;

drop if caste == "" ;

drop count j ;

** final clean up of names ;
expand 2 if state == "JAMMU & KASHMIR" & caste == "Chamar or Ramdasia", gen(x) ;
expand 2 if state == "JAMMU & KASHMIR" & caste == "Doom or Mahasha", gen(y) ;
expand 2 if state == "JAMMU & KASHMIR" & caste == "Megh or Kabirpanthi", gen(z) ;

replace caste = "Chamar" if state == "JAMMU & KASHMIR" & caste == "Chamar or Ramdasia" & x == 0 ;
replace caste = "Ramdasia" if state == "JAMMU & KASHMIR" & caste == "Chamar or Ramdasia" & x == 1 ;

replace caste = "Doom" if  state == "JAMMU & KASHMIR" & caste == "Doom or Mahasha" & y == 0 ;
replace caste = "Mahasha" if  state == "JAMMU & KASHMIR" & caste == "Doom or Mahasha" & y == 1 ;

replace caste = "Megh" if state == "JAMMU & KASHMIR" & caste == "Megh or Kabirpanthi" & z == 0 ;
replace caste = "Kabirpanthi" if state == "JAMMU & KASHMIR" & caste == "Megh or Kabirpanthi" & z == 1 ;

drop x y z ;

replace caste = trim(caste) ;

replace caste = subinstr(caste, " a", "", .) ;
replace caste = subinstr(caste, " b", "", .) ;

replace state = lower(state) ;
replace caste = lower(caste) ;

tempfile hold1 ;
save `hold1', replace ;


** census dataset with cleaned ST names ;
#d ;
foreach num of numlist 1/2 5 8/12 14/33 35 { ;
	import excel "$raw/SC_ST_census/ST-`num'-PCA-A11-APPENDIX.xls", firstrow clear ;
	
	keep AreaName STName ;
	duplicates drop ;
	
	keep if regexm(AreaName, "STATE") == 1 ;
	drop if STName == "All Schedule Tribes" ;
	
	replace AreaName = substr(AreaName, 9, .) ;
	replace AreaName = regexr(AreaName," [0-9]+","") ;
	
	tempfile state`num' ;
	save `state`num'', replace ;
} ;

** appending ;
use `state1', clear ;
foreach num of numlist 1/2 5 8/12 14/33 35 { ;
	append using `state`num'' ;
} ;

rename AreaName state ;
rename STName caste ;

** cleaning up caste names ;
replace caste = "Kuki" if caste == "Kuki,   including the following sub-tribes *" ;
replace caste = subinstr(caste, ",  including:**", "", .) ;
replace caste = subinstr(caste, ", including:**", "", .) ;
replace caste =  regexr(caste, "\((.)+\)", "") ;
replace caste =  regexr(caste, "\[(.)+\]", "") ; 

** converting each observation to caste level ;
split caste, parse(",") ;
gen count = _n ;
drop caste ;

reshape long caste, i(count) j(j) ;

drop if caste == "" ;

drop count j ;

** final clean up of names ;
replace caste = trim(caste) ;

replace caste = subinstr(caste, " a", "", .) ;
replace caste = subinstr(caste, " b", "", .) ;
replace caste = subinstr(caste, " c", "", .) ;
replace caste = subinstr(caste, " d", "", .) ;
replace caste = subinstr(caste, " e", "", .) ;

replace state = lower(state) ;
replace caste = lower(caste) ;

tempfile hold2 ;
save `hold2', replace ;
append using `hold1' ;

rename caste jati ;

replace state = "orissa" if state == "odisha" ;

** creating a file for delhi ;
set obs `=_N+9' ;
replace state = "delhi" if state == "" ;
gen count = _n             if state == "delhi" ;
replace jati = "balmiki"   if state == "delhi" & count == 1 ;
replace jati = "chamar"    if state == "delhi" & count == 2 ;
replace jati = "dhobi"     if state == "delhi" & count == 3 ;
replace jati = "jatav"     if state == "delhi" & count == 4 ;
replace jati = "khatik"    if state == "delhi" & count == 5 ;
replace jati = "kanaujiya" if state == "delhi" & count == 6 ;
replace jati = "kohli"     if state == "delhi" & count == 7 ;
replace jati = "mahwar"    if state == "delhi" & count == 8 ;
replace jati = "harijan"   if state == "delhi" & count == 9 ;

drop count ;

set obs `=_N+1' ;
replace state = "tamil nadu" if state == "" ;
replace jati = "schedule caste" if jati == "" ;

set obs `=_N+1' ;
replace state = "karnataka" if state == "" ;
replace jati = "schedule caste" if jati == "" ;

set obs `=_N+1' ;
replace state = "maharashtra" if state == "" ;
replace jati = "bouddh" if jati == "" ;

set obs `=_N+1' ;
replace state = "maharashtra" if state == "" ;
replace jati = "navbuddha" if jati == "" ;

set obs `=_N+1' ;
replace state = "maharashtra" if state == "" ;
replace jati = "buddhist" if jati == "" ;

set obs `=_N+1' ;
replace state = "orissa" if state == "" ;
replace jati = "harijan" if jati == "" ;

tempfile hold ;
save `hold', replace ;

** dataset with typos in caste names ;
#d ;
use "$tmp/ihds_2011_machine_cleaned.dta", clear ;

replace jati = subinstr(jati, "sc ", "", .) ;
replace jati = subinstr(jati, "hindu ", "", .) ;
replace jati = "" if jati == "sc" ;
replace jati = "" if jati == "hindu" ;

keep if sc == 1 | st == 1 ;

** fix spellings ;
fix_spelling jati, src(`hold') group(state) replace ;

save "$tmp/ihds_2011_machine_cleaned2.dta", replace ;


*/
********************************************************************************
							FINAL MANUAL CLEANING OF CASTES
******************************************************************************** ;
#d ;
use "$tmp/ihds_2011_machine_cleaned.dta", clear ;

keep if sc == 0 & st == 0 ;

tempfile hold ;
save `hold', replace ;

use "$tmp/ihds_2011_machine_cleaned2.dta", clear ;

append using `hold' ;

** clean up jati names ;
replace jati = "" if jati == "dk" | jati == "dk dk" | jati == "schdulh caste" | jati == "sc" | jati == "hedule castgsakki" |
					 jati == "hedulecas tesakk" | jati == "hedulecaste" | jati == "scdulcost" | jati == "scheduie" |
					 jati == "schedule caste" | jati == "st" | jati == "t" | jati == "tribal" ; 
					 
replace jati = subinstr(jati, "hindu", "", .) ;
replace jati = trim(jati) ;

replace jati = id12bnm if state == "himachal pradesh" & substr(jati, 1, 3) == "anu" ;
replace jati = lower(jati) ;

replace jati = "aadivasi" if  jati == "aada vasi" | jati == "aadi vasi" | jati == "aadi wasi" |
							  jati == "aadiba" | jati == "aadibashi" | jati == "aadibasi" |
							  jati == "aadivashi" | jati == "aadiwali" | jati == "aadiwashi" |
							  jati == "aadiwasi" | jati == "adhivasi" | jati == "adhiwashi" |
							  jati == "adibaji" | jati == "adibashi" | jati == "adibasi" |
							  jati == "adivashi" | jati == "adivasi" | jati == "adiwashi" |
							  jati == "adiwasi" | jati == "adiyasi" | jati == "adobashi" |
							  jati == "acivasi" | jati == "addiwasi" | jati == "adhibasi" |
							  jati == "adibahi" | jati == "asibasi" | jati == "aadiivasi" |
							  jati == "aadivasibhil" | jati == "adivashi bhai" | jati == "aapibasi" |
							  (state == "jharkhand" & st == 1 & substr(jati, 1, 3) == "aad");
							  

replace jati = "arya"    if jati == "aarua" | jati == "aarya" ;

replace jati = "adi andhra" if jati == "adhiandracristian" | jati == "adiyandra madiga" | jati == "adiyandramala"  ;

replace jati = "adi dravida" if jati == "casts adhidravidar" | regexm(jati, "adithi") == 1 | regexm(jati, "athithi") == 1 |
								regexm(jati, "aathithi") == 1 | (state == "tamil nadu" & regexm(jati, "ravidar") == 1)  ;

replace jati = "adi dravida" if (jati == "aajhithi ravidas" | jati == "addhidhiravioar" |
								  jati == "adhhitri varar" | jati == "adhidhavadar" |
								  jati == "adhidraadar" | jati == "adhithavidar" |
								  jati == "adhithiravadar" | jati == "adhithiravidaar" |
								  jati == "adidradhar" | jati == "adidraduvidhar" |
								  jati == "adiravinder" | jati == "adthi trivarar" |
								  jati == "ahiravidas" | jati == "atai thiravitar" |
								  jati == "ataythi ravitar" | jati == "athaitheravethan" |
								  jati == " athidhar vadadr" | jati == "athiravitar" |
								  jati == "athitradavar" | jati == "athythi ravidas" |
								  jati == "atkidravider" | jati == "athidhar vadadr" |
								  jati == "hthiravitar" | jati == "padidravdar" ) ;
								  
replace jati = "adi jambava" if jati == "adi jambya" | jati == "adijabava" | jati == "adijamubava" |
								jati == "adhijambava" | jati == "adijabaava" | jati == "adijambava" | jati == "aditabhava" ;
								
replace jati = "agamudi" if jati == "agimudi" | jati == "agumudi" ;

replace jati = "ahirvar" if jati == "ahir var" | jati == "ahirwar" | jati == "ahar bal" | jati == "ahir" | jati == "aharawl" |
                            jati == "ahirvar harijan" ;

replace jati = "arunthathiyar" if jati == "arun" | jati == "arunthathiyar sakkil" | jati == "arunthayar" | jati == "arundhiar" ;

replace jati = "avadhiya" if jati == "avadhvanshi" | jati == "avast" | jati == "avdhavanshi" | jati == "avdhiya" |
							 jati == "awadhiya" | jati == "awdhiya" | jati == "awdhya" | jati == "awdya" | jati == "ayodhya vasi" ;

replace jati = "babrasi" if jati == "babrashi" ;

replace jati = "badodiya" if jati == "badoda" | jati == "badodeya" | jati == "badodoiya" | jati == "badodiha" |
							 jati == "badohia" ;

replace jati = "bagdi" if jati == "bagri" | jati == "bahgri" | jati == "bagari" | jati == "bagare" | jati == "bagoi" ;

replace jati = "bakoliya" if jati == "bakodoliya" ;		
replace jati = "bakthakumbar" if jati == "bakthakgmbar" ;

replace jati = "balae" if jati == "balai" | jati == "balai harijan" | jati == "baliya" | jati == "balyai" |
						  jati == "bhalai" | jati == "balhi" | jati == "balahi" | jati == "balai gfugrat" | jati == "balaie gujrati" |
						  jati == "balayi" | jati == "bali" | jati == "baliai" | jati == "ballie" | jati == "blai" ;

replace jati = "balmiki" if jati == "balmaki" | jati == "balmik" | jati == "balmikee" |
							jati == "valmiki" | jati == "balbiki" | jati == "waimiki" | 
							jati == "bhangi valmiki" | jati == "balmiki nagar" ;
							
replace jati = "banagega" if jati == "banagegar" | jati == "banagi galam baniga" | jati == "banagiga nayak"  | jati == "banajigas";

replace jati = "batu" if jati == "battu" ;
replace jati = "bauri" if jati == "baudi" | jati == "bavari" ;
replace jati = "bavari" if jati == "bawari" ;

replace jati = "bawaria" if jati == "bauri" | jati == "bavari" | jati == "baudi" | jati == "bawari" |
						     jati == "babari" | jati == "babariya" | jati == "babri" ;

							 
replace jati = "bhanjra" if jati == "banjare" | jati == "benjari" ;
							
replace jati = "barga kshatriya" if jati == "bagokhatra" | jati == "bagra khati" | jati == "bagra khatrio" |
									jati == "bagrakhatra" | jati == "barga khatrio" | jati == "bargokhatri" |
									jati == "bargokhotrio" | jati == "borgokhatri" | jati == "brgokhetro" ;
									
replace jati = "beda jangam" if jati == "beda buddga jagam" | jati == "beda" ;
							
replace jati = "berwal" if jati == "behar bal" | jati == "beharval" | jati == "behreal" | jati == "berbal" |
						   jati == "berlal" | jati == "berval" | jati == "berwa" | jati == "bharval" | jati == "badwal" |
						   jati == "barvad" | jati == "barwala" ;
							
replace jati = "bhargav" if jati == "bhargab" | jati == "bhargo" ;

replace jati = "bhaskar" if jati == "banskar" | jati == "barskar" | jati == "basnkar" | jati == "barskar" ;
			  
replace jati = "bhuiya" if jati == "bhuinya" | jati == "bhuiyan" | jati == "bhuyan" |
						   jati == "bhuian" ;
						   
replace jati = "bhil" if jati == "bhilala" | jati == "bhilla" | jati == "bhill" ;
						   
replace jati = "bhangi" if jati == "bhanei harijan" | jati == "bhangi harijan" ;

replace jati = "bihari" if jati == "bihare" ;

replace jati = "boro" if jati == "boro kach" | jati == "borokachari" ;

replace jati = "buddh" if jati == "bouddh" | jati == "bouddha" | jati == "bouddhist" |
						  jati == "boudh" | jati == "boudha" | jati == "buddha" |
						  jati == "buddhist" | jati == "buddi" | jati == "buddist" |
						  jati == "budhisht" | jati == "budhist" | jati == "bauddh" ;

replace jati = "chamar" if jati == "chaabhar" | jati == "chambhar" | jati == "chmar ahirvar" | jati == "rohit chamar" |
						   jati == "chamar suryavansham" | jati == "dchamar" ;

replace jati = "chandala" if jati == "chandol" | jati == "chandel" | jati == "chadel" ;

replace jati = "chauhan" if jati == "chahun" | jati == "chohan" | jati == "chuhan" |
							jati == "chouhan" | jati == "chouhan /" | jati == "chowan" | jati == "chouwan" ;
							
replace jati = "chaudhari" if jati == "chodary" | jati == "chodhry" | jati == "choudhary" | jati == "chaudhri" ;

replace jati = "chenna dasar" if jati == "channa dasa" ;

replace jati = "cheramar" if jati == "cheram" | jati == "cherama" | jati == "cheruman" ;

replace jati = "chowkidar" if jati == "chockidar" | jati == "chokadar" | jati == "chokidar" | jati == "chowkidadr" ;

replace jati = "dadhwal" if jati == "detvaal" | jati == "devatvaal" | jati == "devetvaal" | jati == "devtavaal" | jati == "dhedwal" ;
							
replace jati = "desh lahre" if jati == "desh lahar" | jati == "desh lare" ;

replace jati = "dhed" if jati == "dher" ;

replace jati = "dhiwar" if jati == "dhivar" | jati == "diwar" ;

replace jati = "dhobi" if jati == "dhoba" | jati == "dhopa" | jati == "dhaba" | jati == "dhapa" ;

replace jati = "dhodia" if jati == "dhodiya" | jati == "dhodiya patel" | jati == "dholi" | jati == "dholiya" |
						   jati == "dodiya" | jati == "doli" | jati == "doliya patel" ;

replace jati = "dhruv" if jati == "dhrub" | jati == "dhurwa" | jati == "drub" ;

replace jati = "diwakar" if jati == "dibakar" | jati == "dilvakar" ;

replace jati = "dom" if jati == "doom" | jati == "dome" ;

replace jati = "ediga" if jati == "ediganajaka" | jati == "edtga" | jati == "eediga" | jati == "eedigaru" |
						  jati == "eidge" ;

replace jati = "ganda" if jati == "gand" ;

replace jati = "garo" if jati == "garu harijan" ;

replace jati = "gond" if jati == "gouand" | jati == "gound" | jati == "gounda" | jati == "goundu" | 
						 jati == "gonda" | jati == "gondh"  | jati == "guund" | jati == "gaund" | 
						 jati == "gondi(addivashi)" | jati == "raj gond" | jati == "rajgond" | jati == "rajgord"  |
						 jati == "gond (st)" | jati == "gondas" ;

replace jati = "gothwal" if jati == "gothawal" | jati == "gothvaal" ; 

replace jati = "goud" if jati == "gaud"  | jati == "gouda"  | jati == "gaodha" | jati == "goada"  | jati == "gord" |
						 jati == "gore"  | jati == "gorh"   | jati == "goudh"  | jati == "gourd"  | 
						 jati == "gauad" | jati == "gauda"  | jati == "gaurd"  | jati == "gorad"  |
						 jati == "gowda" | jati == "goudas" | jati == "gowdes" | jati == "gowds"  |
						 jati == "godh adivashi" | jati == "godh adivasi" | jati == "gaud" | jati == "goda" | 
						 jati == "gode"  | jati == "gord addiwasi" | jati == "goud adiwadi" | jati == "guad" |
						 jati == "gaud (aadivasi)" ;
						 
						 
replace jati = "gowari" if jati == "govari" | jati == "goware" | jati == "guhari" ;

replace jati = "gilahare" if jati == "gilehare" | jati == "gilheri" ;

replace jati = "gujjar" if jati == "gujar" | jati == "gurjar" ;

replace jati = "halpati" if jati == "hadapati" | jati == "halapti" | jati == "dubala" ;

replace jati = "harijan" if jati == "haijan" | jati == "hariyana" | jati == "harizan" | jati == "hrijan" |
							jati == "harijan bad wal" | jati == "harijan chamar" | jati == "harijan folaha" |
							jati == "harijan/ chamar" | jati == "harijana" | jati == "hari" | jati == "hari jani" |
							jati == "harijan ramda" | jati == "harinaj" | jati == "harjan" |
							jati == "harigana" | jati == "harijanna" | jati == "harjina"  | jati == "harihana" |
							jati == "hari jan" | jati == "harijnchar" | jati == "arijan" | jati == "harisan" |
							jati == "harizen" | jati == "mharizen" | jati == "hairjan" | jati == "hraijan" ;
							
replace jati = "hindu pariyar" if jati == "hindu paraiyar" | jati == "hindu pariaiyar" ;

replace jati = "holaya dasar" if jati == "holaya" | jati == "holeya" | jati == "holiya" | jati == "holer" | jati == "holiyaru" |
								 jati == "honniyar" ; 
								 
replace jati = "hulasvar" if jati == "holswar" ;

replace jati = "jatav" if jati == "jaatav" | jati == "jatav (chamar)" | jati == "jataw" | jati == "jatay" | jati == "jathav" |
						  jati == "jatv" | jati == "jatab harijan" | jati == "jatava"| jati == "jadab chamar" | jati == "jaday" |
						  jati == "jatau" ;

replace jati = "julaha" if jati == "julahe" | jati == "julha" | jati == "jolaee" | jati == "julah" ; 

replace jati = "kabirpanthi" if jati == "kabir" | jati == "kabir panth" | jati == "kavirpanyi" ;

replace jati = "kaibartta" if jati == "kaibartha" | jati == "kaibatya das" | jati == "kabitra" ;

replace jati = "kapu" if jati == "kap" | jati == "kapu reddy" | jati == "kapulu" ;

replace jati = "kawar" if jati == "kavar" | jati == "kebar" | jati == "kuvar" | jati == "kuwar" ;

replace jati = "kanaujiya" if jati == "kanagujiya" | jati == "kaniyaji" | jati == "kannaojiya" | jati == "kannavjiya" |
							  jati == "kannojia" | jati == "kanojia" | jati == "kanujiya" | jati == "kannojiya" |
							  jati == "kanojiya" | jati == "kanoniya" | jati == "kanoujiya" | jati == "kanjiya" |
							  jati == "kalajiya" | jati == "kanoogia" ;
							  
replace jati = "kashyap" if jati == "kasyap" | jati == "karyap" | jati == "karyay" | jati == "kaishyap" | jati == "kashyep" ;

replace jati = "kevat" if jati == "keavta" | jati == "kebat" | jati == "keot" | jati == "ket vas" | jati == "keth" |
						  jati == "keuta" | jati == "kewat" ;
						  
replace jati = "kharia" if jati == "kharya" | jati == "kharyar" | jati == "khararya" | jati == "khariya" | jati == "khayrray" ;

replace jati = "khorwal" if jati == "khoyval" | jati == "kolval" | jati == "khoywal" ;
							  
replace jati = "kohli" if jati == "kohili" | jati == "kohli bankwar" | jati == "kolhi" | jati == "koli" | jati == "kohali" |
						  jati == "kohalo" | jati == "kol" | jati == "kahli" ;

replace jati = "koppalavelama" if jati == "kopalavelama" | jati == "kopalavelma" | jati == "kopala" | jati == "koppalavelamm" |
								  jati == "koppalvelam" | jati == "kopplavelam" | jati == "koppula velama" | jati == "koppuyelama" ;

replace jati = "korku" if jati == "korko" | jati == "korku thakur" | jati == "kourku" | jati == "kuruku" ;

replace jati = "kori" if jati == "koria" | jati == "kodhi" | jati == "koeri" | jati == "kohri" | jati == "koiri" | 
						 jati == "koiri" | jati == "kouri" | jati == "koyeri" | jati == "koyari" | jati == "koyri"  |
						 jati == "kodiya" ;

replace jati = "korama" if jati == "koracha" | jati == "koraga" | jati == "koramaru" | jati == "koramashetra" ;

replace jati = "korava" if jati == "kunchikoravar" | jati == "kurbas" | jati == "kuravan" | jati == "kuruba" | jati == "kurubas" | 
                           jati == "kurva" | jati == "kurauan" | jati == "kurava" | jati == "kuravar"  ;

replace jati = "kshatriya" if jati == "khatriya" | jati == "khatrya" | jati == "khretiya" | jati == "khsatriya" |
							  jati == "hindhuksthriya" | jati == "kshairiya" | jati == "kshat riya" | jati == "kshtriya" ;

replace jati = "kumhar" if jati == "kumbhar" | jati == "kamar" ;

replace jati = "lahiri" if jati == "lahar" | jati == "lahare" | jati == "lahari" | jati == "lahri" ;

replace jati = "lambada" if jati == "labmbada" | jati == "lambadis" | jati == "lambani" | jati == "laman" | jati == "lamani" |
							jati == "ambadi" | jati == "labadi" | jati == "lombada" ;

replace jati = "madari" if jati == "madara" | jati == "madir" | jati == "madar" | jati == "medara" | jati == "medari" | jati == "madra" |
						   jati == "mataari" | jati == "mathari" ;

replace jati = "madiga"  if jati == "magida" | jati == "macigar" | jati == "madhakari" | jati == "madhegaru" | jati == "madhigaru" | 
							jati == "madigaru" | jati == "madiga kasaram" ;

replace jati = "mahar"   if jati == "mahak" | jati == "mehara" | jati == "mehar" | jati == "meher" | jati == "marar" ;

replace jati = "mahadev koli" if jati == "maha dev koli" | jati == "mahadeo" | jati == "mahadeo koli" | jati == "mahadeokoli" |
								 jati == "mahadev" | jati == "mahadevkoli" | jati == "nahadev koli" ; 

replace jati = "mahasha" if jati == "mahesh" | jati == "mahisha" | jati == "mahisya" ;

replace jati = "mahto" if jati == "mahti" | jati == "mehato" | jati == "mehto" ;
 
replace jati = "majhi" if jati == "manjhi" | jati == "manji" ;

replace jati = "mala" if jati == "malaha" | jati == "mallah" | jati == "malo" | jati == "madiga mala" ;

replace jati = "malviya" if jati == "malabi" | jati == "malai" | jati == "malavai" | jati == "malaviya" | jati == "malaviye" |
							jati == "malbi" | jati == "malbip" | jati == "malbiya" | jati == "maliya" | jati == "malkiya" |
							jati == "malvai" | jati == "malvaibadai" | jati == "malvaye" | jati == "malvi" | jati == "malviy" |
							jati == "malavi" | jati == "malvei"  ;

replace jati = "mang" if jati == "manga" | jati == "mangare" ;

replace jati = "masi" if jati == "mashi" ;
							
replace jati = "mazhabi" if jati == "mazhabi sikh" ;

replace jati = "medari" if jati == "madakrinayaka" | jati == "madjarinayak" ;
							
replace jati = "meghwal" if jati == "meghawal" | jati == "meghlal" | jati == "meghval" | jati == "meghwala" | jati == "megwal" |
							jati == "maghwalo" | jati == "magwal" | jati == "megaval" | jati == "medhwal" |
							jati == "megh" | jati == "meghai" ;
	
replace jati = "mochi" if jati == "moocci" | jati == "muche" | jati == "muchi" | jati == "mutch" | jati == "mouchi" ;

replace jati = "mundala" if jati == "munda" ;

replace jati = "naga" if jati == "nada" | jati == "nag gotar" | jati == "nagar mondal" ;

replace jati = "nagesiya" if jati == "nagesia" ;

replace jati = "navbuddha" if jati == "navboudh" | jati == "navboudha" | jati == "navbuddha" | jati == "nawbuddha" |
							  jati == "nawbudha" | jati == "newbuddha" ;
							  
replace jati = "nayak" if jati == "nayaka" | jati == "nayaks" | jati == "nayek" | jati == "naik" | jati == "naika" | jati == "nayakvalmiki" |
						  jati == "naikpod" | jati == "nayakku" ;

replace jati = "nirmalkar" if jati == "nirmal" | jati == "nimlkar" ;

replace jati = "woddar" if jati == "oddar" ;

replace jati = "pallan" if jati == "palan" ;

replace jati = "palwar" if jati == "pailvar" | jati == "paliwar" | jati == "parivar" ;

replace jati = "pana" if jati == "pan" | jati == "panan" ;

replace jati = "panjari erava" if jati == "panjari" | jati == "panjari eravas" | jati == "panjarierava" | jati == "panjarieravar" |
								  jati == "panjarieravas" | jati == "panjarivarava" | jati == "panjarivaravi" | jati == "panjarivari" |
								  jati == "panjariyarava" | jati == "panjarterava" ;

replace jati = "paraiyar" if jati == "hindu pariyar" | jati == "hinduparaiyar" | jati == "induparayar" | jati == "padaiyer" |
							jati == "parahia" | jati == "pariyar" | jati == "parauar" | jati == "parayan" | jati == "parayar" |
							jati == "parayer" | jati == "pariiayar" | jati == "pariyanar" | jati == "paryar" | jati == "perayar" |
							jati == "praiyer" | jati == "prayer" | jati == "paralyar" | jati == "paraya" | jati == "paraiyer" |
							jati == "parhaiya" | jati == "pariaiyar" | jati == "paryer" ;
							
replace jati = "paswan" if jati == "pasvan" | jati == "paswam" | jati == "paswan (dusad)" | jati == "pasawan" | jati == "pashwan" ;

replace jati = "poundra" if jati == "panda khatrio" | jati == "pandra khatri" | jati == "pandriya (khariya)" ;

replace jati = "prajapati" if jati == "parjapati" | jati == "prajapti" | jati == "prjapati" ; 

replace jati = "pulaya" if jati == "pulayar" | jati == "palayagaru" | jati == "palegar" | jati == "palegararu" |
						   jati == "pallagar" | jati == "palyagaru" ;

replace jati = "purti" if jati == "purty" | jati == "putri" ;

replace jati = "rajbanshi" if jati == "rajbari" | jati == "rajbonchi" | jati == "rajparivara" | jati == "rajwanshi" |
							  jati == "raj parivar" | jati == "rajbanshi jeledk" ;

replace jati = "rajgoud" if jati == "rajgouda" ;
							
replace jati = "rajput" if jati == "rajpoot" | jati == "rajput (kshatriya)";

replace jati = "ramdasi" if jati == "ram dashya" | jati == "ramdas" | jati == "ramidasi" | jati == "ram dasi" | jati == "ram dasiya" |
							jati == "ramdaniya" | jati == "ramdaship" | jati == "ramdashya" | jati == "ramdasia" | jati == "ramdasi sikh" |
							jati == "ramdasiy" | jati == "ramdasiya" | jati == "ramdasiye"  | jati == "radasiya" | jati == "ramdasia sikh" |
							jati == "raydasi" ;

replace jati = "ravidasi" if jati == "ravidasiy" | jati == "ravidas" | jati == "ravidasiya" | jati == "rabidasi" | jati == "raudas" |
							 jati == "redas" | jati == "rendas" | jati == "rodas" | jati == "rodash" | jati == "roudas" |
							 jati == "rabdas" | jati == "rabidas" | jati == "rabidash" | jati == "rabindra das" | jati == "ravida sikh" |
							 jati == "rai" | jati == "rai sikh" | jati == "raidas" | jati == "raidash" | jati == "ravidashi";
							 
replace jati = "rathod" if jati == "rathor" | jati == "rathodchawhan" ;

replace jati = "reshmiya" if jati == "resmiya" ;

replace jati = "rohit" if jati == "hindrohit" ;

replace jati = "sahadeva" if jati == "sahadede" | jati == "shahadive" | jati == "sahadeve" ;

replace jati = "sahota" if jati == "sahote" ;

replace jati = "sakhwar" if jati == "sakhabar" | jati == "sakhbar" | jati == "sakhvar" | jati == "shakvar" ;

replace jati = "salve" if jati == "salave" | jati == "salavi" | jati == "salvi" ;

replace jati = "samagar" if jati == "samagara" | jati == "samgar" | jati == "samgarmocht" | jati == "hindhu samgar" ;

replace jati = "sambhava" if jati == "sambava" | jati == "sambavar" | jati == "sambeava" ; 

replace jati = "santhal" if jati == "santal" | jati == "santa" ;

replace jati = "satdeva" if jati == "satdeve" ;

replace jati = "satnami" if jati == "satmami harijan" | jati == "satnami harijan" | jati == "satnari" | jati == "satmami harjan" | 
							jati == "satyanani" ;

replace jati = "singh" if jati == "sing" ;

replace jati = "solanki" if jati == "solanky" ;

replace jati = "sonkar" if jati == "sonykar" | jati == "sonfar" | jati == "son kar" ;

replace jati = "tiwa" if jati == "tiuya" | jati == "tivya" | jati == "tuya" ;

replace jati = "urab" if jati == "unrav" | jati == "uraba" | jati == "urav" ;

replace jati = "vaghela" if jati == "vagela" ;

replace jati = "valmiki nayak" if jati == "valimikkinayaik" | jati == "valimiknayaik" | jati == "valmiki nayaik" | 
								  jati == "valmiki nayaka" | jati == "valmikinayak" | jati == "valmikinayar" |
								  jati == "valmuki nayak" | jati == "valmukinayak" | jati == "yalmikinajak" |
								  jati == "yalmikinayak" ;
								  
replace jati = "vankar" if jati == "vanakar" ;

replace jati = "varli" if jati == "vali" | jati == "varale" | jati == "varali" | jati == "varhi" | jati == "varle" ;
								  
replace jati = "vasava" if jati == "vsava" | jati == "vas ava" ;

replace jati = "vettuvan" if jati == "vettua" | jati == "vetua" ;

replace jati = "yadav" if jati == "yadava" | regexm(jati, "yadav") == 1 | regexm(jati, "yadhav") == 1 ;

replace jati = "yenadi" if jati == "yandi" ;

replace jati = "yerava" if jati == "erava" | jati == "eravaru" | jati == "eravas" | jati == "earava" ;

replace jati = "yerukulas" if jati == "yrokala" | jati == "erukalla" | jati == "arakala" | jati == "arukula" | jati == "erukuia" |
							  jati == "serukulu" ;

replace jati = "yelamalamandlu" if jati == "yelama" | jati == "elama" ;

replace jati = "waddar" if jati == "vadaru" | jati == "vaddara" | jati == "vadru" ;  

save $tmp/ihds_2011_jati.dta, replace ;
