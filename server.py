import psycopg2
from psycopg2 import Error
import os
import sys
import re

# =============================================================================
# CONFIGURAÇÃO DO BANCO DE DADOS
# =============================================================================
DB_CONFIG = {
    "host": "localhost",
    "database": "Projeto_DB",  
    "user": "postgres",
    "password": "123",  # ATENÇÃO: Altere para a senha do seu PostgreSQL
    "port": "5555"
}

# =============================================================================
# FUNÇÕES UTILITÁRIAS
# =============================================================================


def pausar():
    """Pausa a execução até o usuário pressionar Enter."""
    input("\nPressione <ENTER> para continuar...")

def criar_conexao():
    """Estabelece a conexão com o banco de dados PostgreSQL."""
    conn = None
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Error as e:
        print(f"\n[ERRO CRÍTICO] Falha ao conectar no banco de dados: '{e}'")
        return None

# =============================================================================
# FUNCIONALIDADE 1: INSERÇÃO (CADASTRAR)
# =============================================================================
def cadastrar_conteiner(conn):
    """
    Solicita dados ao usuário e insere um novo contêiner no banco.
    Inclui validação de Regex e tratamento de erros de integridade.
    """
    print("=== CADASTRO DE NOVO CONTÊINER ===")
    
    # Validação do Número de Série
    while True:
        num_serie = input("Digite o Número de Série (Padrão CONT-XXX): ").strip().upper()
        if re.match(r'^CONT-\d+$', num_serie):
            break
        else:
            print("\n[ERRO DE FORMATO] O código deve seguir o padrão 'CONT-' seguido de números.")
            print("Exemplos válidos: CONT-100, CONT-01, CONT-5000\n")
    
    # Validação da Capacidade
    while True:
        try:
            capacidade = float(input("Digite a Capacidade (L): "))
            if capacidade <= 0:
                print("A capacidade deve ser maior que zero.")
                continue
            break
        except ValueError:
            print("Por favor, digite um número válido.")

    # Validação do Tipo
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

    # Execução no Banco
    try:
        cursor = conn.cursor()
        
        sql_insert = """
            INSERT INTO Conteiner (NumSerie, Capacidade, TipoDeResiduo)
            VALUES (%s, %s, %s);
        """
        
        cursor.execute(sql_insert, (num_serie, capacidade, tipo_residuo))
        conn.commit()
        
        print(f"\n[SUCESSO] Contêiner {num_serie} cadastrado com sucesso!")
        
    except psycopg2.IntegrityError:
        conn.rollback()
        print(f"\n[ERRO DE DUPLICIDADE] O código '{num_serie}' já existe no banco de dados.")
        
    except Error as e:
        conn.rollback()
        print(f"\n[ERRO DE BANCO] Falha na operação: {e}")
        
    finally:
        if 'cursor' in locals():
            cursor.close()
    
    pausar()

# =============================================================================
# FUNCIONALIDADE 2: CONSULTA GERAL (DASHBOARD)
# =============================================================================
def consultar_monitoramento(conn):
    """
    Relatório gerencial com JOINs para mostrar status e alertas de nível crítico.
    """
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
              
                # Lógica de Alerta Visual no Python
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

# =============================================================================
# FUNCIONALIDADE 3: CONSULTA PARAMETRIZADA (FILTROS)
# =============================================================================
def consultar_com_filtro(conn):
    """
    Permite filtrar contêineres por Tipo, Capacidade ou Número de Série.
    Usa 'Prepared Statements' (%s) para segurança.
    """
    print("=== CONSULTA PARAMETRIZADA ===")
    print("Escolha o critério de filtro:")
    print("1 - Filtrar por Tipo de Resíduo")
    print("2 - Filtrar por Capacidade Mínima")
    print("3 - Pesquisar por Número de Série (Busca Específica)")
    
    opcao = input("\nOpção: ")
    
    sql_filtro = ""
    parametro = None
    
    # 1. Filtro por Tipo
    if opcao == '1':
        print("\nQual tipo deseja buscar?")
        print("1 - RECICLAVEL")
        print("2 - NAO_RECICLAVEL")
        escolha = input("Opção: ")
        
        if escolha == '1':
            parametro = 'RECICLAVEL'
        elif escolha == '2':
            parametro = 'NAO_RECICLAVEL'
        else:
            print("Opção inválida.")
            pausar()
            return
            
        sql_filtro = "SELECT NumSerie, Capacidade, TipoDeResiduo FROM Conteiner WHERE TipoDeResiduo = %s"

    # 2. Filtro por Capacidade
    elif opcao == '2':
        try:
            valor = float(input("\nDigite a capacidade mínima (Litros): "))
            parametro = valor
            sql_filtro = "SELECT NumSerie, Capacidade, TipoDeResiduo FROM Conteiner WHERE Capacidade >= %s"
        except ValueError:
            print("Valor inválido.")
            pausar()
            return

    # 3. Filtro por Número de Série (ID)
    elif opcao == '3':
        serial_busca = input("\nDigite o Número de Série (ex: CONT-100): ").strip().upper()
        parametro = serial_busca
        sql_filtro = "SELECT NumSerie, Capacidade, TipoDeResiduo FROM Conteiner WHERE NumSerie = %s"

    else:
        print("Opção inválida.")
        pausar()
        return

    # Execução da Consulta
    try:
        cursor = conn.cursor()
        
        # Passamos 'parametro' como tupla (parametro,) para o execute
        cursor.execute(sql_filtro, (parametro,))
        registros = cursor.fetchall()
        
        print(f"\nResultados da busca para: {parametro}")
        print("-" * 55)
        print(f"{'SÉRIE':<15} | {'CAPACIDADE':<15} | {'TIPO':<15}")
        print("-" * 55)
        
        if not registros:
            print("Nenhum registro encontrado com esse critério.")
        else:
            for row in registros:
                print(f"{row[0]:<15} | {row[1]:<15} | {row[2]:<15}")
                
        print("-" * 55)
        
    except Error as e:
        print(f"\n[ERRO NA CONSULTA] {e}")
    finally:
        if 'cursor' in locals():
            cursor.close()
        
    pausar()

# =============================================================================
# MENU PRINCIPAL (MAIN)
# =============================================================================
def main():
    conn = criar_conexao()
    
    # Se não conectar, encerra o programa
    if conn is None:
        sys.exit(1)

    while True:
        print("=== SISTEMA DE GESTÃO DE RESÍDUOS SÓLIDOS ===")
        print("1. Cadastrar Novo Contêiner")
        print("2. Consultar Monitoramento (Dashboard Geral)")
        print("3. Consultar com Filtro (Parametrizada)")
        print("4. Sair")
        
        opcao = input("\nDigite a opção desejada: ")

        if opcao == '1':
            cadastrar_conteiner(conn)
        elif opcao == '2':
            consultar_monitoramento(conn)
        elif opcao == '3':
            consultar_com_filtro(conn)
        elif opcao == '4':
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
