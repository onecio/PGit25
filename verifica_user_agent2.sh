#!/bin/bash

# Lista de URLs do EXEMP a serem verificadas
urls=(
    "exemplo1.com.br"
    "exemplo2.com.br"
    "exemplo3.com.br"
    "exemplo4.com.br"
    "exemplo5.com.br"
    "exemplo6.com.br"
    "exemplo7.com.br"
    "exemplo8.com.br"
    "exemplo9.com.br"
    "exemplo10.com.br"
    "exemplo11.com.br"
    "exemplo12.com.br"
    "exemplo13.com.br"
    "exemplo14.com.br"
    "exemplo15.com.br"
    "exemplo16.com.br"
    "exemplo17.com.br"
    "exemplo18.com.br"
    "exemplo19.com.br"
    "exemplo20.com.br"
    "exemplo21.com.br"
    "exemplo22.com.br"
    "exemplo23.com.br"
    "exemplo24.com.br"
    "exemplo25.com.br"
    "exemplo26.com.br"
    "exemplo27.com.br"
    "exemplo28.com.br"
    "exemplo29.com.br"
    "exemplo30.com.br"
    "exemplo31.com.br"
    "exemplo32.com.br"
    "exemplo33.com.br"
)

total_urls="${#urls[@]}"
counter=0
timeout=30s # Timeout em segundos
output_file="CadeUserAgent.html"

# Inicializa o arquivo HTML
echo "<html><head><title>Diagnóstico User-Agent EXEMP</title></head><body><h1>Diagnóstico User-Agent EXEMP</h1><ul>" > "$output_file"

# Função para executar curl com timeout e tratamento de erros
curl_with_timeout() {
    local url="$1"
    local user_agent="$2"
    local output_file="$3"

    timeout "$timeout" curl -s -L ${user_agent:+-A "$user_agent"} "https://$url" > "$output_file" 2>/dev/null
    return $?
}

# Loop através das URLs
for url in "${urls[@]}"; do
    ((counter++))
    percentage=$(( (counter * 100) / total_urls ))
    echo -ne "\rVerificando: $url ($counter/$total_urls) - $percentage% concluído..."

    padrao_file="PADRAO_$url"
    googlebot_file="GOOGLEBOT_$url"

    if ! curl_with_timeout "$url" "" "$padrao_file"; then
        echo ""
        echo "Timeout ou erro ao executar curl (PADRAO) para $url. Pulando comparação."
        echo "<li><b>$url:</b> Timeout ou erro ao obter a página padrão.</li>" >> "$output_file"
        rm -f "$padrao_file" "$googlebot_file"
        continue
    fi

    if ! curl_with_timeout "$url" "Googlebot" "$googlebot_file"; then
        echo ""
        echo "Timeout ou erro ao executar curl (GOOGLEBOT) para $url. Pulando comparação."
        echo "<li><b>$url:</b> Timeout ou erro ao obter a página com User-Agent Googlebot.</li>" >> "$output_file"
        rm -f "$padrao_file" "$googlebot_file"
        continue
    fi

    diff "$padrao_file" "$googlebot_file" > /dev/null 2>&1

    if [[ $? -eq 0 ]]; then
        echo "<li><b>$url:</b> Nenhuma diferença encontrada.</li>" >> "$output_file"
    else
        echo ""
        echo "Diferenças encontradas para $url."
        echo "<li><b>$url:</b> Diferenças encontradas.</li>" >> "$output_file"
    fi

    rm -f "$padrao_file" "$googlebot_file"
done

echo ""
echo "Verificação concluída. Resultado salvo em $output_file"

# Finaliza o arquivo HTML
echo "</ul></body></html>" >> "$output_file"

# Abrir o arquivo em HTML para facilitar visualização
# Se executar em SO com GUI o html poderá ser aberto automaticamente após a conclusão xdg-open "$output_file"
# Próximos passos: configurar o cron para execução automática periodicamente e renomeação do arquivo html
