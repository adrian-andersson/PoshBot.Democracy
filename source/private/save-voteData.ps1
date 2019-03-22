function save-voteData
{

    <#
        .SYNOPSIS
            Save the vote data
            
        .DESCRIPTION
            Save the vote data

        .PARAMETER voteData
            Hashtable of the voteData
            
        .PARAMETER path
            Path to the xml file

            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
                2019-03-22 - AA
                    - Initial Script
                    
        .COMPONENT
            What cmdlet does this script live in
    #>

    [CmdletBinding()]
    PARAM(
        [Parameter()]
        [string]$Path = 'c:\poshbot\voteData\voteData.xml',
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [hashtable]$voteData
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
    }
    
    process{
        $folder = split-path $Path -Parent
        $file = split-path $Path -Leaf
        
        write-verbose 'Checking for directory'
        if(!$(test-path $folder))
        {
            write-warning 'Folder does not exist'
            new-item -ItemType Directory -Path $folder -Force
            write-verbose "New directory created at $folder"
        }else{
            write-verbose "Directory exists at $folder"
        }

        $voteData | Export-Clixml -Path $path -Depth 6


    }
    
}