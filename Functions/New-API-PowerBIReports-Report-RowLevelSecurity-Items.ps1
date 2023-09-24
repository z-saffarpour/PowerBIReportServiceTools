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
        try {
            $myReportItems = $UploadPowerBIReportItemsJSON | ConvertFrom-Json
            $myReportRowLevelSecurityItems = $PowerBIReportRowLevelSecurityItemsJSON | ConvertFrom-Json
            $myReportRowLevelSecurityResultItems = New-Object System.Collections.ArrayList
            foreach ($myReportRowLevelSecurityItem in $myReportRowLevelSecurityItems) {
                $myReportId = $myReportRowLevelSecurityItem.ReportId
                $myReportItem = $myReportItems | Where-Object { $_.Id -eq $myReportId } 
                if ($null -ne $myReportItem -and $null -ne $myReportItem.Id_New) {   
                    $myReportId_New = $myReportItem.Id_New 
                    $myPowerBIReportAPI = $ReportRestAPIURI + "/api/v2.0/PowerBIReports(" + $myReportId_New + ")/DataModelRoleAssignments"
                    try {
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
                    catch {
                        if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                            "Function : New-RsReportRowLevelSecurityItems" >> $ErrorFile
                            "Report Id : $myReportId"  >> $ErrorFile
                            "Report Name : "  >> $ErrorFile
                            "Report Path : "  >> $ErrorFile
                            $_ >> $ErrorFile  
                            $mySpliter = ("--" + ("==" * 70))
                            $mySpliter >> $ErrorFile 
                        }
                    }
                }
                $myReportRowLevelSecurityResultItems.Add([PSCustomObject]@{"ReportId" = $myReportId; }) | Out-Null
                Write-Verbose ("   Set RowLevelSecurity For Report ==>> " + $myReportRowLevelSecurityResultItems.Count + " Of " + $myReportRowLevelSecurityItems.Count)
            }
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : New-RsReportRowLevelSecurityItems" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter = ("--" + ("==" * 70))
                $mySpliter >> $ErrorFile 
            }
        }
    }
}