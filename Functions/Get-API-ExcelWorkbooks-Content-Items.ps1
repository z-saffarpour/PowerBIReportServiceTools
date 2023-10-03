function Get-RsExcelContentItems {
    <#
        .SYNOPSIS
            This function gets the content of the specified ExcelWorkbook CatalogItem.

        .DESCRIPTION
            This function gets the content of the specified ExcelWorkbook CatalogItem.

        .PARAMETER WebPortalURL
            #Specify the name of the WebPortalURL.

        .PARAMETER Credential
            Specify the credentials to use when connecting to the Report Server.

        .PARAMETER ExcelItemsJSON
            Specify the List of Excel File in Json.

        .PARAMETER ExcelContentPath
            Specify the Excel file save path.

        .PARAMETER ErrorFile
            Specify the path to save the exceptions in the file.

        .EXAMPLE
            $myExcelJSON = '[{"Id":"9b073715-a39c-453b-b2eb-2851acbf704e","Name":"Test.xlsx","Path":"/MobileReport/Test.xlsx"}]'
            Get-RsExcelContentItems -WebPortalURL "http://localhost/reports" -Credential -ExcelItemsJSON $myExcelJSON -ExcelContentPath "C:\Temp" -ErrorFile "C:\Temp\Error_20231003.txt"
            Description
            -----------
            
        .LINK
            https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/ExcelWorkbooks/GetExcelWorkbookContent
    #>
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