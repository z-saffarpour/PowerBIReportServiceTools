function Get-RsPBIReport {
    <#
        .SYNOPSIS
            This function gets an Json of PowerBIReport CatalogItems.

        .DESCRIPTION
            This function gets an Json of PowerBIReport CatalogItems.

        .PARAMETER WebPortalURL
            #Specify the name of the WebPortalURL.

        .PARAMETER Credential
            Specify the credentials to use when connecting to the Report Server.

        .PARAMETER ErrorFile
            Specify the path to save the exceptions in the file.

        .EXAMPLE
            Get-RsPBIReport -WebPortalURL "http://localhost/reports" -Credential -ErrorFile "C:\Temp\Error_20231003.txt"
            Description
            -----------
            
        .LINK
            https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/PowerBIReports/GetPowerBIReports
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
        $myPBIReportAPI = $WebPortalURL + '/api/v2.0/PowerBIReports'
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            if ($null -ne $Credential) {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myPBIReportAPI -Credential $Credential -ContentType 'application/json; charset=unicode' -Verbose:$false
            }
            else {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myPBIReportAPI -UseDefaultCredentials -ContentType 'application/json; charset=unicode' -Verbose:$false
            }
            $myResultJSON = $myResponse.value | ConvertTo-Json -Depth 15   
            return , $myResultJSON 
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsPBIReport" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter >> $ErrorFile 
            }
        } 
    }
}