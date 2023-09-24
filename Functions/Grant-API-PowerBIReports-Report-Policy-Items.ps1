<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/Folders
#>
function Grant-RsReportPolicyItems {
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
        $PowerBIReportPolicyItemsJSON,
        $ErrorFile
    )
    Begin {
        try {
            $myReportItems = $UploadPowerBIReportItemsJSON | ConvertFrom-Json
            $myReportPolicyItems = $PowerBIReportPolicyItemsJSON | ConvertFrom-Json
            $myReportResultItems = New-Object System.Collections.ArrayList
            foreach ($myReportItem in $myReportItems) {
                $myReportId = $myReportItem.ReportId
                $myReportName = $myReportItem.Name
                $myReportPath = $myReportItem.Path
                $myReportId_New = $myReportItem.Id_New

                $myReportPolicyItem = $myReportPolicyItems | Where-Object { $_.ReportId -eq $myReportId } 
                if ($null -ne $myReportId_New) {
                    $myPowerBIReportAPI = $ReportRestAPIURI + "/api/v2.0/PowerBIReports(" + $myReportId_New + ")/Policies"
                    try {
                        if ($null -ne $Credential) {
                            $myResponse = Invoke-RestMethod -Method Get -Uri $myPowerBIReportAPI -Credential $Credential -ContentType 'application/json; charset=unicode' -Verbose:$false
                        }
                        else {
                            $myResponse = Invoke-RestMethod -Method Get -Uri $myPowerBIReportAPI -Credential $Credential -ContentType 'application/json; charset=unicode' -Verbose:$false
                        }
                        $myResponse.Policies = $myReportPolicyItem.Policies
                        $myResponse.InheritParentPolicy = $myReportPolicyItem.InheritParentPolicy #$false
                        $myBody = $myResponse | ConvertTo-Json -Depth 15
                        if ($null -ne $Credential) {
                            $myResponse = Invoke-RestMethod -Method Put -Uri $myPowerBIReportAPI -Credential $Credential -ContentType 'application/json; charset=unicode' -Body $myBody -Verbose:$false
                        }
                        else {
                            $myResponse = Invoke-RestMethod -Method Put -Uri $myPowerBIReportAPI -UseDefaultCredentials -ContentType 'application/json; charset=unicode' -Body $myBody -Verbose:$false
                        }
                    }
                    catch {
                        if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                            "Function : Grant-RsReportPolicyItems" >> $ErrorFile
                            "Report Id : $myReportId"  >> $ErrorFile
                            "Report Name : $myReportName"  >> $ErrorFile
                            "Report Path : $myReportPath"  >> $ErrorFile
                            $_ >> $ErrorFile  
                            $mySpliter = ("--" + ("==" * 70))
                            $mySpliter >> $ErrorFile 
                        }
                    }
                }
                $myReportResultItems.Add([PSCustomObject]@{"Id" = $myReportId; "Name" = $myReportName; "Path" = $myReportPath; }) | Out-Null
                Write-Verbose ("   Set Policy For Report ==>> " + $myReportResultItems.Count + " Of " + $myReportItems.Count)
            }
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Grant-RsReportPolicyItems" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter = ("--" + ("==" * 70))
                $mySpliter >> $ErrorFile 
            }
        }
    }
}