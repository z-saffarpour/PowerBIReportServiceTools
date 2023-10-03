function Get-RsPBIReportScheduleItems {
    <#
        .SYNOPSIS
            This function gets the CacheRefreshPlans for a given Power BI Report.

        .DESCRIPTION
            This function gets the CacheRefreshPlans for a given Power BI Report.

        .PARAMETER WebPortalURL
            #Specify the name of the WebPortalURL.

        .PARAMETER Credential
            Specify the credentials to use when connecting to the Report Server.

        .PARAMETER PowerBIReportItemsJSON
            Specify the List of PowerBIReport in Json.

        .PARAMETER ErrorFile
            Specify the path to save the exceptions in the file.

        .EXAMPLE
            $myPowerBIReportJSON = '[{"Id":"9b073715-a39c-453b-b2eb-2851acbf704e","Name":"Test","Path":"/MobileReport/Test"}]'
            Get-RsPBIReportScheduleItems -WebPortalURL "http://localhost/reports" -Credential -PowerBIReportItemsJSON $myPowerBIReportJSON -ErrorFile "C:\Temp\Error_20231003.txt"
            Description
            -----------
            
        .LINK
            https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/PowerBIReports/GetPowerBICacheRefreshPlans
    #>
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $WebPortalURL,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $PowerBIReportItemsJSON,
        $ErrorFile
    )
    Begin {
        $myReportScheduleItems = New-Object System.Collections.ArrayList
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            $myReportItems = $PowerBIReportItemsJSON | ConvertFrom-Json 
            foreach ($myReportItem in $myReportItems) {
                $myReportId = $myReportItem.Id
                $myReportName = $myReportItem.Name
                $myReportPath = $myReportItem.Path
                try {
                    $myPBIReportAPI = $WebPortalURL + '/api/v2.0/PowerBIReports(' + $myReportId + ')/CacheRefreshPlans'
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
                        $mySpliter >> $ErrorFile 
                    }
                }
                finally {
                    Write-Verbose ("    Get PBIReport Schedule ==>> " + $myReportScheduleItems.Count + " Of " + $myReportItems.Count)
                }
            }
            $myResultJSON = $myReportScheduleItems | ConvertTo-Json -Depth 15 
            return , $myResultJSON
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsPBIReportScheduleItems" >> $ErrorFile
                $_ >> $ErrorFile
                $mySpliter >> $ErrorFile 
            }
        }
    }
}