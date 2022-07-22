Layer 5/6/7 attack tools
========================

## Description:

Set of tools and helpers for attacks on the 5, 6 and 7 layers of the OSI Model.
Some of them I adapted from the Net, some I wrote myself.

Enjoy.

| Name                   | Description                                                                        |
| ---------------------- | ---------------------------------------------------------------------------------- |
| dns_amplflood.py       | Test DNS server against amplification DDoS attack.                                 |
| dns_cachesnoop.pl      | Perform DNS cache snooping against a DNS server.                                   |
| dns_enum.sh            | Enumerate DNS hostnames by brute force guessing of common subdomains.              |
| dns_zoneconf.pl        | Check DNS zone configuration against best practices, including RFC 1912.           |
| dns_zonetransfer.pl    | Perform a zone transfer.                                                           |
| proxy_checker.pl       | Test reliability of open web proxies.                                              |

## Dependencies:

- perl and Net::DNS module
- nmap
- scapy

## See also

- [layer234-attack-tools](https://github.com/chinarulezzz/layer234-attack-tools) - Layer 2, 3 and 4 attack tools.
- smtp-user-enum
- tnscmd10g

<!-- End of file. -->
