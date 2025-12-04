-- ====================================================================
-- 3. INSERTS - Dados de Teste
-- ====================================================================

-- 1. CONTEINER
INSERT INTO Conteiner (NumSerie, Capacidade, TipoDeResiduo) VALUES 
('CONT-001', 240.0, 'RECICLAVEL'),
('CONT-002', 240.0, 'NAO_RECICLAVEL'),
('CONT-003', 360.0, 'RECICLAVEL'),
('CONT-004', 360.0, 'NAO_RECICLAVEL'),
('CONT-005', 120.0, 'RECICLAVEL'),
('CONT-006', 120.0, 'NAO_RECICLAVEL');

-- 2. SENSOR
INSERT INTO Sensor (Conteiner_NumSerie, DataInstalacao) VALUES 
('CONT-001', '2024-01-15'),
('CONT-002', '2024-01-20'),
('CONT-003', '2024-02-10');

-- 3. LEITURA
INSERT INTO Leitura (DataHora, Conteiner_NumSerie, PorcentagemEnchimento) VALUES 
('2024-11-29 08:30:00', 'CONT-001', 45.5),
('2024-11-29 09:15:00', 'CONT-002', 78.2),
('2024-11-29 10:00:00', 'CONT-003', 62.0);

-- 4. PONTO DE COLETA
INSERT INTO PontoDeColeta (Rua, Numero, CEP, ConteinerReciclavel_NumSerie, ConteinerNaoReciclavel_NumSerie) VALUES 
('Av. Paulista', 1000, '01310-100', 'CONT-001', 'CONT-002'),
('Rua Augusta', 500, '01305-000', 'CONT-003', 'CONT-004'),
('Rua da Consolação', 250, '01301-000', 'CONT-005', 'CONT-006');

-- 5. CENTRO DE DESPEJO
INSERT INTO CentroDeDespejo (Rua, Numero, CEP, TipoCentro) VALUES 
('Av. do Estado', 3000, '03103-001', 'ATERRO'),
('Rua Vergueiro', 8500, '04272-300', 'ECOPONTO'),
('Av. Pacaembu', 1200, '01234-010', 'ECOPONTO');

-- 6. ROTA
INSERT INTO Rota (Regiao) VALUES 
('Centro'),
('Zona Sul'),
('Zona Oeste');

-- 7. PONTOS DA ROTA
INSERT INTO PontosDaRota (Rota_Codigo, PontoColeta_ID, NroSequencia) VALUES 
(1, 1, 1),
(1, 2, 2),
(2, 3, 1);

-- 8. DESPEJOS DA ROTA
INSERT INTO DespejosDaRota (Rota_Codigo, Centro_ID) VALUES 
(1, 1),
(1, 2),
(2, 3);

-- 9. MOTORISTA
INSERT INTO Motorista (CPF, CNH, Nome, Contato, Disponibilidade) VALUES 
('123.456.789-00', '12345678901', 'João Silva Santos', '(11) 98765-4321', TRUE),
('234.567.890-11', '23456789012', 'Maria Oliveira Costa', '(11) 97654-3210', TRUE),
('345.678.901-22', '34567890123', 'Pedro Almeida Souza', '(11) 96543-2109', FALSE);

-- 10. VEÍCULO
INSERT INTO Veiculo (Placa, Modelo, Disponibilidade, PesoCapacidadeReciclavel, PesoCapacidadeNaoReciclavel) VALUES 
('ABC-1234', 'Mercedes-Benz Atego 1719', TRUE, 5000.0, 7000.0),
('DEF-5678', 'Volkswagen Constellation 17.280', TRUE, 6000.0, 8000.0),
('GHI-9012', 'Ford Cargo 1719', FALSE, 5500.0, 7500.0);

-- 11. VIAGEM DE COLETA
INSERT INTO ViagemDeColeta (DataHoraInicio, DataHoraFim, Veiculo_Placa, Motorista_CPF, Rota_Codigo, PesoColetado, Status) 
VALUES ('2024-11-29 06:00:00', '2024-11-29 10:30:00', 'ABC-1234', '123.456.789-00', 1, 3200.5, 'CONCLUIDA');
INSERT INTO ViagemDeColeta (DataHoraInicio, Veiculo_Placa, Motorista_CPF, Rota_Codigo, PesoColetado, Status) 
VALUES ('2024-11-29 07:30:00', 'DEF-5678', '234.567.890-11', 2, 4100.0, 'EM_CURSO');
INSERT INTO ViagemDeColeta (DataHoraInicio, Veiculo_Placa, Motorista_CPF, Rota_Codigo, PesoColetado, Status) 
VALUES ('2024-11-30 06:00:00', 'ABC-1234', '123.456.789-00', 3, 0.0, 'PLANEJADA');
