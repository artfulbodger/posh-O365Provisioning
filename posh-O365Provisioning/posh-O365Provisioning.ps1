<#
.Synopsis
   Creates a Email forwader to an external address
.DESCRIPTION
   Creates an Email User in Exchange Online and set the external address
.EXAMPLE
   New-ExternalForwader -Name "John Doe" -ExternalEmailAddress john@example.com -UserID john.doe@contoso.com

#>
function New-ExternalForwarder
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        # The Name parameter specifies the unique name of the mail user, no more than 64 characters.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateLength(1,64)]
        [String]$Name,

        # Specifies the target email address of the mail user.
        [Parameter(Mandatory=$true,
                    Position=1)]
        [String]$ExternalEmailAddress,

        # Specifies the user ID for the object.
        [Parameter(Mandatory=$true,
                    Position=2)]
        [string]$UserID 
    )

    Begin
    {
        $UserCredential = Get-Credential
        $Session = New-PSSession -Name "ExchangeOnline" -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
        Import-PSSession $Session -Prefix EXO
    }
    Process
    {
        New-EXOMailUser -Name $Name -ExternalEmailAddress $ExternalEmailAddress -MicrosoftOnlineServicesID $UserID -Password (ConvertTo-SecureString -String 'P@ssw0rd1' -AsPlainText -Force)
    }
    End
    {
        Remove-PSSession -Name "ExchangeOnline"
    }
}

<#
.Synopsis
   Adds or Verifies a Domain for a Tennant
.DESCRIPTION
   If the domain is not associated with the Tennant the domain is added and the Text entry for the DNS zone is returned, If the Domain exists and is unverifed the domain verification is attempted.
.EXAMPLE
   New-o365Domain -domain "contoso.com"
#>
function New-O365Domain
{
    [CmdletBinding()]
    Param
    (
        # Domain Name to add
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $domain
    )

    Begin
    {
        Connect-MsolService
        $txtrecord=@()
        $domainlist = Get-MsolDomain
    }
    Process
    {   
        If ($domainlist.name.Contains($domain) -eq $false) {
            new-msoldomain -Name $domain
            $txtrecord+=(Get-MsolDomainVerificationDNS -DomainName $domain -mode DnsTxtRecord)
            $txtrecord | select-object text,label,ttl
        } else {
            $addeddomain = Get-MsolDomain -DomainName $domain
            If ($addeddomain.Status -eq "unverified") {
                Confirm-MsolDomain -DomainName $domain
            }
        }    
    }                                                                        
    End
    {
    }
}

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Set-AddressBookPolicyConfig
{
    [CmdletBinding()]
    Param
    (
        # Group, District or County Name
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Department
    )

    Begin
    {
        $UserCredential = Get-Credential
        $Session = New-PSSession -Name "ExchangeOnline" -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
        Import-PSSession $Session -Prefix EXO
    }
    Process
    {
        $transportcfg = Get-EXOTransportConfig
        If(!$transportcfg.AddressBookPolicyRoutingEnabled){
            Set-EXOTransportConfig -AddressBookPolicyRoutingEnabled $true
        }
        
        New-EXOAddressList -Name $Department -RecipientFilter "RecipientType -eq 'UserMailbox' -and Department -eq '$Department'" -DisplayName "$Department Address List"
        New-EXOAddressList -Name "$Department Rooms" -RecipientFilter "RecipientDisplayType -eq 'ConferenceRoomMailbox' -and Department -eq '$Department'"
        New-EXOGlobalAddressList -Name "$Department GAL" -RecipientFilter "Department -eq '$Department'"
        New-EXOOfflineAddressBook -Name "$Department OAB" -AddressLists $Department
        New-EXOAddressBookPolicy -Name "$Department ABP" -AddressLists $Department -OfflineAddressBook "\$Department OAB" -GlobalAddressList "\$Department GAL" -RoomList "\$Department Rooms"
    }
    End
    {
        Remove-PSSession -Name "ExchangeOnline"
    }
}
