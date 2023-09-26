<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/Folders
#>
function New-RsFolderItems { 
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
            $myFolderURI = $ReportRestAPIURI + "/api/v2.0/Folders"
            $myFolderItems = $FolderItemsJSON | ConvertFrom-Json 
            $myFolderResult = New-Object System.Collections.ArrayList
            foreach ($myFolderItem in $myFolderItems) {
                $myFolderId = $myFolderItem.Id
                $myFolderName = $myFolderItem.Name
                $myFolderPath = $myFolderItem.Path
                try {
                    $myBody = @{
                        "Id"   = $myFolderId;
                        "Name" = $myFolderName;
                        "Path" = $myFolderPath;
                    } | ConvertTo-Json -Depth 15
                    if ($null -ne $Credential) {
                        $myResponse = Invoke-RestMethod -Method Post -Uri $myFolderURI -Credential $Credential -Body $myBody -ContentType 'application/json; charset=unicode' -Verbose:$false
                    }
                    else {
                        $myResponse = Invoke-RestMethod -Method Post -Uri $myFolderURI -UseDefaultCredentials -Body $myBody -ContentType 'application/json; charset=unicode' -Verbose:$false
                    }
    
                    $myFolderResult.Add([PSCustomObject]@{"Id" = $myFolderId; "Name" = $myFolderName; "Path" = $myFolderPath; "Id_New" = $myResponse.Id }) | Out-Null    
                }
                catch {
                    if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                        "Function : New-RsFolderItems" >> $ErrorFile
                        "Folder Id : $myFolderId"  >> $ErrorFile
                        "Folder Name : $myFolderName"  >> $ErrorFile
                        "Folder Path : $myFolderPath"  >> $ErrorFile
                        $_ >> $ErrorFile  
                        $mySpliter = ("--" + ("==" * 70))
                        $mySpliter >> $ErrorFile 
                    }
                }
                finally {
                    Write-Verbose ("   Create Folder ==>> " + $myFolderResult.Count + " Of " + $myFolderItems.Count)
                }
            }
            $myResultJSON = $myFolderResult | ConvertTo-Json -Depth 15
            return , $myResultJSON 
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : New-RsFolderItems" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter = ("--" + ("==" * 70))
                $mySpliter >> $ErrorFile 
            }
        }
    }
}