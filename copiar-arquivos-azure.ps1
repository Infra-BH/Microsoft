# Autor: Danilo Neves
# E-mail: danilorpneves@outlook.com
# -------------------------------------------
# Obervações: 
# O script tem como objetivo enviar vários arquivos de uma determinada pasta, para uma pasta compartilhada no Azure.
# URL Artigo Microsoft Azure: https://azure.microsoft.com/pt-br/documentation/articles/storage-dotnet-how-to-use-files/
#
# Leia todos os comentários até o final do script
# Definir as variáveis abaixo conforme desejado
# O script deve ser executado no PowerShell 3.0
# O AzCopy deve está instalado: http://aka.ms/downloadazcopy
# 
#
# Existe a possibilidade de executar o script de duas formas
# 1 - Executar o script definindo um tempo que ele deve ficar em execução, mas só vai finalizar a execução depois que terminar de enviar os arquivos listados.
#     Primeiro ele lista os arquivos dentro da pasta e logo envia todos esses arquivos listados, caso seja inseridos mais arquivos dentro da pasta depois do tempo
#     definido, os arquivos não serão enviados, pois já excedeu o tempo de execução. 
# 
# 2 - Executar o script em modo infinito, dessa forma o script vai ficar executando até que seja cancelado manualmente.
# As alterações devem ser feitas no própio script conforme as orientações abaixo.
#
#--------------------------------------------
 
# Definição de variáveis
#
# Informações da pasta compartilhada no Azure
$pasta_azure = 'https://storage.file.core.windows.net/nome_pasta_compartilhada'
$chave_azure = 'nksOj6GMdBybtJ+dOxRwogNpkpA=='

# Origem da pasta local
$pasta_origem = 'C:\Azure'

# Tipo de arquivo a ser enviado
$tipo_arquivo = '*.JPG'

# Destino que será armazenado os logs de importação.
$dest_arquivo_log = 'C:\Azure\copia-azure.log'


# Nome da lista de arquivos que serão enviados.
$consulta_arquivo = 'files.txt'

# Pasta da onde fica o arquivo de execução AzCopy
$pasta_azcopy = 'C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy'

#### 1 - WHILE COM TEMPO DEFINIDO ######
# Para definir um while com tempo, deve decomentar as três linhas abaixo e difinir abaixo o tempo desejado em minutos e comentar as linhas do while infinito.
 $sw = [diagnostics.stopwatch]::StartNew()
 $timeout = new-timespan -Minutes 1  #Aqui deve definir o tempo desejado em minutos
 while ($sw.elapsed -lt $timeout){

#### 2 - WHILE INFINITO ######
# Para definir um while infinito, deve descomentar as duas linhas abaixo e comentar as linhas do WHILE COM TEMPO DEFINIDO.
# while ($true){
# $i++


   $files = $null
   cd $pasta_origem
   gci -Recurse -Filter $tipo_arquivo  | % fullname > $consulta_arquivo
   $files = Get-Content $consulta_arquivo
   
   cd $pasta_azcopy
 
   foreach($currentfiles in $files)
   {
    
        #Copiando arquivos  
        .\AzCopy.exe /source:$pasta_origem /Dest:$pasta_azure /DestKey:$chave_azure  /S /Y /XO /Pattern:$currentfiles /V:$dest_arquivo_log
        write-host "Arquivo:"  $currentfiles  
              
   }
   cd $pasta_origem
   Get-Content  $consulta_arquivo | Remove-Item

 # Não comentar essa linha, isso garante que o script não consuma processamento, deixar pelo menos em 1 segundo.
  start-sleep -seconds 1
  
 }

$arquivos_enviados = (Get-Content $dest_arquivo_log | Select-String "Finished transfer" | Measure-Object -line).Lines 
write-host "Finalizado"
write-host "Tempo definido:" $timeout
write-host "Tempo de execução do script:" $sw.elapsed
write-host "Total de arquivos enviados:" $arquivos_enviados
