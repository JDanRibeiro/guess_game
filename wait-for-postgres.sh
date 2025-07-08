#!/bin/bash
# Script para aguardar PostgreSQL ficar disponível

set -e

host="$1"
shift
cmd="$@"

until pg_isready -h "$host" -p 5432 -U guessuser; do
  echo "PostgreSQL não está disponível ainda - aguardando..."
  sleep 2
done

echo "PostgreSQL está disponível - executando comando"
exec $cmd 