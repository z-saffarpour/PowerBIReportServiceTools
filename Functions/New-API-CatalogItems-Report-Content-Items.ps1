<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/CatalogItems
#>
function New-RsReportContentItems {
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ReportRestAPIURI,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $PowerBIReportItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $PowerBIReportContentPath,
        $ErrorFile
    )
    Begin {
        try {
            $myCatalogItemsURI = $ReportRestAPIURI + "/api/v2.0/CatalogItems"
            $myReportItems = $PowerBIReportItemsJSON | ConvertFrom-Json
            $myReportResultItems = New-Object System.Collections.ArrayList

            foreach ($myReportItem in $myReportItems) {
                $myReportId = $myReportItem.Id
                $myReportName = $myReportItem.Name
                $myReportPath = $myReportItem.Path    
                try {
                    $myReportFile = $PowerBIReportContentPath + $myReportPath.Replace($myReportName, '') + '/' + $myReportName + '.pbix' 
                    $myReportBytes = [System.IO.File]::ReadAllBytes($myReportFile)
                    $myReportContent = [System.Convert]::ToBase64String($myReportBytes)
                    $myBody = @{
                        "@odata.type" = "#Model.PowerBIReport";
                        "Content"     = $myReportContent;
                        "ContentType" = "";
                        "Id"          = $myReportId;
                        "Name"        = $myReportName;
                        "Path"        = $myReportPath;
                    } | ConvertTo-Json
                    if ($null -ne $Credential) {
                        $myResponse = Invoke-RestMethod -Method Post -Uri $myCatalogItemsURI -Credential $Credential -ContentType 'application/json; charset=unicode' -Body $myBody -Verbose:$false
                    }
                    else {
                        $myResponse = Invoke-RestMethod -Method Post -Uri $myCatalogItemsURI -UseDefaultCredentials -ContentType 'application/json; charset=unicode' -Body $myBody -Verbose:$false
                    }
                    $myReportResultItems.Add([PSCustomObject]@{"Id" = $myReportId; "Name" = $myReportName; "Path" = $myReportPath; "Type" = "PowerBIReport"; "Id_New" = $myResponse.Id }) | Out-Null
                }
                catch {                
                    if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                        "Function : New-RsReportContentItems" >> $ErrorFile
                        "Report Id : $myReportId"  >> $ErrorFile
                        "Report Name : $myReportName"  >> $ErrorFile
                        "Report Path : $myReportPath"  >> $ErrorFile
                        $_ >> $ErrorFile  
                        $mySpliter = ("--" + ("==" * 70))
                        $mySpliter >> $ErrorFile 
                    }
                }
                finally {
                    Write-Verbose ("   Upload PBIReport ==>> " + $myReportResultItems.Count + " Of " + $myReportItems.Count)
                }
            }
            $myResultJSON = $myReportResultItems | ConvertTo-Json -Depth 15
            return , $myResultJSON
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : New-RsReportContentItems" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter = ("--" + ("==" * 70))
                $mySpliter >> $ErrorFile 
            }
        }
    }
}