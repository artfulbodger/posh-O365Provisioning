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