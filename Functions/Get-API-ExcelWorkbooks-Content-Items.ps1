<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/PowerBIReports/GetPowerBIReports
#>
function Get-RsExcelContentItems {
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $WebPortalURL,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ExcelItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ExcelContentPath,
        $ErrorFile
    )
    Begin {
        $myExcelResultItems = New-Object System.Collections.ArrayList
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            $myExcelItems = $ExcelItemsJSON | ConvertFrom-Json 
            if (!(Test-Path -Path $ExcelContentPath)) {
                New-Item -ItemType Directory -Path $ExcelContentPath | Out-Null
            }
            foreach ($myExcelItem in $myExcelItems) {
                $myExcelId = $myExcelItem.Id
                $myExcelName = $myExcelItem.Name
                $myExcelPath = $myExcelItem.Path
                try {
                    $myExcelContentAPI = $WebPortalURL + '/api/v2.0/ExcelWorkbooks(' + $myExcelId + ')/Content/$value'
                    $myExcelDirectory = $ExcelContentPath + $myExcelPath.Substring(0 , $myExcelPath.LastIndexOf($myExcelName))
                    $myExcelContentFile = $myExcelDirectory + '\' + $myExcelName    
                    if (!(Test-Path -Path $myExcelDirectory)) {
                        New-Item -ItemType Directory -Path $myExcelDirectory | Out-Null
                    }
                    if ($null -ne $Credential) {
                        Invoke-WebRequest -Uri $myExcelContentAPI -OutFile $myExcelContentFile -UseBasicParsing -Credential $Credential -Verbose:$false | Out-Null
                    }
                    else {
                        Invoke-WebRequest -Uri $myExcelContentAPI -OutFile $myExcelContentFile -UseBasicParsing -UseDefaultCredentials -Verbose:$false | Out-Null
                    }
                    $myExcelResultItems.Add([PSCustomObject]@{"Id" = $myExcelId; "Name" = $myExcelName; "Path" = $myExcelPath; }) | Out-Null
                }
                catch {
                    if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                        "Function : Get-RsExcelContentItems" >> $ErrorFile
                        "Excel Id : $myExcelId"  >> $ErrorFile
                        "Excel Name : $myExcelName"  >> $ErrorFile
                        "Excel Path : $myExcelPath"  >> $ErrorFile
                        $_ >> $ErrorFile  
                        $mySpliter >> $ErrorFile 
                    }
                }
                finally {
                    Write-Verbose ("   Download Excel Content ==>> " + $myExcelResultItems.Count + " Of " + $myExcelItems.Count)
                }
            }
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsExcelContentItems" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter >> $ErrorFile 
            }
        }
    }
}