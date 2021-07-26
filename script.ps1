<#
    Forex Scraping Script
    
#>

<# parameter definition #>
param ($inputFile, $outputFile, $dayCount)

<# paramater validation #>
if (!(Test-Path -Path inputfile.csv -PathType Leaf) -and ($inputFile -eq $null)) {
    Throw [string]"Input CSV file required for execution."
}
if (Test-Path -Path inputfile.csv -PathType Leaf) {
    $inputFile = (Get-Item inputfile.csv)
}
if ($dayCount -eq $null) {
    $dayCount = read-host -Prompt "Please enter a number of days" 
}

<# UNIX time converter #>
$today = [DateTime](Get-Date).Date
$epoch = [DateTime](Get-Date 01.01.1970)
$startDay = [DateTime](Get-Date).AddDays(-$dayCount).Date
$period2 = [int]($today - $epoch).TotalSeconds
$period1 = [int]($startDay - $epoch).TotalSeconds

<# parse input CSV and scrape Yahoo Finance  #>
$data = Import-Csv $inputFile
ForEach ($forex in $data) {
    $baseCurrency = $($forex.from)
    $counterCurrency = $($forex.to)
    $forexID = $($forex.forex_id)
    $url = [System.Text.StringBuilder]::new()
    $url.Append("https://query1.finance.yahoo.com/v7/finance/download/")
    $url.Append($baseCurrency)
    $url.Append($counterCurrency)
    $url.Append("=X?period1=")
    $url.Append($period1)
    $url.Append("&period2=")
    $url.Append($period2)
    $url.Append("&interval=1d&events=history&includeAdjustedClose=true")
    Write-Host $url
    Invoke-WebRequest $url.ToString()
}

<# TODO: save CSV file 
New-Item -Path $outputFile -ItemType File
#>