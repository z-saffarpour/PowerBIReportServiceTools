function Get-RsPBIReportPolicyItems {
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
            $myPowerBIReportJSON = '[{"Id":"9b073715-a39c-453b-b2eb-2851acbf704e","Name":"Test","Path":"/MobileReport/Test"}]'
            Get-RsPBIReportPolicyItems -WebPortalURL "http://localhost/reports" -Credential -PowerBIReportItemsJSON $myPowerBIReportJSON -ErrorFile "C:\Temp\Error_20231003.txt"
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
        $PowerBIReportItemsJSON,
        $ErrorFile
    )
    Begin {
        $myReportPolicyItems = New-Object System.Collections.ArrayList
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
                }
                catch {
                    if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                        "Function : Get-RsPBIReportPolicyItems" >> $ErrorFile
                        "Report Id : $myReportId"  >> $ErrorFile
                        "Report Name : $myReportName"  >> $ErrorFile
                        "Report Path : $myReportPath"  >> $ErrorFile
                        $_ >> $ErrorFile  
                        $mySpliter >> $ErrorFile 
                    }
                }
                finally {
                    Write-Verbose ("   Get PBIReport Policy ==>> " + $myReportPolicyItems.Count + " Of " + $myReportItems.Count)
                }
            }
            $myResultJSON = $myReportPolicyItems | ConvertTo-Json -Depth 15
            return , $myResultJSON   
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsPBIReportPolicyItems" >> $ErrorFile
                $_ >> $ErrorFile
                $mySpliter >> $ErrorFile 
            }
        }
    }
}