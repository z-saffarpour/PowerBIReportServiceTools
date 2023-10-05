function Get-RsExcelItem {
    <#
        .SYNOPSIS
            This function gets an Json of ExcelWorkbook CatalogItems.

        .DESCRIPTION
            This function gets an Json of ExcelWorkbook CatalogItems.

        .PARAMETER WebPortalURL
            #Specify the name of the WebPortalURL.

        .PARAMETER Credential
            Specify the credentials to use when connecting to the Report Server.

        .PARAMETER ExcelItemPath
            Specify the ExcelItemPath.
        
        .PARAMETER ErrorFile
            Specify the path to save the exceptions in the file.

        .EXAMPLE
            $myCredential = Get-Credential
            Get-RsExcelItem -WebPortalURL "http://localhost/reports" -Credential $myCredential -ExcelItemPath "/MobileReport/Test.xlsx" -ErrorFile "C:\Temp\Error_20231003.txt"
            Description
            -----------
            
        .LINK
            https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/ExcelWorkbooks/GetExcelWorkbooks
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
        $ErrorFile
    )
    Begin {
        $myExcelAPI = $WebPortalURL + "/api/v2.0/ExcelWorkbooks(path='" + $ExcelItemPath + "')"
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            if ($null -ne $Credential) {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myExcelAPI -Credential $Credential -ContentType 'application/json; charset=unicode' -Verbose:$false
            }
            else {
                $myResponse = Invoke-RestMethod -Method Get -Uri $myExcelAPI -UseDefaultCredentials -ContentType 'application/json; charset=unicode' -Verbose:$false
            }
            $myResultJSON = $myResponse | Select-Object Id, Name, Description, Path, Type, Hidden, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate| ConvertTo-Json -Depth 15   
            return , $myResultJSON 
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-RsExcelItem" >> $ErrorFile
                "ExcelItem Path : $ExcelItemPath"  >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter >> $ErrorFile 
            }
        } 
    }
}