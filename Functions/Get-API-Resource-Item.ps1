function Get-RsResourceItem {
    <#
        .SYNOPSIS
            This function gets an Json of Resource CatalogItems.

        .DESCRIPTION
            This function gets an Json of Resource CatalogItems.

        .PARAMETER WebPortalURL
            #Specify the name of the WebPortalURL.

        .PARAMETER Credential
            Specify the credentials to use when connecting to the Report Server.

        .PARAMETER ErrorFile
            Specify the path to save the exceptions in the file.

        .EXAMPLE
            $myCredential = Get-Credential
            Get-RsResourceItem -WebPortalURL "http://localhost/reports" -Credential $myCredential -ResourcePath "/MobileReport/Test.pdf" -ErrorFile "C:\Temp\Error_20231003.txt"
            Description
            -----------
            
        .LINK
            https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/Resources/GetResources
    #>  
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $WebPortalURL,
        [System.Management.Automation.PSCredential]
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ResourcePath,
        $ErrorFile
    )
    Begin {
        $myResourceAPI = $WebPortalURL + "/api/v2.0/Resources(path='" + $ResourcePath + "')"
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            if ($null -ne $Credential) {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myResourceAPI -Credential $Credential -ContentType 'application/json; charset=unicode' -Verbose:$false
            }
            else {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myResourceAPI -UseDefaultCredentials -ContentType 'application/json; charset=unicode' -Verbose:$false
            }
            $myResultJSON = $myResponse | Select-Object Id, Name, Description, Path, Type, Hidden, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate| ConvertTo-Json -Depth 15     
            return , $myResultJSON 
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsResourceItem" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter >> $ErrorFile 
            }
        } 
    }
}