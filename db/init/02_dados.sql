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
('CONT-006', 120.0, 'NAO_RECICLAVEL'),
('CONT-007', 240.0, 'RECICLAVEL'),
('CONT-008', 240.0, 'NAO_RECICLAVEL'),
('CONT-009', 360.0, 'RECICLAVEL'),
('CONT-010', 360.0, 'NAO_RECICLAVEL');

-- 2. SENSOR
INSERT INTO Sensor (Conteiner_NumSerie, DataInstalacao) VALUES 
('CONT-001', '2024-01-15'),
('CONT-002', '2024-01-20'),
('CONT-003', '2024-02-10'),
('CONT-004', '2024-02-15'),
('CONT-005', '2024-03-25'),
('CONT-006', '2024-04-05'),
('CONT-007', '2024-05-10'),
('CONT-008', '2024-05-12');

-- 3. LEITURA
INSERT INTO Leitura (DataHora, Conteiner_NumSerie, PorcentagemEnchimento) VALUES 
('2024-11-29 08:30:00', 'CONT-001', 45.5),
('2024-11-29 09:15:00', 'CONT-002', 78.2),
('2024-11-29 10:00:00', 'CONT-003', 62.0),
('2024-11-29 11:30:00', 'CONT-004', 85.0),
('2024-11-29 12:45:00', 'CONT-005', 92.5),
('2024-11-30 08:00:00', 'CONT-001', 50.0),
('2024-11-30 09:30:00', 'CONT-007', 68.3),
('2024-11-30 10:45:00', 'CONT-008', 75.0);

-- 4. PONTO DE COLETA
INSERT INTO PontoDeColeta (Rua, Numero, CEP, ConteinerReciclavel_NumSerie, ConteinerNaoReciclavel_NumSerie) VALUES 
('Av. Paulista', 1000, '01310-100', 'CONT-001', 'CONT-002'),
('Rua Augusta', 500, '01305-000', 'CONT-003', 'CONT-004'),
('Rua da Consolação', 250, '01301-000', 'CONT-005', 'CONT-006'),
('Av. Faria Lima', 4400, '04538-132', 'CONT-007', 'CONT-008'),
('Rua Bela Cintra', 1500, '01415-001', 'CONT-009', 'CONT-010');

-- 5. CENTRO DE DESPEJO
INSERT INTO CentroDeDespejo (Rua, Numero, CEP, TipoCentro) VALUES 
('Av. do Estado', 3000, '03103-001', 'ATERRO'),
('Rua Vergueiro', 8500, '04272-300', 'ECOPONTO'),
('Av. Pacaembu', 1200, '01234-010', 'ECOPONTO'),
('Rua do Hipódromo', 500, '03051-000', 'ECOPONTO');

-- 6. ROTA
INSERT INTO Rota (Regiao, Descricao) VALUES 
('Centro', 'Rota de alta densidade comercial e financeira (Av. Paulista/Augusta). Abrange áreas com restrição de circulação de caminhões pesados, exigindo coleta preferencialmente noturna e foco em recicláveis de escritório.'),

('Zona Sul', 'Circuito misto residencial de alto padrão e gastronômico. Foco em grandes condomínios verticais e corredores de restaurantes. Gera alto volume de resíduos orgânicos e requer veículos com compactação eficiente.'),

('Zona Oeste', 'Corredor corporativo e universitário (região da Faria Lima). Rota caracterizada pela geração de resíduos secos e eletrônicos. Coleta programada para horários de vale para evitar congestionamentos nas vias arteriais.'),

('Zona Leste', 'Área de expansão com predominância de comércio popular e pequenas indústrias. Rota extensa que demanda otimização logística para economia de combustível, cobrindo pontos dispersos de descarte irregular.');

-- 7. PONTOS DA ROTA
INSERT INTO PontosDaRota (Rota_Codigo, PontoColeta_ID, NroSequencia) VALUES 
(1, 1, 1),
(1, 2, 2),
(2, 3, 1),
(1, 4, 3),
(4, 5, 1);

-- 8. DESPEJOS DA ROTA
INSERT INTO DespejosDaRota (Rota_Codigo, Centro_ID) VALUES 
(1, 1),
(1, 2),
(2, 3),
(2, 1),
(4, 4);

-- 9. MOTORISTA
INSERT INTO Motorista (CPF, CNH, Nome, Contato, Disponibilidade) VALUES 
('123.456.789-00', '12345678901', 'João Silva Santos', '(11) 98765-4321', TRUE),
('234.567.890-11', '23456789012', 'Maria Oliveira Costa', '(11) 97654-3210', TRUE),
('345.678.901-22', '34567890123', 'Pedro Almeida Souza', '(11) 96543-2109', FALSE),
('456.789.012-33', '45678901234', 'Ana Lúcia Ferreira', '(11) 95432-1098', TRUE);

-- 10. VEÍCULO
INSERT INTO Veiculo (Placa, Modelo, Disponibilidade, PesoCapacidadeReciclavel, PesoCapacidadeNaoReciclavel) VALUES 
('ABC-1234', 'Mercedes-Benz Atego 1719', TRUE, 5000.0, 7000.0),
('DEF-5678', 'Volkswagen Constellation 17.280', TRUE, 6000.0, 8000.0),
('GHI-9012', 'Ford Cargo 1719', FALSE, 5500.0, 7500.0),
('JKL-3456', 'Scania P310', TRUE, 6500.0, 8500.0);

-- 11. VIAGEM DE COLETA
-- Viagem 1: Concluída (Libera recursos ao final, mas como já começa concluída, o trigger não trava)
INSERT INTO ViagemDeColeta (DataHoraInicio, DataHoraFim, Veiculo_Placa, Motorista_CPF, Rota_Codigo, PesoColetado, Status) 
VALUES ('2024-11-29 06:00:00', '2024-11-29 10:30:00', 'ABC-1234', '123.456.789-00', 1, 3200.5, 'CONCLUIDA');

-- Viagem 2: EM CURSO (O TRIGGER VAI TRAVAR O VEÍCULO DEF-5678 E O MOTORISTA 234...)
INSERT INTO ViagemDeColeta (DataHoraInicio, Veiculo_Placa, Motorista_CPF, Rota_Codigo, PesoColetado, Status) 
VALUES ('2024-11-29 07:30:00', 'DEF-5678', '234.567.890-11', 2, 4100.0, 'EM_CURSO');

-- Viagem 3: Planejada (Não trava recursos)
INSERT INTO ViagemDeColeta (DataHoraInicio, Veiculo_Placa, Motorista_CPF, Rota_Codigo, PesoColetado, Status) 
VALUES ('2024-11-30 06:00:00', 'ABC-1234', '123.456.789-00', 3, 0.0, 'PLANEJADA');

-- Viagem 4
-- Trocamos o veículo para 'JKL-3456' porque o 'DEF-5678' ainda está preso na viagem EM_CURSO acima.
-- Trocamos o motorista para '456...' (Ana) porque a Maria (234...) está presa na viagem acima.
INSERT INTO ViagemDeColeta (DataHoraInicio, DataHoraFim, Veiculo_Placa, Motorista_CPF, Rota_Codigo, PesoColetado, Status) 
VALUES ('2024-12-01 06:30:00', '2024-12-01 11:00:00', 'JKL-3456', '456.789.012-33', 1, 3500.0, 'CONCLUIDA');

-- Viagem 5: Planejada (Reutilizando João e ABC que estão livres)
INSERT INTO ViagemDeColeta (DataHoraInicio, Veiculo_Placa, Motorista_CPF, Rota_Codigo, PesoColetado, Status) 
VALUES ('2024-12-02 07:00:00', 'ABC-1234', '123.456.789-00', 4, 0.0, 'PLANEJADA');
