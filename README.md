## Instalação

## Estrutura do projeto

```text
├── db/
│ ├── init/                     # Scripts de inicialização automática do banco
│ │ ├── 01_esquema.sql          # Estrutura das tabelas (DDL) e Triggers
│ │ └── 02_dados.sql            # Inserção de dados de teste (DML)
│ └── scripts/                  # Scripts auxiliares e consultas
│ └── consultas.sql             # As 5 consultas complexas do projeto
├── .dockerignore
├── .gitignore
├── docker-compose.yml         # Orquestração dos containers (App + Banco)
├── Makefile                   # Automação de comandos (ex: make run, make clean)
├── README.md                  # Documentação do projeto
└── server.py                  # Código fonte da aplicação Python (Entrypoint)
```

### Requisitos

Antes de iniciar, certifique-se de ter as seguintes versões instaladas:

- **Docker**: versão 20.10 ou superior
- **Docker Compose**: versão 2.0 ou superior (ou Docker Compose Plugin v2)
- **Make**: versão 4.0 ou superior (geralmente já incluído em sistemas Linux/macOS)
- **Python**: versão 3.12.x

Para verificar as versões instaladas:

```bash
docker --version
docker compose version
make --version
python3 --version
```

## Como rodar a aplicação

### Usando Make (Recomendado)

O projeto inclui um `Makefile` com comandos que simplificam o fluxo de desenvolvimento.

1. Iniciar a aplicação em modo desenvolvimento:

```bash
make dev
```

2. Resetar o banco de dados (Soft Clean)

Esse comando remove os dados persistidos no volume e reinicia os containers:

```bash
make soft-clean
```

## Configurando o Ambiente Virtual Python

Após iniciar os containers, crie um ambiente virtual para rodar a aplicação Python:

```bash
python3 -m venv venv          # Criação do ambiente virtual
source venv/bin/activate      # Ativar o ambiente virtual
```

Instalar dependências necessárias

```bash
pip install psycopg2-binary   # Instalar a biblioteca psycopg2
```

## Executando a Aplicação

Com o ambiente virtual ativado, basta rodar:

```bash
python3 server.py
```

## Realizando consultas direto no PostgreSQL (via psql)

Além da interface Python, você também pode consultar o banco diretamente usando psql.

Após rodar `make dev`, aguarde a mensagem no container:

```bash
database system is ready to accept connections
```

Então abra um terminal `bash` e execute:

```bash
psql -h localhost -p 5555 -U postgres -d Projeto_DB
```

A senha padrão é:

```bash
123
```

Após entrar no PostgreSQL, você pode rodar quaisquer consultas desejadas — incluindo as que deixamos no arquivo consultas.sql.

## Guia de Navegação na aplicação python

A interação com o sistema ocorre através de um menu principal numérico, projetado para ser simples e cíclico. Veja como navegar:

**Acesso Inicial:** Ao executar o script (python app.py), o usuário é recebido pelo menu principal contendo as quatro opções operacionais.

**Seleção de Operações:** Para acessar uma funcionalidade, digite o número correspondente (1, 2, 3 ou 4) e pressione **ENTER**.

Opção 1 (Cadastrar): O sistema solicitará sequencialmente o Serial, a Capacidade e o Tipo. Basta digitar os valores e confirmar.

Opção 2 (Monitorar): Painel gerencial que unifica dados de toda a frota (via LEFT JOIN), exibindo inclusive equipamentos sem sensores. Implementa regras de negócio visuais, marcando automaticamente como [CRÍTICO!] os contêineres com ocupação superior a 80%.

Opção 3 (Consultar com Filtro): Ao selecionar esta opção, um submenu será aberto perguntando qual critério de filtro você deseja usar. Selecione o critério e, em seguida, digite o valor de busca (ex: digitar "CONT-100" para buscar pelo serial).

**Retorno ao Menu:** Após a conclusão de qualquer operação (seja um cadastro bem-sucedido ou a visualização de uma consulta), o sistema pausa a execução e exibe a mensagem "Pressione **ENTER** para continuar...". Ao pressionar a tecla, a tela é limpa e o menu principal é recarregado.

**Encerrando:** Para fechar a conexão com o banco de dados de forma segura e sair da aplicação, selecione a Opção 4 (Sair) no menu principal.
