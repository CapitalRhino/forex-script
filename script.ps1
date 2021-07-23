<#
    Forex Scraping Script
    
#>

<# parameter definition #>
param ($inputFile, $outputFile, $dayCount)

<# paramater validation #>
if (!(Test-Path -Path inputfile.csv -PathType Leaf) -and ($configFile -eq $null)) {
    Throw [string]"Input CSV file required for execution."
}
if ($dayCount -eq $null) {
    $dayCount = read-host -Prompt "Please enter a number of days" 
}

<# TODO: parse config CSV #>
$data = Import-Csv $inputFile


<# TODO: scrape Yahoo Finance logic #>
Invoke-WebRequest 
<# https://query1.finance.yahoo.com/v7/finance/download/EURUSD=X?period1=1595498034&period2=1627034034&interval=1d&events=history&includeAdjustedClose=true #>

<# TODO: save CSV file #>
New-Item -Path $outputFile -ItemType File