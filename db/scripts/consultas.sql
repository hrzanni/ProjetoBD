-- Esta consulta identifica os motoristas que já passaram por absolutamente todas as rotas cadastradas no sistema.
-- Objetivo: Listar motoristas cuja contagem de rotas distintas percorridas é igual à contagem total de rotas existentes na tabela Rota. 

SELECT    
       m.Nome AS Nome_Motorista, m.CPF, 
       COUNT(DISTINCT v.Rota_Codigo) AS Qtd_Rotas_Distintas_Percorridas 
FROM Motorista m 
JOIN ViagemDeColeta v ON m.CPF = v.Motorista_CPF 
GROUP BY m.CPF, m.Nome 
HAVING COUNT(DISTINCT v.Rota_Codigo) = (SELECT COUNT(*) FROM Rota);

-- Esta consulta gera um painel geral mostrando a última vez que cada sensor comunicou dados e qual foi o nível reportado.
-- Objetivo: Mostrar todos os sensores instalados, a data da última leitura e o nível de enchimento, tratando casos onde não houve leitura.

SELECT 
    s.Conteiner_NumSerie,
    TO_CHAR(s.DataInstalacao, 'DD/MM/YYYY') AS Data_Instalacao,
    COALESCE(TO_CHAR(MAX(l.DataHora), 'DD/MM/YYYY HH24:MI'), '--') AS Data_Ultima_Leitura,
    CASE 
        WHEN MAX(l.PorcentagemEnchimento) IS NULL THEN 'SEM LEITURA'
        ELSE CONCAT(MAX(l.PorcentagemEnchimento), '%')
    END AS Nivel_Mais_Recente
FROM Sensor s
LEFT JOIN 
    Leitura l ON s.Conteiner_NumSerie = l.Conteiner_NumSerie
GROUP BY s.Conteiner_NumSerie, s.DataInstalacao
ORDER BY s.DataInstalacao;

-- Esta consulta cria um ranking de performance para os caminhões, baseando-se na média de peso coletado por viagem.
-- Objetivo: Classificar veículos que transportam mais carga em média, considerando apenas viagens concluídas.

SELECT 
        v.Modelo, v.Placa, 
        COUNT(vc.ID_Viagem) AS Total_Viagens_Realizadas,            ROUND(AVG(vc.PesoColetado)::numeric, 2) AS Media_Peso_Por_Viagem, 
         DENSE_RANK() OVER (ORDER BY AVG(vc.PesoColetado) DESC) AS                    Ranking_Eficiencia   
FROM Veiculo v 
JOIN ViagemDeColeta vc ON v.Placa = vc.Veiculo_Placa 
WHERE vc.Status = 'CONCLUIDA' GROUP BY v.Placa, v.Modelo;

-- Esta é uma consulta de monitoramento crítico. Ela busca apenas o estado atual do container, ignorando históricos antigos de quando ele estava cheio no passado.
-- Objetivo: Listar containers que, em sua leitura mais recente, apresentaram mais de 80% de ocupação.

SELECT 
    l1.Conteiner_NumSerie,
    l1.PorcentagemEnchimento,
    l1.DataHora
FROM
    Leitura l1
WHERE 
    l1.PorcentagemEnchimento > 80.0
    AND l1.DataHora = (
        SELECT MAX(l2.DataHora)
        FROM Leitura l2
        WHERE l2.Conteiner_NumSerie = l1.Conteiner_NumSerie
    );

-- Esta consulta serve para análise gerencial e tomada de decisão estratégica sobre alocação de recursos.
-- Objetivo: Agrupar os dados por região geográfica e categorizá-las (Alta, Média ou Baixa demanda) com base no volume total de lixo coletado.

SELECT 
r.Regiao, 
COUNT(vc.ID_Viagem) AS Qtd_Viagens,
COALESCE(SUM(vc.PesoColetado), 0) AS Peso_Total_Acumulado, 
CASE WHEN SUM(vc.PesoColetado) > 5000 THEN 'ALTA DEMANDA'
WHEN SUM(vc.PesoColetado) BETWEEN 1000 AND 5000 THEN 'MEDIA DEMANDA' 
ELSE 'BAIXA DEMANDA' 
      END AS Classificacao_Fluxo 

FROM Rota r 
LEFT JOIN ViagemDeColeta vc ON r.CodigoRota = vc.Rota_Codigo 
GROUP BY r.CodigoRota, r.Regiao 
ORDER BY Peso_Total_Acumulado DESC;