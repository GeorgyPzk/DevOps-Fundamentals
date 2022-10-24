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

        # Check if network_mask num 
        if ($network_mask.Length -ge 3){
            [IPAddress]$mask = [Net.IPAddress]::Parse($network_mask)
            Write-Host "tst"
        } else {
            # Convert num to demical IP
            $network_mask = ([math]::Pow(2,$network_mask) - 1) * ([math]::Pow(2,32-$network_mask))
            # Convert demical IP to standart IP form
            $bin = [Convert]::ToString($network_mask,2)
            $fullBin = "0" * (32 - $bin.Length) + $bin
            $network_mask_str=[string]::Join(".", $(0,8,16,24 | %{[Convert]::ToInt32($fullBin.Substring($_,8),2)}))
            [IPAddress]$mask = [Net.IPAddress]::Parse($network_mask_str)
        }
        $ipAddr1 = [Net.IPAddress]::Parse($ip_address_1)
        $ipAddr2 = [Net.IPAddress]::Parse($ip_address_2)

        Write-Host "
            IP Address 1: $($ipAddr1.IPAddressToString)
            IP Address 2: $($ipAddr2.IPAddressToString)
            Mask: $($mask.IPAddressToString)
        " -ForegroundColor DarkMagenta
        # Getting subnets of IPs
        $ipAddr1Band =  $ipAddr1.Address -band $mask.Address
        $ipaddr2Band =  $ipAddr2.Address -band $mask.Address
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
