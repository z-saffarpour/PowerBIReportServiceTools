<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/PowerBIReports/CacheRefreshPlans
#>
function Get-RsPBIReportScheduleItems {
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ReportRestAPIURI,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $PowerBIReportItemsJSON,
        $ErrorFile
    )
    Begin {
        try {
            $myReportScheduleItems = New-Object System.Collections.ArrayList
            $myReportItems = $PowerBIReportItemsJSON | ConvertFrom-Json 
            foreach ($myReportItem in $myReportItems) {
                $myReportId = $myReportItem.Id
                $myReportName = $myReportItem.Name
                $myReportPath = $myReportItem.Path
                try {
                    $myPBIReportAPI = $ReportRestAPIURI + '/api/v2.0/PowerBIReports(' + $myReportId + ')/CacheRefreshPlans'
                    if ($null -ne $Credential) {
                        $myResponse = Invoke-RestMethod -Method Get -Uri $myPBIReportAPI -UseBasicParsing -Credential $Credential -Verbose:$false
                    }
                    else {
                        $myResponse = Invoke-RestMethod -Method Get -Uri $myPBIReportAPI -UseBasicParsing -UseDefaultCredentials -Verbose:$false
                    }
                    $myScheduleItems = $myResponse.value
                    $myReportScheduleItems.Add([PSCustomObject]@{"ReportId" = $myReportId; "Name" = $myReportName; "Path" = $myReportPath; "Schedules" = $myScheduleItems; }) | Out-Null
                }
                catch {
                    if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                        "Function : Get-RsPBIReportScheduleItems" >> $ErrorFile
                        "Report Id : $myReportId"  >> $ErrorFile
                        "Report Name : $myReportName"  >> $ErrorFile
                        "Report Path : $myReportPath"  >> $ErrorFile
                        $_ >> $ErrorFile  
                        $mySpliter = ("--" + ("==" * 70))
                        $mySpliter >> $ErrorFile 
                    }
                }
            }
            $myResultJSON = $myReportScheduleItems | ConvertTo-Json -Depth 15 
            return , $myResultJSON
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsPBIReportScheduleItems" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter = ("--" + ("==" * 70))
                $mySpliter >> $ErrorFile 
            }
        }
    }
}