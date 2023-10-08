function Get-RsPBIReportScheduleItem {
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
            $myCredential = Get-Credential
            Get-RsPBIReportScheduleItem -WebPortalURL "http://localhost/reports" -Credential $myCredential -PowerBIReportPath "/MobileReport/Test" $myPowerBIReportJSON -ErrorFile "C:\Temp\Error_20231003.txt"
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
        $PowerBIReportPath,
        $ErrorFile
    )
    Begin {
        $myPBIReportAPI = $WebPortalURL + "/api/v2.0/PowerBIReports(path='" + $PowerBIReportPath + "')"
        $myReportScheduleItems = New-Object System.Collections.ArrayList
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            if ($null -ne $Credential) {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myPBIReportAPI -Credential $Credential -ContentType 'application/json; charset=unicode' -Verbose:$false
            }
            else {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myPBIReportAPI -UseDefaultCredentials -ContentType 'application/json; charset=unicode' -Verbose:$false
            }
            $myReportId = $myResponse.Id
            $myReportName = $myResponse.Name
            $myReportPath = $myResponse.Path
            $myPBIReportAPI = $WebPortalURL + '/api/v2.0/PowerBIReports(' + $myReportId + ')/CacheRefreshPlans'
            if ($null -ne $Credential) {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myPBIReportAPI -UseBasicParsing -Credential $Credential -Verbose:$false
            }
            else {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myPBIReportAPI -UseBasicParsing -UseDefaultCredentials -Verbose:$false
            }
            $myScheduleItems = $myResponse.value
            $myReportScheduleItems.Add([PSCustomObject]@{"ReportId" = $myReportId; "Name" = $myReportName; "Path" = $myReportPath; "Schedules" = $myScheduleItems; }) | Out-Null
            $myResultJSON = $myReportScheduleItems | ConvertTo-Json -Depth 15 
            return , $myResultJSON
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsPBIReportScheduleItem" >> $ErrorFile
                "PowerBIReport Path : $PowerBIReportPath"  >> $ErrorFile
                $_ >> $ErrorFile
                $mySpliter >> $ErrorFile 
            }
        }
    }
}