function Grant-SystemPolicyItems { 
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ReportServiceURI,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $SystemPolicyItemsJSON,
        $ErrorFile
    )
    Begin {
        try {
            $mySystemPolicyItems = $SystemPolicyItemsJSON | ConvertFrom-Json
            $myProxyURI = $ReportServiceURI + "/ReportService2010.asmx?wsdl"
            if ($null -ne $Credential) {
                $myProxy = New-WebServiceProxy -Class 'RS' -Namespace 'RS' -Uri $myProxyURI -Credential $Credential -Verbose:$false
            }
            else {
                $myProxy = New-WebServiceProxy -Class 'RS' -Namespace 'RS' -Uri $myProxyURI -UseDefaultCredential -Verbose:$false
            }
            $myOriginalPolicies = $myProxy.GetSystemPolicies()
        
            $myPolicyDataType = 'RS.Policy'
            $myRoleDataType = 'RS.Role'

            $myNumPolicies = $myOriginalPolicies.Length 
            foreach ($mySystemPolicyItem in $mySystemPolicyItems) {
                if (!($myOriginalPolicies | Where-Object { $_.GroupUserName -eq $mySystemPolicyItem.GroupUserName })) {
                    $myNumPolicies = $myNumPolicies + 1
                }
            }
        
            $myNewPolicies = New-Object -TypeName "$myPolicyDataType[]" -ArgumentList $myNumPolicies
            $myPolicyIndex = 0
            foreach ($myOriginalPolicy in $myOriginalPolicies) {
                $myNewPolicies[$myPolicyIndex++] = $myOriginalPolicy
            }

            foreach ($mySystemPolicyItem in $mySystemPolicyItems) {
                if (!($myOriginalPolicies | Where-Object { $_.GroupUserName -eq $mySystemPolicyItem.GroupUserName })) {
                    $myRolesNum = $mySystemPolicyItem.Roles.Count
                    $myNewRoles = New-Object -TypeName "$myRoleDataType[]" -ArgumentList $myRolesNum

                    $myNewRoleIndex = 0
                    foreach ($myRoleItem in $mySystemPolicyItem.Roles) {
                        $myNewRole = New-Object -TypeName $myRoleDataType
                        $myNewRole.Name = $myRoleItem.Name
                        $myNewRoles[$myNewRoleIndex++] = $myNewRole
                    }

                    $myNewPolicy = New-Object -TypeName $myPolicyDataType
                    $myNewPolicy.GroupUserName = $mySystemPolicyItem.GroupUserName

                    $myNewPolicy.Roles = New-Object -TypeName "$myRoleDataType[]" -ArgumentList $myRolesNum
                    $myNewPolicy.Roles = $myNewRoles
                    $myNewPolicies[$myPolicyIndex++] = $myNewPolicy
                }
            }
            if ($myPolicyIndex -gt $myOriginalPolicies.Count) {
                $myProxy.SetSystemPolicies($myNewPolicies)
            }
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Grant-SystemPolicyItems" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter = ("--" + ("==" * 70))
                $mySpliter >> $ErrorFile 
            }
        }
    }
}