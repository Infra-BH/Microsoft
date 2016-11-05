<#
Esse script é para ser utilzado no Runbooks no Azure para otimizar o banco em determinado horário.
Um caso de uso é criar um agendamento para o banco utilizar o plano Standard S3 no horário comercial e outro agendamento para utilizar 
o plano Standard S0.
Com isso conseguimos rezudir custos e ter performance somente quando necessário.

- Tipo de Runbook: Fluxo de Trabalho do PowerShell

#>

# O nome do workflow, deve ser o mesmo do Runbook
workflow runbook-altera-tipo-banco
{
   
    inlinescript
    {
        Write-Output "Alterando tamanho do banco..."

        # Senha
        $secpasswd = ConvertTo-SecureString “senha” -AsPlainText -Force

        # Conectando com o banco de dados 
        $Servercredential = new-object System.Management.Automation.PSCredential("usuario-banco",$secpasswd) 
        
        # Conexão com banco de dados
        $CTX = New-AzureSqlDatabaseServerContext -ManageUrl "https://servidor.database.windows.net" -Credential $ServerCredential
        
        # Obtendo context
        $Db = Get-AzureSqlDatabase $CTX -DatabaseName "nome-banco"
        
        # Especificar o tamanho do banco de dados, no exemplo estou usando S2
        $ServiceObjective = Get-AzureSqlDatabaseServiceObjective $CTX -ServiceObjectiveName "S2"
        
        # Setar configurações e qual o tipo de banco, no exemplo estou usando Standard
        Set-AzureSqlDatabase $CTX -Database $Db -ServiceObjective $ServiceObjective -Edition "Standard" -Force
        
        # Mensagem final
        Write-Output "Tamanho do banco alterado"
        
    }
}
