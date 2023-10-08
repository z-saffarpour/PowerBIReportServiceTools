function Get-RsPBIReportRLSItem {
    <#
        .SYNOPSIS
            This function gets the data model role assignments that are associated with the specified PowerBIReport.

        .DESCRIPTION
            This function gets the data model role assignments that are associated with the specified PowerBIReport.

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
            Get-RsPBIReportRLSItem -WebPortalURL "http://localhost/reports" -Credential $myCredential -PowerBIReportPath "/MobileReport/Test" -ErrorFile "C:\Temp\Error_20231003.txt"
            Description
            -----------
            
        .LINK
            https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/PowerBIReports/GetPowerBIReportDataModelRoleAssignments
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
        $myReportRowLevelSecurityItems = New-Object System.Collections.ArrayList
        $myReportResultItems = New-Object System.Collections.ArrayList
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
            $myPBIReportAPI = $WebPortalURL + '/api/v2.0/PowerBIReports(' + $myReportId + ')/DataModelRoleAssignments'
            if ($null -ne $Credential) {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myPBIReportAPI -Credential $Credential -Verbose:$false
            }
            else {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myPBIReportAPI -UseDefaultCredentials -Verbose:$false
            }
            if (($null -ne $myResponse.value) -and ($myResponse.value.length -gt 0)) {
                $myRowLevelSecurityItems = $myResponse.value
                $myReportRowLevelSecurityItems.Add([PSCustomObject]@{"ReportId" = $myReportId; "Name" = $myReportName; "Path" = $myReportPath; "RowLevelSecurity" = $myRowLevelSecurityItems }) | Out-Null
            }
            $myReportResultItems.Add([PSCustomObject]@{"Id" = $myReportId; "Name" = $myReportName; "Path" = $myReportPath; }) | Out-Null
            $myResultJSON = $myReportRowLevelSecurityItems | ConvertTo-Json -Depth 15
            return , $myResultJSON  
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsPBIReportRLSItem" >> $ErrorFile
                "PowerBIReport Path : $PowerBIReportPath"  >> $ErrorFile
                $_ >> $ErrorFile
                $mySpliter >> $ErrorFile 
            }
        }
    }
}
