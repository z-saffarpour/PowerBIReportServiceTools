
function Get-RsFolderPolicyItem {
    <#
        .SYNOPSIS
            This function gets policies associated with the Folder CatalogItem.

        .DESCRIPTION
            This function gets policies associated with the Folder CatalogItem.

        .PARAMETER WebPortalURL
            #Specify the name of the WebPortalURL.

        .PARAMETER Credential
            Specify the credentials to use when connecting to the Report Server.

        .PARAMETER FolderPath
            Specify the Folder Path.
            
        .PARAMETER ErrorFile
            Specify the path to save the exceptions in the file.

        .EXAMPLE
            $myCredential = Get-Credential
            Get-RsFolderPolicyItem -WebPortalURL "http://localhost/reports" -Credential $myCredential -FolderPath "/Dataset" -ErrorFile "C:\Temp\Error_20231003.txt"
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
        $FolderPath,
        $ErrorFile
    )
    Begin {
        $myFolderAPI = $WebPortalURL + "/api/v2.0/Folders(path='" + $FolderPath + "')"
        $myFolderPolicyAPI = $myFolderAPI + "/Policies"
        $myFolderPolicyItems = New-Object System.Collections.ArrayList
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            if ($null -ne $Credential) {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myFolderAPI  -Credential $Credential -Verbose:$false
            }
            else {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myFolderAPI -UseDefaultCredentials -Verbose:$false
            }
            $myFolderId = $myResponse.Id
            $myFolderName = $myResponse.Name
            ##================================================
            if ($null -ne $Credential) {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myFolderPolicyAPI  -Credential $Credential -Verbose:$false
            }
            else {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myFolderPolicyAPI -UseDefaultCredentials -Verbose:$false
            }
            $myPolicyItems = New-Object System.Collections.ArrayList
            foreach ($myPolicy in $myResponse.Policies | Sort-Object GroupUserName) {
                $myRoleItems = New-Object System.Collections.ArrayList
                foreach ($myRole in $myPolicy.Roles) {
                    $myRoleItems.Add([PSCustomObject]@{"Name" = $myRole.Name; "Description" = $myRole.Description }) | Out-Null
                }       
                $myPolicyItems.Add([PSCustomObject]@{"GroupUserName" = $myPolicy.GroupUserName; "Roles" = $myRoleItems; }) | Out-Null
            }
            $myFolderPolicyItems.Add([PSCustomObject]@{"Id" = $myFolderId; "Name" = $myFolderName; "Path" = $FolderPath; "InheritParentPolicy" = $myResponse.InheritParentPolicy; "Policies" = $myPolicyItems }) | Out-Null
            $myResultJSON = $myFolderPolicyItems | ConvertTo-Json -Depth 15 
            return , $myResultJSON    
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsFolderPolicyItem" >> $ErrorFile
                "Folder Path : $FolderPath"  >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter >> $ErrorFile 
            }
        }
    }
}