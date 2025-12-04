## Instalação

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

### Usando Make (Recomendado)

O projeto inclui um `Makefile` com comandos simplificados:

1. Iniciar a aplicação em modo desenvolvimento:

```bash
make dev
```

Caso queira reiniciar os dados do banco você deve usar o comando soft-clean

```bash
# Remove dados do banco e reinicia os containers
make soft-clean
```

Agora você deve criar um ambiente virtual para rodar a aplicação python

```bash
python3 -m venv venv          # Criação do ambiente virtual
source venv/bin/activate      # Ativar o ambiente virtual
pip install psycopg2-binary   # Instalar a biblioteca psycopg2
python3 server.py
```
