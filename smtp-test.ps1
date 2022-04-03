# This is just a generic test message; get's split into an array of commands
$Global:defaultBody = Get-Content .\EmailMessage.txt

<#
  A DNS Name resolving function
  Designed to be flexible, and work with a list of hostnames
  Can use a specific DNS server/s, or use the one for local interfaces
  Also allows for Type/s, or ALL (either text or * character)
#>
function Get-DNSResolved {
  [cmdletbinding()]
  param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeLine)]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $Hostname,
    [Parameter(Mandatory=$false, Position=1)]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $Server,
    [Parameter(Mandatory=$false, Position=2)]
    [ValidateSet("UNKNOWN", "A_AAAA", "A", "NS", "MD", "MF", "CNAME", "SOA", "MB", "MG", "MR", "NULL", "WKS", "PTR", "HINFO", "MINFO", "MX", "TXT", "RP",
    "AFSDB", "X25", "ISDN", "RT", "AAAA", "SRV", "DNAME", "OPT", "DS", "RRSIG", "NSEC", "DNSKEY", "DHCID", "NSEC3", "NSEC3PARAM", "ANY", "ALL", "WINS",
    "*", ignorecase=$true)]
    [string[]]
    $Type = @("A")
  )
  begin{
    if($type -contains "*"){$Type = @("ALL")}
    $results = @()
  }
  process{
    foreach($hn in $hostname){
      foreach($typ in $type){
        if($null -eq $server -or $server -eq @()){
          $results += Resolve-DNSName -Name $hn -Type $Typ
        }
        else{
          foreach($serv in $server){
            $cnt = $results.count
            $results += Resolve-DNSName -Name $hn -Type $Typ -Server $serv
            $results[(($results.count - $cnt) * -1)..-1] | ForEach-Object{$_.Name += " ($($serv))"}
          }
        }
      }
    }
  }
  end{
    return $results
  }
}

# No TLS / SSL support yet...
function Run-SMTPTest {
  [cmdletbinding()]
  param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeLine)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Recipient,
    [Parameter(Mandatory=$false, Position=1)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Subject = "SMTP Testing - IT Administration",
    [Parameter(Mandatory=$false, Position=2)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Sender = "SMTPTest@FakeDomain.com",
    [Parameter(Mandatory=$false, Position=3)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Server = "",
    [Parameter(Mandatory=$false, Position=4)]
    [ValidateNotNullOrEmpty()]
    [int32]
    $ServerPort = 25,
    [Parameter(Mandatory=$false, Position=5)]
    [ValidateSet("Inbound","INB","IN","OUT","OUTB","OUTBOUND", ignorecase=$true)]
    [int32]
    $Direction = "Inbound"
  )
  # Need to figure out the possible mode we are going for...
  begin{
    # Figure out whether inbound / outbound (Inbound meaning you focus on recipient end / sending as a server, or Outbound as in connecting
    # to the desired server for sending - I.e. Exchange Online)
    if($direction.ToUpper() -in @("INBOUND","INB","IN")){
      $domain = ($Recipient -split "@")[-1]
    }else{
      $domain = ($Sender -split "@")[-1]
    }
    # Since a custom server is not defined, let's just set it to what the MX record of the Sender's domain
    # NOTE: it will likely return as multiple IPs depending on the server; so logic should be set to try one, and then the next...
    #       until either one works or all fail
    if($Server -eq "" -or $null -eq $Server){
      $Server = (Get-DNSResolved (Get-DNSResolved $domain -Type MX).NameExchange).IPAddress
    }
  }
  process{
    ## Process will involve handling the connection, and going through a specific series of commands up until the attempt
    ## Of actually sending the email
  }
  end{
    
  }
}


while($tcp.connected)
{
write-host ([char]$Reader.Read()) -NoNewLine
while(($reader.Peek() -ne -1) -or ($tcp.Available)){
write-host ([char]$reader.Read()) -NoNewLine
}
if($tcp.connected)
{
write-host -NoNewLine "_"
$command = Read-Host
if($command -eq "escape")
{
break
}
$writer.WriteLine($command)|Out-Null
}
}
$reader.Close()
$writer.close()
$tcp.Close()
