function Get-RsSystem {
    <#
        .SYNOPSIS
            This function gets the SystemInformation.

        .DESCRIPTION
            This function gets the SystemInformation.

        .PARAMETER WebPortalURL
            #Specify the name of the WebPortalURL.

        .PARAMETER Credential
            Specify the credentials to use when connecting to the Report Server.


        .PARAMETER ErrorFile
            Specify the version of REST Endpoint to use. Valid values are: "v2.0".

        .EXAMPLE
            Get-RsSystem -WebPortalURL "http://localhost/reports" -Credential -ErrorFile "C:\Temp\Error_20231003.txt"
            Description
            -----------
            
        .LINK
            https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/system/Getsystem
    #>
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $WebPortalURL,
        [System.Management.Automation.PSCredential]
        $Credential,
        $ErrorFile
    )
    Begin {
        $mySystemAPI = $WebPortalURL + '/api/v2.0/system'
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            if ($null -ne $Credential) {
                $myResponse = Invoke-RestMethod -Method Get -Uri $mySystemAPI -Credential $Credential -ContentType 'application/json; charset=unicode' -Verbose:$false
            }
            else {
                $myResponse = Invoke-RestMethod -Method Get -Uri $mySystemAPI -UseDefaultCredentials -ContentType 'application/json; charset=unicode' -Verbose:$false
            }
            $myResultJSON = $myResponse.value | ConvertTo-Json -Depth 15   
            return , $myResultJSON 
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsSystem" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter >> $ErrorFile 
            }
        } 
    }
}