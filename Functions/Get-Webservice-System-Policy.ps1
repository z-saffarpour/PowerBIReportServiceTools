function Get-SystemPolicy {
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ReportServiceURI,
        [System.Management.Automation.PSCredential] 
        $Credential,
        $ErrorFile
    )
    Begin {
        try {
            $myProxyURI = $ReportServiceURI + "/ReportService2010.asmx?wsdl"
            $mySystemPolicyItems = New-Object System.Collections.ArrayList
            if ($null -ne $Credential) {
                $myProxy = New-WebServiceProxy -Class 'RS' -Namespace 'RS' -Uri $myProxyURI -Credential $Credential -Verbose:$false
            }
            else {
                $myProxy = New-WebServiceProxy -Class 'RS' -Namespace 'RS' -Uri $myProxyURI -UseDefaultCredential -Verbose:$false
            }
            $mySystemPolicies = $myProxy.GetSystemPolicies()
            foreach ($mySystemPolicyItem in $mySystemPolicies) {
                $myRoleItems = New-Object System.Collections.ArrayList
                foreach ($myRole in $mySystemPolicyItem.Roles) {
                    $myRoleItems.Add([PSCustomObject]@{"Name" = $myRole.Name; "Description" = $myRole.Description; }) | Out-Null
                }
                $mySystemPolicyItems.Add([PSCustomObject]@{"GroupUserName" = $mySystemPolicyItem.GroupUserName; "Roles" = $myRoleItems; }) | Out-Null
            }
            $myResultJSON = $mySystemPolicyItems | ConvertTo-Json -Depth 15
            return , $myResultJSON  
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-SystemPolicy" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter = ("--" + ("==" * 70))
                $mySpliter >> $ErrorFile 
            }
        }
    }
}