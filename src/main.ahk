/*
 * =============================================================================================== *
 * Author           : Isaias Baez  (RaptorX) <graptorx@gmail.com>
 * Script Name      : CSV Remapping Tool
 * Script Version   : 0.0.1-161020
 * Homepage         : -
 *
 * Creation Date    : April 29, 2017
 * Modification Date: April 29, 2017
 *
 * Description      :
 * ------------------
 * This small tool allows you to take one or more CSV files that contain data that you need but
 * that has more heathers than what you want to use, or the
 * headers are not ordered the way that you need it.
 *
 * Simply select the files that you want to remap, set a list of custom heathers that you want to use
 * and map the existing heathers to the custom ones. Let the program do the rest.
 * -----------------------------------------------------------------------------------------------
 * License          :       Copyright ©2016 Isaias Baez (RaptorX) <GPLv3>
 *
 *          This program is free software: you can redistribute it and/or modify
 *          it under the terms of the GNU General Public License as published by
 *          the Free Software Foundation, either version 3 of  the  License,  or
 *          (at your option) any later version.
 *
 *          This program is distributed in the hope that it will be useful,
 *          but WITHOUT ANY WARRANTY; without even the implied warranty  of
 *          MERCHANTABILITY or FITNESS FOR A PARTICULAR  PURPOSE.  See  the
 *          GNU General Public License for more details.
 *
 *          You should have received a copy of the GNU General Public License
 *          along with this program.  If not, see <http://www.gnu.org/licenses/gpl-3.0.txt>
 * =============================================================================================== *
 */

;[Includes]{
#include *i ..\
#include includes\libraries.h
;}

;[Directives]{
#noEnv
#singleInstance force
; --
setBatchLines, -1
sendMode, input
setWorkingDir, %a_scriptdir%
onExit, exit
;}

;[General Variables]{
null        := ""
sec         := 1000						; 1 second
min         := 60*sec					; 1 minute
hour        := 60*min					; 1 hour

cfgFile     := "config.ini"
;}

;[Main]{

	gui add, groupbox, section w365, Original File
	gui add, edit, xp+10 yp+20 w260 vorigFile
	gui add, button, x+10 yp w75 gBROWSE, &Browse...

	gui add, groupbox, xs y+20 w365 h85, Target Headers
	gui add, text, xp+10 yp+23 w45 right, Preset:
	gui add, combobox, x+10 yp-3 w120 gLOADPRESET vpresetKey, % LoadPresets(cfgFile)
	gui add, button, x+10 yp w75 gSAVEPRESET, Save
	gui add, button, x+10 yp w75 gDELETEPRESET, Delete
	gui add, text, xs+10 y+13 w45 right, Headers:
	gui add, edit, x+10 yp-3 w290 vtgtHeaders
	;gui add, text, y+10 w290
	;			 , % "You can save a new preset by writting a custom "
	;			 . "name in the preset name box, typing the headers and "
	;			 . "then hitting ""Save"".`n`n"
	;			 . "Type the target headers or select a saved preset.`n`n"
	;			 . "You can paste CSV or TSV here and they will be "
	;			 . "properly formated."

	gui add, button, % "xs+" 365 - (75+75+10+10) " w75 gREMAP", Remap
	gui add, button, % "x+10 yp w75 gGUIESCAPE", Exit
	gui show

return                      ; [End of Auto-Execute area]
;}

;[Labels]{

BROWSE:
	fileSelectFile, orgCSVFile,,,, CSV Files (*.csv;*.txt)

	if (!orgCSVFile)
		msgbox 0x40010, Error, No file was selected.
	else {

		guiControl,, origFile, %orgCSVFile%
		fileReadLine, orgHeaders, %orgCSVFile%, 1

	}
	return

LOADPRESET:
	gui, submit, nohide

	if (!presetKey) {

		guiControl,, tgtHeaders
		return

	}

	iniRead, PRESET, %cfgFile%, PRESETS, %presetKey%

	if (PRESET != "ERROR")
		guiControl,, tgtHeaders, %PRESET%

	return

SAVEPRESET:
	gui, submit, nohide

	if (!presetKey)
		msgbox 0x40010, Error, No name for the preset was set.
	else if (!tgtHeaders)
		msgbox 0x40010, Error, No target headers were specified.
	else{

		iniWrite, % regexReplace(tgtHeaders, "(\s?,\s?|\t)", ","), %cfgFile%, PRESETS, %presetKey%
		guiControl,, tgtHeaders
		guiControl,, presetKey, % LoadPresets(cfgFile)

		MsgBox 0x40, Success, The preset was saved successfuly!

	}

	return

DELETEPRESET:
	gui, submit, nohide

	iniDelete, %cfgFile%, PRESETS, %presetKey%
	guiControl,, tgtHeaders
	guiControl,, presetKey, % LoadPresets(cfgFile)

	MsgBox 0x40, Success, The preset was deleted successfuly!
	return

REMAP:
	gui, submit, nohide

	gui, Remap:new, +Delimiter`,
	
	/*
	
		Find the biggest Header and use its size for all others
		
	*/	hdrSize := ""
	
	Loop, parse, tgtHeaders, CSV
	{
		hdrCount := a_index
		hdrSize := (strLen(a_loopfield) > hdrSize ? strLen(a_loopfield) : hdrSize)
	}
	
	hdrSize += 175 ; allocate 175px
	hdrHeight := 20
	
	Loop, parse, tgtHeaders, CSV
	{
		
		if (a_index == 1) {

			gui, Remap:add, text, xm ym+10 w%hdrSize% h%hdrHeight% border right section, % a_loopfield ":"
			gui, Remap:add, dropdownlist, x+10 yp-3 choose1 hwnd_ddl%a_index%, % "Ignore," orgHeaders

		} else if (mod(a_index, hdrCount > 50 ? 25 : 10) == 1) {

			gui, Remap:add, text, x+10 ym+10 w%hdrSize% h%hdrHeight% border right section, % a_loopfield ":"
			gui, Remap:add, dropdownlist, x+10 yp-3 choose1 hwnd_ddl%a_index%, % "Ignore," orgHeaders

		} else {

			gui, Remap:add, text, xs w%hdrSize% h%hdrHeight% border right section, % a_loopfield ":"
			gui, Remap:add, dropdownlist, x+10 yp-3 choose1 hwnd_ddl%a_index%, % "Ignore," orgHeaders

		}

	}

	gui, Remap:add, button, xp-39 y+30 w75 gMAPPREVIEW vmapPreview, Preview ; position minus half of 75 (rounded)
	gui, Remap:add, button, x+10 w75 gMAPSAVE vmapSave, Save
	gui, Remap:show

	return

MAPPREVIEW:
MAPSAVE:
	oldHeaders := ""
	Loop, parse, tgtHeaders, CSV
	{
		control := "_ddl" a_index
		guicontrolget, field,, % %control%
		
		if (field = "ignore")
			field := ""

		oldHeaders .= field ","
	} oldHeaders := regexReplace(oldHeaders, "`,$")

	clipboard := mappedCSV := mapCSV(orgCSVFile, oldHeaders, tgtHeaders)
	
	gui, Preview:new
	gui, Preview:add, listview, vpreviewList w500 r20 grid, % regexReplace(tgtHeaders, "`,", "|")
	
	loop, parse, mappedCSV, `n, `r 
	{
		row := a_index
		lv_add("", "")
		
		loop, parse, a_loopfield, CSV
			lv_modify(row, "col" a_index, a_loopfield)

	}
	
	lv_delete(1)
	lv_modifycol()
	lv_modifycol(0, "AutoHdr")
	
	gui, Preview:show
	
	if (a_guicontrol == "mapSave")
	{
		fileSelectFile, newCSVFile, S24,,, CSV Files (*.csv)

		if (!newCSVFile)
			msgbox 0x40010, Error, No file was selected or created.
		else
			fileAppend, %mappedCSV%, % newCSVFile (inStr(newCSVFile, ".csv") ? "" : ".csv"), UTF-8
		
		gui, Preview:submit
	}
	return

GUISIZE:        ;{ Gui Size Handler
	return

;}

GUICLOSE:
GUIESCAPE:
EXIT:
    ExitApp
;}