function get-voteData
{

    <#
        .SYNOPSIS
            Get the vote data
            
        .DESCRIPTION
            Get the vote data
            
        .PARAMETER path
            Path to the xml file

        .EXAMPLE
            verb-noun param1
            
            #### DESCRIPTION
            Line by line of what this example will do
            
            
            #### OUTPUT
            Copy of the output of this line
            
            
            
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
        [string]$Path = 'c:\poshbot\voteData\voteData.xml'
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
            new-item -ItemType Directory -Path $folder -Force
            write-verbose "New directory created at $folder"
        }else{
            write-verbose "Directory exists at $folder"
        }

        write-verbose 'Checking for file'
        if(!$(test-path $Path))
        {
            write-verbose 'File not found, creating hash'
            $voteHash = @{}
            
        }else{
            write-verbose 'File found, importing'
            $voteHash = import-clixml $path
        }

        return $voteHash


    }
    
}