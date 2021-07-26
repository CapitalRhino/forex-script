# forex-script
Simple PowerShell script which scrapes historical Yahoo Finance data for defined symbols

Syntax: ./script.ps1 -inputFile (inputFile) -outputFile (outputFile) -dayCount (dayCount)

## Flags
inputFile - path to input file, defaults to inputfile.csv in the executing directory

outputFile - path to output file, defaults to export.csv in the executing directory

dayCount - get data for this amount of days, if not given the script promts the user
