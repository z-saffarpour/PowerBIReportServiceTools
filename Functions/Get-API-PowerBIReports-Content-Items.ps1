<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/PowerBIReports/GetPowerBIReports
#>
function Get-RsPBIContentItems {
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ReportRestAPIURI,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $PowerBIReportItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $DownloadPath,
        $ErrorFile
    )
    Begin {
        try {
            $myReportItems = $PowerBIReportItemsJSON | ConvertFrom-Json 
            if (!(Test-Path -Path $DownloadPath)) {
                New-Item -ItemType Directory -Path $DownloadPath | Out-Null
            }
            foreach ($myReportItem in $myReportItems) {
                $myReportId = $myReportItem.Id
                $myReportName = $myReportItem.Name
                $myReportPath = $myReportItem.Path
                try {
                    $myPBIContentAPI = $ReportRestAPIURI + '/api/v2.0/PowerBIReports(' + $myReportId + ')/Content/$value'
                    $myPBIReportDirectory = $DownloadPath + $myReportPath.Replace($myReportName, '')
                    $myPBIContentFile = $myPBIReportDirectory + '\' + $myReportName + '.pbix'    
                    if (!(Test-Path -Path $myPBIReportDirectory)) {
                        New-Item -ItemType Directory -Path $myPBIReportDirectory | Out-Null
                    }
                    if ($null -ne $Credential) {
                        Invoke-WebRequest -Uri $myPBIContentAPI -OutFile $myPBIContentFile -UseBasicParsing -Credential $Credential -Verbose:$false | Out-Null
                    }
                    else {
                        Invoke-WebRequest -Uri $myPBIContentAPI -OutFile $myPBIContentFile -UseBasicParsing -UseDefaultCredentials -Verbose:$false | Out-Null
                    }   
                }
                catch {
                    if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                        "Function : Get-RsPBIContentItems" >> $ErrorFile
                        "Report Id : $myReportId"  >> $ErrorFile
                        "Report Name : $myReportName"  >> $ErrorFile
                        "Report Path : $myReportPath"  >> $ErrorFile
                        $_ >> $ErrorFile  
                        $mySpliter = ("--" + ("==" * 70))
                        $mySpliter >> $ErrorFile 
                    }
                }
            }
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsPBIContentItems" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter = ("--" + ("==" * 70))
                $mySpliter >> $ErrorFile 
            }
        }
    }
}