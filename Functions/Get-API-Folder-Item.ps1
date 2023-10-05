function Get-RsFolderItem {
    <#
        .SYNOPSIS
            This function gets an Json of Folder CatalogItems.

        .DESCRIPTION
            This function gets an Json of Folder CatalogItems.

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
            Get-RsFolderItem -WebPortalURL "http://localhost/reports" -Credential $myCredential -FolderPath "/Dataset" -ErrorFile "C:\Temp\Error_20231003.txt"
            Description
            -----------
            
        .LINK
            https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/Folders/GetFolders
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
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            if ($null -ne $Credential) {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myFolderAPI -Credential $Credential -ContentType 'application/json; charset=unicode' -Verbose:$false
            }
            else {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myFolderAPI -ContentType 'application/json; charset=unicode' -UseDefaultCredentials -Verbose:$false
            }
            $myResultJSON = $myResponse | Select-Object Id, Name, Description, Path, Type, Hidden, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate| ConvertTo-Json -Depth 15   
            return , $myResultJSON 
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsFolderItem" >> $ErrorFile
                "Folder Path : $FolderPath"  >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter >> $ErrorFile 
            }
        }
    }
}