Import-Module $PSScriptRoot\..\PowerShellNotebook.psd1 -Force

Describe "Test PS Notebook Content" -Tag "Get-NotebookContent" {

    It "Should have Get-NotebookContent" {
        $actual = Get-Command Get-NotebookContent -ErrorAction SilentlyContinue
        $actual | Should -Not -Be  $Null
    }

    It "testPSNb1.ipynb should have this content" {
        <#
            NoteBookName    Type     Source
            ------------    ----     ------
            testPSNb1.ipynb code     8+12
            testPSNb1.ipynb code     8+3
            testPSNb1.ipynb markdown ## Math...
        #>

        $actual = Get-NotebookContent -NoteBookFullName "$PSScriptRoot\GoodNotebooks\testPSNb1.ipynb"

        $actual.Count | Should -Be 3

        $actual[0].NoteBookName | Should -Be "testPSNb1.ipynb"
        $actual[0].Type | Should -Be "code"
        $actual[0].Source | Should -Be "8+12"

        $actual[1].NoteBookName | Should -Be "testPSNb1.ipynb"
        $actual[1].Type | Should -Be "code"
        $actual[1].Source | Should -Be "8+3"

        $actual[2].NoteBookName | Should -Be "testPSNb1.ipynb"
        $actual[2].Type | Should -Be "markdown"

        $actual[2].Source.IndexOf('## Math') -ge 0 | Should -Be $true
        $actual[2].Source.IndexOf('- show addition') -ge 0 | Should -Be $true
        $actual[2].Source.IndexOf('- show other') -ge 0 | Should -Be $true
    }

    It "testPSNb1.ipynb should have only this code" {
        $actual = Get-NotebookContent -NoteBookFullName "$PSScriptRoot\GoodNotebooks\testPSNb1.ipynb" -JustCode

        $actual.Count | Should -Be 2
        $actual[0].NoteBookName | Should -Be "testPSNb1.ipynb"
        $actual[0].Type | Should -Be "code"
        $actual[0].Source | Should -Be "8+12"

        $actual[1].NoteBookName | Should -Be "testPSNb1.ipynb"
        $actual[1].Type | Should -Be "code"
        $actual[1].Source | Should -Be "8+3"
    }

    It "testPSNb1.ipynb should have only this markdown" {
        $actual = @(Get-NotebookContent -NoteBookFullName "$PSScriptRoot\GoodNotebooks\testPSNb1.ipynb" -JustMarkdown)

        $actual[0].NoteBookName | Should -Be "testPSNb1.ipynb"
        $actual[0].Type | Should -Be "markdown"
 
        $actual[0].Source.IndexOf('## Math') -ge 0 | Should -Be $true
        $actual[0].Source.IndexOf('- show addition') -ge 0 | Should -Be $true
        $actual[0].Source.IndexOf('- show other') -ge 0 | Should -Be $true
    }

    It "Should read ipynb from url" {
        $actual = Get-NotebookContent -NoteBookFullName "https://raw.githubusercontent.com/dfinke/PowerShellNotebook/AddJupyterNotebookMetaInfo/samplenotebook/powershell.ipynb"

        $actual | Should -Not -Be $null
    }

    It "Tests -Passthru Switch" {
        $fileName = "$PSScriptRoot\ChartNotebooks\charts.ipynb"
        $actual = Get-NotebookContent -NoteBookFullName $fileName -PassThru

        $actual.cells.Count | Should -Be 2
        $actual.cells[0].outputs.output_type | Should -BeExactly 'display_data'
        $actual.cells[0].outputs.data.'text/html'.Count  | Should -Be 25        
    }
}