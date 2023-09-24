<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/Folders
#>

function Get-RsFolderPolicyItems {
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ReportRestAPIURI,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $FolderItemsJSON,
        $ErrorFile
    )
    Begin {
        try {
            $myFolderPolicyItems = New-Object System.Collections.ArrayList
            $myFolderItems = $FolderItemsJSON | ConvertFrom-Json 
            foreach ($myFolderItem in $myFolderItems) {
                $myFolderId = $myFolderItem.Id
                $myFolderName = $myFolderItem.Name
                try {
                    $myFolderAPI = $ReportRestAPIURI + '/api/v2.0/Folders(' + $myFolderId + ')/Policies'
                    if ($null -ne $Credential) {
                        $myResponse = Invoke-RestMethod -Method Get -Uri $myFolderAPI  -Credential $Credential -Verbose:$false
                    }
                    else {
                        $myResponse = Invoke-RestMethod -Method Get -Uri $myFolderAPI -UseDefaultCredentials -Verbose:$false
                    }
                    $myPolicyItems = New-Object System.Collections.ArrayList
                    foreach ($myPolicy in $myResponse.Policies | Sort-Object GroupUserName) {
                        $myRoleItems = New-Object System.Collections.ArrayList
                        foreach ($myRole in $myPolicy.Roles) {
                            $myRoleItems.Add([PSCustomObject]@{"Name" = $myRole.Name; "Description" = $myRole.Description }) | Out-Null
                        }       
                        $myPolicyItems.Add([PSCustomObject]@{"GroupUserName" = $myPolicy.GroupUserName; "Roles" = $myRoleItems; }) | Out-Null
                    }
                    $myFolderPolicyItems.Add([PSCustomObject]@{"Id" = $myFolderId; "Name" = $myFolderName; "InheritParentPolicy" = $myResponse.InheritParentPolicy; "Policies" = $myPolicyItems }) | Out-Null
                }
                catch {
                    if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                        "Function : Get-RsFolderPolicyItems" >> $ErrorFile
                        "Folder Id : $myFolderId"  >> $ErrorFile
                        "Folder Name : $myFolderName"  >> $ErrorFile
                        $_ >> $ErrorFile  
                        $mySpliter = ("--" + ("==" * 70))
                        $mySpliter >> $ErrorFile 
                    }
                }
            }
            $myResultJSON = $myFolderPolicyItems | ConvertTo-Json -Depth 15 
            return , $myResultJSON    
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsFolderPolicyItems" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter = ("--" + ("==" * 70))
                $mySpliter >> $ErrorFile 
            }
        }
    }
}