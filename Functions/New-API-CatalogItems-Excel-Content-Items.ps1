<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/CatalogItems
#>
function New-RsExcelContentItems {
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $WebPortalURL,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ExcelItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ExcelContentPath,
        $ErrorFile
    )
    Begin {
        $myCatalogItemsURI = $WebPortalURL + "/api/v2.0/CatalogItems"
        $myExcelResultItems = New-Object System.Collections.ArrayList
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            $myExcelItems = $ExcelItemsJSON | ConvertFrom-Json
            foreach ($myExcelItem in $myExcelItems) {
                $myExcelId = $myExcelItem.Id
                $myExcelName = $myExcelItem.Name
                $myExcelPath = $myExcelItem.Path    
                try {
                    $myExcelFile = $ExcelContentPath + $myExcelPath.Substring(0 , $myExcelPath.LastIndexOf($myExcelName)) + '/' + $myExcelName
                    $myExcelBytes = [System.IO.File]::ReadAllBytes($myExcelFile)
                    $myExcelContent = [System.Convert]::ToBase64String($myExcelBytes)
                    $myBody = @{
                        "@odata.type" = "#Model.ExcelWorkbook";
                        "Content"     = $myExcelContent;
                        "ContentType" = "";
                        "Id"          = $myExcelId;
                        "Name"        = $myExcelName;
                        "Path"        = $myExcelPath;
                    } | ConvertTo-Json
                    if ($null -ne $Credential) {
                        $myResponse = Invoke-RestMethod -Method Post -Uri $myCatalogItemsURI -Credential $Credential -ContentType 'application/json; charset=unicode' -Body $myBody -Verbose:$false
                    }
                    else {
                        $myResponse = Invoke-RestMethod -Method Post -Uri $myCatalogItemsURI -UseDefaultCredentials -ContentType 'application/json; charset=unicode' -Body $myBody -Verbose:$false
                    }
                    $myExcelResultItems.Add([PSCustomObject]@{"Id" = $myExcelId; "Name" = $myExcelName; "Path" = $myExcelPath; "CreatedBy" = $myExcelItem.CreatedBy; "CreatedDate" = $myExcelItem.CreatedDate; "Hidden" = $myExcelItem.Hidden; "Id_New" = $myResponse.Id }) | Out-Null
                }
                catch {                
                    if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                        "Function : New-RsExcelContentItems" >> $ErrorFile
                        "Excel Id : $myExcelId"  >> $ErrorFile
                        "Excel Name : $myExcelName"  >> $ErrorFile
                        "Excel Path : $myExcelPath"  >> $ErrorFile
                        $_ >> $ErrorFile  
                        $mySpliter >> $ErrorFile 
                    }
                }
                finally {
                    Write-Verbose ("   Upload Excel Content ==>> " + $myExcelResultItems.Count + " Of " + $myExcelItems.Count)
                }
            }
            $myResultJSON = $myExcelResultItems | ConvertTo-Json -Depth 15
            return , $myResultJSON
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : New-RsExcelContentItems" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter >> $ErrorFile 
            }
        }
    }
}