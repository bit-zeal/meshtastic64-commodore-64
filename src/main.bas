#lowercase
#linestep 10
#lineskip 10
header:
    rem *******************************
    rem meshtastic 64 for the
	rem commodore 64
	rem 
    rem version 1.1
	rem original sept 13th, 2025 @ vcfmw
	rem 
	rem copyright (c) 2026 bit zeal llc
    rem all rights reserved
    rem proprietary software - see
    rem license.md for terms of use
	rem 
	rem by jim happel / jimR64
	rem *******************************
	:
	:


initialize:
#lineskip 500
	rem **initialize**
    open 2,2,3,chr$(7):rem was 8 for 1200 baud, 7 for 600 baud
    gosub initComputer  : rem init computer
    gosub listHelp : rem list help
    :
    :


mainLoop:
#lineskip 500
    rem **main loop**
    gosub LEDblinking : rem led routine
    gosub readSerialInputAndConvertToPetscii : rem read serial input
    gosub printPetsciiArt : rem print petscii
    gosub printIncommingMessage : rem print input
    gosub readKeyboard : rem read keyboard
    goto  checkForPetsciiEdit  : rem check for petscii edit
    goto  mainLoop
    :
    :


LEDblinking:
#lineskip 500
    rem ***led blinking***
    poke 56579, 126 : poke 56577, ld(lc)
    lc = lc + li
    if lc=ld then li=-1
    if lc=0 then li=+1
    return
    :
    :


dingSound:
#lineskip 500
    rem ***ding sound for new message***
    if ss = 0 then return : rem sound off
    poke 54296,15 : rem volume max
    poke 54277,9 : rem attack=0, decay=9
    poke 54278,9 : rem sustain=0, release=9
    poke 54273,28 : poke 54272,214 : rem frequency ~1000Hz
    poke 54276,17 : rem triangle + gate on (starts sound)
    poke 54276,16 : rem gate off (starts release fade)
    for ds = 1 to 250 : next : rem let release fade
    poke 54296,0 : rem volume off (silences cartridge noise)
    return
    :
    :


initComputer:
#lineskip 500
	rem **init computer**
	dim og$(6) : dim ic$(6) : dim ld(6) : dim ps$(9) : dim ps(9)
	ss = 0 : rem sound state (1=on, 0=off)
	poke 53280,11 : poke 53281,00 : print"{clear}{lightgreen}"chr$(142);
	for i = 1 to 40*6 : print chr$(205.5+rnd(1)); : next
	print"{down}{down}NNMeshtNMstNc 64" : ?"{14 down}version: 1.1"
	initComputerKeyWait:
	get a$ : if a$ = "" then initComputerKeyWait
	poke 53280,12 : poke 53281,00
	print"{clear}"chr$(14);
	gosub redrawInputBox : rem draw input box
	rem led light show setup
	ld(0) = 064 : rem x100000x
	ld(1) = 032 : rem x010000x
	ld(2) = 016 : rem x001000x
	ld(3) = 008 : rem x000100x
	ld(4) = 004 : rem x000010x
	ld(5) = 002 : rem x000001x
	ld = 5 : rem number of LED light steps
	return
	:
	:


checkForPetsciiEdit:
#lineskip 500
	rem ***check for petscii edit ***
	if ep = 0 then mainloop
	goto petsciiEditor
	:
	:


convertINstingToMSstringAndStore:
#lineskip 500
	rem **convert in$ to ms$ and store**
	ms$ = in$
	if len(ms$) < 7 then ms$ = ms$ + "{7 space}"
	ms$ = left$(ms$,4) + "{rvof} {grey}" + right$(ms$,len(ms$)-6)
	ms$ = "{lightgreen}{rvon}" + ms$
	bc = 0 : in$ = "" : rem reset for next message
	im$(im) = ms$ : im = im + 1  
	return
	:
	:


printIncommingMessage:
#lineskip 500
	rem ***prnt income msg to scrn***
	if pp = 1 then return
	if im = 0 then return : rem none
	ms$ = im$(0) : im = im - 1 : rem ms$ = im$(im-1) : im = im - 1
	gosub dingSound : rem ding on new message
	for i = 0 to (im-1)
	im$(i) = im$(i+1)
	next
	gosub updateScreen : rem print ms$
	gosub reprintInputString
	return
	:
	:


readSerialInputAndConvertToPetscii:
#lineskip 500
	rem ***read serial input and convert to petscii***
	get#2, rb$ : rem get read byte
	if rb$ = "" then return : rem ignore null values
#	rem if ej = 1 or asc(rb$)=226 or asc(rb$)=240 then processEmoji : rem emoji
#	rem if (ic = 1) or (bc = 0 and rb$ = chr$(27)) then incommingCommands : rem commands
	if bc = 0 and (rb$ = chr$(13) or rb$ = chr$(10)) then return : rem skip
	rem if rb$ = chr$(10) then goto convertINstingToMSstringAndStore : rem process input and prep print
	rem readSerialColonHandling:
	rem if rb$ = ":" and bc < 4 then in$ = " " + in$ : bc = bc + 1 : goto readSerialColonHandling
	if bc = 6 and rb$ = chr$(27) then ic = 1
	if ic = 1 and rb$ = chr$(96) then in$ = in$ + chr$(96) : goto convertINstingToMSstringAndStore
	if ic = 1 then nc$ = rb$ : goto readSerialFinish
	if rb$ = chr$(10) then goto convertINstingToMSstringAndStore : rem process input and prep print
	readSerialColonHandling:
	if rb$ = ":" and bc < 4 then in$ = " " + in$ : bc = bc + 1 : goto readSerialColonHandling
	rem *convert to petscii*
	nc$ = ""
	if rb$ = chr$(13) then nc$ = ""
	if rb$ = chr$(226) then nc$ = "'"
	a = asc(rb$)
	if a > 31 and a < 127 then nc$ = rb$
	if a > 64 and a <  91 then nc$ = chr$(a+128)
	if a > 96 and a < 123 then nc$ = chr$(a-32)
	if rb$ = chr$(34) then nc$ = "''"
	readSerialFinish:
	in$ = in$ + nc$ : bc = bc + 1
	return
	:
	:
#
#
#processEmoji:
#	rem **process emoji**
#	return
#	ej$ = ej$ + rb$ : ej = 1
#	ifej$ = eu$$(240)+chr$(159)+chr$(145)+chr$(141) then in$
#	:
#	:


readKeyboard:
#lineskip 500
	rem **read keyboard**
	if pp = 1 then return
	if ep = 1 then return
	get a$ : if a$ = "" then return
	if a$ = chr$(13) and og$<>"" then gosub sendSerialMessage :og$="" :gosub redrawInputBox:return
	if a$ = chr$(20) then gosub deleteKey : return
	if a$ = chr$(34) then a$="'"
	if asc(a$) < 032 or asc(a$) > 218 then return
	if asc(a$) > 095 and asc(a$) < 193 then return
	og$ = og$ + a$ : og$ = left$(og$,79)
	gosub reprintInputString
	return
	:
	:

reprintInputString:
#lineskip 500
	rem **reprint input string**
	print"{home}{lightblue}{rvon}{23 down}";og$;
	return
	:
	:


deleteKey:
#lineskip 500
	rem *delete key*
	if og$="" then return
	og$ = left$(og$,len(og$)-1)
	gosub redrawInputBox : gosub reprintInputString
	return
	:
	:


sendSerialMessage:
#lineskip 500
	rem *send serial message*
	gosub redrawInputBox : rem clean box to give input to user
	if left$(og$,1) = "/" then goto parseCommands
	ms$ = "" : nc$ = ""
	for i = 1 to len(og$)
		a$ = mid$(og$,i,1)
		a = asc(a$)
		if a = 13 then nc$ = a$
		if a >  31 and a < 127 then nc$ = a$
		if a >  64 and a <  91 then nc$ = chr$(a + 032)
		if a > 192 and a < 219 then nc$ = chr$(a - 128)
		ms$ = ms$ + nc$
		nc$ = ""
	next i
	print#2, ms$;
	ms$ = "{rvof}{5 space}{lightblue}{rvof}" + og$
	goto updateScreen : rem print to screen
	return
	:
	:


redrawInputBox:
#lineskip 500
    rem *redraw input box*
    print"{home}{lightblue}{23 down}{rvon}{38 space}";
    print"{41 space}";
    poke 2023,160 : poke 56295,14
    return
    :
    :

updateScreen:
#lineskip 500
    rem *update screen*
    for i = 1 to 2 : poke 781,22+i : sys59903 : next i : rem erase input area
    for i = 1 to 7 : poke 216+i,132 :next i : rem unlink top lines b4 scroll
    if right$(in$,1) = chr$(13) then ms$ = left$(ms$,len(ms$)-1)
#   if len(ms$) > 40 then ms$=ms$+"{4 down}"
#   if len(ms$) < 40 then ms$=ms$+"{4 down}"
	ms$=ms$+"{4 down}"
    if len(ms$) > 251 then ms$=left(ms$,251) + "{4 down}"
    print"{home}{21 down}{grey}{rvof}";ms$;
    gosub redrawInputBox
    return
    :
    :
#
#
#incommingCommands:
##lineskip 500
#   rem *incmg commds (petscii art)*
#   print"{home}{4 down}incomming commands"
#   ic = 1
#   if rb$ = chr$(10) goto 37050
#	ic$ = ic$ + rb$
#	return
#   :
#	:
#
#
#endOfCommand:
#lineskip 500
#37050 :
#	rem *end of command*
#	im$(im) = ic$ : im = im + 1
#	ic$ = "" : ic = 0
#	return
#    :
#    :


printPetsciiArt:
#lineskip 500
    rem ***print petscii art***
    if im = 0 then return :rem no msg
    rem if im$="" then return :rem no msg
    if pp = 1 then goto printPetsciiArtNext
    if asc(mid$(im$(im-1),10,1)) <> 27 then return
    if mid$(im$(im-1),11,1) = "p" then pp = 1
	printPetsciiArtNext:
    if dp = 1 then endPetsciiView
    ms$="received petscii art - press f1 to view{up}" : gosub updateScreen
    get a$ : if a$ <> "{f1}" then return
    print"{clear}"+chr$(142)
    dp = 1
    xc=asc(mid$(im$(im-1),12,1)) : yc=asc(mid$(im$(im-1),13,1))
    pc = 14 : xo = int((40-xc)/2) : yo = int((25-yc)/2)
    for y = 0 to yc-1
		for x = 0 to xc-1
    		poke 1024+x+xo+(y+yo)*40,asc(mid$(im$(im-1),pc,1))
    		pc = pc + 1
    	next x
    next y
    for y = 0 to yc-1
		for x = 0 to xc-1
    		poke 55296+x+xo+(y+yo)*40,asc(mid$(im$(im-1),pc,1))
    		pc = pc + 1
    	next x
    next y
    return
    :
	:


endPetsciiView:
#lineskip 500
	rem *end petscii view*
	get a$ : if a$ = "" then return
	print"{home}{23 down}{grey} press # to store in slot or f7 to end"
	if a$<>"{f7}" and (asc(a$)< 48 or asc(a$) > 57) then return
	if a$ = "{f7}" then ms$ = "" : goto endPetsciiViewExit
	sl = asc(a$)-48
	ps$(sl) = right$(im$(im-1),len(im$(im-1))-9)
	ps(sl) = 1
	ms$ = "<petscii: stored slot"+str$(sl)+">"
	endPetsciiViewExit:
	rem *clean up and end*
	pp = 0 : dp = 0 : a$="" : ic = 0
	im = im - 1
	for i = 0 to (im-1)
		im$(i) = im$(i+1)
	next
	print "{clear}" + chr$(14) : rem clear and lower case
	gosub redrawInputBox : rem redraw input
	gosub updateScreen
	return
	:
	:


parseCommands:
#lineskip 500
	rem *parse commands*
	ms$ = "<command unrecognized error, /? for help>"
	sc$ = og$
	if og$ = "/p edit" then ep = 1 : return : rem gosub petsciiEditor
	if len(og$) > 7 and left$(og$,7) = "/p edit" then ea=99 : ep = 1 : return : rem gosub petsciiEditor
	if len(og$) > 9 and left$(og$,8) = "/p clear" then gosub clearPetsciiSlot
	if len(og$) > 8 and left$(og$,7) = "/p send" then gosub sendPetsciiArt
	if len(og$) > 8 and left$(og$,7) = "/p save" then gosub savePetsciiArtToDisk
	if len(og$) > 8 and left$(og$,7) = "/p load" then gosub loadPetsciiArtFromDisk
	if og$ = "/?" then gosub listHelp
	if og$ = "/s on" then ss = 1 : ms$ = "<sound: on>"
	if og$ = "/s off" then ss = 0 : ms$ = "<sound: off>"
	print chr$(14); : gosub redrawInputBox : rem lower case and redraw
	goto updateScreen : rem print ms$ to screen
	return
	:
	:


petsciiEditor:
#lineskip 500
	rem *petcii editor*
	print"{clear}{rvof}"+chr$(142);
	print"x{down}"+chr$(109)+"{down}draw image at top left"
	print"{home}{13 down}below, change x,y to image size, sl to"
	print"slot, and press return to read art and"
	print"store in slot. use sl=99 for no slot."
	print"x*y must be less than 98!"
	print"{down}{white}x=01 : y=01 : sl=01 : goto 50000{lightblue}"
	print"{3 down}"; : for i=1to8 : print"{rvof} sl";right$(str$(i),1);
	i$=":open " : if ps(i)=1 then i$=":{rvon}used{rvof} "
	printi$; : next
	print"{7 up}{grey}"
	ep = 0 : rem turn off Edit Petscii mode
	if ea <> 0 then gosub petsciiEditDrawingExisting
	stop
	return
	:
	:


clearPetsciiSlot:
#lineskip 500
	rem *clear petscii art slot*
	sl = asc(right$(og$,1)) - 48
	ms$ = "<pescii: clear slot failed>"
	if sl < 0 or sl > 9 then return
	ps(sl) = 0
	ms$ = "<petscii: cleared slot"+str$(sl)+">"
	return
	:
	:


sendPetsciiArt:
#lineskip 500
	rem *send petscii art*
	sl = asc(right$(og$,1)) - 48
	ms$ = "<pescii: send slot failed>"
	if sl < 0 or sl > 9 then return
	if ps(sl) = 0 then ms$ = "<petcii art: send error - empty slot>" : return
	print#2,ps$(sl);
	ms$ = "<petscii: sent slot"+str$(sl)+">"
	return
	:
	:


petsciiEditDrawingExisting:
#lineskip 500
	rem *petscii edit draw existng*
	ea = asc(right$(sc$,1)) - 48
	if ea < 0 or ea > 9 then return
	if ps(ea) = 0 then return
	for i = 0 to 2 : poke 781,i : sys 59903 : next i : rem erase input area
	dp = 1
	xc=asc(mid$(ps$(ea),3,1)) : yc=asc(mid$(ps$(ea),4,1))
	pc = 5
	for y = 0 to yc-1
		for x = 0 to xc-1
			poke 1024+x+y*40,asc(mid$(ps$(ea),pc,1))
			pc = pc + 1
		next x
	next y
	for y = 0 to yc-1
		for x = 0 to xc-1
			poke 55296+x+y*40,asc(mid$(ps$(ea),pc,1))
			pc = pc + 1
		next x
	next y
	print"{home}{white}{18 down}x=";str$(xc);"{2 space}: y=";str$(yc);"{2 space}: ";
	print"sl=";str$(ea);" : goto 50000{up}{grey}"
	return
	:
	:


savePetsciiArtToDisk:
#lineskip 500
	rem *save petcsii art to disk*
	ms$ = "<petscii art: save error - bad slot or filename>"
	if len(og$) <  11 then return
	sl = asc(mid$(og$,9,1)) - 48
	fl$ = right$(og$,len(og$)-10)
	if sl < 0 or sl > 9 or fl$ = "" then return
	open 8,8,8,"@0:"+fl$+",s,w"
	print#8, ps$(sl)
	close 8
	ms$ = "<petscii: saved slot"+str$(sl)+" to file "+fl$+">"
	return
	:
	:


loadPetsciiArtFromDisk:
#lineskip 500
	rem *load petcsii art from disk*
	ms$ = "<petscii: load error - bad slot or{6 space}filename>"
	if len(og$) < 11 then return
	sl = asc(mid$(og$,9,1)) - 48
	fl$ = right$(og$,len(og$)-10)
	if sl < 0 or sl > 9 or fl$ = "" then return
	ps$(sl) = "" : ps(sl) = 0
	open 8,8,8,"0:"+fl$+",s,r"
	loadPetsciiArtFromDiskNextByte:
	get#8, a$ : if st = 64 then loadPetsciiArtFromDiskEnd
	if st = 66 then close 8 : return
	if a$ = "" then loadPetsciiArtFromDiskNextByte
	ps$(sl) = ps$(sl) + a$ : goto loadPetsciiArtFromDiskNextByte
	loadPetsciiArtFromDiskEnd:
	close 8
	ps(sl) = 1
	ms$ = "<petscii: loaded slot"+str$(sl)+" from file "+fl$+">"
	return
	:
	:
	

petsciiScreenReader:
	# This needs to be at line 50000 due to jump text in PETSCII screen editting screen
	50000 rem *petscii screen reader*
	if x*y>97 then print"{up}"; : stop
	if sl > 9 then goto petsciiScreenReaderExit
	ps$(sl)=chr$(27)+"p"+chr$(x)+chr$(y)
	pc = 5 : xc=x : yc=y
	poke 53280,1
	for y = 0 to yc-1
		for x = 0 to xc-1
			i = peek(1024+x+y*40)
			if i = 96 then i = 32
			ps$(sl)=ps$(sl)+chr$(i)
			pc = pc + 1
		next x
		poke 53280,y+2
	next y
	for y = 0 to yc-1
		for x = 0 to xc-1
			i = peek(55296+x+y*40) and 15
			ps$(sl)=ps$(sl)+chr$(i)
			pc = pc + 1
		next x
		poke 53280,y+1
	next y
	ps$(sl) = ps$(sl) + chr$(96) : rem add end of petscii marker
	petsciiScreenReaderExit:
	ea = 0 : if sl < 10 then ps(sl)=1
	print"{clear}" : poke 53280,11
	ms$ = "<petscii: stored slot"+str$(sl)+">"
	if sl > 9 then ms$ = "<petscii: storage error - invalid slot>"
	print chr$(14) : rem lower case
	gosub updateScreen
	goto mainLoop
	:
	:


listHelp:
#lineskip 500
    rem *list commands*
    ms$ = "** meshtastic 64 **" : gosub updateScreen
    ms$ = "text<return> [send text over primary]" : gosub updateScreen
    ms$ = "/? {rvon}[help]" : gosub updateScreen
    ms$ = "/p edit {rvon}[petscii edit from blank]" : gosub updateScreen
    ms$ = "/p edit n {rvon}[petscii edit with slot n]" : gosub updateScreen
    ms$ = "/p send n {rvon}[petscii send slot n]" : gosub updateScreen
    ms$ = "/p clear n {rvon}[petscii clear slot n]" : gosub updateScreen
    ms$ = "/p save n filename {rvon}[petscii save disk]" : gosub updateScreen
    ms$ = "/p load n filename {rvon}[petscii load disk]" : gosub updateScreen
    ms$ = "/s on {rvon}[sound on]" : gosub updateScreen
    ms$ = "/s off {rvon}[sound off]" : gosub updateScreen
    ms$ = "  " : gosub updateScreen
    ms$ = ""
    return