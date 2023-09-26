<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/PowerBIReports/GetPowerBIReports
#>
function Get-RsResourceContentItems {
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ReportRestAPIURI,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ResourceItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ResourceContentPath,
        $ErrorFile
    )
    Begin {
        try {
            $myResourceItems = $ResourceItemsJSON | ConvertFrom-Json 
            $myResourceResultItems = New-Object System.Collections.ArrayList
            if (!(Test-Path -Path $ResourceContentPath)) {
                New-Item -ItemType Directory -Path $ResourceContentPath | Out-Null
            }
            foreach ($myResourceItem in $myResourceItems) {
                $myResourceId = $myResourceItem.Id
                $myResourceName = $myResourceItem.Name
                $myResourcePath = $myResourceItem.Path
                try {
                    $myResourceContentAPI = $ReportRestAPIURI + '/api/v2.0/Resources(' + $myResourceId + ')/Content/$value'
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
                        $mySpliter = ("--" + ("==" * 70))
                        $mySpliter >> $ErrorFile 
                    }
                }
                finally {
                    Write-Verbose ("   ResourceContent ==>> " + $myResourceResultItems.Count + " Of " + $myResourceItems.Count)
                }
            }
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsResourceContentItems" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter = ("--" + ("==" * 70))
                $mySpliter >> $ErrorFile 
            }
        }
    }
}