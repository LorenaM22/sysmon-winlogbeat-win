Para instalar sysmon y winlogbeat en windows simplemente debemos descargar y ejecutar el archivo setup-sysmon-winlogbeat.ps1 de la siguiente forma

1. Abrir powershell como Administrador
2. ./setup-sysmon-winlogbeat.ps1 "logstash_ip_addr" "logstash_port"
      siendo logstash_ip_addr y logstash_port la ip y puerto de la máquina donde se encuetran logstash agent escuchando
