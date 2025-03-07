get-aduser -filter * | select name,samaccountname

Get-ADGroupMember -Identity "domain admins" | select name,samaccountname

get-aduser james -Properties *

Unlock-ADAccount -Identity james

Search-ADAccount -LockedOut

get-aduser -filter * | Where-Object {passwordlastset -gt ((get-date).AddDays(-365))}


Get-SmbShare





$users = import-csv 'C:\users\bob\Desktop\Creation Template Example.csv'


new-aduser -GivenName $u.givenname -DisplayName $u.displayname -Surname $u.sn -name $u.givenName -pass

foreach ($u in $users){
$password = ConvertTo-SecureString $u.password -AsPlainText -force
$userdata = @{
    GivenName = $u.givenname 
    DisplayName = $u.displayname 
    Surname = $u.sn 
    name = $u.givenName
    password = (ConvertTo-SecureString $u.password -AsPlainText -force)
}
    new-aduser @userdata
    }

set-aduser james -Manager "bob"
