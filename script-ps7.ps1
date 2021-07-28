<#
    Forex Scraping Script
    (using Yahoo Finance CSV endpoint API v7)

    REQUIRES POWERSHELL VERSION 7
#>

<# parameter definition #>
param ($inputFile, $outputFile, $downloadDirectory, $dayCount)

<# paramater validation #>
if (!(Test-Path -Path "inputfile.csv" -PathType Leaf) -and ($inputFile -eq $null)) {
    Throw [string]"Input CSV file required for execution."
}
if ($inputFile -eq $null) {
    $inputFile = "inputfile.csv"
}
if ($outputFile -eq $null) {
    $outputFile = "export.csv"
}
if ($downloadDirectory -eq $null) {
    $downloadDirectory = "download"
}
if ($dayCount -eq $null) {
    $dayCount = 1
}

$execDir = Split-Path $MyInvocation.MyCommand.Path

<# clear existing $outputFile #>
if ((Test-Path $outputFile) -eq $true) {
  Remove-Item $outputFile
  Write-Host "INFO: Cleared existing output file."
}
<# delete download directory if found #>
if ((Test-Path $downloadDirectory) -eq $true) {
  Remove-Item $downloadDirectory -Recurse
  Write-Host "INFO: Cleared existing download directory."
}

<# create download directory if not found#>
if (!(Test-Path -Path $downloadDirectory -PathType Leaf)) {
    [void](New-Item -Path $execDir -Name $downloadDirectory -ItemType Directory)
    Write-Host "INFO: Created download directory."
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
    $localURL = "$execDir\$downloadDirectory\$($downloadURL.segments[-1])"

    <# API connection #>
    try {
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile($downloadURL, $localURL)
        Write-Host "INFO: $symbol downloaded."

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
            $objResults | Export-Csv -Append -UseQuotes AsNeeded -NoTypeInformation -Path $outputFile
        }
        Write-Host "INFO: $symbol complete."
    }
    catch [System.Net.WebException]  {
        $statusCodeValue = $_.Exception.Response.StatusCode.value__
        switch ($statusCodeValue) {
            400 {
                Write-Warning -Message "$symbol HTTP 400 Bad Request"
            }
            401 {
                Write-Warning -Message "$symbol HTTP 401 Unauthorized."
            }
            403 {
                Write-Warning -Message "$symbol HTTP 403 Forbidden"
            }
            404 {
                Write-Warning -Message "$symbol HTTP 404 Not found. Invalid symbol."
            }
            500 {
                Write-Warning -Message "$symbol HTTP 500 Internal Server Error"
            }
            Default {
                Write-Warning "$symbol download failed!"
            }
        }
    }
    catch {
        Write-Warning "Unknown error while proccessing $symbol!"
    }
}