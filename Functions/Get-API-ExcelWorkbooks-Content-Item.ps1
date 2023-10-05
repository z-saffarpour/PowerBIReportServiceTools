function Get-RsExcelContentItem {
    <#
        .SYNOPSIS
            This function gets the content of the specified ExcelWorkbook CatalogItem.

        .DESCRIPTION
            This function gets the content of the specified ExcelWorkbook CatalogItem.

        .PARAMETER WebPortalURL
            #Specify the name of the WebPortalURL.

        .PARAMETER Credential
            Specify the credentials to use when connecting to the Report Server.

        .PARAMETER ExcelItemPath
            Specify the ExcelItemPath.

        .PARAMETER ExcelContentPath
            Specify the Excel file save path.

        .PARAMETER ErrorFile
            Specify the path to save the exceptions in the file.

        .EXAMPLE
            $myCredential = Get-Credential
            Get-RsExcelContentItem -WebPortalURL "http://localhost/reports" -Credential -ExcelItemPath "/MobileReport/Test.xlsx" -ExcelContentPath "C:\Temp" -ErrorFile "C:\Temp\Error_20231003.txt"
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
        $ExcelItemPath,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ExcelContentPath,
        $ErrorFile
    )
    Begin {
        $myExcelAPI = $WebPortalURL + "/api/v2.0/ExcelWorkbooks(path='" + $ExcelItemPath + "')"
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            if (!(Test-Path -Path $ExcelContentPath)) {
                New-Item -ItemType Directory -Path $ExcelContentPath | Out-Null
            }
            if ($null -ne $Credential) {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myExcelAPI -Credential $Credential -ContentType 'application/json; charset=unicode' -Verbose:$false
            }
            else {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myExcelAPI -UseDefaultCredentials -ContentType 'application/json; charset=unicode' -Verbose:$false
            }
            $myExcelId = $myResponse.Id
            $myExcelName = $myResponse.Name
            $myExcelPath = $myResponse.Path
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
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsExcelContentItem" >> $ErrorFile
                "ExcelItem Path : $ExcelItemPath"  >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter >> $ErrorFile 
            }
        }
    }
}