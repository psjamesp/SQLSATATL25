function Restart-bitsService {
    Restart-Service bits -force
}

Restart-bitsService

function new-userpassword {
    $password = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 8 | % { [char]$_ })
    return $password
}

new-userpassword

function new-userpassword1 {
    param (
        $length = 8
    )
    $password = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count $length | % { [char]$_ })
    return $password
}
new-userpassword1 -length 19

function new-userpassword1 {
    param (
        [Parameter(Mandatory = $true)]
        [int]$length
    )
    $password = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count $length | % { [char]$_ })
    return $password
}
new-userpassword1 -length 19


function new-userpassword1 {
    param (
        [Parameter(Mandatory = $true)]
        [int]$length
    )
    If ( $length -lt 8 -or $length -gt 45) {
        Write-Error "Password length must be at least 8 characters"
    }
    else {
        $password = -join ((65..90) + (97..122) + (48..57) + "!" + "@" + "#" | Get-Random -Count $length | % { [char]$_ })
        return $password
    }
}
new-userpassword1 -length 32

1..10
"a".."z"
"A".."Z"

function FunctionName {
    param (
        [ValidateSet("bits", "spooler", "xbox")]    
    $servicename
    )
    Restart-service -name $servicename
}
FunctionName -servicename bbiuviuy