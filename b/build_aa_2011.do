clear 
set more off 
qui creturn list 
local os = c(os) 
cap log close

global raw $mobility/jati 

use "$tmp/ihds_2011_jati.dta", clear 

ren district ihds_district_name 
decode ihds_district_name, gen(dist_name) 
replace dist_name = lower(dist_name) 

********************************************************************************
* Andhra Pradesh 
********************************************************************************
*pre 76 areas 

*Region A: throughout the state 
gen rega = 1 if state == "andhra pradesh" 

*Region B 
*Districts of Srikakkulam, Visakhapatnam, East Godavari, West Godavari, Krishna, Guntur, Ongole, Nellore 
*Chittoor, Cuddapah, Anantapur & Kurnool 

*SRIKAKULAM 
gen regb=0 if state == "andhra pradesh" 
replace regb=1 if state == "andhra pradesh" & dist_name == "srikakulam" 
*VIZIANAGARAM (created from Srikakulam) 
replace regb=1 if state == "andhra pradesh" & dist_name == "vizianagaram" 
*VISAKHAPATNAM 
replace regb=1 if state == "andhra pradesh" & dist_name == "visakhapatnam" 
*EAST GODAVARI 
replace regb=1 if state == "andhra pradesh" & dist_name == "east godavari" 
*WEST GODAVARI 
replace regb=1 if state == "andhra pradesh" & dist_name == "east godavari" 
*KRISHNA 
replace regb=1 if state == "andhra pradesh" & dist_name == "krishna" 
*GUNTUR 
replace regb=1 if state == "andhra pradesh" & dist_name == "guntur" 
*PRAKASAM (new name of Ongole) 
replace regb=1 if state == "andhra pradesh" & dist_name == "prakasam" 
*NELLORE 
replace regb=1 if state == "andhra pradesh" & dist_name == "nellore" 
*CHITTOOR 
replace regb=1 if state == "andhra pradesh" & dist_name == "chittoor" 
*CUDDAPAH 
replace regb=1 if state == "andhra pradesh" & dist_name == "cuddapah" 
*ANANTAPUR 
replace regb=1 if state == "andhra pradesh" & dist_name == "anantapur" 
*KURNOOL 
replace regb=1 if state == "andhra pradesh" & dist_name == "kurnool" 


*Region C 
*districts of Mahbubnagar, Hyderabad, Medak, Nizamabad, Adilabad, Karimnagar, Warangal, Khamman, & Nalgoda 
gen regc=0 if state == "andhra pradesh" 
*MAHBUBNAGAR 
replace regc=1 if state == "andhra pradesh" & dist_name == "mahbubnagar" 
*RANGAREDDY created from Hyderabad 
replace regc=1 if state == "andhra pradesh" & dist_name == "rangareddi" 
*HYDERABAD 
replace regc=1 if state == "andhra pradesh" & dist_name == "hyderabad" 
*MEDAK 
replace regc=1 if state == "andhra pradesh" & dist_name == "medak" 
*NIZAMABAD 
replace regc=1 if state == "andhra pradesh" & dist_name == "nizamabad" 
*ADILABAD 
replace regc=1 if state == "andhra pradesh" & dist_name == "adilabad" 
*KARIMNAGAR 
replace regc=1 if state == "andhra pradesh" & dist_name == "karimnagar" 
*WARANGAL 
replace regc=1 if state == "andhra pradesh" & dist_name == "warangal" 
*KHAMMAM 
replace regc=1 if state == "andhra pradesh" & dist_name == "khammam" 
*NALGONDA 
replace regc=1 if state == "andhra pradesh" & dist_name == "nalgonda" 


gen reg     = 1 if state == "andhra pradesh" & regb == 1 
replace reg = 2 if state == "andhra pradesh" & regc == 1 
replace reg = 3 if state == "andhra pradesh" & regb == 0 & regc == 0 

***************
*  SC Coding  *
*************** 
gen sc63 = . 
gen sc64 = . 
gen sc76=. 
gen sc77=. 
gen sc02=. 

*Adi Andhra 
replace sc76=1 if jati =="adi andhra" & state == "andhra pradesh" & regb == 1 

*Adi Dravida 
*Anamuk 
*Aray Mala 
*Arundhatiya 
*Arwa Mala 
*Bariki 
*Bavuri 
*Beda Jangam, Budga Jangam 
replace sc76=1 if (jati =="beda jangam" | jati == "budga jangam")  & state == "andhra pradesh" & regc == 1 

*Bindla 
*Byagara 
*Chachati 
*Chalavadi 
*Chamar, Mochi, Muchi 
replace sc76=1 if jati =="mochi" & state == "andhra pradesh" & rega == 1 

*Chambhar 
*Chandala 
*Dakkal, Dokkalwar 
*Dandasi 
*Dhor 
*Dom, Dombara, Padi, Pano 
*Ellamalawar, Yelamalawandlu 
replace sc76=1 if jati == "yelamalamandlu" & state == "andhra pradesh" & regc == 1 

*Ghasi, Haddi, Relli Chachandi 
*Godagali 
replace sc76 = 1 if jati == "godagali" & state == "andhra pradesh" & regb == 1 

*Godari 
*Gosangi 
*Holeya 
*Holeya Dasari 
*Jaggali 
*Jambuvulu 
*Kolupulvandlu 
*Madasi Kuruva, Madari Kuruva 
replace sc76 = 1 if jati == "madari" & state == "andhra pradesh" & regb == 1 

*Madiga 
replace sc76=1 if jati == "madiga" & state == "andhra pradesh" & rega == 1 

*Magida Dasu, Mashteen 
*Mahar 
replace sc76 = 1 if jati == "mahar" & state == "andhra pradesh" & regc == 1 

*Mala 
replace sc76=1 if jati == "mala" & state == "andhra pradesh" & rega == 1 

*Mala Dasari 
*Mala Dasu 
*Mala Hannai 
*Malajangam 
*Mala Masti 
*Mala Sale, Nektani 
*Mala Sanyasi 
*Mang 
*Mang Garodi 
*Manne 
*Mashti 
*Matangi 
*Mehtar 
*Mitha Ayyalvar 
*Mundala 
replace sc76 = 1 if jati == "mundala" & state == "andhra pradesh" & regb == 1 

*Paky, Moti, Thoti 
*Pambada, Pambanda 
*Pamidi 
*Panchama,Pariah 
*Relli 
replace sc76 = 1 if jati == "relli" & state == "andhra pradesh" & regb == 1 

*Samagara 
*Samban 
*Sapru 
*Sindhollu, chindholu

********************************************************************************
* Assam
********************************************************************************

** all SC castes were present throughout the state 
replace sc76 = 1 if sc == 1 & state == "assam" 

********************************************************************************
* Bihar 
********************************************************************************
*pre 76 reservation areas 

*Region A: Patna, Shahabad, Gaya and Palamau 
*Patna becomes Patna and Nalanda 
*Shahabad becomes Bhojpur, Buxar, Rohtas and Kaimur (Bhabua) *Buxar and Kaimur (Bhabua) created in 2001 so not in DHS 
*Gaya becomes Gaya, Jehanabad, Nawada and Aurangabad 
*Palamau becomes Palamu and Garhwa* Gharwa created in 2001 so not in DHS 
replace rega=0 if state == "bihar" 
*Patna 
replace rega=1 if state == "bihar" & dist_name == "patna" 
*Nalanda/Bisharsharif 
replace rega=1 if state == "bihar" & dist_name == "nalanda" 
*Buxar 
replace rega=1 if state == "bihar" & dist_name == "buxar" | dist_name == "kaimur (bhabua)" 
* Rohtas 
replace rega=1 if state == "bihar" & dist_name == "rohtas" 
*Gaya 
replace rega=1 if state == "bihar" & dist_name == "gaya" 


*Region B: Monghyr, Bhagalpur, Palamau and Purnea districts, Patna and Tirhut divisions 
*Tirhut division: Bettiah/Pashin Champaran, Motihari/Purba Chamaparan, Muzzafarpur, Sitamarhi, Sheohar (2001), Vaishali 
*Patna division: Patana, Nalanda/Bisharsharif, Bhojpur/Arrah,  Rohtas/Sasaram, Buxar (2001), Kaimur / Bhabhua (2001) district., 
*Monghyr becomes Munger, Lakhisarai, Sheikhpura, Jamui, Khagaria and Begusarai 
*Bhagalpur becomes Bhagalpur and Banka* Banka created in 2001 so not in DHS 
*Palamau becomes Palamu and Garhwa* Gharwa created oin 2001 so not in DHS 
*Purnea becomes Purnia, Araria, Kishanganj and Katihar 


replace regb=0 if state == "bihar" 
*Bhagalpur 
replace regb=1 if state == "bihar" & dist_name == "bhagal pur" 
*Purnea 
replace regb=1 if state == "bihar" & dist_name == "purnia" 
*Motihari/Purba chamaparan 
replace regb=1 if state == "bihar" & dist_name == "purbi champaran" 
*Muzzafarpur 
replace regb=1 if state == "bihar" & dist_name == "muzzarfar pur" 
*Patna 
replace regb=1 if state == "bihar" & dist_name == "patna" 
*Nalanda/Bisharsharif 
replace regb=1 if state == "bihar" & dist_name == "nalanda" 
*Rohtas/Sasaram 
replace regb=1 if state == "bihar" & dist_name == "rohtas" 
*Sheikhpura 
replace regb=1 if state == "bihar" & dist_name == "sheikhpura" 

replace reg=1 if state == "bihar" & (rega == 1 | regb == 1) 
replace reg=2 if state == "bihar" & (rega==0 & regb==0) 

***************************
***  SC coding        ***
***************************

*Bantar 
replace sc76=1 if jati == "bantar" & (state == "bihar" | state == "jharkhand") 

*Bauri 
replace sc76=1 if jati == "bawariya" & (state == "bihar" | state == "jharkhand") 

*Bhogta 
replace sc76=1 if jati == "bhogta" & (state == "bihar" | state == "jharkhand") 

*Bhuiya 
replace sc76=1 if jati == "bhuiya" & (state == "bihar" | state == "jharkhand") & rega == 1 

*Bhumij 
replace sc76=1 if jati =="bhumij" & (state == "bihar" | state == "jharkhand") &  regb==1 

*Chamar, Mochi, Chamar-Rabidas, Chamar Ravidas, Chamar Rohidas, Charmarkar, dhusiya 
replace sc76=1 if (jati == "chamar" | jati == "mochi" | jati == "ravidasi" | jati == "ravi das" | jati == "dhusiya") ///
           & (state == "bihar" | state == "jharkhand")  

*Chaupal 
*Dabgar 
*Dhobi, Rajak, kanaujiya 
replace sc76=1 if (jati == "dhobi" | jati == "rajak" | jati == "kanaujiya") & (state == "bihar" | state == "jharkhand") 

*Dom, Dhangad, Bansphor, Dharikar, Dharkar, Domra 
replace sc76=1 if jati == "dom"  & (state == "bihar" | state == "jharkhand") 

*Dusadh, Dhari, Dharhi, Paswan 
replace sc76=1 if (jati == "paswan" | jati == "dusadh")  & (state == "bihar" | state == "jharkhand") 

*Ghasi 
*Halalkhor 
*Hari, Mehtar, Bhangi 
replace sc76 = 1 if (jati == "harijan" | jati == "mehtar")  & (state == "bihar" | state == "jharkhand") 

*Kanjar 
*Kurariar 
*Lalbegi 
*Mushar 
replace sc76=1 if jati == "musahar"  & (state == "bihar" | state == "jharkhand") 
  
*Nat 
replace sc76=1 if jati == "musahar"  & (state == "bihar" | state == "jharkhand") 
   
*Pan, Sawasi, Panr 
*Pasi, chaudhari
replace sc76=1 if (jati == "pasi" | jati == "chaudhari")  & (state == "bihar" | state == "jharkhand") 

*Rajwar 
replace sc76=1 if (jati == "rajwar")  & (state == "bihar" | state == "jharkhand") 

*Turi, Majhi 
replace sc76=1 if (jati == "turi" | jati == "majhi")  & (state == "bihar" | state == "jharkhand") 


********************************************************************************
* Gujarat
********************************************************************************
*pre 76 areas 

*Region A 
*Districts of Banas Kantha, Sabar Kantha, 
*Mahesana, Gandhinagar, Ahmadabad, Kheda, Panch Mahals, Vadodara, Bharacuh, Surat, Valsad and the Dangs 

replace rega=0 if state == "gujarat" 
*MAHESANA 
replace rega=1 if state == "gujarat" & dist_name == "mahesana" 
*GANDHINAGAR 
replace rega=1 if state == "gujarat" & dist_name == "gandhinagar" 
*AHMADABAD 
replace rega=1 if state == "gujarat" & dist_name == "ahmedabad" 
*KHEDA 
replace rega=1 if state == "gujarat" & dist_name == "kheda" 
*VADODARA 
replace rega=1 if state == "gujarat" & dist_name == "vadodara" 
*BHARUCH 
replace rega=1 if state == "gujarat" & dist_name == "bharuch" 
*SURAT 
replace rega=1 if state == "gujarat" & dist_name == "surat" 

*Region B: districts of the Dangs and Umb taluka of Valsad district 
replace regb=0 if state == "gujarat" 

*Region C  
*districts of Jamnagar, Rajkot, Surendranagar, Bhavnagar, Amreli and Junagadh 
replace regc=0 if state == "gujarat" 
*JAMNAGAR 
replace regc=1 if state == "gujarat" & dist_name == "jamnagar" 
*RAJKOT 
replace regc=1 if state == "gujarat" & dist_name == "rajkot" 
*SURENDRANAGAR 
replace regc=1 if state == "gujarat" & dist_name == "surendranagar" 
*BHAVNAGAR 
replace regc=1 if state == "gujarat" & dist_name == "bhavnagar" 
*AMRELI 
replace regc=1 if state == "gujarat" & dist_name == "amreli" 
*JUNAGADH 
replace regc=1 if state == "gujarat" & dist_name == "junagadh" 

*Region D: district of Kutch 
gen regd=0 if state == "gujarat" 
replace regd=1 if state == "gujarat" & dist_name == "kachchh" 

*Region E: Dang district 
gen rege=0 if state == "gujarat" 

* Region F Also, certain tribes are reserved only in the NEsses of the forests of Alech, Bharada and Gir 
*Gir is located in Junagadh district 
gen regf=0 if state == "gujarat" 
replace regf=1 if state == "gujarat" & dist_name == "junagadh" 

*Region G: Surendranagar district 
gen regg=0 if state == "gujarat" 
replace regg=1 if state == "gujarat" & dist_name == "surendranagar" 


replace reg = 1 if state == "gujarat" & (rega == 1 | regb == 1 | rege == 1) 
replace reg = 2 if state == "gujarat" & (regc == 1 | regf == 1 | regg == 1) 
replace reg = 3 if state == "gujarat" & (regd == 1) 
replace reg = 4 if state == "gujarat" & rega == 0 & regb == 0 & regc == 0 & regd == 0 & rege == 0 & regf == 0 & regg == 0 

***************
*  SC Coding  *
***************


*AGER 
*BAKAD, BANT 
*BAWA-DEDH, DEDH SADHU 

*BHAMBI,  BHAMBHI, ASADARU, ASODI, CHAMADIA, CHAMAR, CHAMBHAR, CHAMGAR, HARALAYYA, HARALI, KHALPA 
*MACHIGAR, MOCHIGAR, MADAR, MADIG, MOCHI, NALIA, TELEGU MOCHI, KAMATI MOCHI, RANIGAR, ROHIDAS, ROHIT, SAMGAR 
replace sc76=1 if (jati == "chamar" | jati == "harijan" | jati == "mochi" | jati == "rohit" | jati == "samagar") & state == "gujarat" & ///
          (rega == 1 | regb == 1 |regc == 1|regd == 1) 
          
*BHANGI, MEHTAR, OLGANA, RUKHI, MALKANA, HALAKHOR, LALBEGI, BALMIKI, KORAR, ZADMALLI, HARIJAN 
replace sc76=1 if (jati == "bhangi" | jati == "balmiki" | jati == "harijan") & state == "gujarat" & ///
          (rega == 1 | regc == 1 | regd == 1) 

*CHALVADI, CHANNAYYA 
*CHENNA DASAR, HOLAYA DASAR 
*DANGASHIA 
replace sc76=1 if jati == "dangashia" & state == "gujarat" & (regc == 1) 

*DHOR, KAKKAYYA, KANKAYYA 
*GARMATANG 
*GARODA, GARO 
replace sc76=1 if jati == "garoda" & state == "gujarat" & (rega == 1 | regc == 1 | regd == 1) 

*HALLEER 
*HALSAR, HASLAR, HULASWAR, HALASVAR 
*HOLAR, VALHAR 
replace sc76=1 if jati == "valhar" & state == "gujarat" & (rega == 1 | regc == 1 | regd == 1) 

*HOLAYA HOLER 
*LINGADER 
*MAHAR, TARAl, DHEGU MEGU (considered as synonyms of DHER) 
replace sc76=1 if jati == "dher" & state == "gujarat" & (rega == 1) 

*MAHYAVANSHI, DHED, DHEDH, VANKAR, MARU VANKAR, ANTYAJ 
replace sc76=1 if (jati=="mahyavansi" | jati == "vankar") & state == "gujarat" & (rega==1 | regc==1) 

*MANG, MATANG, MINIMADIG 
*MANG GARUDI 
*MAGHVAL, MEGHWAL, MENGHVAR 
replace jati = "meghwar" if jati == "vaghat" & state == "gujarat" 
replace sc76=1 if jati=="meghwar" & state == "gujarat" & (rega == 1 | regc == 1 | regd == 1) 

*MUKRI 
*NADIA, HADI 
replace sc76=1 if jati=="nadia" & state == "gujarat" & (rega == 1 | regc == 1) 

*PASI 
*SENVA, SHENVA, CHENVA, SEDMA, RAWAT 
replace jati = "rawat" if jati == "senma" & state == "gujarat" 
replace sc76=1 if jati == "rawat" & state == "gujarat" & (rega==1 | regc==1) 

*SHEMALIA 
replace sc76=1 if jati == "shemalia" & state == "gujarat" & regc == 1 
*THORI 
*TIRGAR, TIRBANDA 
*TURI 

* KORI 
replace sc02 = 1 if jati == "kori" & state == "gujarat" 
replace sc63 = 0 if jati == "kori" & state == "gujarat" 
replace sc64 = 0 if jati == "kori" & state == "gujarat" 
replace sc76 = 0 if jati == "kori" & state == "gujarat" 
replace sc77 = 0 if jati == "kori" & state == "gujarat" 

********************************************************************************
* Delhi
********************************************************************************

** All SC castes are present throughout the union territory 
replace sc76=1 if state == "delhi" & sc == 1 

********************************************************************************
* Manipur
********************************************************************************

** All SC castes are present throughout the union territory 
replace sc76=1 if state == "manipur" & sc == 1 

********************************************************************************
* Tripura
********************************************************************************

** All SC castes are present throughout the union territory 
replace sc76=1 if state == "tripura" & sc == 1 

********************************************************************************
* Dadra and Nagar Haveli
********************************************************************************

** All SC castes are present throughout the union territory 
replace sc76=1 if state == "dadra+nagar haveli" & sc == 1 

********************************************************************************
* Nagaland
********************************************************************************

** All SC castes are present throughout the union territory 
replace sc76=1 if state == "nagaland" & sc == 1 

********************************************************************************
* Haryana
********************************************************************************
*Pre 1976 Areas 

*Region A 
*Throughout the state 
replace rega = 1 if state == "haryana" 

*Region B 
*Throughout the state except in Mahendragarh and Jind district 
*Mahendragarh split between Mahendragarh and Rewari 
replace regb = 1 if state == "haryana" 
replace regb = 0 if state == "haryana" & dist_name == "mahendragarh" | dist_name == "rewari" | dist_name == "jind" 

*Region C 
* Mahendragarh and Jind district 
replace regc = 1 if state == "haryana" & dist_name == "mahendragarh" | dist_name == "rewari" | dist_name == "jind" 

replace reg = 1 if state == "haryana" & regb == 1 
replace reg = 2 if state == "haryana" & regc == 1 


***************
*SC Coding
*************** 

*Ad Dharmi 
*Bangali 
*Barar, Burar or Berar 
*Batwal 
*Bauria or Bawaria 
replace sc76 = 1 if jati == "bawaria" & state == "haryana" & rega == 1 

*Bazigar 
replace sc76 = 1 if jati == "bazigar" & state == "haryana" & rega == 1 

*Balmiki, Chura or Bhangi 
replace sc76 = 1 if (jati == "balmiki" | jati == "bhangi") & state == "haryana" & rega == 1 

*Bhanjra 
*Chamar, Jatia Chamar, Reghar, Raigar, Ramdasi or Ravidasi, Jatav 
replace sc76 = 1 if (jati == "chamar" | jati == "raigar" | jati == "ramdasi" | jati == "ravidasi" | jati == "jatav" | jati == "harijan") ///
                    & state == "haryana" & rega == 1 
          
*Chanal 
*Dagi 
*Dhanak 
replace sc76 = 1 if jati == "dhanak" & state == "haryana" & rega == 1 

*Dumna, Mahasia or Doom 
replace sc76 = 1 if jati == "dom" & state == "haryana" & rega == 1 

*Gagra 
replace sc76 = 1 if jati == "gagra" & state == "haryana" & rega == 1 

*Gandhila or Gandil Gondola 
*Kabirpanthi or Julaha 
replace sc76 = 1 if jati == "julaha" & state == "haryana" & rega == 1 

*Khatik 
replace sc76 = 1 if jati == "khatik" & state == "haryana" & rega == 1 

*Kori or Koli 
replace sc76 = 1 if jati == "kohli" & state == "haryana" & rega == 1 

*Marija or Marecha 
*Mazhabi 
*Megh 
*Nat 
replace sc76 = 1 if jati == "nat" & state == "haryana" & rega == 1 

*Od 
replace sc76 = 1 if jati == "od" & state == "haryana" & rega == 1 

*Pasi 
*Perna 
*Pherera 
*Sanhai 
*Sanhal 
*Sansi, Bhedkut or Manesh 
*Sapela 
*Sarera 
*Sikligar 
*Sirkiband 
*Darain 
*DHogri, Dhangri or Siggi 
*Sansoi 
*Deha, Dhaya or Dhea 

********************************************************************************
* Himachal Pradesh
********************************************************************************
*pre 76 areas 


*Region A  
replace rega=0 if state == "himachal pradesh" 
*CHAMBA 
replace rega=1 if state == "himachal pradesh" & dist_name == "chamba" 
*MANDI 
replace rega=1 if state == "himachal pradesh" & dist_name == "mandi" 
*BILASPUR 
replace rega=1 if state == "himachal pradesh" & dist_name == "bilaspur" 
*MAHASU is merged with SIMLA (from region B...) in 1981 
replace rega=1 if state == "himachal pradesh" & dist_name == "shimla" 
*SIRMAUR 
replace rega=1 if state == "himachal pradesh" & dist_name == "sirmaur" 
*KINNAUR is NOT in the dataset 


*Region B 
replace regb=0 if state == "himachal pradesh" 
*KANGRA 
*Una  and Harmipur parted from Kangra in 1981 
replace regb=1 if state == "himachal pradesh" & (dist_name == "kangra" | dist_name == "una" | dist_name == "hamirpur") 
*KULU 
replace regb=1 if state == "himachal pradesh" & dist_name == "kullu" 
*LAHUL & SPITI 
replace regb=1 if state == "himachal pradesh" & (dist_name == "lahul" | dist_name == "spitti") 
*SIMLA 
*Solan parted from Simla in 1981 
replace regb=1 if state == "himachal pradesh" & (dist_name == "shimla" | dist_name == "solan") 

*REgion C : Lahul and Spiti 
replace regc=0 if state == "himachal pradesh" 
replace regc=1 if state == "himachal pradesh" & (dist_name == "lahul" | dist_name == "spitti") 


replace reg =1 if state == "himachal pradesh" & rega == 1 
replace reg =2 if state == "himachal pradesh" & (regb == 1 | regc == 1) 
replace reg =3 if state == "himachal pradesh" & (rega == 0 & regb == 0 & regc == 0) 

***************
*SC Coding
*************** 

*Ad Dharmi 
*Badhi, Nagalu 
*Balmiki, Bhangi, Chuhra, Chura, Chuhre 
replace sc76=1 if jati == "balmiki" & state == "himachal pradesh" & (rega == 1 | regb == 1) 

*Bandhela 
*Bangali 
*Banjara 
*Bansi 
replace sc76 = 1 if jati == "bansi" & state == "himachal pradesh" & (rega == 1 | regb == 1) 

*Barad 
*Barar, Burar, Berar 
*Batwal 
replace jati = "batwal" if (jati == "badbal" | jati == "berwal") & state == "himachal pradesh" 
replace sc76=1 if jati == "batwal" & state == "himachal pradesh" & (rega|regb) 

*Bauria, Bawaria 
*Bazigar 
*Bhanjra, Bhanjre 
*Chamar, Rehgar, Raigar, Ramdasi, Ravidasi, Ramdasia, Mochi, harijan (most of them are chamar and kohli and can be included here) 
replace sc76=1 if (jati == "chamar" | jati == "harijan" | jati == "ravidasi")  & state == "himachal pradesh" & (rega|regb) 

*Chimbe, Dhobi 
replace sc76=1 if jati == "dhobi" & state == "himachal pradesh" & (rega) 

*Dagi 
*Darain 
*Darai, Darya 
*Daule, Deole 
*Dhaki, Toori 
*Dhanak 
*Dhaogri, Dhuai 
*Dhogri, Dhangri, Siggi 
*Doom, Doomna, Dumna, Dumne, Mahasha 
replace sc76=1 if jati == "dumna" & state == "himachal pradesh" & (rega|regb) 

*Gagra 
*Gandhila, Gandil, Gondola 
*Hali 
*Hesi 
*Jogi 
replace sc76=1 if jati == "jogi" & state == "himachal pradesh" & rega 

*Julaha, Julahe, Kabirpanthi 
replace sc76=1 if (jati == "julaha" | jati == "kabirpanthi") & state == "himachal pradesh" & (rega|regb) 

*Kamoh, Dagoli 
*Karoack 
*Khatik 
*Kori, Koli 
replace sc76=1 if (jati == "kohli" | jati == "koi" | jati == "kori") & state == "himachal pradesh" & (rega|regb) 

*Lohar 
replace sc76=1 if jati == "lohar" & state == "himachal pradesh" & rega 

*Marija, Marecha 
*Mazhabi 
*Megh 
*Nat 
replace sc76=1 if jati == "nat" & state == "himachal pradesh" & (rega|regb) 

*Od 
*Pasi 
*Perna 
*Phrera, Pherera 
*Rehar, Rehara 
*Sanhai 
*Sanhal 
*Sansi, Bhedkut, Manesh 
*Sansoi 
*Sapela 
*Sarde, Sarera, Sarare, Siryare, Sarehde 
replace sc76=1 if jati == "sarade" & state == "himachal pradesh" & rega 

*Sikligar 
*Sipi 
replace sc76=1 if jati == "sipi" & state == "himachal pradesh" & rega 

*Sirkiband 
*Teli 
*Thathiar, Thathera 

********************************************************************************
* Jammu and Kashmir
********************************************************************************

** All SC castes were present throughout the state 
replace sc76=1 if sc == 1 & state == "jammu & kashmir" 

********************************************************************************
* Orissa
********************************************************************************

** All except one caste were present throughout the state: kuli 
replace sc76=1 if sc == 1 & state == "orissa" 

********************************************************************************
* Karnataka
********************************************************************************
*pre 76 areas 

*Region A  
*Districts of Bangalore, Kolar, Tumkur, Mandya, Hassan, Chikmagalur, Chitradurga, Shimoga, Bellary and Mysore 
replace rega=0 if state == "karnataka" 
*BANGALORE 
replace rega=1 if state == "karnataka" & dist_name == "bangalore" 
*BANGALORE RURAL 
replace rega=1 if state == "karnataka" & dist_name == "bangalore rural" 
*BELLARY 
replace rega=1 if state == "karnataka" & dist_name == "bellary" 
*CHIKMAGALUR 
replace rega=1 if state == "karnataka" & dist_name == "chikmagalur" 
*CHITRADURGA 
replace rega=1 if state == "karnataka" & dist_name == "chitradurga" 
*HASSAN 
replace rega=1 if state == "karnataka" & dist_name == "hassan" 
*KOLAR 
replace rega=1 if state == "karnataka" & dist_name == "kolar" 
*MANDYA 
replace rega=1 if state == "karnataka" & dist_name == "mandya" 
*MYSORE 
replace rega=1 if state == "karnataka" & dist_name == "mysore" 
*SHIMOGA 
replace rega=1 if state == "karnataka" & dist_name == "shimoga" 
*TUMKUR 
replace rega=1 if state == "karnataka" & dist_name == "tumkur" 


*Region B 
*districts of Belgaum, Bijapur, Dharwar & Kanara 
replace regb=0 if state == "karnataka" 
*BELGAUM 
replace regb=1 if state == "karnataka" & dist_name == "belgaum" 
*BIJAPUR 
replace regb=1 if state == "karnataka" & dist_name == "bijapur" 
*DHARWAD 
replace regb=1 if state == "karnataka" & dist_name == "dharwad" 
*UTTAR KANNAD 
replace regb=1 if state == "karnataka" & dist_name == "uttar kannad" 

*Region C 
*districts of Gulbarga, Bidar and Raichur 
replace regc=0 if state == "karnataka" 
*BIDAR 
replace regc=1 if state == "karnataka" & dist_name == "bidar" 
*GULBARGA 
replace regc=1 if state == "karnataka" & dist_name == "gulbarga" 
*RAICHUR 
replace regc=1 if state == "karnataka" & dist_name == "raichur" 

*Region D 
*South Kanara 
replace regd=0 if state == "karnataka" 
*DAKSHIN KANNAD 
replace regd=1 if state == "karnataka" & dist_name == "dakshin kannada" 
*UDUPI 
replace regd=1 if state == "karnataka" & dist_name == "udupi" 

*Region G 
*Coorg 
replace regg=0 if state == "karnataka" 
*KODAGU 
replace regg=1 if state == "karnataka" & dist_name == "kodagu" 

replace reg = 1 if rega == 1 
replace reg = 2 if regb == 1 
replace reg = 3 if regc == 1 
replace reg = 4 if regd == 1 
replace reg = 5 if regg == 1 
replace reg = 6 if rega == 0 & regb == 0 & regc == 0 & regd == 0 & regg == 0 

**************
* SC coding
************** 

*ADI ANDHRA 
replace sc76=1 if jati == "adi andhra" & state == "karnataka" & (rega == 1 | regd == 1) 

*ADI DRAVIDA 
replace sc76=1 if jati == "adi dravida" & state == "karnataka" & (rega == 1 | regd == 1 | regg == 1) 

*ADI KARNATAKA (also including harijan here because 90% are adi karnataka)
replace sc76=1 if (jati == "adi karnataka" | jati == "harijan") & state == "karnataka" & (rega == 1 | regd == 1 | regg == 1) 

*ADIYA 
replace sc76=1 if jati == "adiya" & state == "karnataka" & regg == 1 

*Ager 
*Ajila 
*Anamuk 
*Aray Mala 
*Arunthathiyar 
*Arwa Mala 
*Baira 
*Bakad 
*Bant 
*Bakuda 
*Balagai 
*Bandi 
replace sc76=1 if jati == "bandi" & state == "karnataka" & regd == 1 

*BANJARA/LAMBANI 
replace sc76=1 if (jati == "banjara" | jati == "lambada") & state == "karnataka" & rega == 1 

*Bathada 
*BEDA JANGAM, Budga Jangam 
*Bellara 
*Bhangi, Mehtar, Olgana, Rukhi, Mlkana, Halakhor, Lalbegi, Balmiki, Korar, Zadmalli 
*Bhambi, Bhambhi, Asadaru, Asodi, Chmadia, Chamar, Chambhar, Chamgar, Haralayya, Harali, Khalpa, MAchigar, Mochigar, Madar, MAdig, Mochi, Muchi, Telegu Mochi, Kamati Mochi, Ranigar, Rohidas, Rohit, Samgar 
replace sc76=1 if (jati == "mochi" | jati == "madiga" | jati == "madari" | jati == "muchger" | jati == "samagar") & state == "karnataka" & (rega == 1 | regb == 1 | regc == 1 | regg == 1) 

*BHOVI 
replace sc76=1 if jati == "bhovi" & state == "karnataka" & rega == 1 

*Bindla 
*Byagara 
*Chakkiliyan 
*Chalavadi, Chalvadi, Channayya 
replace sc76 = 1 if jati == "chalvadi" & state == "karnataka" & regb == 1 

*Chandala 
*Chenna Dasar, Holaya Dasar 
replace sc76=1 if (jati == "chenna dasar" | jati == "holaya dasar") & state == "karnataka" & regb == 1 

*Dakkal, Dokkalwar 
*Dakkaliga 
*Dhor, Kakkayya, Kankayya 
replace sc76=1 if jati == "dhor" & state == "karnataka" & regc == 1 

*Dom, Dombara, Paidi, Pano 
*Ellamalwar, Yellammalawandlu 
*Ganti Chores 
*Garoda, Garo 
*Godda 
*Gosangi 
*Halleer 
*Halsar, Haslar, Hulasvar, Halasvar 
replace sc76=1 if jati == "hulasvar" & state == "karnataka" & regb == 1 

*Handi Jogis 
*Hasla 
*Holar, Valhar 
*Holeya Dasari
*Jaggali 
*Jambuvulu 
replace jati = "jambuvulu" if jati == "adi jambava" 
replace sc76=1 if jati == "jambuvulu" & state == "karnataka" & regd == 1 

*Kadaiyan 
*Kalladi 
*Kepmaris 
*Kolupulvandlu 
*Koosa 
*Koracha 
*Korama
replace sc76=1 if jati == "korama" & state == "karnataka" & rega == 1 

*Kotegar, Metri 
*Kudumban 
*Kuravan 
replace sc76=1 if jati == "korava" & state == "karnataka" & regd == 1 

*Lingader 
*Machala 
*Madari 
replace sc76=1 if jati == "madari" & state == "karnataka" & (regd == 1) 

*Madiga 
replace sc76=1 if jati == "madiga" & state == "karnataka" & (regc == 1 | regd == 1 | regg == 1) 

*Mahar, Taral, Dhegu, Megu 
replace sc76=1 if jati == "mahar" & state == "karnataka" & (regb == 1 | regc == 1) 

*Mahyavanshi, Dhed, Vankar, Mahu Vankar 
*Maila 
*Mala 
replace sc76=1 if jati == "mala" & state == "karnataka" & (regc == 1 | regd == 1) 

*Mala Dasari 
*Mala Hannai 
*Mala Jangam 
*Mala Masti 
*Mala Sale, Nektani 
*Mang, MAtang, Minimadig 
replace sc76=1 if (jati == "mang" | jati == "mathangi") & state == "karnataka" & (regb == 1 | regc == 1) 

*Mang Garudi, Mang Garodi 
*Manne 
*Masthi 
*Mavijan 
*Meghval, Menghvar 
*Moger 
replace sc76=1 if jati == "moger" & state == "karnataka" & regd == 1 

*Mukri 
*Mundala 
replace sc76=1 if jati == "mundala" & state == "karnataka" & (regd == 1 | regg == 1) 

*Nadia, Hadi 
replace sc76=1 if jati == "hadi" & state == "karnataka" & regb == 1 

*Nalkadaya 
*Nalakeyava 
*Nayadi 
*Pale 
replace sc76=1 if jati == "palegara" & state == "karnataka" & regg == 1 

*Palian 
*Pambada 
*Panchama 
*Panniandi 
*Paraiyan, Paraya 
*Raneyar 
*Samagara 
replace sc76=1 if jati == "samagar" & state == "karnataka" & (regc == 1 | regd == 1 | regg == 1) 

*Samban 
*Sapari 
*Sillekyathas 
replace sc76=1 if jati == "sillekyathas" & state == "karnataka" & rega == 1 

*Sindhollu, Chindollu 
*Sudugadu Siddha 
replace sc76=1 if (jati == "sudugadu siddha" | jati == "siddi") & state == "karnataka" & rega == 1 

*Thoti 
replace sc76=1 if jati == "thotigaru" & state == "karnataka" & regd == 1 

*Tirgar, Tirbanda 
*Valluvan 
replace sc76=1 if jati == "vawlluan" & state == "karnataka" & dist_name == "mysore" 

********************************************************************************
* Kerala
********************************************************************************
*Region A 
*all Kerala except Malabar district 
*there is no Malabar district in  Kerala : it is the name of the district of Madras transferred to Kerala in 1956. 
*It is divided in Cannanore, Palghat, Koshikode in 1951. 
*Cannanore is partitionned between Cannanore and Wayanad, then renamed Kannur and partitioned with Kasaragod 
*Kozhikode is partitioned with Malappuram 

replace rega=1 if state == "kerala" 
*Kannur 
replace rega=0 if state == "kerala" & dist_name == "kannur" 
*Wayanad 
replace rega=0 if state == "kerala" & dist_name == "wayanad" 
*Kasagarod 
replace rega=0 if state == "kerala" & dist_name == "kasaragod" 
*Kozhikode 
replace rega=0 if state == "kerala" & dist_name == "kozhikode" 
*Malappuram 
replace rega=0 if state == "kerala" & dist_name == "malappuram" 
*Palghat 
replace rega=0 if state == "kerala" & dist_name == "palakkad" 

replace regb=1 if state == "kerala" & (rega==0) 
replace regb=0 if state == "kerala" & rega == 1 

replace reg = 1 if state == "kerala" & rega == 1 
replace reg = 2 if state == "kerala" & regb == 1 

**************
* SC coding
************** 

*ADI ANDHRA 
*ADI DRAVIDA 
replace sc76=1 if jati == "adi dravida" & state == "kerala" & regb == 1 

*ADI KARNATAKA 
*AJILA 
*ARUNTHATIHYAR 
*AYANAVAR 
replace sc76=1 if jati == "ayannar" & state == "kerala" & rega == 1 

*BAIRA 
*BAKUDA 
*BANDI 
*BATHADA 
*BELLARA 
*BARATHAR 
replace sc76=1 if jati == "barathar" & state == "kerala"  & rega == 1 

*BOYAN 
*CHAKKILIYAN 
replace sc76=1 if jati == "chakkiliyan" & state == "kerala" & (rega == 1 | regb == 1) 

*CHAMAR OR MUCHI 
replace sc76=1 if jati == "chamar" & state == "kerala" & regb == 1 

*CHANDALA 
replace sc76=1 if jati == "chandala" & state == "kerala" & regb == 1 

*CHERUMAN 
replace sc76=1 if jati == "cheruman" & state == "kerala" & regb == 1 

*CHERAMAR, PULAYAN 
replace sc76=1 if (jati == "cheramar" | jati == "pulaya") & state == "kerala" & rega == 1 

*DOMBAN 
*GAVARA 
*GODAGALI 
*GODDA 
*GOSANGI 
*HASLA 
*HOLEYA 
*KADAIYAN 
*KAKKALAN 
*KALLADI 
replace sc76=1 if jati == "kalladi" & state == "kerala"  & regb == 1 

*KANAKKAN OR PADANNA 
replace sc76=1 if (jati == "kanakkan" | jati == "padanna") & state == "kerala" & (rega == 1 | regb == 1) 

*KARIMPALAN 
*KAVARA 
*KOOSA 
*KOOTAN 
*KUDUMBAN 
*KURAVAN, SIDHANAR 
replace sc76=1 if jati == "korava" & state == "kerala" & (rega == 1 | regb == 1) 

*MAILA 
*MALAYAN 
replace sc76=1 if jati == "malayan" & state == "kerala"  & regb == 1 

*MANNAN 
replace sc76=1 if jati == "mannan" & state == "kerala" & rega == 1 

*MAVILAN 
*MOGER 
*MUNDALA 
*NALAKEYAVA 
*NALKADAYA 
*NAYADI 
*PADANNAN 
*PALLAN 
replace sc76=1 if jati == "pallan" & state == "kerala"  & (rega == 1 | regb == 1) 

*PALLUVAN 
*PAMBADA 
*PANAN 
replace sc76=1 if jati == "pana" & state == "kerala"  & (rega == 1 | regb == 1) 

*PANCHAMA 
*PARAYAN, Sambava 
replace sc76=1 if (jati == "paraiyar" | jati == "palayar" | jati == "sambhava") & state == "kerala"  & (rega == 1 | regb == 1) 

*PARAVAN 
replace sc76=1 if jati == "paravan" & state == "kerala"  & dist_name != "kasagarod" 

*PATHIYAN 
replace sc76=1 if jati == "pathiyan" & state == "kerala"  & rega == 1 

*PERUMANNAN 
replace sc76=1 if jati == "perumannan" & state == "kerala"  & rega == 1 

*PULAYA VETTUVAN 
replace sc76=1 if jati == "pulaya" & state == "kerala" & regb == 1 & dist_name != "kasaragod" 

*PUTHIRAI VANNAN 
*RANEYAR 
*SAMAGAR 
*SAMBAN 
*SEMMAN 
*THANDAN 
replace sc76=1 if jati == "thandan" & state == "kerala"  & rega == 1 

*THOTI (Mala synonym of Thoti) 
replace sc76=1 if jati == "mala" & state == "kerala"  & regb == 1 

*ULLADAN (not coded as SC as Ulladan also in ST list, and all the Ulladan declare to be ST) 
*URALY 
*VALLON 
*VANNAN 
replace sc76=1 if jati == "vannan" & state == "kerala"  & rega == 1 

*VELAN 
replace sc76=1 if jati == "velan" & state == "kerala"  & rega == 1 

*VETAN 
*VETTUVAN 
replace sc76=1 if jati == "vettuvan" & state == "kerala"  & rega == 1 


********************************************************************************
* Madhya Pradesh
********************************************************************************
*pre 76 reservation areas 


*Region A 
*1971 districts 
*Bhind, Gird, Morena, Shivpuri, Guna, Rajgarh, Shajapur, Ujjain, Ratlam, Mandsaur 
*Bhilsa (excluding Sironj sub division), Indore, Dewas, Dhar, Jhabua & Nimar (MB) 

replace rega=0 if (state == "madhya pradesh" | state == "chhattisgarh") 
*Bhind 
replace rega=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "bhind" 
*Gird becomes Gwalior 
replace rega=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "gwalior" 
*Dewas  
replace rega=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "dewas" 
*Dhar 
replace rega=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "dhar" 
*West Nimar 
replace rega=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "west nimar" 
*Bhilsa (now called Vidisha) 
replace rega=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "bhilsa" 
*Guna 
replace rega=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "guna" 
*Indore 
replace rega=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "indore" 
*Jhabua 
replace rega=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "jhabua" 
*Mandsaur 
replace rega=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "mandsaur" 
*Morena 
replace rega=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "morena" 
*Rajgarh 
replace rega=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "rajgarh" 
*Ratlam 
replace rega=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "ratlam" 
*Shajapur 
replace rega=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "shajapur" 
*Shivpuri 
replace rega=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "shivpuri" 
*Ujjain 
replace rega=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "ujjain" 


*Region B 
*1971 districts  
*Chhindwara, Seoni, Betul, Jabalpur, Sagar, Damoh, Mandla, Hoshangabad, Narsimhapur, 
*Nimar, Balaghat, Raipur, Bilaspur, Durg, Bastar, Surguja & Raigarh 

replace regb=0 if (state == "madhya pradesh" | state == "chhattisgarh") 
*Balaghat 
replace regb=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "balaghat" 
*Bastar 
replace regb=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "bastar" 
*Betul 
replace regb=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "betul" 
*Bilaspur 
replace regb=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "bilas pur" 
*Chhindwara 
replace regb=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "chhindwara" 
*Damoh 
replace regb=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "damoh" 
*Durg 
replace regb=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "durg" 
*East Nimar (Khandwa) 
replace regb=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "east nimar" 
*Hoshangabad 
replace regb=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "hoshangabad" 
*Jabalpur 
replace regb=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "jabalpur" 
*Mandla 
replace regb=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "mandla" 
*Narsimhapur 
replace regb=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "narsimhapur" 
*Raigarh 
replace regb=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "raigarh" 
*Raipur 
replace regb=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "raipur" 
*Rajnandgaon 
replace regb=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "rajnandgaon" 
*Sagar 
replace regb=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "sagar" 
*Seoni 
replace regb=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "seoni" 
*Surguja 
replace regb=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "sarguja" 


*Region C 
*1971 districts: 
*Balaghat, Bilaspur, Durg, Raipur, Bastar, Surguja & Raigarh 

replace regc=0 if (state == "madhya pradesh" | state == "chhattisgarh") 
*Balaghat 
replace regc=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "balaghat" 
*Bastar 
replace regc=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "bastar" 
*Bilaspur 
replace regc=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "bilas pur" 
*Durg 
replace regc=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "durg" 
*Raigarh 
replace regc=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "raigarh" 
*Raipur 
replace regc=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "raipur" 
*Rajnandgaon 
replace regc=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "rajnandgaon" 
*Surguja 
replace regc=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "sarguja" 



*Region D 
*1971 Districts: 
*Balaghat, Bilaspur, Durg, Raipur, Bastar, & Raigarh 

replace regd=0 if (state == "madhya pradesh" | state == "chhattisgarh") 
*Balaghat 
replace regd=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "balaghat" 
*Bilaspur 
replace regd=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "bilas pur" 
*Durg 
replace regd=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "durg" 
*Raigarh 
replace regd=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "raigarh" 
*Raipur 
replace regd=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "raipur" 
*Rajnandgaon 
replace regd=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "rajnandgaon" 
*Surguja 
replace regd=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "sarguja" 



*Region E 
*1971 districts 
*Balaghat, Betul, Bilaspur, Durg, Nimar, Raipur, Bastar, Surguja, Raigarh 
*Hoshangabad & Seoni Malwa tahsils of Hoshangabad 
*Chhindwara & Sagar 

replace rege=0 if (state == "madhya pradesh" | state == "chhattisgarh") 
*Balaghat 
replace rege=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "balaghat" 
*Bastar 
replace rege=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "bastar" 
*Betul 
replace rege=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "betul" 
*Bilaspur 
replace rege=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "bilas pur" 
*Chhindwara 
replace rege=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "chhindwara" 
*Durg 
replace rege=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "durg" 
*East Nimar (Khandwa) 
replace rege=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "east nimar" 
*Hoshangabad 
replace rege=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "hoshangabad" 
*Raigarh 
replace rege=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "raigarh" 
*Raipur 
replace rege=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "raipur" 
*Sagar 
replace rege=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "sagar" 
*Surguja 
replace rege=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "sarguja" 


*Region F 
*1971 districts: 
*Sagar & Damoh 
*Hoshangabad & Seoni Malwa tahsils of Hoshangabad 

replace regf=0 if (state == "madhya pradesh" | state == "chhattisgarh") 
*Damoh 
replace regf=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "damoh" 
*Hoshangabad 
replace regf=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "hoshangabad" 
*Sagar
replace regf=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "sagar" 



*Region G 
*1971 districts: 
*Chhindwara, Seoni, Betul, Jabalpur, Narsimhapur, Sagar, Mandla, Damoh, Nimar, Balaghat, 
*Raipur, Bilaspur, Durg, Bastar, Surguja & Raigarh 
*in Hoshangabad district except Harda and Sohagpur 

replace regg=0 if (state == "madhya pradesh" | state == "chhattisgarh") 

*Balaghat 
replace regg=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "balaghat" 
*Bastar 
replace regg=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "bastar" 
*Betul 
replace regg=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "betul" 
*Bilaspur 
replace regg=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "bilas pur" 
*Chhindwara 
replace regg=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "chhindwara" 
*Damoh 
replace regg=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "damoh" 
*Durg 
replace regg=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "durg" 
*East Nimar (Khandwa) 
replace regg=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "east nimar" 
*Hoshangabad 
replace regg=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "hoshangabad" 
*Jabalpur 
replace regg=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "jabalpur" 
*Mandla 
replace regg=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "mandla" 
*Narsimhapur 
replace regg=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "narsimhapur" 
*East Nimar (Khandwa) 
replace regg=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "east nimar" 
*Raigarh 
replace regg=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "raigarh" 
*Raipur 
replace regg=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "raipur" 
*Rajnandgaon 
replace regg=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "rajnandgaon" 
*Sagar 
replace regg=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "sagar" 
*Seoni 
replace regg=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "seoni" 
*Surguja 
replace regg=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "sarguja" 


*Region H 
*1971 districts: 
*Chhindwara, Seoni,Betul, Jabalpur, Narsimhapur, Sagar, Mandla, Damoh, Nimar, Balaghat, Raipur, Bilaspur 
*Durg, Bastar, Surguja & Raigarh 
*Hoshangabad district except Harda and Sohagpur tehsil 

gen regh=0 if (state == "madhya pradesh" | state == "chhattisgarh") 

*Balaghat 
replace regh=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "balaghat" 
*Bastar 
replace regh=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "bastar" 
*Betul 
replace regh=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "betul" 
*Bilaspur 
replace regh=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "bilas pur" 
*Chhindwara 
replace regh=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "chhindwara" 
*Damoh 
replace regh=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "damoh" 
*Durg 
replace regh=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "durg" 
*East Nimar (Khandwa) 
replace regh=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "east nimar" 
*Hoshangabad 
replace regh=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "hoshangabad" 
*Jabalpur 
replace regh=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "jabalpur" 
*Mandla 
replace regh=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "mandla" 
*Narsimhapur 
replace regh=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "narsimhapur" 
*Raigarh 
replace regh=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "raigarh" 
*Raipur 
replace regh=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "raipur" 
*Bilaspur 
replace regh=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "bilas pur" 
*Rajnandgaon 
replace regh=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "rajnandgaon" 
*Sagar 
replace regh=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "sagar" 
*Seoni 
replace regh=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "seoni" 
*Surguja 
replace regh=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "sarguja" 



*Region I 
*1971 districts 
*Datia, Tikamgarh, Chhatapur, Panna, Satna, Rewa, Sidhi and Shahdol 

gen regi=0 if (state == "madhya pradesh" | state == "chhattisgarh") 

*Chhatarpur 
replace regi=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "chhatarpur" 
*Datia 
replace regi=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "datia" 
*Rewa 
replace regi=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "rewa" 
*Satna 
replace regi=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "satna" 
*Shahdol 
replace regi=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "shahdol" 
*Sidhi 
replace regi=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "sidhi" 
*Tikamgarh 
replace regi=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "tikamgarh" 


*Region J 
*1971 districts 
*Dhar & Jhabua 
*in the tahsils of Sendhwa, Barwani, Rajpur, Khargone, Bhikangaon & Maheswar of Nimar 
*in the tahsil of Sailana in Ratlam 

gen regj=0 if (state == "madhya pradesh" | state == "chhattisgarh") 

*Dhar 
replace regj=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "dhar" 
*East Nimar (Khandwa) 
replace regj=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "east nimar" 
*Jhabua 
replace regj=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "jhabua" 
*Ratlam 
replace regj=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "ratlam" 


*Region K 
*1971 districts 
*Bastar, Chhindwara, Seoni, Mandla, Raigarh & Surguja, Narsimhapur 
*Baihar tahsil of Balaghat 
*Betul & Bhainsdehi tahsil of Betul 
*Bilaspur & Katghora tahsil of Bilaspur 
*Durg and Sanjari tahsil of Durg 
*Murwara, PAtan & Sihora tahsil of Jabalpur 
*Hoshangabad & Sohagpur tahsil of Hoshangabad 
*Harsud tahsil of the Nimar district 
*Bindranawagarh, Dhamtari & Mahasamund tahsil of Raipur 

gen regk=0 if (state == "madhya pradesh" | state == "chhattisgarh") 

*Balaghat 
replace regk=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "balaghat" 
*Bastar 
replace regk=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "bastar" 
*Betul 
replace regk=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "betul" 
*Bilaspur 
replace regk=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "bilas pur" 
*Chhindwara 
replace regk=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "chhindwara" 
*Durg 
replace regk=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "durg" 
*East Nimar (Khandwa) 
replace regk=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "east nimar" 
*Hoshangabad 
replace regk=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "hoshangabad" 
*Jabalpur 
replace regk=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "jabalpur" 
*Mandla 
replace regk=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "mandla" 
*Raigarh 
replace regk=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "raigarh" 
*Raipur 
replace regk=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "raipur" 
*Rajnandgaon 
replace regk=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "rajnandgaon" 
*Seoni 
replace regk=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "seoni" 
*Surguja 
replace regk=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "sarguja" 


*Region L 
*1971 districts: 
* Datia, Tikamgarh, Chhatarpur, Panna, Satna, Rewa, Sidhi and Shahdol 

gen regl=0     if (state == "madhya pradesh" | state == "chhattisgarh") 

*Chhatarpur 
replace regl=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "chhatarpur" 
*Datia 
replace regl=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "datia" 
*Rewa 
replace regl=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "rewa" 
*Satna 
replace regl=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "satna" 
*Shahdol 
replace regl=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "shahdol" 
*Sidhi 
replace regl=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "sidhi" 
*Tikamgarh 
replace regl=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "tikamgarh" 

*Region M 
* 1971 districts 
*Raisen and Sehore 
gen regm=0     if (state == "madhya pradesh" | state == "chhattisgarh") 
*Raisen 
replace regm=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "raisen" 
*Sehore 
replace regm=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "sehore" 
*Bhopal (partitioned from Sehore)
replace regm=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "bhopal" 

*Region N 
*Sironj subdivision of Bhilsa district 
*Bhilsa (now called Vidisha) 
gen regn=0     if (state == "madhya pradesh" | state == "chhattisgarh") 
replace regn=1 if (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "bhilsa" 


replace reg = 1 if (state == "madhya pradesh" | state == "chhattisgarh") & rega == 1 
replace reg = 2 if (state == "madhya pradesh" | state == "chhattisgarh") & (regb == 1 | regc == 1 | regd == 1 | rege == 1 | regf == 1 | regg == 1 | regh == 1 | regj == 1 | regk == 1) 
replace reg = 3 if (state == "madhya pradesh" | state == "chhattisgarh") & regi == 1 
replace reg = 4 if (state == "madhya pradesh" | state == "chhattisgarh") & regm == 1 
replace reg = 5 if (state == "madhya pradesh" | state == "chhattisgarh") & regn == 1 
replace reg = 6 if (state == "madhya pradesh" | state == "chhattisgarh") & (rega == 0 & regb == 0 & regc == 0 & regd == 0 & rege == 0 & regf == 0 & regg ==0 ///
          & regh == 0 & regi == 0 & regj == 0 & regk == 0 & regl == 0 & regm == 0 & regn == 0) 
          
          
***********
*SC coding
*********** 

*Audhelia (Varman is a synonym) 
replace sc76=1 if jati == "verma" & (state == "madhya pradesh" | state == "chhattisgarh") & (dist_name == "bilas pur") 

*Bagri, Bagdi 
replace sc76=1 if jati == "bagdi" & (state == "madhya pradesh" | state == "chhattisgarh") & (rega == 1) 

*Bahna, Bahana 
*Balahi, Balai 
replace sc76=1 if jati == "balae" & (state == "madhya pradesh" | state == "chhattisgarh") & (rega == 1 | regb == 1 | regm == 1) 

*Banchada 
*Bargunda 
replace sc76=1 if jati == "bargunda" & (state == "madhya pradesh" | state == "chhattisgarh") & (rega == 1) 

*Basor, Burud, Bansor, Bansodi, Bansphor, Basar + Barahar & BAsod 
replace jati = "basor" if jati == "basodhi" | jati == "basooh" | jati == "basor" | jati == "basud" 
replace sc76=1 if jati=="BASOR"  & (state == "madhya pradesh" | state == "chhattisgarh") & (rega == 1 | regb == 1 | regi == 1 | regm == 1) 

*Beldar, Sunkar 
replace sc76=1 if jati == "sunkar" & (state == "madhya pradesh" | state == "chhattisgarh") & (regi == 1 | regm == 1) 

*Bhangi, Mehtar, Balmik, Lalbegi, Dharkar 
replace sc76=1 if (jati == "mehtar" | jati == "balmiki")  & (state == "madhya pradesh" | state == "chhattisgarh") & (rega == 1 | regb == 1 | regi == 1 | regm == 1) 

*Bhanumati 
*Chadar 
replace sc76=1 if jati == "chadar" & (state == "madhya pradesh" | state == "chhattisgarh") & (dist_name == "sagar" | dist_name == "damoh") 

*Chamar, Chamari, Bairwa, Bhambi, Jatav, Mochi, Regar, Nona, Rohidas, Ramnami, Satnami, Surjyabanshi, Surjyaralnai, Ahirwar, Chlar Langan, Raidas 
replace sc76=1 if (jati == "chamar" | jati == "jatav" | jati == "mochi" | jati == "satnami" | jati == "surjyabanshi" | ///
           jati == "ahirvar" | jati == "ravidasi" | jati == "harijan") & (state == "madhya pradesh" | state == "chhattisgarh")  & (rega|regb|regi|regm) 

*Chidar 
replace sc76=1 if jati == "chirad" & (state == "madhya pradesh" | state == "chhattisgarh") & (rega == 1) 

*Chikwa, Chikwi 
replace sc76=1 if jati == "chikwa" & (state == "madhya pradesh" | state == "chhattisgarh") & (regb == 1) 

*Chitar 
*Dahait, Dahayat, Dahat 
replace sc76=1 if jati == "dahait" & (state == "madhya pradesh" | state == "chhattisgarh") & dist_name == "damoh" 

*Dewar 
*Dhanuk 
*Dhed, Dher 
*Dhobi 
replace sc76=1 if jati == "dhobi" & (state == "madhya pradesh" | state == "chhattisgarh") & (regm == 1) 

*Dohor 
*Dom, Dumar, Dome, Domar, Doris 
replace sc76=1 if jati == "dumar" & (state == "madhya pradesh" | state == "chhattisgarh") & (rega == 1 | regb == 1 | regi == 1 | regm == 1) 

*Ganda, Gandi 
replace jati = "ganda" if (jati == "gada" | jati == "gada harijan" | jati == "gadi" | jati == "goud") & (state == "madhya pradesh" | state == "chhattisgarh") 
replace sc76=1 if jati == "ganda" & (state == "madhya pradesh" | state == "chhattisgarh") & (rega == 1 | regb == 1 | regi == 1 | regm == 1) 

*Ghasi, Ghasia 
replace sc76=1 if jati == "ghasia" & (state == "madhya pradesh" | state == "chhattisgarh") & (regc == 1 | regi == 1) 

*Holiya 
*Kanjar 
*Katia, Patharia 
*Khatik 
replace sc76=1 if jati == "khatik" & (state == "madhya pradesh" | state == "chhattisgarh") & (rega == 1 | regb == 1 | regm == 1) 

*Koli, Kori 
replace sc76=1 if (jati == "kohli" | jati == "kori") & (state == "madhya pradesh" | state == "chhattisgarh") & (rega == 1 | regm == 1 | regg == 1) 

*Kotwal 
replace sc76=1 if jati == "kotwal" & (state == "madhya pradesh" | state == "chhattisgarh") & rega == 1 

*Khangar 
replace sc76=1 if jati == "khangar" & (state == "madhya pradesh" | state == "chhattisgarh") & (regf == 1) 

*Kuchbandia 
*Kumhar 
replace sc76=1 if jati == "kumhar" & (state == "madhya pradesh" | state == "chhattisgarh") & (regi == 1) 

*Mahar, Mehra, Mehar 
replace jati = "mahar" if (jati == "mahars" | jati == "mehra") & (state == "madhya pradesh" | state == "chhattisgarh") 
replace sc76=1 if jati == "mahar" & (state == "madhya pradesh" | state == "chhattisgarh")  & (rega == 1 | regh == 1 | regm == 1) 

*Mang, Mang Garodi, Mang Garudi, Dankhi Mang, Mang Mahasi, Madari, Garudi, Radhe Mang 
replace sc76=1 if jati == "mang" & (state == "madhya pradesh" | state == "chhattisgarh") & (rega == 1 | regb == 1 | regm == 1) 

*Meghwal 
*Moghia (syn of BAURI) 
replace sc76=1 if jati == "mogiya" & (state == "madhya pradesh" | state == "chhattisgarh") & (rega == 1 | regi == 1) 

*Muskhan 
*Nat, Kalbelia, Sapera, Navdigar, Kubut 
*Pasi 
*Rujjhar 
*Sansi, Sansia 
*Silawat 
*Zamral 

          
********************************************************************************
* Maharashtra
********************************************************************************

*pre 76 reservation areas 

*Region A : bombay and Poona division 
*throuhout the state except Buldana, Akola, Amravati, Yeotmal, Wardha, Nagpur, Bhandara, Chanda, Aurangabad, Parbhani
*Nanded, Bhir, Osmanabad, and Rajura 
replace rega=0 if state == "maharashtra" 
*MUMBAI 
replace rega=1 if state == "maharashtra" & dist_name == "mumbai (suburban)" 
*THANE 
replace rega=1 if state == "maharashtra" & dist_name == "thane" 
*RAIGARH (=Kolaba) 
replace rega=1 if state == "maharashtra" & dist_name == "kolaba" 
*RATNAGIRI 
replace rega=1 if state == "maharashtra" & dist_name == "ratnagiri" 
*SINDHUDURG 
replace rega=1 if state == "maharashtra" & dist_name == "sindhudurg" 
*NASHIK 
replace rega=1 if state == "maharashtra" & dist_name == "nasik" 
*DHULE 
replace rega=1 if state == "maharashtra" & dist_name == "dhule" 
*JALGAON 
replace rega=1 if state == "maharashtra" & dist_name == "jalgaon" 
*AHMADNAGAR 
replace rega=1 if state == "maharashtra" & dist_name == "ahmadnagar" 
*PUNE 
replace rega=1 if state == "maharashtra" & dist_name == "pune" 
*SATARA 
replace rega=1 if state == "maharashtra" & dist_name == "satara" 
*SANGLI 
replace rega=1 if state == "maharashtra" & dist_name == "sangli" 
*SOLAPUR 
replace rega=1 if state == "maharashtra" & dist_name == "solapur" 
*KOLHAPUR 
replace rega=1 if state == "maharashtra" & dist_name == "kolhapur" 


*Region B : Aurangabad Division 
*Districts of Aurangabad, Parbhani, Nanded, Rajura, Bhir and Osmanabad 
replace regb=0 if state == "maharashtra" 
*AURANGABAD 
replace regb=1 if state == "maharashtra" & dist_name == "aurangabad" 
*JALNA (partitioned from Aurangabad) 
replace regb=1 if state == "maharashtra" & dist_name == "jalna" 
*PARBHANI 
replace regb=1 if state == "maharashtra" & dist_name == "parbhani" 
*BID (partitioned from Bhir) 
replace regb=1 if state == "maharashtra" & dist_name == "bid" 
*NANDED 
replace regb=1 if state == "maharashtra" & dist_name == "nanded" 
*LATUR (partitioned from Osmanabad) 
replace regb=1 if state == "maharashtra" & dist_name == "osmanabad" 


*Region C: Nagpur Division 
*Buldana, Akola, Amravati, Yeotmal, Wardha, Nagpur, Bhandara, & Chanda 
replace regc=0 if state == "maharashtra" 
*BULDANA 
replace regc=1 if state == "maharashtra" & dist_name == "buldana" 
*AKOLA 
replace regc=1 if state == "maharashtra" & dist_name == "akola" 
*AMRAVATI 
replace regc=1 if state == "maharashtra" & dist_name == "amarawti" 
*YAVATMAL 
replace regc=1 if state == "maharashtra" & dist_name == "yavatmal" 
*WARDHA 
replace regc=1 if state == "maharashtra" & dist_name == "wardha" 
*NAGPUR 
replace regc=1 if state == "maharashtra" & dist_name == "nagpur" 
*BHANDARA 
replace regc=1 if state == "maharashtra" & dist_name == "bhandara" 
*CHANDRAPUR (partitioned from Chanda) 
replace regc=1 if state == "maharashtra" & dist_name == "chandrapur" 
*Gadchiroli (partitioned from Chanda) not in the data 

*Region H  :Thana district 
replace regh=0 if state == "maharashtra" 
replace regh=1 if state == "maharashtra" & dist_name == "thane" 

*Region I: Ahmenadnagar, Kolaba, Nasik, Poona, Thana districts 
replace regi=0 if state == "maharashtra" 
*AHMENADNAGAR 
replace regi=1 if state == "maharashtra" & dist_name == "ahmadnagar" 
*RAIGARH (=Kolaba) 
replace regi=1 if state == "maharashtra" & dist_name == "kolaba" 
*NASIK 
replace regi=1 if state == "maharashtra" & dist_name == "nasik" 
*POONA 
replace rega=1 if state == "maharashtra" & dist_name == "pune" 
*THANA 
replace regi=1 if state == "maharashtra" & dist_name == "thane" 

* Region J: Melghat Tahsil of Amravatai district, Gadhchiroli and Sironcha tahsils of Chanda district, Kelapur and Yavatmal tahsil of Yeotmal district 
replace regj=0 if state == "maharashtra" 
*AMRAVATI 
replace regj=1 if state == "maharashtra" & dist_name == "amarawti" 
*CHANDRAPUR (partitioned from Chanda) 
replace regj=1 if state == "maharashtra" & dist_name == "chandrapur" 
*YEOTMAL 
replace regj=1 if state == "maharashtra" & dist_name == "yavatmal" 

replace reg = 0 if state == "maharashtra" 
replace reg = 1 if state == "maharashtra" & (rega | regh | regi) 
replace reg = 2 if state == "maharashtra" & regb 
replace reg = 3 if state == "maharashtra" & (regc | regj) 

***********
*SC coding
*********** 

*Ager 
*Anamuk 
*Aray Mala 
*Arwa Mala 
*Bahna, Bahana 
*Bakad, Band 
*Balashi, Balai 
replace sc76=1 if jati == "balae" & state == "maharashtra" & regc 

*Basor, Burud, Bansor, Basodi 
replace sc76=1 if jati == "burud" & state == "maharashtra" & regc 

*Beda Jangam, Budga Jangam 
*Bedar 
replace sc76=1 if jati == "bedar" & state == "maharashtra" & (dist_name == "akola" | dist_name == "buldana" | dist_name == "amarawti") 

*Bhambi, Bhambhi, Asadaru, Asodi, Chamadia, Chamar, Chamari, Chambhar, Chamgar, Harakayya, Harali, 
*Khalpa, MAchigar, Mochigar, Machigar, Madar, Madig, Mochi, Telegu MOchi, KAmati mochi, Ranigar, 
*Rohidas, Nona, Ramnami, Rohit, Samgar, Samagara, Satnami, Surjabanshi, Surjyaramnami 
replace sc76=1 if (jati == "chamar" | jati == "madiga" | jati == "mochi")  ///
          & state == "maharashtra" & (rega| regb| regc) 

*Bhangi, Mehtar, Olgana, Rukhi, Malkana, Halalkhor, Lalbegi, Balmiki, Korar, Zadmali 
replace sc76=1 if (jati == "bhangi" | jati == "mehtar") & state == "maharashtra" & ( rega| regb| regc) 

*Bindla 
*Byagara 
*Chalvadi, Channayya 
*Chenna Dasar, Holaya Dasar, Holeya Dasari 
*Dakkal, Dokkalwar 
*Dhor, Kukkaya, Kankayya, Dohor (syn of DABGAR) 
*Dom, Dumnar 
*Ellamalvar, Yellammalawandlu 
*Ganda, Gandi 
*Garoda, Garo 
*Ghasi, Ghasia 
replace sc76=1 if jati == "ghasi" & state == "maharashtra" & regc 

*Halleer 
*Halsar, Haslar, Hulasvar, Halasvar 
*Holar, Valhar 
replace sc76=1 if jati == "holar" & state == "maharashtra" & (rega| regb) 

*Holaya, Holer, Holeya, Holiya 
*Kaikadi 
replace sc76=1 if jati == "kaikadi" & state == "maharashtra" & regc 

*Katia, Patharia 
*Khangar, Kanera, Mirdha 
*Khatik, Chikwa, Chikvi 
replace sc76=1 if jati == "khatik" & state == "maharashtra" & regc 

*Kolupulvandlu 
*Kori 
*Lingader 
*Madgi 
*Madiga 
*Mahar, Mehra, Taral, Dhegu, Megu, syn: DHER  ;       
replace sc76=1 if (jati == "mahar" | jati == "harijan") & state == "maharashtra" & (rega| regb| regc) 

*Mahyavanshi, Dhed, Vankar, Maru Vankar 
*Mala 
*Mala Dasari 
*Mala Hannai 
*Mala Jangam 
*Mala Masti 
*Mala Sale, Netkani 
*Mala Sanyasi 
*Mang, Matang, Minimadig, Dankhni, Mang, Madari, Garudi, Radhe Mang 
replace sc76=1 if (jati == "mang" | jati == "matang" | jati == "matana") & state == "maharashtra" & (rega| regb| regc) 

*Mang Garodi, Mang Garudi 
*Manne 
*Mashti 
*MEghval, Menghvar 
*Mitha Ayyalvar 
*Mukri 
*Nadia, Hadi 
*Pasi 
*Sansi 
*Shenva, Chenva, Sedma, Ravat 
*Sindhollu, Chindollu 
*Tirgar, Tirbanda 
*Turi 

********************************************************************************
* Punjab
********************************************************************************;       
*pre 76 areas

*Region A : throughout the state
replace rega= 1 if state == "punjab" 


*Region B: throughout the state except Patiala, Bathinda, Mahendragarh, Kapurthala and Sangrur 
replace regb = 1 if state == "punjab" 
*Patiala: becomes  Patiala & Rupnagar 
replace regb = 0 if state == "punjab" & (dist_name == "patiala" | dist_name == "rupnagar") 
*Bathinda: 
replace regb = 0 if state == "punjab" & dist_name == "bathinda" 
*Mahendragarh : part of Haryana 
*Kapurthala 
replace regb = 0 if state == "punjab" & dist_name == "kapurthala" 
*Sangrur 
replace regb = 0 if state == "punjab" & dist_name == "sangrur" 

replace reg = 1 if state == "punjab" & rega == 1 
replace reg = 2 if state == "punjab" & regb == 1 

***************
*SC Coding
*************** 

*Ad Dharmi 
replace sc76=1 if jati == "ad dharmi" & state == "punjab" & (rega) 

*Balmiki, Chura or Bhangi 
replace sc76=1 if (jati == "balmiki" | jati == "chuhra" | jati == "bhangi") & state == "punjab" & (rega) 

*Bangali 
*Barar, Burar or Berar 
replace sc76=1 if jati == "barar" & state == "punjab" & rega 

*Batwal 
*Bauria or Bawaria 
replace sc76=1 if jati == "babriya" & state == "punjab" & rega 

*Bazigar 
*Bhanjra 
*Chamar, Jatia Chamar, Rehgar, Raigar, Ramdasi or Ravidasi 
replace sc76=1 if (jati == "chamar" | jati == "chamaar vidaasi" | jati == "harijan ramdasi" | ///
           jati == "ramadasi" | jati == "ramdashi" | jati == "ramdasi" | jati == "ramgadi" | /// 
           jati == "randasi" | jati == "ravi dasi" | jati == "ravidasi" | jati == "ravi dass" | ///
           jati == "rem dasi" | jati == "rai dasi") & state == "punjab" & (rega) 

*Chanal 
*Darain 
*Deha, Dhaya or Dhea 
*Dhanak 
replace sc76=1 if jati == "dhanak" & state == "punjab" & rega 


*Dhogri, Dhangri or Siggi 
*Dumna, Mahasha or Doom 
replace sc76=1 if (jati == "mahasha") & state == "punjab" & rega 


* Gagra 
replace sc76=1 if jati == "gagra" & state == "punjab" & rega 

* Gandhila or Gandil Gondola 
*Kabirpanthi or Julaha 
*Khatik 
*Kori or Koli 
replace sc76=1 if jati == "kohli" & state == "punjab" & rega 

*Marija or Marecha 
*Mazhabi 
replace sc76=1 if jati == "mazhabi" & state == "punjab" & rega 

*Megh 
replace sc76=1 if jati == "meghwal" & state == "punjab" & rega 

*Nat 
replace sc76=1 if jati == "nat" & state == "punjab" & rega 

*Od 
replace sc76=1 if jati == "od" & state == "punjab" & rega 

*Pasi 
replace sc76=1 if jati == "pasi" & state == "punjab" & rega 

*Perna 
*Pherera 
*Sanhai 
*Sanhal 
*Sansi Bhedkut or Manesh 
replace sc76=1 if jati == "sansi" & state == "punjab" & rega 

*Sansoi 
*Sapela 
*Sarera 
*Sikligar 
*Sirkiband 

********************************************************************************
* Rajasthan
********************************************************************************
*Region A 
*throughout the state except Ajmer district, Abu Road taluka of sirohi district and Sunel Tappa of Jhalawar district 
replace rega=1 if state == "rajasthan" 
replace rega=0 if state == "rajasthan" & dist_name == "ajmer" 
replace rega=0 if state == "rajasthan" & dist_name == "sirohi" 
replace rega=0 if state == "rajasthan" & dist_name == "jhalawar" 

*Region B 
*Ajmer district 
replace regb=0 if state == "rajasthan" 
replace regb=1 if state == "rajasthan" & dist_name == "ajmer" 


*Region C 
*Abu Road Taluka of Sirohi district 
replace regc=0 if state == "rajasthan" 
replace regc=1 if state == "rajasthan" & dist_name == "sirohi" 

*Region D 
*Sunnel Tappa of Jhalawar district 
replace regd=0 if state == "rajasthan" 
replace regd=1 if state == "rajasthan" & dist_name == "jhalawar" 

replace reg = 1 if state == "rajasthan" & rega==1 
replace reg = 2 if state == "rajasthan" & regb==1 
replace reg = 3 if state == "rajasthan" & regc==1 
replace reg = 4 if state == "rajasthan" & regd==1 
replace reg = 5 if state == "rajasthan" & rega == 0 & regb == 0 & regc == 0 & regd == 0 

*******************
***  SC coding  ***
******************* 

*Balai: POI SC : balai of rajasthan also cllaed meghwal or meghbansi 

*Adi Dharmi 
*Ager 
*Aheri 
*Badi 
*Bagri 
replace sc76=1 if jati == "bagdi" & state == "rajasthan" & (rega|regb) 

*Bairwa or Berwa 
replace sc76=1 if (jati == "bairwa" | jati == "barva" | jati == "barba" | jati == "borva" | jati == "berwal") & state == "rajasthan" & rega 

*Bajgar 
*Balai 
replace sc76=1 if jati == "balae" & state == "rajasthan" & (rega|regb|regd) 

*Bambhi 
replace sc76=1 if jati == "bambi" & state == "rajasthan" & regb 

*Bansphod 
*Bansphor 
*Baori 
replace sc76=1 if (jati == "bavri" | jati == "bahvari") & state == "rajasthan" & regb 
 
*Bargi, Vargi or Birgi 
*Bawaria 
replace sc76=1 if (jati == "bawaria" | jati == "bumariya") & state == "rajasthan" & rega 

*Bazigar 
*Bedia or Beria 
*Bhand 
*Bhangi 
*Bidakia 
*Bola 
*Chamar, Bhambhi, Jatav, Mochi, Raidass, Raigar or Ramdasia 
replace sc76=1 if (jati == "chamar" | jati == "jatav" | jati == "jaatv" | jati == "jat" | ///
           jati == "harijan" | jati == "raigar" | jati == "regar")                        ///
          & state == "rajasthan" & regc 

*Chandal 
*Chura 
*Dabgar 
*Dhanak 
*Dhankia 
*Dhed 
*Dheda 
*Dhobi 
replace sc76=1 if jati == "dhobi" & state == "rajasthan"  & regb 

*Dholi 
replace sc76=1 if jati == "dholi" & state == "rajasthan"  & regb 

*Dom 
*Dome 
*Gandia 
*Garancha, Gancha 
*Garo, Garura,Gurda 
replace sc76=1 if jati == "garo" & state == "rajasthan" & rega 

*Garoda 
*Gancha 
replace sc76=1 if jati == "gancha" & state == "rajasthan" & regb 

*Gavaria 
replace sc76=1 if jati == "gavaria" & state == "rajasthan" & rega

*Godhi 
*Jingar 
replace sc76=1 if jati == "jingar" & state == "rajasthan"  & rega 

*Kabirpanthi 
*Kalbelia 
*Kamad or Kamadia 
*Kanjar 
*Kapadia Sansi 
*Khangar 
*Khatik 
replace sc76=1 if jati == "khatik" & state == "rajasthan" & (rega|regb|regd) 

*Koli or Kori 
replace sc76=1 if (jati == "kohli" | jati == "kori") & state == "rajasthan" & (rega|regb|regd) 

*Kooch Band 
*Koria 
*Kuchband 
*Kunjar 
*Madari or Bazigar 
*Mahar 
replace sc76=1 if jati == "mahar" & state == "rajasthan"  & (regb|regc|regd) 

*Majhabi 
*Mang, Matang, Minimadig 
*Mang Garodi, Mang Garudi 
*Megh or Meghwal 
replace sc76=1 if (jati == "megawal" | jati == "meghalal" | jati == "meghwal" |  ///
           jati == "meghwal dhanik" | jati == "mehwal") & state == "rajasthan" & (regb|regd) 

*Mehar 
*Mehtar 
replace sc76=1 if jati == "mehtar" & state == "rajasthan" & rega 

*Nut 
replace sc76=1 if jati == "nat" & state == "rajasthan"  & (rega|regb|regd) 

*Pasi 
*Rawal 
replace sc76=1 if jati == "rawal" & state == "rajasthan"  & (rega|regb) 

*Salvi 
replace sc76=1 if jati == "salve" & state == "rajasthan" & rega 

*Sansi 
*Santia 
*Sarbhangi 
*Sargara 
replace sc76=1 if jati == "sargara" & state == "rajasthan" & (rega|regb) 

*Satia 
*Singiwala 
*Thori or Nayak 
replace sc76=1 if jati == "nayak" & state == "rajasthan" & (rega|regb) 

*Tirgar 
replace sc76=1 if jati == "tirgar" & state == "rajasthan" & (rega|regb|regc) 

*Valmiki 
replace sc76=1 if jati == "balmiki" & state == "rajasthan" & rega 

********************************************************************************
* Tamil Nadu
********************************************************************************
*pre 76 areas 

*Region A: throughout the state 
replace rega=1 if state == "tamil nadu" 

*Region B: throughout the state except Kanyakumari district and Shecottah taluk of Tirunelveli district 
replace regb = 0 if state == "tamil nadu" 
replace regb = 1 if state == "tamil nadu" & (dist_name != "kanniyakumari" & dist_name != "tirunelveli")

*Region C: Nigliris district 
replace regc = 0 if state == "tamil nadu" 
*Nilgiris 
replace regc = 1 if state == "tamil nadu" & dist_name == "nilgiris" 

*Region D: Coimbatore and Salem districts 
replace regd = 0 if state == "tamil nadu" 
*Salem 
replace regd = 1 if state == "tamil nadu" & dist_name == "salem" 
*Coimbatore 
replace regd = 1 if state == "tamil nadu" & dist_name == "coimbatore" 
*Periyar 
replace regd = 1 if state == "tamil nadu" & dist_name == "periyar" 

*Region E: Kanyakumari district and Shecottah taluk of Tirunelveli district 
replace rege = 0 if state == "tamil nadu" 
*Kanyakumari 
replace rege = 1 if state == "tamil nadu" & dist_name == "kanniyakumari" 
*Tirunvelveli 
replace rege = 1 if state == "tamil nadu" & dist_name == "tirunelveli" 

*Region F: in Thanjavur district 
replace regf = 0 if state == "tamil nadu" 
replace regf = 1 if state == "tamil nadu" & dist_name == "thanjavur" 


replace reg = 1 if state == "tamil nadu" & regb 
replace reg = 2 if state == "tamil nadu" & regc 
replace reg = 3 if state == "tamil nadu" & regd 
replace reg = 4 if state == "tamil nadu" & rege 
replace reg = 5 if state == "tamil nadu" & regf 
replace reg = 6 if state == "tamil nadu" & regb == 0 & regc == 0 & regd == 0 & rege== 0 & regf == 0 

************
*SC Coding
************

*Adi Andra 
replace sc76=1 if jati == "adi andhra" & state == "tamil nadu" & regb 

*Adi Dravida 
replace sc76=1 if jati == "adi dravida" & state == "tamil nadu" & regb 

*Adi Karnataka 
*Ajila 
*Arunthathiyar 
replace sc76=1 if jati == "arunthathiyar" & state == "tamil nadu" & regb 

*Ayyanavar 
*Baira 
replace sc76=1 if jati == "baira" & state == "tamil nadu" & regb 
 
*Bakuda 
*Bandi 
*Bellara 
*Bharatar 
replace sc76=1 if jati == "bharatar" & state == "tamil nadu" & rege 

*Chakkiliyan, harijan 
replace sc76=1 if (jati == "chakkiliyan" | jati == "harijan") & state == "tamil nadu" & rega 

*Chalavadi 
*Chamar, Muchi 
*Chandala 
*Cheruman 
*Devendrakulathan
replace sc76=1 if jati == "devendrakulathan" & state == "tamil nadu" & regb 

*Dom, Dombara, Paidi, Pano 
*Domban 
*Godagali 
*Godda 
replace sc76=1 if jati == "godda" & state == "tanil nadu" & regb 

*Gosangi 
*Holeya 
*Jaggali 
*Jambuvulu 
*Kadaiyan 
*Kakkalan 
*Kalladi 
*Kanakka, Padanna 
*Karimpalan 
*Kavara 
*Koliyan 
*Koosa syn Kulala 
*Kootan, Koodan 
*Kudumban 
*Kuravan, Sidhanar 
replace sc76=1 if jati == "korava" & state == "tamil nadu" & rega 

*Madari 
replace sc76=1 if jati == "madari" & state == "tamil nadu" & regb 

*MAdiga 
replace sc76=1 if jati == "madiga" & state == "tamil nadu" & regb 

*Maila 
*mala 
*Mannan 
*Mavilan 
*Moger 
*Mundala 
*Nalakeyava 
*Nayadi 
*Padannan 
*Pagadai 
*Pallan 
replace jati = "pallan" if jati == "pallar" & state == "tamil nadu" 
replace sc76=1 if jati == "pallan" & state == "tamil nadu"  

*Palluvan 
*Pambada 
*Panan 
*Panchama 
*Pannadi 
replace sc76=1 if jati == "pannadi" & state == "tamil nadu" & regd 

*Panniandi 
*Paraiyan, Parayan, Sambava 
replace sc76=1 if (jati == "paraiyar" | jati == "sambhava") & state == "tamil nadu" & rega 

*Paravan 
*Pathiyan 
*Pulayan, Cheramar  
*Puthirai Vannan, syn Dhobi 
*Raneyar 
*Samagara 
*Samban 
*Sapari 
*Semman 
*Thandan 
*Thoti 
replace sc76=1 if jati == "thoti" & state == "tamil nadu" & regb 

*Tiruvalluvar 
*Vallon 
*Valluvan 
*Vannan 
*Vathiriyan 
*Velan 
*Vetan 
*Vettiyan 
replace sc76=1 if jati == "vettiyan" & state == "tamil nadu" & rege 

*Vettuvan 

********************************************************************************
* Uttar Pradesh
********************************************************************************

*Region A 
*throughout the State except Agra, Meerut and Rohilkhand Division 
replace rega=1 if state == "uttar pradesh" 
*Meerut division : Meerut, Bulandsahar, Gutam Buddha Nagar, Ghaziabad and Bagpat districts 
*Agra Division : Agra, Firozabad, Mainpuri, Mathudra, Hatras, Aligarh, Etah districts 
*Rohilkhand division in now BAreilly division : Bareilly, Badaun, Pilibhit and Shahjahanpur districts 
*Meerut 
replace rega=0 if state == "uttar pradesh" & dist_name == "meerut" 
*Bulandsahar 
replace rega=0 if state == "uttar pradesh" & dist_name == "bulandsahar" 
*Gutam Buddha Nagar 
replace rega=0 if state == "uttar pradesh" & dist_name == "gautam buddha nagar" 
*Ghaziabad 
replace rega=0 if state == "uttar pradesh" & dist_name == "ghaziabad" 
*Bagpat 
replace rega=0 if state == "uttar pradesh" & dist_name == "bagpat" 
*Agra 
replace rega=0 if state == "uttar pradesh" & dist_name == "agra" 
*Firozabad 
replace rega=0 if state == "uttar pradesh" & dist_name == "firozabad" 
*Mainpuri 
replace rega=0 if state == "uttar pradesh" & dist_name == "mainpuri" 
*Mathudra 
replace rega=0 if state == "uttar pradesh" & dist_name == "mathura" 
*Hatras 
replace rega=0 if state == "uttar pradesh" & dist_name == "hathras" 
*Aligarh 
replace rega=0 if state == "uttar pradesh" & dist_name == "aligarh" 
*Etah 
replace rega=0 if state == "uttar pradesh" & dist_name == "etah" 
*Bareilly 
replace rega=0 if state == "uttar pradesh" & dist_name == "bareilly" 
*Badaun 
replace rega=0 if state == "uttar pradesh" & dist_name == "budaun" 
*Pilibhit 
replace rega=0 if state == "uttar pradesh" & dist_name == "pilibhit" 
*Shahjahanpur 
replace rega=0 if state == "uttar pradesh" & dist_name == "shahjahanpur" 

replace regb=1 if state == "uttar pradesh" & (rega==0) 
replace regb=0 if state == "uttar pradesh" & (rega==1) 

replace reg = 1 if state == "uttar pradesh" & rega == 1 
replace reg = 2 if state == "uttar pradesh" & regb == 1 

*************
*SC coding
************* 

*Only one change in the SC/ST list : the Kori 
replace sc76=1 if (jati == "kori" |  jati == "kohli") & (state == "uttar pradesh" | state == "uttarakhand")  & regb 
replace sc76=1 if sc == 1 & (state == "uttar pradesh" | state == "uttarakhand") 

********************************************************************************
* West Bengal
********************************************************************************

*Region A 
*Throughout the state 
replace rega=1 if state == "west bengal" 


*Region B: throughout the state except in th Purulia district and the territories transferred from the Purnea district of Bihar (ie West Dinajpur district) 
replace regb=1 if state == "west bengal" 
replace regb=0 if state == "west bengal" & (dist_name == "purulia" | dist_name == "uttar dinajpur") 

*Region C 
*in th Purulia district and the territories transferred from the Purnea district of Bihar (ie West Dinajpur district) 
replace regc=0 if state == "west bengal" 
replace regc=1 if state == "west bengal" & (dist_name == "purulia" | dist_name == "uttar dinajpur") 


*Region D: in the territories transferred from the Purnea district of Bihar (ie West Dinajpur district) 
replace regd=0 if state == "west bengal" 
replace regd=1 if state == "west bengal" & dist_name == "uttar dinajpur" 

*Region E: throughout the state except the territories transferred from the Purnea district of Bihar 
replace rege=0 if state == "west bengal" 
replace rege=1 if state == "west bengal" & regd==0 


replace reg = 0 if state == "west bengal" 
replace reg = 1 if state == "west bengal" & (regb|regc|regd)  

***********
*SC Coding
*********** 

*BAGDI, DULEY 
replace sc76=1 if jati == "bagdi" & state == "west bengal" & regb 

*BAHELIA 
*BAITI 
*BANTAR 
*BAURI 
*BELDAR 
*BHOGTA 
*BHUIMALI 
replace sc76=1 if jati == "bhuimali" & state == "west bengal" & regb 

*BHUIYA 
replace sc76=1 if jati == "bhuiya" & state == "west bengal" & regb 

*BIND 
*CHAMAR, CHARMAKAR, MOCHI, MUCHI, RABIDAS, RUIDAS, RISHI 
replace sc76=1 if (jati == "chamar" | jati == "machhi" | jati == "mochi" | jati == "ravidasi" | ///
           jati == "rishi" | jati == "rishi das") & state == "west bengal" & rega 

*CHAUPAL 
*DABGAR 
*DAMAI (Nepali) 
replace sc76=1 if (jati == "nepali" | jati == "napali") & state == "west bengal" &  regb 

*DHOBA, DHOBI 
replace sc76=1 if jati == "dhobi"  & state == "west bengal" & rega 

*DOAI 
*DOM, DHANGAD 
replace sc76=1 if jati == "dom" & state == "west bengal" & rega 

*DOSADH, DUSADH, DHARI, DHARHI 
replace sc76=1 if (jati == "dusadh" | jati == "darhi") & state == "west bengal" 

*GHASI 
*GONRHI 
*HALALKHOR 
*HARI, MEHTAR, MEHTOR, BHANGI 
replace sc76=1 if (jati == "harijan" | jati == "mehtar") & state == "west bengal" & regc 

*JALIA KAIBARTTA 
replace sc76=1 if (jati == "jala karybatta" | jati == "jalia kaibartta") & state == "west bengal" & regb 

*JHALO MALO, MALO 
*KADAR 
*KAMI (Nepali) 
replace sc76=1 if jati == "kami" & state == "west bengal" & regb 

*KANDRA 
*KANJAR 
*KAORA 
*KARENGA, KORANGA 
*KAUR 
*KEOT, KEYOT 
replace sc76=1 if jati == "kevat" & state == "west bengal" & regb 

*KHARIA 
replace sc76=1 if jati == "kharia" & state == "west bengal" & regb 

*KHATIK 
replace sc76=1 if jati == "khatik" & state == "west bengal" & regb 

*KOCH 
*KONAI 
*KONWAR 
*KOTAL 
replace sc76=1 if jati == "kotal" & state == "west bengal" & regb 

*KURARIAR 
*LALBEGI 
*LOHAR 
replace sc76=1 if jati == "lohar" & state == "west bengal" & regb 

*MAHAR 
replace sc76=1 if jati == "mahar" & state == "west bengal" & regb 

*MAL 
*MALLAH 
replace sc76=1 if jati == "mala" & state == "west bengal" & regb 

*MUSAHAR 
replace sc76=1 if jati == "musahar" & state == "west bengal" 

*NAMASUDRA 
replace sc76=1 if jati == "namasudra" & state == "west bengal" & regb 

*NAT 
replace sc76=1 if jati == "nat" & state == "west bengal" & regc 

*NUNIYA 
replace sc76=1 if jati == "nuniya" & state == "west bengal" & regb 

*PALIYA 
*PAN, SAWASI 
*PASI 
*PATNI 
replace sc76=1 if jati == "patni" & state == "west bengal"& regb 

*POD, POUNDRA 
replace sc76=1 if jati == "poundra" & state == "west bengal" & regb 

*RAJBANSHI 
replace sc76=1 if jati == "rajbanshi" & state == "west bengal" & regb 

*RAJWAR 
replace sc76=1 if jati == "rajwar" & state == "west bengal" & rega 

*SARKI (Nepali) 
*SUNRI (excluding SAHA) 
replace sc76=1 if jati == "sunri" & state == "west bengal" & regb 

*TIYAR 
replace sc76=1 if jati == "tiyar" & state == "west bengal" & regb 

*TURI 

*CHAIN 
replace sc02=1 if jati == "chain" & state == "west bengal" & (dist_name == "maldah" | dist_name == "murshidabad" | ///
                                dist_name == "nadia") 
replace sc02=0 if jati == "chain" & state == "west bengal" & (dist_name != "maldah" & dist_name != "murshidabad" & ///
                                dist_name != "nadia") 
replace sc63=0 if jati == "chain" & state == "west bengal" 
replace sc64=0 if jati == "chain" & state == "west bengal" 
replace sc76=0 if jati == "chain" & state == "west bengal" 
replace sc77=0 if jati == "chain" & state == "west bengal" 
                                
********************************************************************************
* Pondicherry
********************************************************************************
* SCs in Pondicherry came into being in 1964 
replace sc63 = 0 if jati != "" & state == "pondicherry" 
replace sc64 = 1 if jati != "" & state == "pondicherry" 
replace sc76 = 1 if jati != "" & state == "pondicherry" 
replace sc77 = 1 if jati != "" & state == "pondicherry" 
replace sc02 = 1 if jati != "" & state == "pondicherry" 

* Finally giving all SC castes that have not been given sc76 but have a jati, a value of 0
replace sc76 = 0 if jati != "" & sc76 == . & sc == 1 & ///
          (state != "arunachal pradesh" & state != "daman & diu" & state != "goa" & ///
           state != "meghalaya" & state != "mizoram" & state != "pondicherry" & state != "sikkim") 
           
replace sc77 = 1 if sc76 != . & sc77 == . 

foreach var in sc63 sc64 { 
  replace `var' = 1 if sc76 == 1 & sc77 == 1 & `var' == . 
  replace `var' = 0 if sc76 == 0 & sc77 == 1 & `var' == . 
} 

replace sc02 = 1 if sc77 == 1 & sc02 == . 

********************************************************************************
* Interacting age with SC status
********************************************************************************
** Here the assumption I make is that people can take advantage of their SC status till 16 years of age 

gen age_63 = . 
gen age_76 = . 
gen age_02 = . 
gen age_sc = . 

** (1) areas that have always been SC 
replace age_sc = age if sc63 == 1 & sc64 == 1 & sc76 == 1 & sc77 == 1 & sc02  == 1 

** (2) areas that were categorized into SC in 1964 
replace age_63 = age - 48       if                             sc63 == 0 & sc64 == 1 & sc76 == 1 & sc77 == 1 & sc02 == 1 
replace age_sc = age            if age_63 <= 0               & sc63 == 0 & sc64 == 1 & sc76 == 1 & sc77 == 1 & sc02 == 1 
replace age_sc = 0              if age_63 > 16 & age_63 !=.  & sc63 == 0 & sc64 == 1 & sc76 == 1 & sc77 == 1 & sc02 == 1 
replace age_sc = 16 - age_63    if age_63 > 0 & age_63 <= 16 & sc63 == 0 & sc64 == 1 & sc76 == 1 & sc77 == 1 & sc02 == 1 

** (3) areas that were categorized into SC in 1977 
replace age_76 = age - 35       if                              sc63 == 0 & sc64 == 0 & sc76 == 0 & sc77 == 1 & sc02 == 1 
replace age_sc = age            if age_76 <= 0                & sc63 == 0 & sc64 == 0 & sc76 == 0 & sc77 == 1 & sc02 == 1 
replace age_sc = 0              if age_76 > 16 & age_76 != .  & sc63 == 0 & sc64 == 0 & sc76 == 0 & sc77 == 1 & sc02 == 1 
replace age_sc = 16 - age_76    if age_76 > 0 & age_76 <= 16  & sc63 == 0 & sc64 == 0 & sc76 == 0 & sc77 == 1 & sc02 == 1 

** (4) areas that were categorized into SC in 2002 
replace age_02 = age - 9        if                              sc63 == 0 & sc64 == 0 & sc76 == 0 & sc77 == 0 & sc02 == 1 
replace age_sc = age            if age_02 <= 0                & sc63 == 0 & sc64 == 0 & sc76 == 0 & sc77 == 0 & sc02 == 1 
replace age_sc = 0              if age_02 > 16 & age_02 != .  & sc63 == 0 & sc64 == 0 & sc76 == 0 & sc77 == 0 & sc02 == 1 
replace age_sc = 16 - age_02    if age_02 > 0 & age_02 <= 16  & sc63 == 0 & sc64 == 0 & sc76 == 0 & sc77 == 0 & sc02 == 1 

** finally assigning SC years to be 16 if SC years are greater than 16 
replace age_sc = 16 if age_sc > 16 & age_sc != . 

** Cassan "age at reform" variable at 1977 
gen young_77 = 1     if (age - 35) < 12
replace young_77 = 0 if (age - 35) >= 12 & age != . 

/* set SC variables to zero for all individuals who are never SCs */
foreach year in 63 64 76 77 02 { 
  replace sc`year' = 0 if sc`year' == . & sc == 0 
} 

/* drop if missing sc status - this is fewer than 800 people (previously 600 for QJE paper) */
count if sc63 == . | sc64 == . | sc76 == . | sc77 == . | sc02 == . 
assert `r(N)' < 800
drop if  sc63 == . | sc64 == . | sc76 == . | sc77 == . | sc02 == .

/* label vars */
label var reg "Region"

/* label variables (2022-09-09)  */
label var sc77 "Group is on an SC list in 1977"
label var sc76 "Group is on a pre-1976 SC list"
label var sc63 "Group is on a pre-1963 SC list"
label var sc64 "Group is on a 1964-76 SC list (identical to sc76)"

/* keep only vars used for jati analysis to avoid replicating ihds which is cleaned elsewhere */
keep jati* hhid wt idperson sc* reg group male
save "$mobility/ihds_2011_jati_aa.dta", replace 
