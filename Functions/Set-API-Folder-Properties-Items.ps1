<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/Folders
#>
function Set-RsFolderPropertiesItems {
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $WebPortalURL,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $UploadFolderItemsJSON,
        $ErrorFile
    )
    Begin {
        $myFolderResultItems = New-Object System.Collections.ArrayList
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            $myFolderItems = $UploadFolderItemsJSON | ConvertFrom-Json
            foreach ($myFolderItem in $myFolderItems) {
                $myFolderId = $myFolderItem.Id
                $myFolderName = $myFolderItem.Name
                $myFolderPath = $myFolderItem.Path   
                $myFolderId_New = $myFolderItem.Id_New 
                try {  
                    if ($null -ne $myFolderItem.Id_New) {
                        $myFolderAPI = $WebPortalURL + "/api/v2.0/Folders(" + $myFolderId_New + ")/"
                        $myHidden = $myFolderItem.Hidden
                        $myBody = [PSCustomObject]@{
                            "Hidden" = $myHidden;
                        } | ConvertTo-Json -Depth 15

                        if ($null -ne $Credential) {
                            Invoke-RestMethod -Method Patch -Uri $myFolderAPI -Credential $Credential -Body $myBody -ContentType 'application/json; charset=unicode' -UseBasicParsing -Verbose:$false
                        }
                        else {
                            Invoke-RestMethod -Method Patch -Uri $myFolderAPI -UseDefaultCredentials -Body $myBody -ContentType 'application/json; charset=unicode' -UseBasicParsing -Verbose:$false
                        }
                    }
                    $myFolderResultItems.Add([PSCustomObject]@{"Id" = $myFolderId; "Name" = $myFolderName; "Path" = $myFolderPath; }) | Out-Null
                }
                catch {
                    if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                        "Function : Set-RsFolderPropertiesItems" >> $ErrorFile
                        "Folder Id : $myFolderId"  >> $ErrorFile
                        "Folder Name : $myFolderName"  >> $ErrorFile
                        "Folder Path : $myFolderPath"  >> $ErrorFile
                        $_ >> $ErrorFile  
                        $mySpliter >> $ErrorFile 
                    }
                }
                finally {
                    Write-Verbose ("   Set Properties For Folder ==>> " + $myFolderResultItems.Count + " Of " + $myFolderItems.Count)
                }
            }
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Set-RsFolderPropertiesItems" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter >> $ErrorFile 
            }
        }
    }
}