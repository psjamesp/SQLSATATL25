function new-userpassword1 {
    param (
        [Parameter(Mandatory = $true)]
        [int]$length
    )
    $password = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count $length | % { [char]$_ })
    return $password
}
new-userpassword1 -length 19