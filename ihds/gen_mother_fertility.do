/*************************************************************************/
/* IHDS: Calculate number siblings based on mothers' number of children. */
/*       Only possible for children who still live with mom.             */
/*************************************************************************/

/************************************************************************************/
/* Assignments made:                                                                */
/*  3 son/daughter -- mother TFR = head or head wife's TFR (1,2)                    */
/*  5 grandchild   -- mother TFR = mean of head's daughters TFRs (3)                */
/*                                                                                  */
/* Not done yet:                                                                    */
/*  1 Head           -- mother TFR = head's mother's TFR (6)                        */
/*  7 Brother/sister -- mother TFR = head's mother's TFR (6)                        */
/*                                                                                  */
/* Note: We don't assign niece/nephews to aunts/uncles as we don't know who mom is. */
/************************************************************************************/

/* open clean 2011 IHDS members */
use $ihds/ihds_2011_members, clear

/* keep children with ed-mobility-relevant ages */
keep if inrange(age, 15, 100)

/* merge in women's questionnaire */
merge 1:1 idperson using $ihds/ihds_2011_ew, keepusing(number_children)

/* create placeholder for mother's fertility (i.e. # siblings via mother) */
gen mom_num_kids = .

/* HEAD OF HOUSEHOLD/WIFE --> SONS / DAUGHTERS */

/* calculate number of children for head of households or their wife */
gen fhead_number_children_tmp = number_children if inlist(relation, 1, 2) & male == 0
bys hhid: egen fhead_number_children = mean(fhead_number_children_tmp)

/* set mother's TFR to the head/head wife's fertility if you're child of head */
replace mom_num_kids = fhead_number_children if relation == 3
drop fhead_number_children*

/* DAUGHTER OF HEAD ---> GRANDCHILDREN OF HEAD */

/* generate head's daughter's fertility */
gen mother_of_grandson_nc_tmp = number_children if relation == 3 & male == 0
bys hhid: egen mother_of_grandson_nc = mean(mother_of_grandson_nc_tmp)

/* set mother's fertility equal to the head's daughter's fertility if you're grandchild of head */
replace mom_num_kids = mother_of_grandson_nc if relation == 5 & mi(mom_num_kids)
drop mother_of_grandson_nc*

/* MOTHER OF HEAD ----> HEAD AND SIBLINGS */
gen mother_of_head_nc_tmp = number_children if relation == 6 & male == 0
bys hhid: egen mother_of_head_nc = mean(mother_of_head_nc_tmp)

/* assign head and daughters' mom's TFR  */
replace mom_num_kids = mother_of_head_nc if inlist(relation, 1, 7) & mi(mom_num_kids)


/* CLEAN UP AND SAVE */

/* set impossible values to missing */
replace mom_num_kids = . if mom_num_kids == 0

/* fractions round up from zero, otherwise round down */
replace mom_num_kids = 1 if mom_num_kids < 1
replace mom_num_kids = floor(mom_num_kids)

/* save the person id, and the person's mother's fertility */
keep idperson mom_num_kids

/* only keep non-missing data */
keep if !mi(mom_num_kids)

/* save the dataset */ 
compress
save $tmp/ihds/mother_tfr, replace
