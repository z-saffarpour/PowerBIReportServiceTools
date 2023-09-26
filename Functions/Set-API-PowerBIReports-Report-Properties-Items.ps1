<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/Folders
#>
function Set-RsReportPropertiesItems {
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ReportRestAPIURI,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $UploadPowerBIReportItemsJSON,
        $ErrorFile
    )
    Begin {
        try {
            $myReportItems = $UploadPowerBIReportItemsJSON | ConvertFrom-Json
            $myReportResultItems = New-Object System.Collections.ArrayList
            foreach ($myReportItem in $myReportItems) {
                $myReportId = $myReportItem.Id
                $myReportName = $myReportItem.Name
                $myReportPath = $myReportItem.Path   
                $myReportId_New = $myReportItem.Id_New   
                if ($null -ne $myReportItem.Id_New) {
                    $myPowerBIReportAPI = $ReportRestAPIURI + "/api/v2.0/PowerBIReports(" + $myReportId_New + ")/DataSources"
                    $myDescription = [string]::Format("Created By: {0} `n`nCreated Date:{1}", $myReportItem.CreatedBy , $myReportItem.CreatedDate.Replace("T", " ") )
                    $myHidden = $myReportItem.Hidden
                    $myBody = [PSCustomObject]@{
                        "Description" = $myDescription;
                        "Hidden"      = $myHidden;
                    } | ConvertTo-Json -Depth 15

                    if ($null -ne $Credential) {
                        Invoke-RestMethod -Method Patch -Uri $myPowerBIReportAPI -Credential $Credential -Body $myBody -ContentType 'application/json; charset=unicode' -UseBasicParsing -Verbose:$false
                    }
                    else {
                        Invoke-RestMethod -Method Patch -Uri $myPowerBIReportAPI -UseDefaultCredentials -Body $myBody -ContentType 'application/json; charset=unicode' -UseBasicParsing -Verbose:$false
                    }
                }
                catch {
                    if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                        "Function : Set-RsReportPropertiesItems" >> $ErrorFile
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
            Write-Verbose ("   Set Properties For Report ==>> " + $myReportResultItems.Count + " Of " + $myReportItems.Count)
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Set-RsReportPropertiesItems" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter = ("--" + ("==" * 70))
                $mySpliter >> $ErrorFile 
            }
        }
    }
}