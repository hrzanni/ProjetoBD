SELECT    
       m.Nome AS Nome_Motorista, m.CPF, 
       COUNT(DISTINCT v.Rota_Codigo) AS Qtd_Rotas_Distintas_Percorridas 
FROM Motorista m 
JOIN ViagemDeColeta v ON m.CPF = v.Motorista_CPF 
GROUP BY m.CPF, m.Nome 
HAVING COUNT(DISTINCT v.Rota_Codigo) = (SELECT COUNT(*) FROM Rota);



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




SELECT 
        v.Modelo, v.Placa, 
        COUNT(vc.ID_Viagem) AS Total_Viagens_Realizadas,            ROUND(AVG(vc.PesoColetado)::numeric, 2) AS Media_Peso_Por_Viagem, 
         DENSE_RANK() OVER (ORDER BY AVG(vc.PesoColetado) DESC) AS                    Ranking_Eficiencia   
FROM Veiculo v 
JOIN ViagemDeColeta vc ON v.Placa = vc.Veiculo_Placa 
WHERE vc.Status = 'CONCLUIDA' GROUP BY v.Placa, v.Modelo;



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