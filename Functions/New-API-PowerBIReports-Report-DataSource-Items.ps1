<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/Folders
#>
function New-RsReportDataSourceItems {
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ReportRestAPIURI,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $UploadPowerBIReportItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $PowerBIReportDataSourceItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $PowerBIReportCredentialItemsJSON,
        $ErrorFile
    )
    Begin {
        try {
            $myReportItems = $UploadPowerBIReportItemsJSON | ConvertFrom-Json
            $myReportDataSourceItems = $PowerBIReportDataSourceItemsJSON | ConvertFrom-Json
            $myReportCredentialItems = $PowerBIReportCredentialItemsJSON | ConvertFrom-Json
            $myReportResultItems = New-Object System.Collections.ArrayList
            foreach ($myReportItem in $myReportItems) {
                $myReportId = $myReportItem.Id
                $myReportName = $myReportItem.Name
                $myReportPath = $myReportItem.Path   
                $myReportId_New = $myReportItem.Id_New   
                $myReportDataSourceItem = $myReportDataSourceItems | Where-Object { $_.ReportId -eq $myReportId } 
                if ($null -ne $myReportItem.Id_New) {
                    $myPowerBIReportAPI = $ReportRestAPIURI + "/api/v2.0/PowerBIReports(" + $myReportId_New + ")/DataSources"
                    try {
                        if ($null -ne $Credential) {
                            $myResponse = Invoke-RestMethod -Method Get -Uri $myPowerBIReportAPI -Credential $Credential -ContentType 'application/json; charset=unicode' -Verbose:$false
                        }
                        else {
                            $myResponse = Invoke-RestMethod -Method Get -Uri $myPowerBIReportAPI -UseDefaultCredentials -ContentType 'application/json; charset=unicode' -Verbose:$false
                        }
                        $myUploadDataSourceItems = $myResponse.value
                        foreach ($myDataSourceItem in $myReportDataSourceItem.DataSources) {
                            $myUploadDataSourceItem = $myUploadDataSourceItems | Where-Object { $_.ConnectionString -eq $myDataSourceItem.ConnectionString }
                            if ($null -ne $myUploadDataSourceItem -and $null -ne $myDataSourceItem.DataModelDataSource.Username) {
                                $myUploadDataSourceItem.DataModelDataSource.AuthType = $myDataSourceItem.DataModelDataSource.AuthType
                                $myReportCredentialItem = $myReportCredentialItems | Where-Object { $_.Username -eq $myDataSourceItem.DataModelDataSource.Username }
                                if ($null -ne $myReportCredentialItem) {
                                    $myUploadDataSourceItem.DataModelDataSource.Username = $myReportCredentialItem.CredentialUsername
                                    $myUploadDataSourceItem.DataModelDataSource.Secret = $myReportCredentialItem.CredentialPassword
                                    if ($myUploadDataSourceItem.DataModelDataSource.Kind -eq "AnalysisServices") {
                                        $myUploadDataSourceItem.DataModelDataSource.AuthType = "Impersonate"
                                    }
                                }
                                else {
                                    $myUploadDataSourceItem.DataModelDataSource.Username = $myDataSourceItem.DataModelDataSource.Username
                                    $myUploadDataSourceItem.DataModelDataSource.Secret = ""
                                }
                            }
                        }
                        $myUploadDataSourceArray = @($myUploadDataSourceItems)
                        $myBody = ConvertTo-Json -InputObject $myUploadDataSourceArray -Depth 15
                        if ($null -ne $Credential) {
                            $myResponse = Invoke-RestMethod -Method PATCH -Uri $myPowerBIReportAPI -Credential $Credential -Body $myBody -ContentType 'application/json; charset=unicode' -Verbose:$false
                        }
                        else {
                            $myResponse = Invoke-RestMethod -Method PATCH -Uri $myPowerBIReportAPI -UseDefaultCredentials -Body $myBody -ContentType 'application/json; charset=unicode' -Verbose:$false
                        }
                    }
                    catch {
                        if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                            "Function : New-RsReportContentItems" >> $ErrorFile
                            "Report Id : $myReportId"  >> $ErrorFile
                            "Report Name : $myReportName"  >> $ErrorFile
                            "Report Path : $myReportPath"  >> $ErrorFile
                            $_ >> $ErrorFile  
                            $mySpliter = ("--" + ("==" * 70))
                            $mySpliter >> $ErrorFile 
                        }
                    }
                }
                $myReportResultItems.Add([PSCustomObject]@{"Id" = $myReportId; "Name" = $myReportName; "Path" = $myReportPath; }) | Out-Null
                Write-Verbose ("   Set DataSource For Report ==>> " + $myReportResultItems.Count + " Of " + $myReportItems.Count)
            }
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : New-RsReportContentItems" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter = ("--" + ("==" * 70))
                $mySpliter >> $ErrorFile 
            }
        }
    }
}