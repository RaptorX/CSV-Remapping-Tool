/*
	Author           : RaptorX <graptorx@gmail.com>
	Homepage         :
	Creation Date    : October 30, 2016
	Modification Date: April 25, 2017

    Function: mapCSV
    Re-maps all the data in a CSV file to match new headers provided by the user

    Very good for situations in which you have to migrate data from one app to another one, both of which
    can work with CSV data but have different data order or header names.

    The *map* parameter is where you specify what to do with the original headers.
	You can ommit a field you must set it to blank or zero manually in this parameter.

    Known Limitations:
    The original headers must not contain a field named "0" since that is a keyword for not mapping a column.

    Parameters:
    mapCSV(srcCSVFile, map,tgtHeaders)

    srcCSVFile		-	Path to the CSV file that will be converted
    map				-	Definition of how you are going to map the original information.

						valid maps in the *map* parameter would be:

						header names: "name,date,order number"
						column numbers: "12,6,1"
						blanks: "name,,,date,order number,location"
						zeroes: "name,0,0,date"
						mixed: name,,date,0,location"
    tgtHeaders		-	Headers to use on the new file. this should be a valid comma separated CSV line
						ex. field1,field with spaces,"field,that,contain,commas,must,be,quoted",field3

    Returns:
    mappedCSV		-	Resulting CSV that can be saved to a file or stored in a variable

    Examples:
    (Start Code)

    ; Assuming the source file has the following headers:
    ; Name,Phone,Client Type,Location,City,Order Date,Order Total
    ;
    ; And we want to map it to our bank app which uses the following headers:
    ; Date,Payee,Category,Memo,Outflow,Inflow

	; Then we call our function like this:
	; Note the blank fields on the map params. This is because we dont really need to map that data.
    msgbox % mapCSV(a_desktop "\example.csv", "Order Date,Name,,,,Order Total", "Date,Payee,Category,Memo,Outflow,Inflow")

	; The Original data was:
    ; Name,Phone,Client Type,Location,City,Order Date,Order Total
    ; Maria Gonzales,555-555-5555,Retail,USA,Miami,20160503,200
    ; Jack Summers,333-333-3333,Wholesale,China,Guang Zu,20160504,1250
    ;
    ; The function result is this:
    ; Date,Payee,Category,Memo,Outflow,Inflow
    ; 20160503,Maria Gonzales,,,,200
    ; 20160504,Jack Summers,,,,1250


    (End)

*/

mapCSV(srcCSVFile, orgHeaders,tgtHeaders) {

	map := strSplit(orgHeaders, "`,")
	mappedCSV := tgtHeaders "`n"

	try {

		FileReadLine, srcHeaders, %srcCSVFile%, 1

	} catch e {

		; there was an error reading the file
		return e.Message

	}

	/*
		Convert the map values from text to their column numbers.

		This is done by first verifying that the value of the key
		is not numeric which implies that they are already column numbers.

		The script parses the source headers and matches the current value against the
		parsing position (which is basically the current column).

		When a match occurs we set the current key to the a_index effectively "converting" a column name
		to its column number counter part and put it in our map.
	*/

	for k,value in map
	{

		if (RegexMatch(value, "^\d+$")) ; if is already a number then we leave it as is
			continue
		else if (value == "")
			map[k] := 0 ; if we dont have any value, set it to zero to signal the next process to leave this field empty
		else
		{

			Loop, Parse, srcHeaders, CSV
			{

				if (value && value == a_loopfield)
				{
					map[k] := a_index
					break
				}

			}

		}

	}

	Loop, Read, %srcCSVFile%
	{
		if (a_index == 1)
			continue

		map_index := 0, line := ""
		Loop, Parse, tgtHeaders, CSV
		{

			map_index++

			value := "", fieldCount := 0
			inString := ignore_line := quote := false

			Loop, Parse, A_LoopReadLine, CSV
			{

				if (!map[map_index]) { ; The data from this column must be ignored

					line .= ","
					break

				} else if (map[map_index] == a_index)
					line .= """" a_loopfield """" ","

			}

		} mappedCSV .= regexReplace(line, ",$", "`n")

	}

	return mappedCSV

}