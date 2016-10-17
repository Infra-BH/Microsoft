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


###### Definições de pastas ######
##Observação: Não esquecer de cr.
#
#Pasta da origem dos arquivos
$pasta_origem = 'C:\Azure'

#Pasta onde será movido os arquivos para cópia
$pasta_arquivos = 'C:\Azure\arquivos'

#Pasta de logs
$pasta_arquivo_log = 'C:\Azure\Logs\'




# Tipo de arquivo a ser enviado
$tipo_arquivo = ".txt"


# Destino que será armazenado os logs de importação.
$dest_arquivo_log = 'C:\Azure\Logs\copia-azure.log'
$arquivo_lot_log = 'C:\Azure\Arquivos\lote.txt'
$arquivo_azure_log = 'C:\Azure\log-arquivos-azure.log'



# Pasta da onde fica o arquivo de execução AzCopy
$pasta_azcopy = 'C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy'

#### 1 - WHILE COM TEMPO DEFINIDO ######
# Para definir um while com tempo, deve decomentar as três linhas abaixo e difinir abaixo o tempo desejado em minutos e comentar as linhas do while infinito.
$sw = [diagnostics.stopwatch]::StartNew()
$timeout = new-timespan -Minutes 1  #Aqui deve definir o tempo desejado em minutos
while ($sw.elapsed -lt $timeout){

#### 2 - WHILE INFINITO ######
# Para definir um while infinito, deve descomentar as duas linhas abaixo e comentar as linhas do WHILE COM TEMPO DEFINIDO.
#while ($true){
#$i++


 
   cd $pasta_origem
  
  
   Move-Item -Path *$tipo_arquivo -Destination $pasta_arquivos

    
  #$count = Write-Host (dir $pasta_arquivos | measure).Count
 
 
if (Test-Path $pasta_arquivos\* -include *$tipo_arquivo ) {


    if(Test-Path -Path $arquivo_azure_log ) {
   
         
                                             }
   
    else {
 
 
   New-Item -Path $arquivo_azure_log -type file  
    
        }


    
 Remove-Item "$pasta_arquivo_log\*.*" -Confirm:$false


   cd $pasta_azcopy
        
       

        #Copiando arquivos  
        .\AzCopy.exe /source:$pasta_arquivos /Dest:$pasta_azure /DestKey:$chave_azure  /S /Y /XO /V:$dest_arquivo_log
                     
            # $arquivos_enviados = (Get-Content $dest_arquivo_log | Select-String "Finished transfer" | Measure-Object -line).Lines 
             $arquivos_enviados = (Get-Content $dest_arquivo_log | Select-String "Finished transfer")
       
            #echo $arquivos_enviados > $pasta_arquivos\lote.txt 
            #Add-Content -Path "C:\Azure\Logs\copia-azure.txt","C:\Azure\Arquivos\lote.txt" -Value $($arquivos_enviados) 
            Add-Content -Path $pasta_arquivos\lote.log -Value $($arquivos_enviados)    
          
        
                    
      If (( get-content -Path $pasta_arquivos\lote.log) -ne $Null) {
        
                  #If [string]::IsNullOrEmpty( get-content -Path $pasta_arquivos\lote.log) {
                 


          Get-ChildItem $pasta_arquivos\*.log | select FullName, Extension, @{name='md5'; expression={(Get-FileHash $_ -Algorithm md5).Hash}} | foreach {Rename-Item $_.FullName -NewName "$($_.md5)$($_.extension)"} 
       
       
        .\AzCopy.exe /source:$pasta_arquivos /Dest:$pasta_azure /DestKey:$chave_azure /S /Y /XO /V:$dest_arquivo_log         
      
             }  

        Get-Content $dest_arquivo_log  >> $arquivo_azure_log   
        Remove-Item  "$pasta_arquivos\*.*" -Confirm:$false
            
          
      }

  
 # Não comentar essa linha, isso garante que o script não consuma processamento, deixar pelo menos em 1 segundo.
  start-sleep -seconds 1

 }
 

if (Test-Path $arquivo_azure_log) {

    write-host "Finalizado"
    $arquivos_enviados = (Get-Content $arquivo_azure_log | Select-String "Finished transfer" |  Select-String $tipo_arquivo | Measure-Object -line).Lines 
    write-host "Total de arquivos:" $arquivos_enviados
    write-host "Tempo definido:" $timeout
    write-host "Tempo de execução do script:" $sw.elapsed
    Remove-Item  $arquivo_azure_log -Confirm:$false
                                  }
    else { 
    
        write-host "Finalizado."
        write-host "ATENÇÃO: Nenhum arquivo foi disponibilizado para envio."
        write-host "Tempo definido:" $timeout
    
         }
