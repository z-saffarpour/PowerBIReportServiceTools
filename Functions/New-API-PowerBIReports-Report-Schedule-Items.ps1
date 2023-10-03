<#
https://app.swaggerhub.com/apis/microsoft-rs/PBIRS/2.0#/Folders
#>
function New-RsReportScheduleItems {
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ReportRestAPIURI,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $UploadSystemScheduleItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $PowerBIReportScheduleItemsJSON,
        $ErrorFile
    )
    Begin {
        $myCacheRefreshPlanAPI = $ReportRestAPIURI + "/api/v2.0/CacheRefreshPlans"
        $myReportScheduleResultItems = New-Object System.Collections.ArrayList
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            $myUploadSystemScheduleItems = $UploadSystemScheduleItemsJSON | ConvertFrom-Json
            $myReportScheduleItems = $PowerBIReportScheduleItemsJSON | ConvertFrom-Json
            foreach ($myReportScheduleItem in $myReportScheduleItems) {
                $myReportId = $myReportScheduleItem.ReportId
                $myReportName = $myReportScheduleItem.Name
                $myReportPath = $myReportScheduleItem.Path
                try {
                    $myPowerBIReportAPI = $ReportRestAPIURI + "/api/v2.0/PowerBIReports(Path='" + $myReportPath + "')/CacheRefreshPlans"
                    if ($null -ne $Credential) {
                        $myResponse = Invoke-RestMethod -Method Get -Uri $myPowerBIReportAPI -UseBasicParsing -Credential $Credential -ContentType "application/json; charset=unicode" -Verbose:$false
                    }
                    else {
                        $myResponse = Invoke-RestMethod -Method Get -Uri $myPowerBIReportAPI -UseBasicParsing -UseDefaultCredentials -ContentType "application/json; charset=unicode" -Verbose:$false
                    }
                    if (!($null -ne $myResponse.value) -or ($myResponse.value.length -le 0)) {
                        foreach ($myScheduleItem in $myReportScheduleItem.Schedules) {
                            $myScheduleID = $null
                            $myDefinition = $null
                            $mySchedule = $myScheduleItem.Schedule
                            if ($null -ne $mySchedule.ScheduleID) {
                                $myUploadSystemScheduleItem = $myUploadSystemScheduleItems | Where-Object { $_.ScheduleID -eq $mySchedule.ScheduleID } 
                                $myScheduleID = $myUploadSystemScheduleItem.ScheduleID_New
                            }
                            $myDefinition = $mySchedule.Definition
                            $myUploadPBIReportScheduleItem = [PSCustomObject]@{
                                "CatalogItemPath" = $myScheduleItem.CatalogItemPath;
                                "EventType"       = "DataModelRefresh";
                                "Description"     = $myScheduleItem.Description;
                                "Schedule"        = @{
                                    "ScheduleID" = $myScheduleID;
                                    "Definition" = $myDefinition
                                };
                            }
                            $myBody = ConvertTo-Json -InputObject $myUploadPBIReportScheduleItem -Depth 10
                            try {
                                if ($null -ne $Credential) {
                                    Invoke-WebRequest -Uri $myCacheRefreshPlanAPI -Method Post -Body $myBody -ContentType "application/json; charset=unicode" -Credential $Credential -UseBasicParsing -Verbose:$false | Out-Null
                                }
                                else {
                                    Invoke-WebRequest -Uri $myCacheRefreshPlanAPI -Method Post -Body $myBody -ContentType "application/json; charset=unicode" -UseDefaultCredentials -UseBasicParsing -Verbose:$false | Out-Null
                                }
                            }
                            catch {
                                if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                                    "Function : New-RsReportScheduleItems" >> $ErrorFile
                                    "Report Id : $myReportId"  >> $ErrorFile
                                    "Report Name : $myReportName"  >> $ErrorFile
                                    "Report Path : $myReportPath"  >> $ErrorFile
                                    $_ >> $ErrorFile  
                                    $mySpliter >> $ErrorFile 
                                }
                            }
                        }
                    }
                    $myReportScheduleResultItems.Add([PSCustomObject]@{"Id" = $myReportId; "Name" = $myReportName; "Path" = $myReportPath; }) | Out-Null
                }
                catch {            
                    if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                        "Function : New-RsReportScheduleItems" >> $ErrorFile
                        "Report Id : $myReportId"  >> $ErrorFile
                        "Report Name : $myReportName"  >> $ErrorFile
                        "Report Path : $myReportPath"  >> $ErrorFile
                        $_ >> $ErrorFile  
                        $mySpliter >> $ErrorFile 
                    }
                }
                finally {
                    Write-Verbose ("   Set Schedule For Report ==>> " + $myReportScheduleResultItems.Count + " Of " + $myReportScheduleItems.Count)
                }
            }
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : New-RsReportScheduleItems" >> $ErrorFile
                $_ >> $ErrorFile
                $mySpliter >> $ErrorFile 
            }
        }
    }
}
