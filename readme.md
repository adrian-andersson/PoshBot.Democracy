# POSHBOT.DEMOCRACY


> A poshbot based slack voting system

[releasebadge]: https://img.shields.io/static/v1.svg?label=version&message=1.1.0&color=blue
[datebadge]: https://img.shields.io/static/v1.svg?label=Date&message=2019-03-23&color=yellow
[psbadge]: https://img.shields.io/static/v1.svg?label=PowerShell&message=5.0.0&color=5391FE&logo=powershell
[btbadge]: https://img.shields.io/static/v1.svg?label=bartender&message=6.1.22&color=0B2047


| Language | Release Version | Release Date | Bartender Version |
|:-------------------:|:-------------------:|:-------------------:|:-------------------:|
|![psbadge]|![releasebadge]|![datebadge]|![btbadge]|


Authors: Adrian.Andersson

Company: Adrian.Andersson

Latest Release Notes: [here](./documentation/1.1.0/release.md)

***

<!--Bartender Dynamic Header -- Code Below Here -->



##  Getting Started

### Installation
How to install:

Setup your poshbot server, add the module, go


#### If you are installing from psgallery via PoshBot

```powershell
Install-Plugin

```


---

### Example

Simple example

```
!newVote -title 'Vote yes or no' -options 'yes','no' 

```

Simple example that will auto-close after 3 votes

```
!newVote -title 'Vote yes or no' -options 'yes','no'  -closeAfter 3

```

***
## What Is It

Simple Slack Voting using PoshBot

## Acknowledgements

Brandon Olin - For PoshBot

## Misc

Has a postBuildScript to automatically pull the poshbot permissions on build, this module does not make use of permissions, so it exists as an example only

<!--Bartender Link, please leave this here if you make use of this module -->
***

## Build With Bartender
> [A PowerShell Module Framework](https://github.com/DomainGroupOSS/bartender)

