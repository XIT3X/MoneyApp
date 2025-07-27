#!/bin/bash

# Script di backup automatico per MoneyApp
echo "🚀 Avvio backup su GitHub..."

# Controlla se ci sono modifiche
if ! git diff --quiet || ! git diff --staged --quiet; then
    echo "📝 Trovate modifiche da salvare..."
    
    # Mostra le modifiche
    echo "📋 File modificati:"
    git status --porcelain
    
    # Aggiungi tutti i file
    git add .
    
    # Richiedi messaggio di commit
    if [ -z "$1" ]; then
        echo "💬 Inserisci un messaggio per il commit:"
        read -r commit_message
    else
        commit_message="$1"
    fi
    
    # Se non è stato fornito un messaggio, usa uno di default
    if [ -z "$commit_message" ]; then
        commit_message="Auto-backup $(date '+%Y-%m-%d %H:%M:%S')"
    fi
    
    # Crea il commit
    git commit -m "$commit_message"
    
    # Push su GitHub
    echo "☁️ Caricamento su GitHub..."
    git push
    
    echo "✅ Backup completato con successo!"
    echo "🌐 Visualizza su: https://github.com/XIT3X/MoneyApp"
else
    echo "ℹ️ Nessuna modifica da salvare."
fi

echo "📊 Stato attuale:"
git status --short 