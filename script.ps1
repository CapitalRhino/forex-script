<#
    Forex Scraping Script
    (using Yahoo Finance CSV endpoint API v7)
#>

<# parameter definition #>
param ($inputFile, $outputFile, $dayCount)

<# paramater validation #>
if (!(Test-Path -Path inputfile.csv -PathType Leaf) -and ($inputFile -eq $null)) {
    Throw [string]"Input CSV file required for execution."
}
if (!(Test-Path -Path inputfile.csv -PathType Leaf)) {
    $inputFile = (Get-Item inputfile.csv)
}
if ($outputFile -eq $null) {
    $outputFile = "export.csv"
}
if ($dayCount -eq $null) {
    $dayCount = 1
}

<# clear existing $outputFile #>
if ((Test-Path $outputFile) -eq $true) {
  Remove-Item $outputFile
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
    <# CSV input fields #>
    $symbol = "$($forex.from)$($forex.to)"
    $forexID = $($forex.forex_id)

    <# URL building #>
    $url = [System.Text.StringBuilder]::new()
    [void]$url.Append('https://query1.finance.yahoo.com/v7/finance/download/')
    [void]$url.Append($symbol)
    [void]$url.Append('=X?period1=')
    [void]$url.Append($period1)
    [void]$url.Append('&period2=')
    [void]$url.Append($period2)
    [void]$url.Append('&interval=1d&events=history&includeAdjustedClose=true')

    $downloadURL = [uri]($url.ToString())
    $localURL = "$(Split-Path $MyInvocation.MyCommand.Path)\$($downloadURL.segments[-1])"

    <# API connection #>
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile($downloadURL, $localURL)

    <# import downloaded CSV file #>
    $apiResponse = Import-Csv $localURL

    <# add one-by-one output lines #>
    ForEach ($row in $apiResponse) {
        $objResults = New-Object PSObject -Property ([ordered]@{
            forex_id = $forexID;
            symbol   = $symbol;
            date     = $($row.Date);
            rate     = $($row.Close);
        })
        $objResults | Export-Csv -Append -NoTypeInformation -Path $outputFile
    }
}