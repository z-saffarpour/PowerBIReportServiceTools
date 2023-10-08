<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/PowerBIReports/GetPowerBIReports
#>
function Get-RsPBIReportContentItems {
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
            $myPowerBIReportJSON = '[{"Id":"9b073715-a39c-453b-b2eb-2851acbf704e","Name":"Test","Path":"/MobileReport/Test"}]'
            $myCredential = Get-Credential
            Get-RsPBIReportContentItems -WebPortalURL "http://localhost/reports" -Credential $myCredential -PowerBIReportItemsJSON $myPowerBIReportJSON -PowerBIReportContentPath "C:\Temp" -ErrorFile "C:\Temp\Error_20231003.txt"
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
        $PowerBIReportItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $PowerBIReportContentPath,
        $ErrorFile
    )
    Begin {
        $myReportResultItems = New-Object System.Collections.ArrayList
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            $myReportItems = $PowerBIReportItemsJSON | ConvertFrom-Json 
            if (!(Test-Path -Path $PowerBIReportContentPath)) {
                New-Item -ItemType Directory -Path $PowerBIReportContentPath | Out-Null
            }
            foreach ($myReportItem in $myReportItems) {
                $myReportId = $myReportItem.Id
                $myReportName = $myReportItem.Name
                $myReportPath = $myReportItem.Path
                try {
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
                    $myReportResultItems.Add([PSCustomObject]@{"Id" = $myReportId; "Name" = $myReportName; "Path" = $myReportPath; }) | Out-Null
                }
                catch {
                    if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                        "Function : Get-RsPBIReportContentItems" >> $ErrorFile
                        "Report Id : $myReportId"  >> $ErrorFile
                        "Report Name : $myReportName"  >> $ErrorFile
                        "Report Path : $myReportPath"  >> $ErrorFile
                        $_ >> $ErrorFile  
                        $mySpliter >> $ErrorFile 
                    }
                }
                finally {
                    Write-Verbose ("   Download PBIReport Content ==>> " + $myReportResultItems.Count + " Of " + $myReportItems.Count)
                }
            }
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsPBIReportContentItems" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter >> $ErrorFile 
            }
        }
    }
}