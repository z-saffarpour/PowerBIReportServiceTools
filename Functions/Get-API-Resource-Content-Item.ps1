<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/PowerBIReports/GetPowerBIReports
#>
function Get-RsResourceContentItem {
    <#
        .SYNOPSIS
            This function gets the content of the specified Resource CatalogItem.

        .DESCRIPTION
            This function gets the content of the specified Resource CatalogItem.

        .PARAMETER WebPortalURL
            #Specify the name of the WebPortalURL.

        .PARAMETER Credential
            Specify the credentials to use when connecting to the Report Server.

        .PARAMETER ResourceItemsJSON
            Specify the List of Resource File in Json.

        .PARAMETER ResourceContentPath
            Specify the Resource file save path.

        .PARAMETER ErrorFile
            Specify the path to save the exceptions in the file.

        .EXAMPLE
            $myCredential = Get-Credential
            Get-RsResourceContentItem -WebPortalURL "http://localhost/reports" -Credential $myCredential -ResourcePath "/MobileReport/Test.pdf" -ResourceContentPath "C:\Temp" -ErrorFile "C:\Temp\Error_20231003.txt"
            Description
            -----------
            
        .LINK
            https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/ExcelWorkbooks/GetResourceContent
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
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ResourceContentPath,
        $ErrorFile
    )
    Begin {
        $myResourceAPI = $WebPortalURL + "/api/v2.0/Resources(path='" + $ResourcePath + "')"
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            if (!(Test-Path -Path $ResourceContentPath)) {
                New-Item -ItemType Directory -Path $ResourceContentPath | Out-Null
            }
            if ($null -ne $Credential) {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myResourceAPI -Credential $Credential -ContentType 'application/json; charset=unicode' -Verbose:$false
            }
            else {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myResourceAPI -UseDefaultCredentials -ContentType 'application/json; charset=unicode' -Verbose:$false
            }
            $myResourceId = $myResponse.Id
            $myResourceName = $myResponse.Name
            $myResourcePath = $myResponse.Path
            $myResourceContentAPI = $WebPortalURL + '/api/v2.0/Resources(' + $myResourceId + ')/Content/$value'
            $myResourceDirectory = $ResourceContentPath + $myResourcePath.Substring(0 , $myResourcePath.LastIndexOf($myResourceName))
            $myResourceContentFile = $myResourceDirectory + '\' + $myResourceName    
            if (!(Test-Path -Path $myResourceDirectory)) {
                New-Item -ItemType Directory -Path $myResourceDirectory | Out-Null
            }
            if ($null -ne $Credential) {
                Invoke-WebRequest -Uri $myResourceContentAPI -OutFile $myResourceContentFile -UseBasicParsing -Credential $Credential -Verbose:$false | Out-Null
            }
            else {
                Invoke-WebRequest -Uri $myResourceContentAPI -OutFile $myResourceContentFile -UseBasicParsing -UseDefaultCredentials -Verbose:$false | Out-Null
            }
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsResourceContentItem" >> $ErrorFile
                "Resource Path : $ResourcePath"  >> $ErrorFile
                $_ >> $ErrorFile
                $mySpliter >> $ErrorFile 
            }
        }
    }
}