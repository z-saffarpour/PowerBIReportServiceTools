<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/CatalogItems
#>
function New-RsResourceContentItems {
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $WebPortalURL,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ResourceItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ResourceContentPath,
        $ErrorFile
    )
    Begin {
        $myCatalogItemsURI = $WebPortalURL + "/api/v2.0/CatalogItems"
        $myResourceResultItems = New-Object System.Collections.ArrayList
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            $myResourceItems = $ResourceItemsJSON | ConvertFrom-Json
            foreach ($myResourceItem in $myResourceItems) {
                $myResourceId = $myResourceItem.Id
                $myResourceName = $myResourceItem.Name
                $myResourcePath = $myResourceItem.Path    
                try {
                    $myResourceFile = $ResourceContentPath + $myResourcePath.Substring(0 , $myResourcePath.LastIndexOf($myResourceName)) + '/' + $myResourceName
                    $myResourceBytes = [System.IO.File]::ReadAllBytes($myResourceFile)
                    $myResourceContent = [System.Convert]::ToBase64String($myResourceBytes)
                    $myBody = @{
                        "@odata.type" = "#Model.Resource";
                        "Content"     = $myResourceContent;
                        "ContentType" = "";
                        "Id"          = $myResourceId;
                        "Name"        = $myResourceName;
                        "Path"        = $myResourcePath;
                    } | ConvertTo-Json
                    if ($null -ne $Credential) {
                        $myResponse = Invoke-RestMethod -Method Post -Uri $myCatalogItemsURI -Credential $Credential -ContentType 'application/json; charset=unicode' -Body $myBody -Verbose:$false
                    }
                    else {
                        $myResponse = Invoke-RestMethod -Method Post -Uri $myCatalogItemsURI -UseDefaultCredentials -ContentType 'application/json; charset=unicode' -Body $myBody -Verbose:$false
                    }
                    $myResourceResultItems.Add([PSCustomObject]@{"Id" = $myResourceId; "Name" = $myResourceName; "Path" = $myResourcePath; "CreatedBy" = $myResourceItem.CreatedBy; "CreatedDate" = $myResourceItem.CreatedDate; "Hidden" = $myResourceItem.Hidden; "Id_New" = $myResponse.Id }) | Out-Null
                }
                catch {                
                    if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                        "Function : New-RsResourceContentItems" >> $ErrorFile
                        "Resource Id : $myResourceId"  >> $ErrorFile
                        "Resource Name : $myResourceName"  >> $ErrorFile
                        "Resource Path : $myResourcePath"  >> $ErrorFile
                        $_ >> $ErrorFile  
                        $mySpliter >> $ErrorFile 
                    }
                }
                finally {
                    Write-Verbose ("   Upload Resource Content ==>> " + $myResourceResultItems.Count + " Of " + $myResourceItems.Count)
                }
            }
            $myResultJSON = $myResourceResultItems | ConvertTo-Json -Depth 15
            return , $myResultJSON
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : New-RsResourceContentItems" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter >> $ErrorFile 
            }
        }
    }
}