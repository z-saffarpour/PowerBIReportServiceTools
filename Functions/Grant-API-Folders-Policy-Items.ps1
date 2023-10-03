<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/Folders
#>
function Grant-RsFolderPolicyItems {
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ReportRestAPIURI,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $UploadFolderItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $FolderPolicyItemsJSON,
        $ErrorFile
    )
    Begin {
        $myFolderResultItems = New-Object System.Collections.ArrayList
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            $myFolderItems = $UploadFolderItemsJSON | ConvertFrom-Json
            $myFolderPolicyItems = $FolderPolicyItemsJSON | ConvertFrom-Json
            foreach ($myFolderItem in $myFolderItems) {
                $myFolderId = $myFolderItem.Id
                $myFolderName = $myFolderItem.Name
                $myFolderPath = $myFolderItem.Path
                $myFolderId_New = $myFolderItem.Id_New
                try {
                    $myFolderPolicyItem = $myFolderPolicyItems | Where-Object { $_.Id -eq $myFolderId } 
                    if ($null -ne $myFolderId_New -and $myFolderPolicyItem.InheritParentPolicy -eq $false) {
                        $myFolderAPI = $ReportRestAPIURI + "/api/v2.0/Folders(" + $myFolderId_New + ")/Policies"
                        if ($null -ne $Credential) {
                            $myResponse = Invoke-RestMethod -Method Get -Uri $myFolderAPI -Credential $Credential -ContentType 'application/json; charset=unicode' -Verbose:$false
                        }
                        else {
                            $myResponse = Invoke-RestMethod -Method Get -Uri $myFolderAPI -Credential $Credential -ContentType 'application/json; charset=unicode' -Verbose:$false
                        }
                        $myResponse.Policies = $myFolderPolicyItem.Policies
                        $myResponse.InheritParentPolicy = $false
                        $myBody = $myResponse | ConvertTo-Json -Depth 15
                        if ($null -ne $Credential) {
                            Invoke-RestMethod -Method Put -Uri $myFolderAPI -Credential $Credential -Body $myBody -ContentType 'application/json; charset=unicode' -Verbose:$false | Out-Null
                        }
                        else {
                            Invoke-RestMethod -Method Put -Uri $myFolderAPI -UseDefaultCredentials  -Body $myBody -ContentType 'application/json; charset=unicode' -Verbose:$false | Out-Null
                        }
                    }
                    $myFolderResultItems.Add([PSCustomObject]@{"Id" = $myFolderId; "Name" = $myFolderName; }) | Out-Null
                }
                catch {
                    if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                        "Function : Grant-RsFolderPolicyItems" >> $ErrorFile
                        "Folder Id : $myFolderId"  >> $ErrorFile
                        "Folder Name : $myFolderName"  >> $ErrorFile
                        "Folder Path : $myFolderPath"  >> $ErrorFile
                        "Folder Id_New : $myFolderId_New"  >> $ErrorFile
                        $_ >> $ErrorFile
                        $mySpliter >> $ErrorFile 
                    }
                }
                finally {
                    Write-Verbose ("   Set Policy For Folder ==>> " + $myFolderResultItems.Count + " Of " + $myFolderItems.Count)
                }           
            }
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Grant-RsFolderPolicyItems" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter >> $ErrorFile 
            }
        }
    }
}