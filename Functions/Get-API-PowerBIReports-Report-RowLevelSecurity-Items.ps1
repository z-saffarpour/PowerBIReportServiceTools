<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/PowerBIReports/DataSources
#>
function Get-RsPBIReportRLSItems {
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
            $myReportRowLevelSecurityItems = New-Object System.Collections.ArrayList
            $myReportItems = $PowerBIReportItemsJSON | ConvertFrom-Json 
            foreach ($myReportItem in $myReportItems) {
                $myReportId = $myReportItem.Id
                $myReportName = $myReportItem.Name
                $myReportPath = $myReportItem.Path
                try {
                    $myPBIReportAPI = $ReportRestAPIURI + '/api/v2.0/PowerBIReports(' + $myReportId + ')/DataModelRoleAssignments'
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
                }
                catch {
                    if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                        "Function : Get-RsPBIReportRLSItems" >> $ErrorFile
                        "Report Id : $myReportId"  >> $ErrorFile
                        "Report Name : $myReportName"  >> $ErrorFile
                        "Report Path : $myReportPath"  >> $ErrorFile
                        $_ >> $ErrorFile  
                        $mySpliter = ("--" + ("==" * 70))
                        $mySpliter >> $ErrorFile 
                    }
                }
            }
            $myResultJSON = $myReportRowLevelSecurityItems | ConvertTo-Json -Depth 15
            return , $myResultJSON  
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsPBIReportRLSItems" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter = ("--" + ("==" * 70))
                $mySpliter >> $ErrorFile 
            }
        }
    }
}