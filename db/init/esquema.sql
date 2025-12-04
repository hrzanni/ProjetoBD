-- ====================================================================
-- 1. ESTRUTURA (DDL) - Criação das Tabelas e Constraints
-- ====================================================================

-- 1. Tabela CONTÊINER
CREATE TABLE Conteiner (
    NumSerie VARCHAR(50) NOT NULL,
    Capacidade FLOAT NOT NULL,
    TipoDeResiduo VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Conteiner PRIMARY KEY (NumSerie),
    CONSTRAINT CK_Conteiner_Tipo CHECK (TipoDeResiduo IN ('RECICLAVEL', 'NAO_RECICLAVEL')),
    CONSTRAINT CK_Conteiner_Capacidade CHECK (Capacidade > 0)
);

-- 2. Tabela SENSOR
CREATE TABLE Sensor (
    Conteiner_NumSerie VARCHAR(50) NOT NULL,
    DataInstalacao DATE NOT NULL DEFAULT CURRENT_DATE,
    StatusAtivo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT PK_Sensor PRIMARY KEY (Conteiner_NumSerie),
    CONSTRAINT FK_Sensor_Conteiner FOREIGN KEY (Conteiner_NumSerie) 
        REFERENCES Conteiner (NumSerie) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 3. Tabela LEITURA
CREATE TABLE Leitura (
    ID_Leitura SERIAL NOT NULL,
    DataHora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Conteiner_NumSerie VARCHAR(50) NOT NULL,
    PorcentagemEnchimento FLOAT NOT NULL,
    CONSTRAINT PK_Leitura PRIMARY KEY (ID_Leitura),
    CONSTRAINT FK_Leitura_Conteiner FOREIGN KEY (Conteiner_NumSerie) 
        REFERENCES Sensor (Conteiner_NumSerie) ON DELETE CASCADE,
    CONSTRAINT CK_Leitura_Enchimento CHECK (PorcentagemEnchimento BETWEEN 0 AND 100)
);

-- 4. Tabela PONTO DE COLETA
CREATE TABLE PontoDeColeta (
    ID_Ponto SERIAL NOT NULL,
    Rua VARCHAR(100) NOT NULL,
    Numero INT NOT NULL,
    CEP VARCHAR(20) NOT NULL,
    ConteinerReciclavel_NumSerie VARCHAR(50),
    ConteinerNaoReciclavel_NumSerie VARCHAR(50),
    CONSTRAINT PK_PontoDeColeta PRIMARY KEY (ID_Ponto),
    CONSTRAINT FK_Ponto_ContReciclavel FOREIGN KEY (ConteinerReciclavel_NumSerie) 
        REFERENCES Conteiner (NumSerie) ON DELETE SET NULL,
    CONSTRAINT FK_Ponto_ContNaoReciclavel FOREIGN KEY (ConteinerNaoReciclavel_NumSerie) 
        REFERENCES Conteiner (NumSerie) ON DELETE SET NULL,
    CONSTRAINT UQ_Ponto_ContReciclavel UNIQUE (ConteinerReciclavel_NumSerie),
    CONSTRAINT UQ_Ponto_ContNaoReciclavel UNIQUE (ConteinerNaoReciclavel_NumSerie)
);

-- 5. Tabela CENTRO DE DESPEJO
CREATE TABLE CentroDeDespejo (
    ID_Centro SERIAL NOT NULL,
    Rua VARCHAR(100) NOT NULL,
    Numero INT NOT NULL,
    CEP VARCHAR(20) NOT NULL,
    TipoCentro VARCHAR(20) NOT NULL,
    CONSTRAINT PK_CentroDeDespejo PRIMARY KEY (ID_Centro),
    CONSTRAINT CK_TipoCentro CHECK (TipoCentro IN ('ATERRO', 'ECOPONTO'))
);

-- 6. Tabela ROTA
CREATE TABLE Rota (
    CodigoRota SERIAL NOT NULL,
    Regiao VARCHAR(100) NOT NULL,
    Descricao TEXT,
    CONSTRAINT PK_Rota PRIMARY KEY (CodigoRota)
);

-- 7. Tabela PONTOS DA ROTA
CREATE TABLE PontosDaRota (
    Rota_Codigo INT NOT NULL,
    PontoColeta_ID INT NOT NULL,
    NroSequencia INT NOT NULL,
    CONSTRAINT PK_PontosDaRota PRIMARY KEY (Rota_Codigo, PontoColeta_ID),
    CONSTRAINT FK_PR_Rota FOREIGN KEY (Rota_Codigo) 
        REFERENCES Rota (CodigoRota) ON DELETE CASCADE,
    CONSTRAINT FK_PR_Ponto FOREIGN KEY (PontoColeta_ID) 
        REFERENCES PontoDeColeta (ID_Ponto) ON DELETE RESTRICT,
    CONSTRAINT UQ_Rota_Sequencia UNIQUE (Rota_Codigo, NroSequencia),
    CONSTRAINT CK_Sequencia CHECK (NroSequencia > 0)
);

-- 8. Tabela DESPEJOS DA ROTA
CREATE TABLE DespejosDaRota (
    Rota_Codigo INT NOT NULL,
    Centro_ID INT NOT NULL,
    CONSTRAINT PK_DespejosDaRota PRIMARY KEY (Rota_Codigo, Centro_ID),
    CONSTRAINT FK_DR_Rota FOREIGN KEY (Rota_Codigo) 
        REFERENCES Rota (CodigoRota) ON DELETE CASCADE,
    CONSTRAINT FK_DR_Centro FOREIGN KEY (Centro_ID) 
        REFERENCES CentroDeDespejo (ID_Centro) ON DELETE RESTRICT
);

-- 9. Tabela MOTORISTA
CREATE TABLE Motorista (
    CPF VARCHAR(14) NOT NULL,
    CNH VARCHAR(20) NOT NULL,
    Nome VARCHAR(100) NOT NULL,
    Contato VARCHAR(50),
    Disponibilidade BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT PK_Motorista PRIMARY KEY (CPF),
    CONSTRAINT UQ_Motorista_CNH UNIQUE (CNH)
);

-- 10. Tabela VEÍCULO
CREATE TABLE Veiculo (
    Placa VARCHAR(10) NOT NULL,
    Modelo VARCHAR(50) NOT NULL,
    Disponibilidade BOOLEAN NOT NULL DEFAULT TRUE,
    PesoCapacidadeReciclavel FLOAT NOT NULL,
    PesoCapacidadeNaoReciclavel FLOAT NOT NULL,
    CONSTRAINT PK_Veiculo PRIMARY KEY (Placa),
    CONSTRAINT CK_Veiculo_PesoR CHECK (PesoCapacidadeReciclavel >= 0),
    CONSTRAINT CK_Veiculo_PesoNR CHECK (PesoCapacidadeNaoReciclavel >= 0)
);

-- 11. Tabela VIAGEM DE COLETA
CREATE TABLE ViagemDeColeta (
    ID_Viagem SERIAL NOT NULL,
    DataHoraInicio TIMESTAMP NOT NULL,
    DataHoraFim TIMESTAMP,
    Veiculo_Placa VARCHAR(10) NOT NULL,
    Motorista_CPF VARCHAR(14) NOT NULL,
    Rota_Codigo INT NOT NULL,
    PesoColetado FLOAT DEFAULT 0,
    Status VARCHAR(20) NOT NULL DEFAULT 'PLANEJADA',
    CONSTRAINT PK_ViagemDeColeta PRIMARY KEY (ID_Viagem),
    CONSTRAINT FK_Viagem_Veiculo FOREIGN KEY (Veiculo_Placa) REFERENCES Veiculo (Placa),
    CONSTRAINT FK_Viagem_Motorista FOREIGN KEY (Motorista_CPF) REFERENCES Motorista (CPF),
    CONSTRAINT FK_Viagem_Rota FOREIGN KEY (Rota_Codigo) REFERENCES Rota (CodigoRota),
    CONSTRAINT CK_Viagem_Status CHECK (Status IN ('PLANEJADA', 'EM_CURSO', 'CONCLUIDA', 'CANCELADA')),
    CONSTRAINT CK_Viagem_Peso CHECK (PesoColetado >= 0),
    CONSTRAINT CK_Viagem_Conclusao CHECK (
        (Status = 'CONCLUIDA' AND DataHoraFim IS NOT NULL) OR 
        (Status <> 'CONCLUIDA')
    )
);

-- ====================================================================
-- 2. TRIGGERS - Lógica de Negócios no Banco
-- ====================================================================

-- Trigger 1: Validação de Centros
CREATE OR REPLACE FUNCTION fn_valida_centros_rota()
RETURNS TRIGGER AS $$
DECLARE
    qtd_centros INT;
    tipos_distintos INT;
BEGIN
    SELECT COUNT(*) INTO qtd_centros FROM DespejosDaRota WHERE Rota_Codigo = NEW.Rota_Codigo;
    IF qtd_centros > 2 THEN
        RAISE EXCEPTION 'Regra Violada: Uma rota não pode ter mais de 2 centros de despejo.';
    END IF;
    IF qtd_centros = 2 THEN
        SELECT COUNT(DISTINCT cd.TipoCentro) INTO tipos_distintos
        FROM DespejosDaRota dr
        JOIN CentroDeDespejo cd ON dr.Centro_ID = cd.ID_Centro
        WHERE dr.Rota_Codigo = NEW.Rota_Codigo;
        IF tipos_distintos < 2 THEN
            RAISE EXCEPTION 'Regra Violada: Se a rota possui 2 centros, um deve ser ATERRO e o outro ECOPONTO.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trg_check_centros_rota
AFTER INSERT OR UPDATE ON DespejosDaRota
FOR EACH ROW EXECUTE FUNCTION fn_valida_centros_rota();

-- Trigger 2: Validação de Disponibilidade
CREATE OR REPLACE FUNCTION fn_valida_disponibilidade_viagem()
RETURNS TRIGGER AS $$
DECLARE
    motorista_disp BOOLEAN;
    veiculo_disp BOOLEAN;
BEGIN
    SELECT Disponibilidade INTO motorista_disp FROM Motorista WHERE CPF = NEW.Motorista_CPF;
    IF motorista_disp = FALSE THEN
        RAISE EXCEPTION 'Regra Violada: O Motorista % não está disponível.', NEW.Motorista_CPF;
    END IF;
    SELECT Disponibilidade INTO veiculo_disp FROM Veiculo WHERE Placa = NEW.Veiculo_Placa;
    IF veiculo_disp = FALSE THEN
        RAISE EXCEPTION 'Regra Violada: O Veículo % não está disponível.', NEW.Veiculo_Placa;
    END IF;
    IF NEW.Status = 'EM_CURSO' THEN
        UPDATE Motorista SET Disponibilidade = FALSE WHERE CPF = NEW.Motorista_CPF;
        UPDATE Veiculo SET Disponibilidade = FALSE WHERE Placa = NEW.Veiculo_Placa;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trg_check_disp_viagem
BEFORE INSERT ON ViagemDeColeta
FOR EACH ROW EXECUTE FUNCTION fn_valida_disponibilidade_viagem();

-- Trigger 3: Liberação de Recursos
CREATE OR REPLACE FUNCTION fn_libera_recursos_viagem()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.Status = 'EM_CURSO' AND (NEW.Status = 'CONCLUIDA' OR NEW.Status = 'CANCELADA') THEN
        UPDATE Motorista SET Disponibilidade = TRUE WHERE CPF = NEW.Motorista_CPF;
        UPDATE Veiculo SET Disponibilidade = TRUE WHERE Placa = NEW.Veiculo_Placa;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trg_libera_recursos
AFTER UPDATE ON ViagemDeColeta
FOR EACH ROW EXECUTE FUNCTION fn_libera_recursos_viagem();

