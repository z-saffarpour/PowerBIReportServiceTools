
function Get-RsFolderPolicyItems {
    <#
        .SYNOPSIS
            This function gets policies associated with the Folder CatalogItem.

        .DESCRIPTION
            This function gets policies associated with the Folder CatalogItem.

        .PARAMETER WebPortalURL
            #Specify the name of the WebPortalURL.

        .PARAMETER Credential
            Specify the credentials to use when connecting to the Report Server.

        .PARAMETER FolderItemsJSON
            Specify the List of Folder in Json.
            
        .PARAMETER ErrorFile
            Specify the path to save the exceptions in the file.

        .EXAMPLE
            $myFolderJSON = '[{"Id":"7c022d2c-1412-40dc-a0ee-02ee4c240a06","Name":"Data Sources","Path":"/Data Sources"}]'
            Get-RsFolderPolicyItems -WebPortalURL "http://localhost/reports" -Credential -FolderItemsJSON $myFolderJSON -ErrorFile "C:\Temp\Error_20231003.txt"
            Description
            -----------
            
        .LINK
            https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/Folders/GetFolderPolicies
    #>  
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $WebPortalURL,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $FolderItemsJSON,
        $ErrorFile
    )
    Begin {
        $myFolderPolicyItems = New-Object System.Collections.ArrayList
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            $myFolderItems = $FolderItemsJSON | ConvertFrom-Json 
            foreach ($myFolderItem in $myFolderItems) {
                $myFolderId = $myFolderItem.Id
                $myFolderName = $myFolderItem.Name
                try {
                    $myFolderAPI = $WebPortalURL + '/api/v2.0/Folders(' + $myFolderId + ')/Policies'
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
                        $mySpliter >> $ErrorFile 
                    }
                }
                finally {
                    Write-Verbose ("   Get Folder Policy ==>> " + $myFolderPolicyItems.Count + " Of " + $myFolderItems.Count)
                }
            }
            $myResultJSON = $myFolderPolicyItems | ConvertTo-Json -Depth 15 
            return , $myResultJSON    
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsFolderPolicyItems" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter >> $ErrorFile 
            }
        }
    }
}