function New-SystemScheduleItems { 
    
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ReportServiceURI,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ScheduleItemsJSON,
        $ErrorFile
    )
    Begin {
        $myProxyURI = $ReportServiceURI + "/ReportService2010.asmx?wsdl"
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            $myScheduleItems = $ScheduleItemsJSON | ConvertFrom-Json
            if ($null -ne $Credential) {
                $myProxy = New-WebServiceProxy -Class 'NewRS' -Namespace 'NewRS' -Uri $myProxyURI -Credential $Credential -Verbose:$false
            }
            else {
                $myProxy = New-WebServiceProxy -Class 'NewRS' -Namespace 'NewRS' -Uri $myProxyURI -UseDefaultCredential -Verbose:$false
            }
            $myScheduleList = $myProxy.ListSchedules([System.Management.Automation.Language.NullString]::Value)
            $myScheduleResult = @()
            foreach ($myScheduleItem in $myScheduleItems) {
                $myScheduleID = $myScheduleItem.ScheduleID
                $myName = $myScheduleItem.Name
                $myDescription = $myScheduleItem.Description
                if (!($myScheduleList | Where-Object { $_.Name -eq $myName })) {
                    try {
                        $myScheduleDefinition = New-Object "NewRS.ScheduleDefinition" 
                        if ($null -ne $myScheduleItem.MinuteInterval) {
                            $myScheduleDefinition.Item = New-Object "NewRS.MinuteRecurrence"
                            $myScheduleDefinition.Item.MinutesInterval = $myScheduleItem.MinuteInterval
                        }
                        elseif ($null -ne $myScheduleItem.DailyInterval) {
                            $myScheduleDefinition.Item = New-Object "NewRS.DailyRecurrence"
                            $myScheduleDefinition.Item.DaysInterval = $myScheduleItem.DailyInterval
                        }
                        elseif ($null -ne $myScheduleItem.WeeklyInterval) {
                            $myScheduleDefinition.Item = New-Object "NewRS.WeeklyRecurrence"
                            $myScheduleDefinition.Item.WeeklyInterval = $myScheduleItem.WeeklyInterval
                        }
                        elseif ($null -ne $myScheduleItem.MonthlyInterval) {
                            $myScheduleDefinition.Item = New-Object "NewRS.MonthlyRecurrence"
                            $myScheduleDefinition.Item.MonthlyInterval = $myScheduleItem.MonthlyInterval
                        }
                        elseif ($null -ne $myScheduleItem.MonthlyDOWInterval) {
                            $myScheduleDefinition.Item = New-Object "NewRS.MonthlyDOWRecurrence"
                            $myScheduleDefinition.Item.MonthlyDOWInterval = $myScheduleItem.MonthlyDOWInterval
                        }
                        $myScheduleDefinition.StartDateTime = [datetime]($myScheduleItem.StartDateTime)
                        $mySiteUrl = [System.Management.Automation.Language.NullString]::Value

                        $myScheduleID_New = $myProxy.CreateSchedule($myName, $myScheduleDefinition, $mySiteUrl)

                        $myScheduleResult += [PSCustomObject]@{
                            "ScheduleID"         = $myScheduleID;
                            "Name"               = $myName;
                            "Description"        = $myDescription;
                            "ScheduleStateName"  = $myScheduleItem.ScheduleStateName;
                            "StartDateTime"      = $myScheduleItem.StartDateTime;
                            "MinuteInterval"     = $myScheduleItem.MinuteInterval;
                            "DailyInterval"      = $myScheduleItem.DailyInterval;
                            "WeeklyInterval"     = $myScheduleItem.WeeklyInterval;
                            "MonthlyInterval"    = $myScheduleItem.MonthlyInterval;
                            "MonthlyDOWInterval" = $myScheduleItem.MonthlyDOWInterval;
                            "ScheduleID_New"     = $myScheduleID_New;
                        }
                    }
                    catch {
                        if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                            "Function : New-SystemScheduleItems" >> $ErrorFile
                            "Name : $myName" >> $ErrorFile
                            "Description : $myDescription" >> $ErrorFile
                            $_ >> $ErrorFile
                            $mySpliter >> $ErrorFile 
                        }
                    }
                    finally {
                        Write-Verbose ("   Create Shared Schedule ==>> " + $myScheduleResult.Count + " Of " + $myScheduleItems.Count)
                    }
                }
            }
            $myResultJSON = $myScheduleResult | ConvertTo-Json -Depth 15
            return , $myResultJSON
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : New-SystemScheduleItems" >> $ErrorFile
                $_ >> $ErrorFile
                $mySpliter >> $ErrorFile 
            }
        }
    }
}