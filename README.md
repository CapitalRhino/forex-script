# forex-script
Simple PowerShell script which scrapes historical Yahoo Finance data for defined symbols. A version for PowerShell v7 is also avaliable, because in previous versions the method for cleaning CSV data from quotes is really dumb. Fortunately, the new PowerShell has a built-in way of removing excess quotes.

Syntax: ./script.ps1 -inputFile (inputFile) -outputFile (outputFile) -downloadDirectory (downloadDirectory) -dayCount (dayCount)

## Flags
inputFile - path to input file, defaults to "inputfile.csv" in the executing directory

outputFile - path to output file, defaults to "export.csv" in the executing directory

downloadDirectory - path to a temporary folder, **deleted recursively on execution**, defaults to "download" in the executing directory

dayCount - get data for this amount of days, defaults to 1
