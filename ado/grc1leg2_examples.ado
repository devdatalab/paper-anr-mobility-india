*! Version 1.5	4Apr2021 by Mead Over, Center for Global Development
*! Companion program to be executed by the help file: grc1leg2.sthlp
program grc1leg2_examples
	version 13.1
	if (_caller() < 13.1)  version 12
	else		      version 13.1

	set more off
	`0'
	
	capture prog drop grc1leg2
end

program Msg
	di as txt
	di as txt "-> " as res `"`0'"'
end

program Xeq
	di as txt
	di as txt `"-> "' as res _asis `"`0'"'
	`0'
end

program define NewFile 
	args fn
	capture confirm new file `fn'
	if _rc {
		di as txt "{p 0 2 2}"
		di "Example cannot be run because you already have a"
		di "file named {res:`fn'}"
		di "{p_end}"
		error 602
	}
end

program define NewName 
	args fn
	capture graph rename `fn' `fn'
	if _rc==0 {
		di as txt "{p 0 2 2}"
		di "Example cannot be run because you already have a"
		di "graph in memory named {res:`fn'}."
		di "Either drop this graph or simply click {stata graph drop _all}."
		di "{p_end}"
		di as err _n "graph `fn' already exists"
		exit 110
	}
end

**************************Begin Mead's code***************************
program setup
	capture sysuse auto
	if _rc~=0 {
		Msg sysuse auto
		di as err "no; data in memory would be lost"
		di as err "First {stata clear:clear} your memory before running these examples"
		exit
	}
	foreach name in  ///
		grby3 grby5   ///
		grcomb3 grcomb5  ///
		panel1 panel2 panel3 ///
		grc13woxtob1 grc13 grc18  ///
		grc13labsize grc14  {
		
		NewName `name'
	}

	set more off
	Xeq sysuse auto
	Xeq gen byte qual = 1*(rep78<3)+2*(rep78==3)+3*(rep78>=4)
	Xeq lab def qual 1 "Low Quality"  2  "Medium"  3  "High Quality"
	Xeq lab value qual qual
	Xeq lab var qual "Quality: Mapping of rep78 into trichotomy"
	Xeq tab rep78 qual
end

program grby3
*	NewName grby3  //  Checks for whether graphs exist have been moved to -setup-
	set graph on
	Xeq twoway  ///
		(scatter mpg weight)  ///
		(lfit mpg weight ),  ///
			legend(col(1)) ///
			by(qual,  ///
				legend(pos(0) at(4))  ///
				title("Three panels, with legend in a hole")  ///
				subtitle("Use -twoway ..., by()- with -at(4) pos(5)-") ///
			)  ///
		name(grby3, replace)
end

program grby5
*	NewName grby5
	set graph on
	Xeq twoway  ///
		(scatter mpg weight)  ///
		(lfit mpg weight ),  ///
			legend(col(1)) ///
			by(rep78,  ///
				legend(pos(0) at(6))  ///
				title("Five panels, with legend in a hole")  ///
				subtitle("Use -twoway ..., by()- with -at(6) pos(0)-") ///
			)   ///
		name(grby5, replace)

end

program make3panels
*	NewName panel1
*	NewName panel2
*	NewName panel3
	
	Xeq set graph off
	
	Xeq twoway  ///
		(scatter mpg weight if qual==1)  ///
		(lfit mpg weight if qual==1),  ///
			ytitle(Mileage rating)  ///
			subtitle("Low Quality")  ///
			legend(col(1) off) ///  The -col(1)- option is used by -grc1leg2-
			name(panel1, replace)

	Xeq twoway  ///
		(scatter mpg weight if qual==2)  ///
		(lfit mpg weight if qual==2),  ///
			ytitle(Mileage rating)  ///
			subtitle("Medium")  ///
			legend(off) ///
			name(panel2, replace)

	Xeq twoway  ///
		(scatter mpg weight if qual==3)  ///
		(lfit mpg weight if qual==3),  ///
			ytitle(Mileage rating)  ///
			subtitle("High Quality")  ///
			legend(col(1) ring(0) pos(5) xoffset(40) )  ///
			name(panel3, replace)

	Xeq set graph on
	Xeq graph dir, memory // These named graphs are now in memory
end

program grcomb3
*	NewName grcomb3
	set graph on
	Xeq gr combine panel1 panel2 panel3,  ///
		xcommon ycommon      ///
		title("Three panels, with legend in a hole")  ///
		subtitle("Use -gr combine ... `altshrinktitle', having specified"  ///
			"-ring(0) pos(5) xoffset(40)- on the last graph")  ///
		name(grcomb3, replace) 
	
end


program grcomb5
*	NewName grcomb5
	set graph on
	Xeq gr combine panel1 panel2 panel1 panel2 panel3,  ///
		xcommon ycommon      ///
		title("Five panels, with legend in a hole")  ///
		subtitle("Use -gr combine ... `altshrinktitle', having specified"  ///
			"-ring(0) pos(5) xoffset(40)- on the last graph")  ///
		name(grcomb5, replace) 
	
end

program grcomb8
*	NewName grcomb8
	set graph on
	Xeq gr combine panel1 panel2 panel1 panel3 panel1 panel2 panel1 panel2,  ///
		xcommon ycommon holes(5)    ///
		title("Eight panels, with legend in the middle")  ///
		subtitle("Use -gr combine ... `altshrinktitle', having specified"  ///
			"-ring(0) pos(5) xoffset(40)- on the fourth graph")  ///
		b1title("Weight")  ///
		name(grcomb8, replace) 

end

program grc13woxtob1
*	NewName grc13woxtob1
	set graph on
	Xeq grc1leg2 panel1 panel2 panel3,  ///
		xcommon ycommon ring(0) pos(5) legendfrom(panel1)    ///
		title("Three panels, with legend in a hole")  ///
		subtitle("Use -grc1leg2- with options -ring(0) pos(5)- `altshrinktitle'" /// 
			"without the option -xtob1title-")  ///
		name(grc13woxtob1, replace)

end

program grc13_offset
*	NewName grc13woxtob1
	set graph on
	Xeq grc1leg2 panel1 panel2 panel3,  ///
		xcommon ycommon ring(0) pos(5) legendfrom(panel1)    ///
		lxoffset(-10) lyoffset(17)  ///
		title("Three panels, with legend in a hole")  ///
		subtitle("Use -grc1leg2- with options -ring(0) pos(5)- `altshrinktitle'" /// 
			 "fine-tuned with legend offset options")  ///
		name(grc13_offset, replace)

end

program grc13
*	NewName grc13
	set graph on
	Xeq grc1leg2 panel1 panel2 panel3,  ///
		xcommon ycommon ring(0) pos(5) legendfrom(panel1)    ///
		lxoffset(-10) lyoffset(17)  ///
		title("Three panels, with legend in a hole")  ///
		subtitle("Use -grc1leg2- with options -ring(0) pos(5)- `altshrinktitle'" /// 
			"with the offset options plus -xtob1title- and -ytol1title-")  ///
		xtob1title ytol1title  ///
		name(grc13, replace)

end

program grc13labsize
*	NewName grc13labsize
	set graph on
	Xeq grc1leg2 panel1 panel2 panel3,  ///
		xcommon ycommon ring(0) pos(5) legendfrom(panel1)    ///
		lxoffset(-6) lyoffset(14)  ///
		title("Three panels, with legend in a hole")  ///
		subtitle("Use -grc1leg2- with options -ring(0) pos(5)- `altshrinktitle'" /// 
			"with the offset and borrowed title options plus -labsize(large)-")  ///
		xtob1title ytol1title labsize(large) ///
		name(grc13labsize, replace)

end

program grc18
*	NewName grc18
	set graph on
	Xeq grc1leg2 panel1 panel2 panel3 panel2 panel3 panel2 panel3 panel2,  ///
		xcommon ycommon ring(0) pos(0) holes(5) legendfrom(panel1)    ///
		title("Eight panels: with legend in middle")  ///
		subtitle("Use -grc1leg2- with options -ring(0) pos(0) holes(5)-  "  ///
			"with the options -xtob1title- and -ytol1title-")  ///
		xtob1title ytol1title  ///
		name(grc18, replace)

end
 
program grc14
*	NewName grc14
	set graph on
	Xeq grc1leg2 panel1 panel2 panel1 panel3 ,  ///
		xcommon ycommon ring(2) pos(6) lrows(1)   ///
		title("Four panels: with legend at bottom")  ///
		subtitle("Use -grc1leg2- with options -ring(2) pos(6)-  "  ///
			"with the options -xtob1title- and -ytol1title-")  ///
		xtob1title ytol1title  ///
		name(grc14, replace)

end

program grc1fromby
*	NewName grc1fromby
	set graph off 
	cap gr des grby3
	if _rc>0 qui grby3 
	cap gr des grcomb3
	if _rc>0 qui grcomb3
	set graph on
	Xeq grc1leg2 grby3 grcomb3,  ///
		title("Relocating the legend from a by() graph")  ///
		name(grc1fromby, replace)

end
 
program grc1fromcomb
*	NewName grc1fromcomb
	cap gr des grby3
	if _rc>0 qui grby3 
	cap gr des grcomb3
	if _rc>0 qui grcomb3
	set graph on
	Xeq grc1leg2 grcomb3 grby3,  ///
		title("Relocating the legend from a combined graph")  ///
		name(grc1fromcomb, replace)

end

program grc1y2tor1
*	NewName grc1y2tor1
	Xeq set graph off
	Xeq twoway  ///
		(scatter mpg weight if qual==1, yaxis(1))  ///
		(scatter length weight if qual==1, yaxis(2)),  ///
			subtitle("Low Quality")  ///
			ylabel(,angle(hor) axis(2))  ///
			name(panel4, replace)
	
	Xeq twoway  ///
		(scatter mpg weight if qual==2, yaxis(1))  ///
		(scatter length weight if qual==2, yaxis(2)),  ///
			subtitle("Medium")  ///
			ylabel(,angle(hor) axis(2))  ///
			name(panel5, replace)
	
	Xeq twoway  ///
		(scatter mpg weight if qual==3, yaxis(1))  ///
		(scatter length weight if qual==3, yaxis(2)),  ///
			subtitle("High Quality")  ///
			ylabel(,angle(hor) axis(2))  ///
			name(panel6, replace)
	Xeq set graph on
		
	Xeq grc1leg2 panel4 panel5 panel6,  ///
		title("Relocating the title on yaxis(2)")  ///
		xtob1title ytol1title y2tor1title  ///
		pos(4) ring(0) lxoffset(-20) lyoffset(15) lcols(1)  ///
		name(grcy2tor1, replace)
end

program grc1hide  

	Xeq set graph off
	
	Xeq twoway  ///
		(scatter mpg weight, mcolor(blue)),  ///
			name(panel7, replace)
	
	Xeq twoway  ///
		(scatter length weight, mcolor(red)),  ///
			name(panel8, replace)
	
	
	Xeq twoway  ///
		(scatter price weight, mcolor(green))  ///
		(lfit  price weight, lcolor(green)),  ///
			name(panel9, replace)
	
	Xeq twoway  ///  This is the dummy graph from which we take the legend
		(scatter mpg weight, mcolor(blue))  ///
		(scatter length weight, mcolor(red))  ///
		(scatter price weight, mcolor(green))  ///
		(lfit  price weight, lcolor(green)),  ///
			name(panel10, replace)
			
	Xeq set graph on
	
	Xeq grc1leg2 panel7 panel8 panel9 panel10,  ///
		title("Assemble the legend keys from different panels"  "to construct the combined legend")  ///
		xtob1title legendfrom(panel10) hidelegendfrom  ///
		pos(4) ring(0) lxoffset(-10) lyoffset(15) lcols(1)  ///
		name(grc1hide, replace)

end 

 
*	Version 1.0.0 by Mead Over 1Apr2016
*		Based on Stata's gr_example2.ado, version 1.4.4  27aug2014
*	V. 1.0.1 11Apr2016: Adds the program -grc13lsize-
*	V. 1.0.2 23Jan2021: Renames it -grc13labsize-, adds -set graph on- commands
*	V. 1.1	29Jan2021: Add the options xtsize, ytsize, mtsize and Example 3.6 (grc14) 
*	V. 1.2	23Mar2021: Add the options xtsize, ytsize, mtsize and Example 3.6 (grc14)
*	V. 1.3	26Mar2021: Add the program -grc1y2tor1- to demonstrate reloaction of the y2-axis 
*	V. 1.5	4Apr2021: Demonstrate the option -lcols(1)- in -grc1hide-

