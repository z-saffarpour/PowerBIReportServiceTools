function Get-RsPBIReportPolicyItem {
    <#
        .SYNOPSIS
            This function gets ItemPolicies associated with the specified PowerBIReport CatalogItem.

        .DESCRIPTION
            This function gets ItemPolicies associated with the specified PowerBIReport CatalogItem.

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
            Get-RsPBIReportPolicyItem -WebPortalURL "http://localhost/reports" -Credential $myCredential -PowerBIReportPath "/MobileReport/Test" -ErrorFile "C:\Temp\Error_20231003.txt"
            Description
            -----------
            
        .LINK
            https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/PowerBIReports/GetPowerBIReportPolicies
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
        $myReportPolicyItems = New-Object System.Collections.ArrayList
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
            $myPBIReportAPI = $WebPortalURL + '/api/v2.0/PowerBIReports(' + $myReportId + ')/Policies'
            if ($null -ne $Credential) {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myPBIReportAPI -Credential $Credential -Verbose:$false
            }
            else {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myPBIReportAPI -UseDefaultCredentials -Verbose:$false
            }
            $myPolicyItems = New-Object System.Collections.ArrayList
            foreach ($myPolicy in $myResponse.Policies) {
                $myRoleItems = New-Object System.Collections.ArrayList
                foreach ($myRole in $myPolicy.Roles) {
                    $myRoleItems.Add([PSCustomObject]@{"Name" = $myRole.Name; "Description" = $myRole.Description; }) | Out-Null
                }
                $myPolicyItems.Add([PSCustomObject]@{"GroupUserName" = $myPolicy.GroupUserName; "Roles" = $myRoleItems; }) | Out-Null
            }
            $myReportPolicyItems.Add([PSCustomObject]@{"ReportId" = $myReportId; "Name" = $myReportName; "Path" = $myReportPath; "InheritParentPolicy" = $myResponse.InheritParentPolicy; "Policies" = $myPolicyItems }) | Out-Null
            $myResultJSON = $myReportPolicyItems | ConvertTo-Json -Depth 15
            return , $myResultJSON   
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsPBIReportPolicyItem" >> $ErrorFile
                "PowerBIReport Path : $PowerBIReportPath"  >> $ErrorFile
                $_ >> $ErrorFile
                $mySpliter >> $ErrorFile 
            }
        }
    }
}