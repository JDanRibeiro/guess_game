# Jogo de Adivinhação com Docker Compose

Este é um jogo de adivinhação desenvolvido com Flask (backend) e React (frontend), implementado em uma arquitetura containerizada usando Docker Compose com balanceamento de carga e alta disponibilidade.

## Arquitetura da Solução

A aplicação é composta por 5 containers principais orquestrados via Docker Compose:

### 1. **Banco de Dados PostgreSQL**
- Container: `postgres:15`
- Função: Armazenamento persistente dos dados do jogo
- Volumes: Dados persistentes em `postgres_data`

### 2. **Backend Flask (2 instâncias)**
- Containers: `backend1` e `backend2`
- Função: API REST para lógica do jogo de adivinhação
- Balanceamento: Distribuição automática de carga via NGINX
- Resiliência: Reinício automático em caso de falha

### 3. **Frontend React**
- Container: `frontend` (build apenas)
- Função: Build da aplicação React em arquivos estáticos
- Otimizações: Sourcemaps desabilitados para produção

### 4. **NGINX (Proxy Reverso)**
- Container: `nginx:1.25-alpine`
- Função: 
  - Servidor web para arquivos estáticos React
  - Proxy reverso com balanceamento de carga para backends
  - Ponto de entrada único na porta 80

## Opções de Design Adotadas

### **Balanceamento de Carga**
- **Estratégia**: Round-robin automático entre `backend1` e `backend2`
- **Benefícios**: Alta disponibilidade, distribuição de carga, escalabilidade
- **Configuração**: Upstream `backend` no NGINX

### **Volumes Persistentes**
- **postgres_data**: Dados do PostgreSQL sobrevivem a reinicializações
- **frontend_build**: Compartilhamento de arquivos build entre containers

### **Rede Isolada**
- **guess_network**: Rede bridge dedicada para comunicação interna
- **Segurança**: Containers isolados do host, comunicação apenas entre serviços

### **Estratégia de Restart**
- **Backend/NGINX**: `restart: always` para alta disponibilidade
- **Frontend**: Container temporário apenas para build

### **Otimizações de Produção**
- **NGINX**: Compressão gzip, cache headers, configurações de segurança
- **React**: Build otimizado, sourcemaps desabilitados
- **PostgreSQL**: Imagem oficial otimizada

## Instalação e Execução

### **Pré-requisitos**
```bash
# Docker e Docker Compose instalados
docker --version
docker-compose --version
```

### **1. Clonar o Repositório**
```bash
git clone https://github.com/JDanRibeiro/guess_game.git
cd guess_game
```

### **2. Executar a Aplicação**
```bash
# Construir e executar todos os serviços
docker-compose up -d

# Verificar status dos containers
docker-compose ps

# Visualizar logs
docker-compose logs -f
```

### **3. Acessar a Aplicação**
- **Frontend**: http://localhost
- **API Backend**: http://localhost/api
- **Health Check**: http://localhost/health

### **4. Parar os Serviços**
```bash
# Parar containers (mantém dados)
docker-compose stop

# Parar e remover containers (mantém volumes)
docker-compose down

# Remover tudo incluindo volumes (CUIDADO!)
docker-compose down -v
```

## Atualizações de Componentes

### **Backend Flask**
```bash
# Atualizar apenas o backend
docker-compose build backend1 backend2
docker-compose up -d backend1 backend2

# Ou rebuild completo
docker-compose build --no-cache backend1 backend2
docker-compose up -d --force-recreate backend1 backend2
```

### **Frontend React**
```bash
# Rebuild do frontend
docker-compose build frontend
docker-compose up -d frontend

# NGINX automaticamente serve os novos arquivos
```

### **NGINX**
```bash
# Aplicar nova configuração
docker-compose restart nginx

# Ou com rebuild
docker-compose build nginx
docker-compose up -d nginx
```

### **PostgreSQL**
```bash
# Atualizar versão do PostgreSQL
# 1. Editar docker-compose.yml (ex: postgres:16)
# 2. Fazer backup dos dados
docker-compose exec postgres pg_dump -U guessuser guessdb > backup.sql

# 3. Atualizar container
docker-compose pull postgres
docker-compose up -d postgres
```

## Estratégias de Atualização

### **Zero Downtime (Produção)**
```bash
# 1. Atualizar uma instância do backend por vez
docker-compose stop backend1
docker-compose build backend1
docker-compose up -d backend1

# 2. Verificar se está funcionando
curl http://localhost/health

# 3. Repetir para backend2
docker-compose stop backend2
docker-compose build backend2
docker-compose up -d backend2
```

### **Rollback Rápido**
```bash
# Voltar para versão anterior
docker-compose down
git checkout <commit-anterior>
docker-compose up -d
```

### **Atualização de Versões Docker**
```yaml
# No docker-compose.yml
services:
  postgres:
    image: postgres:16  # Alterar versão
  nginx:
    image: nginx:1.26-alpine  # Alterar versão
```

## Funcionalidades do Jogo

### **Criar Novo Jogo**
1. Acesse http://localhost
2. Digite uma frase secreta
3. Clique em "Criar Jogo"
4. Salve o `game_id` gerado

### **Adivinhar a Senha**
1. Acesse http://localhost
2. Vá para "Breaker"
3. Digite o `game_id`
4. Tente adivinhar a senha
5. Receba feedback das tentativas

## Monitoramento e Logs

### **Verificar Status**
```bash
# Status dos containers
docker-compose ps

# Logs em tempo real
docker-compose logs -f

# Logs específicos
docker-compose logs nginx
docker-compose logs backend1
```

### **Métricas de Recursos**
```bash
# Uso de recursos
docker stats

# Espaço em disco
docker system df
```

## Resolução de Problemas

### **Container não inicia**
```bash
# Verificar logs
docker-compose logs <service-name>

# Rebuild forçado
docker-compose build --no-cache <service-name>
```

### **Problemas de conectividade**
```bash
# Verificar rede
docker network ls
docker network inspect guess_game_guess_network

# Testar conectividade interna
docker-compose exec backend1 ping postgres
```

### **Banco de dados não conecta**
```bash
# Verificar se PostgreSQL está rodando
docker-compose exec postgres psql -U guessuser -d guessdb -c "SELECT 1;"

# Verificar logs do banco
docker-compose logs postgres
```

## Ambiente de Desenvolvimento

### **Desenvolvimento Local**
```bash
# Executar apenas banco de dados
docker-compose up -d postgres

# Executar backend local
export FLASK_DB_TYPE=postgres
export FLASK_DB_HOST=localhost
export FLASK_DB_NAME=guessdb
export FLASK_DB_USER=guessuser
export FLASK_DB_PASSWORD=guesspass
./start-backend.sh

# Frontend local
cd frontend
npm install
npm start
```

## Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

---

**Desenvolvido com Docker Compose para máxima portabilidade e escalabilidade.**

