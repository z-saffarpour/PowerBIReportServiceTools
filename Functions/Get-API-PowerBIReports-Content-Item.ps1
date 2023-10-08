<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/PowerBIReports/GetPowerBIReports
#>
function Get-RsPBIReportContentItem {
    <#
        .SYNOPSIS
            This function gets the content of the specified PowerBIReport CatalogItem.

        .DESCRIPTION
            This function gets the content of the specified PowerBIReport CatalogItem.

        .PARAMETER WebPortalURL
            #Specify the name of the WebPortalURL.

        .PARAMETER Credential
            Specify the credentials to use when connecting to the Report Server.

        .PARAMETER PowerBIReportItemsJSON
            Specify the List of PowerBIReport in Json.

        .PARAMETER PowerBIReportContentPath
            Specify the PowerBIReport save path.

        .PARAMETER ErrorFile
            Specify the path to save the exceptions in the file.

        .EXAMPLE
            $myCredential = Get-Credential
            Get-RsPBIReportContentItem -WebPortalURL "http://localhost/reports" -Credential $myCredential -PowerBIReportPath "/MobileReport/Test" -PowerBIReportContentPath "C:\Temp" -ErrorFile "C:\Temp\Error_20231003.txt"
            Description
            -----------
            
        .LINK
            https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/PowerBIReports/GetPowerBIReportContent
    #>
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $WebPortalURL,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $PowerBIReportPath,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $PowerBIReportContentPath,
        $ErrorFile
    )
    Begin {
        $myPBIReportAPI = $WebPortalURL + "/api/v2.0/PowerBIReports(path='" + $PowerBIReportPath + "')"
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            if (!(Test-Path -Path $PowerBIReportContentPath)) {
                New-Item -ItemType Directory -Path $PowerBIReportContentPath | Out-Null
            }
            if ($null -ne $Credential) {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myPBIReportAPI -Credential $Credential -ContentType 'application/json; charset=unicode' -Verbose:$false
            }
            else {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myPBIReportAPI -UseDefaultCredentials -ContentType 'application/json; charset=unicode' -Verbose:$false
            }
            $myReportId = $myResponse.Id
            $myReportName = $myResponse.Name
            $myReportPath = $myResponse.Path
            $myPBIContentAPI = $WebPortalURL + '/api/v2.0/PowerBIReports(' + $myReportId + ')/Content/$value'
            $myPBIReportDirectory = $PowerBIReportContentPath + $myReportPath.Substring(0 , $myReportPath.LastIndexOf($myReportName))
            $myPBIContentFile = $myPBIReportDirectory + '\' + $myReportName + '.pbix'    
            if (!(Test-Path -Path $myPBIReportDirectory)) {
                New-Item -ItemType Directory -Path $myPBIReportDirectory | Out-Null
            }
            if ($null -ne $Credential) {
                Invoke-WebRequest -Uri $myPBIContentAPI -OutFile $myPBIContentFile -UseBasicParsing -Credential $Credential -Verbose:$false | Out-Null
            }
            else {
                Invoke-WebRequest -Uri $myPBIContentAPI -OutFile $myPBIContentFile -UseBasicParsing -UseDefaultCredentials -Verbose:$false | Out-Null
            }
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsPBIReportContentItem" >> $ErrorFile
                "PowerBIReport Path : $PowerBIReportPath"  >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter >> $ErrorFile 
            }
        }
    }
}