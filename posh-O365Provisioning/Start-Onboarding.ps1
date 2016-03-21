$msolcred = get-credential
connect-msolservice -credential $msolcred
 
#Get-MsolAccountSku

$userlist = Import-Csv -Path 'C:\Users\Richard\OneDrive for Business\Office 365\1stWillingham\UserImport.csv' 

foreach ($user in $userlist) {
    $AccountExists = $null
    $AccountExists = Get-Msoluser -UserPrincipalName $user.UserPrincipalName -ErrorAction SilentlyContinue
    If ($AccountExists -eq $null) {
    #we have a user to create
    Write-Host "Creating Account for $user.UserPrincipalName"
    New-MsolUser `
        -DisplayName $user.DisplayName `
        -FirstName $user.FirstName `
        -LastName $user.LastName `
        -Password $user.Password `
        -UserPrincipalName $user.UserPrincipalName `
        -LicenseAssignment 'cambridgeshirescouts:STANDARDWOFFPACK' `
        -UsageLocation GB
        } else {
        Write-Host "Account Exists for " $user.UserPrincipalName
        }
}

foreach ($user in $userlist) {

    Get-MsolUser -UserPrincipalName $user.UserPrincipalName | Set-MsolUserPassword -NewPassword $user.Password -ForceChangePassword $false

}


$cred = get-credential
$s = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $cred -Authentication Basic –AllowRedirection
Import-pssession $s

Connect-MsolService -Credential $cred

$resetlist = Import-Csv -Path 'C:\Users\Richard\OneDrive\Documents\Scouts (1)\Office 365\PasssordResetFile.csv'




foreach ($reset in $resetlist) {
    get-msoluser -UserPrincipalName david.robinson@cambridgeshirescouts.org.uk | Set-MsolUserPassword -NewPassword "Sn0wFl@k3" -ForceChangePassword $false
}