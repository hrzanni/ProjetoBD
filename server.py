import psycopg2
from psycopg2 import Error
import os
import sys
import re  

# Conexão com o banco de dados do PostgreSQL

DB_CONFIG = {
    "host": "localhost",
    "database": "Projeto_DB",  
    "user": "postgres",
    "password": "123",
    "port": "5555"
}

def limpar_tela():
    """Limpa o terminal para melhorar a usabilidade."""
    os.system('cls' if os.name == 'nt' else 'clear')

def criar_conexao():
    """Estabelece a conexão com o banco de dados PostgreSQL."""
    conn = None
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Error as e:
        print(f"\n[ERRO CRÍTICO] Falha ao conectar no banco de dados: '{e}'")
        return None

def pausar():
    """Pausa a execução até o usuário pressionar Enter."""
    input("\nPressione <ENTER> para continuar...")


# Inserção (Cadastrar Contêiner)

def cadastrar_conteiner(conn):
    """
    Solicita dados ao usuário e insere um novo contêiner no banco.
    Inclui validação estrita do formato do nome (CONT-XXXX).
    """
    limpar_tela()
    print("=== CADASTRO DE NOVO CONTÊINER ===")
    
    while True:
        num_serie = input("Digite o Número de Série (Padrão CONT-XXX): ").strip().upper()
        
        if re.match(r'^CONT-\d+$', num_serie):
            break
        else:
            print("\n[ERRO DE FORMATO] O código deve seguir o padrão 'CONT-' seguido de números.")
            print("Exemplos válidos: CONT-100, CONT-01, CONT-5000")
            print("Tente novamente.\n")
    
    while True:
        try:
            capacidade = float(input("Digite a Capacidade (L): "))
            if capacidade <= 0:
                print("A capacidade deve ser maior que zero.")
                continue
            break
        except ValueError:
            print("Por favor, digite um número válido.")

    print("\nEscolha o Tipo de Resíduo:")
    print("1 - RECICLAVEL")
    print("2 - NAO_RECICLAVEL")
    
    while True:
        opcao_tipo = input("Opção: ")
        if opcao_tipo == '1':
            tipo_residuo = 'RECICLAVEL'
            break
        elif opcao_tipo == '2':
            tipo_residuo = 'NAO_RECICLAVEL'
            break
        else:
            print("Opção inválida. Digite 1 ou 2.")

    try:
        cursor = conn.cursor()
        
        sql_insert = """
            INSERT INTO Conteiner (NumSerie, Capacidade, TipoDeResiduo)
            VALUES (%s, %s, %s);
        """
        
        cursor.execute(sql_insert, (num_serie, capacidade, tipo_residuo))
        conn.commit()
        
        print(f"\n[SUCESSO] Contêiner {num_serie} cadastrado com sucesso!")
        
    except psycopg2.IntegrityError as e:
        conn.rollback()
        print(f"\n[ERRO DE DUPLICIDADE] Não foi possível cadastrar.")
        print(f"O código '{num_serie}' já existe no banco de dados.")
        
    except Error as e:
        conn.rollback()
        print(f"\n[ERRO DE BANCO] Falha na operação: {e}")
        
    finally:
        if 'cursor' in locals():
            cursor.close()
    
    pausar()


# Consulta (Monitoramento de Status)

def consultar_monitoramento(conn):
    """Realiza uma consulta com JOIN para mostrar o status atual dos contêineres."""
    limpar_tela()
    print("=== MONITORAMENTO DE CONTÊINERES (DASHBOARD) ===")
    
    try:
        cursor = conn.cursor()
        
        sql_query = """
            SELECT 
                c.NumSerie,
                c.TipoDeResiduo,
                COALESCE(TO_CHAR(s.DataInstalacao, 'DD/MM/YYYY'), 'SEM SENSOR') as Data_Sensor,
                CASE 
                    WHEN MAX(l.PorcentagemEnchimento) IS NULL THEN 'AGUARDANDO DADOS'
                    ELSE CONCAT(MAX(l.PorcentagemEnchimento), '%')
                END as Nivel_Atual
            FROM 
                Conteiner c
            LEFT JOIN 
                Sensor s ON c.NumSerie = s.Conteiner_NumSerie
            LEFT JOIN 
                Leitura l ON s.Conteiner_NumSerie = l.Conteiner_NumSerie
            GROUP BY 
                c.NumSerie, c.TipoDeResiduo, s.DataInstalacao
            ORDER BY 
                c.NumSerie ASC;
        """
        
        cursor.execute(sql_query)
        registros = cursor.fetchall()

        if not registros:
            print("\nNenhum registro encontrado.")
        else:
            print("-" * 75)
            print(f"{'SÉRIE':<15} | {'TIPO':<15} | {'SENSOR INST.':<15} | {'STATUS':<20}")
            print("-" * 75)
            
            for row in registros:
                serie, tipo, data_sensor, status = row
                alerta = ""
              
                if status != 'AGUARDANDO DADOS':
                    try:
                        valor_numerico = float(status.strip('%'))
                        if valor_numerico > 80:
                            alerta = " [CRÍTICO!]"
                    except ValueError:
                        pass
                
                print(f"{serie:<15} | {tipo:<15} | {data_sensor:<15} | {status:<15}{alerta}")
            
            print("-" * 75)
            print(f"Total de registros: {len(registros)}")

    except Error as e:
        print(f"\n[ERRO] Falha ao consultar dados: {e}")
        
    finally:
        if 'cursor' in locals():
            cursor.close()
            
    pausar()

# Main

def main():
    conn = criar_conexao()
    
    if conn is None:
        sys.exit(1)

    while True:
        limpar_tela()
        print("=== SISTEMA DE GESTÃO DE RESÍDUOS SÓLIDOS ===")
        print("1. Cadastrar Novo Contêiner")
        print("2. Consultar Monitoramento (Dashboard)")
        print("3. Sair")
        
        opcao = input("\nDigite a opção desejada: ")

        if opcao == '1':
            cadastrar_conteiner(conn)
        elif opcao == '2':
            consultar_monitoramento(conn)
        elif opcao == '3':
            print("\nEncerrando sistema... Até logo!")
            break
        else:
            print("\nOpção inválida!")
            pausar()

    if conn:
        conn.close()
        print("Conexão encerrada.")

if __name__ == "__main__":
    main()