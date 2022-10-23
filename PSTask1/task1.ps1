param (
    [Parameter(Mandatory)]
    [IPAddress]
    [string]$ip_address_1,

    [Parameter(Mandatory)]
    [IPAddress]
    [string]$ip_address_2,

    [Parameter(Mandatory)]
    [ValidateScript({$_ -In 1..31 -Or [IPAddress]$_})]
    [string]$network_mask
)

begin {
    # Turn all non-terminating errors into terminating ones
    $ErrorActionPreference = "Stop"

    # Suppress breaking changes warnings (https://aka.ms/azps-changewarnings)
    #Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"
    #$WarningPreference = 'SilentlyContinue'

    # Init flags for error handling
    $isErrorState = $false
}

process {
    try {
        Write-Host "Processing..." -ForegroundColor DarkGray

        # Check if network_mask contains '.', because only ip-type mask contain '.'
        if ($network_mask -Match "."){
            [IPAddress]$netMask = [Net.IPAddress]::Parse($network_mask)
        } else {
            # Init var like ip adress
            [IPAddress]$netMask = 0
            # Using type specific to get netmask in string
            $netMask.Address = ([UInt32]::MaxValue) -shl (32 - $network_mask) -shr (32 - $network_mask)
        }
        $ipAddr1 = [Net.IPAddress]::Parse($ip_address_1)
        $ipAddr2 = [Net.IPAddress]::Parse($ip_address_2)

        Write-Host "
            IP Address 1: $($ipAddr1.IPAddressToString)
            IP Address 2: $($ipAddr2.IPAddressToString)
            Mask: $($netMask.IPAddressToString)
        " -ForegroundColor DarkMagenta
        # Getting subnets of IPs
        $ipAddr1Band =  $ipAddr1.Address -band $netMask.address
        $ipaddr2Band =  $ipAddr2.Address -band $netMask.address
        # Compare IPs
        if ($ipAddr2Band -eq $ipAddr1Band) {
            Write-host "ip_address_1 and ip_address_2 belong to the same network" -ForegroundColor Green
            $res = $true
        } else {
            Write-host "ip_address_1 and ip_address_2 do not belong to the same network" -ForegroundColor Red
            $res = $false 
        }

    } catch {
        $isErrorState = $true
        $catchedError = $_
    }
}
end {
    if ($isErrorState) {
        Write-Host "An error occurred in the script `nDetailed information is provided in the error below:" -ForegroundColor Red
        $catchedError
    } else {
        Return $res
    }
}
