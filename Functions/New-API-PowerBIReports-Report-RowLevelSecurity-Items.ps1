<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/Folders
#>
function New-RsReportRowLevelSecurityItems {
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ReportRestAPIURI,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $UploadPowerBIReportItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $PowerBIReportRowLevelSecurityItemsJSON,
        $ErrorFile
    )
    Begin {
        $myReportRowLevelSecurityResultItems = New-Object System.Collections.ArrayList
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            $myReportItems = $UploadPowerBIReportItemsJSON | ConvertFrom-Json
            $myReportRowLevelSecurityItems = $PowerBIReportRowLevelSecurityItemsJSON | ConvertFrom-Json
            foreach ($myReportRowLevelSecurityItem in $myReportRowLevelSecurityItems) {
                $myReportId = $myReportRowLevelSecurityItem.ReportId
                try {
                    $myReportItem = $myReportItems | Where-Object { $_.Id -eq $myReportId } 
                    if ($null -ne $myReportItem -and $null -ne $myReportItem.Id_New) {   
                        $myReportId_New = $myReportItem.Id_New 
                        $myPowerBIReportAPI = $ReportRestAPIURI + "/api/v2.0/PowerBIReports(" + $myReportId_New + ")/DataModelRoleAssignments"
                        $myRowLevelSecurityJSON = $myReportRowLevelSecurityItem.RowLevelSecurity | ConvertTo-Json -Depth 15
                        if ($myReportRowLevelSecurityItem.RowLevelSecurity.Count -eq 1) {
                            $myBody = "[" + $myRowLevelSecurityJSON + "]"
                        }
                        else {
                            $myBody = $myRowLevelSecurityJSON
                        }
                        if ($null -ne $Credential) {
                            Invoke-RestMethod -Method Put -Uri $myPowerBIReportAPI -Credential $Credential -Body $myBody -ContentType 'application/json; charset=unicode' -Verbose:$false | Out-Null
                        }
                        else {
                            Invoke-RestMethod -Method Put -Uri $myPowerBIReportAPI -UseDefaultCredentials -Body $myBody -ContentType 'application/json; charset=unicode' -Verbose:$false | Out-Null
                        }
                    }
                    $myReportRowLevelSecurityResultItems.Add([PSCustomObject]@{"ReportId" = $myReportId; }) | Out-Null
                }
                catch {
                    if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                        "Function : New-RsReportRowLevelSecurityItems" >> $ErrorFile
                        "Report Id : $myReportId"  >> $ErrorFile
                        "Report Name : "  >> $ErrorFile
                        "Report Path : "  >> $ErrorFile
                        $_ >> $ErrorFile  
                        $mySpliter >> $ErrorFile 
                    }
                }
                finally {
                    Write-Verbose ("   Set RowLevelSecurity For Report ==>> " + $myReportRowLevelSecurityResultItems.Count + " Of " + $myReportRowLevelSecurityItems.Count)
                }
            }
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : New-RsReportRowLevelSecurityItems" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter >> $ErrorFile 
            }
        }
    }
}