<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/Folders
#>
function Set-RsFolderPropertiesItems {
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ReportRestAPIURI,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $UploadFolderItemsJSON,
        $ErrorFile
    )
    Begin {
        try {
            $myFolderItems = $UploadFolderItemsJSON | ConvertFrom-Json
            $myFolderResultItems = New-Object System.Collections.ArrayList
            foreach ($myFolderItem in $myFolderItems) {
                $myFolderId = $myFolderItem.Id
                $myFolderName = $myFolderItem.Name
                $myFolderPath = $myFolderItem.Path   
                $myFolderId_New = $myFolderItem.Id_New 
                try {  
                    if ($null -ne $myFolderItem.Id_New) {
                        $myFolderAPI = $ReportRestAPIURI + "/api/v2.0/Folders(" + $myFolderId_New + ")/"
                        $myHidden = $myFolderItem.Hidden
                        $myBody = [PSCustomObject]@{
                            "Hidden"      = $myHidden;
                        } | ConvertTo-Json -Depth 15

                        if ($null -ne $Credential) {
                            Invoke-RestMethod -Method Patch -Uri $myFolderAPI -Credential $Credential -Body $myBody -ContentType 'application/json; charset=unicode' -UseBasicParsing -Verbose:$false
                        }
                        else {
                            Invoke-RestMethod -Method Patch -Uri $myFolderAPI -UseDefaultCredentials -Body $myBody -ContentType 'application/json; charset=unicode' -UseBasicParsing -Verbose:$false
                        }
                    }
                }
                catch {
                    if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                        "Function : Set-RsFolderPropertiesItems" >> $ErrorFile
                        "Folder Id : $myFolderId"  >> $ErrorFile
                        "Folder Name : $myFolderName"  >> $ErrorFile
                        "Folder Path : $myFolderPath"  >> $ErrorFile
                        $_ >> $ErrorFile  
                        $mySpliter = ("--" + ("==" * 70))
                        $mySpliter >> $ErrorFile 
                    }
                }
            }
            $myFolderResultItems.Add([PSCustomObject]@{"Id" = $myFolderId; "Name" = $myFolderName; "Path" = $myFolderPath; }) | Out-Null
            Write-Verbose ("   Set Properties For Folder ==>> " + $myFolderResultItems.Count + " Of " + $myFolderItems.Count)
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Set-RsFolderPropertiesItems" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter = ("--" + ("==" * 70))
                $mySpliter >> $ErrorFile 
            }
        }
    }
}