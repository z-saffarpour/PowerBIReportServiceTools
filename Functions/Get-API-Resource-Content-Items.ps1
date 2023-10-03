<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/PowerBIReports/GetPowerBIReports
#>
function Get-RsResourceContentItems {
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
            $myResourceJSON = '[{"Id":"9b073715-a39c-453b-b2eb-2851acbf704e","Name":"Test.pdf","Path":"/MobileReport/Test.pdf"}]'
            Get-RsResourceContentItems -WebPortalURL "http://localhost/reports" -Credential -ResourceItemsJSON $myResourceJSON -ResourceContentPath "C:\Temp" -ErrorFile "C:\Temp\Error_20231003.txt"
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
        $ResourceItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ResourceContentPath,
        $ErrorFile
    )
    Begin {
        $myResourceResultItems = New-Object System.Collections.ArrayList
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            $myResourceItems = $ResourceItemsJSON | ConvertFrom-Json 
            if (!(Test-Path -Path $ResourceContentPath)) {
                New-Item -ItemType Directory -Path $ResourceContentPath | Out-Null
            }
            foreach ($myResourceItem in $myResourceItems) {
                $myResourceId = $myResourceItem.Id
                $myResourceName = $myResourceItem.Name
                $myResourcePath = $myResourceItem.Path
                try {
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
                    $myResourceResultItems.Add([PSCustomObject]@{"Id" = $myResourceId; "Name" = $myResourceName; "Path" = $myResourcePath; }) | Out-Null
                }
                catch {
                    if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                        "Function : Get-RsResourceContentItems" >> $ErrorFile
                        "Resource Id : $myResourceId"  >> $ErrorFile
                        "Resource Name : $myResourceName"  >> $ErrorFile
                        "Resource Path : $myResourcePath"  >> $ErrorFile
                        $_ >> $ErrorFile  
                        $mySpliter >> $ErrorFile 
                    }
                }
                finally {
                    Write-Verbose ("   Download Resource Content ==>> " + $myResourceResultItems.Count + " Of " + $myResourceItems.Count)
                }
            }
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsResourceContentItems" >> $ErrorFile
                $_ >> $ErrorFile
                $mySpliter >> $ErrorFile 
            }
        }
    }
}