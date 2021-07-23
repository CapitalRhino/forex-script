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

<# TODO: parse config CSV #>
$data = Import-Csv $inputFile

<# UNIX time converter #>
$today = [DateTime](Get-Date).Date
$epoch = [DateTime](Get-Date 01.01.1970)
$startDay = [DateTime](Get-Date).AddDays(-$dayCount).Date
$period2 = [int]($today - $epoch).TotalSeconds
$period1 = [int]($startDay - $epoch).TotalSeconds

Write-Host $period1
Write-Host $period2
<# TODO: scrape Yahoo Finance logic #>
foreach ($row in $data) {
    $url = [System.Text.StringBuilder]::new()
    $url.Append("https://query1.finance.yahoo.com/v7/finance/download/EURUSD=X?period1=")
    $url.Append($period1)
    $url.Append("&period2=")
    $url.Append($period2)
    $url.Append("&interval=1d&events=history&includeAdjustedClose=true")
    Invoke-WebRequest $url.ToString()
}

<# Invoke-WebRequest  

<# TODO: save CSV file 
New-Item -Path $outputFile -ItemType File
#>