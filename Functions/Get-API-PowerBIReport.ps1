<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/PowerBIReports/GetPowerBIReports
#>
function Get-RsPBIReport {
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