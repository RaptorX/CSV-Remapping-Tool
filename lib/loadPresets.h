LoadPresets(file) {

	presets := "", pos := 1

	IniRead, SECTION, %file%, PRESETS

	while pos := regexMatch(SECTION, "m`n)^(.*?)\s?=.*?$", match,pos + (strLen(match)))
		presets .= match1 "|"


	return regexReplace("||" presets, "\|$")
}