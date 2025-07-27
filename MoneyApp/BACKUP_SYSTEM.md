# Sistema di Backup e Persistenza - Money Manager

## Panoramica

Il sistema di backup e persistenza di Money Manager garantisce che i tuoi dati rimangano al sicuro anche se disinstalli e reinstalli l'app. Il sistema utilizza una combinazione di Core Data per la persistenza locale e backup automatici in formato JSON.

## Caratteristiche Principali

### 🔄 Backup Automatico
- **Backup Locale**: I dati vengono salvati automaticamente nel file system del dispositivo
- **Backup iCloud**: Se disponibile, una copia viene salvata anche su iCloud
- **Frequenza**: Il backup viene creato automaticamente ogni volta che aggiungi, modifichi o elimini una transazione

### 📱 Persistenza Robusta
- **Core Data**: Utilizza il framework Core Data di Apple per una gestione affidabile dei dati
- **Migrazione Automatica**: I dati esistenti vengono migrati automaticamente dal vecchio sistema UserDefaults
- **Integrità**: I dati sono protetti da corruzioni e perdite accidentali

### 🔧 Backup Manuale
- **Creazione Manuale**: Puoi creare backup manuali dalle impostazioni
- **Ripristino**: Possibilità di ripristinare i dati da un backup esistente
- **Gestione**: Elimina i backup quando non servono più

## Come Funziona

### 1. Salvataggio Automatico
Ogni volta che:
- Aggiungi una nuova transazione
- Modifichi una transazione esistente
- Elimini una transazione
- Aggiungi, modifichi o elimini una categoria

Il sistema:
1. Salva i dati in Core Data
2. Crea un backup automatico in formato JSON
3. Salva una copia su iCloud (se disponibile)

### 2. Backup Locale
I backup vengono salvati in:
```
/Users/[username]/Library/Containers/[app-bundle]/Data/Documents/money_manager_backup.json
```

### 3. Backup iCloud
Se l'utente ha iCloud abilitato, una copia viene salvata anche in:
```
iCloud Drive/Documents/money_manager_backup.json
```

### 4. Ripristino Automatico
Quando l'app viene avviata:
1. Controlla se esistono dati in Core Data
2. Se non ci sono dati, cerca un backup locale
3. Se non trova backup locali, cerca su iCloud
4. Ripristina automaticamente i dati trovati

## Utilizzo

### Creare un Backup Manuale
1. Apri l'app Money Manager
2. Vai nelle Impostazioni (icona ingranaggio)
3. Tocca "Crea Backup"
4. Conferma l'operazione

### Ripristinare un Backup
1. Apri l'app Money Manager
2. Vai nelle Impostazioni
3. Tocca "Ripristina Backup"
4. Conferma l'operazione (i dati attuali verranno sovrascritti)

### Eliminare un Backup
1. Apri l'app Money Manager
2. Vai nelle Impostazioni
3. Tocca "Elimina Backup"
4. Conferma l'operazione

## Sicurezza

### Protezione dei Dati
- I backup sono salvati in formato JSON crittografato
- I dati Core Data sono protetti dal sistema operativo
- Nessun dato viene inviato a server esterni (tranne iCloud se abilitato)

### Privacy
- Tutti i dati rimangono sul dispositivo
- Nessuna condivisione con terze parti
- Controllo completo sui propri dati

## Risoluzione Problemi

### Se i dati non si caricano
1. Verifica che l'app abbia i permessi per accedere ai file
2. Controlla se c'è spazio sufficiente sul dispositivo
3. Prova a ripristinare da un backup manuale

### Se il backup non funziona
1. Verifica la connessione internet per iCloud
2. Controlla lo spazio disponibile su iCloud
3. Prova a creare un backup manuale

### Se l'app non si avvia
1. Elimina l'app e reinstallala
2. I dati verranno ripristinati automaticamente dal backup

## Note Tecniche

### Formato Backup
Il backup è salvato in formato JSON con la seguente struttura:
```json
{
  "transactions": [
    {
      "id": "UUID",
      "description": "Descrizione",
      "amount": 100.0,
      "category": "Categoria",
      "date": "2024-01-01T00:00:00Z"
    }
  ],
  "categories": [
    {
      "id": "UUID",
      "name": "Nome Categoria",
      "color": "#ffbeaa",
      "emoji": "🍖"
    }
  ]
}
```

### Compatibilità
- iOS 15.0+
- Compatibile con tutte le versioni future di iOS
- Migrazione automatica tra versioni dell'app

## Supporto

Se riscontri problemi con il sistema di backup:
1. Controlla questa documentazione
2. Prova a ripristinare da un backup manuale
3. Se il problema persiste, contatta il supporto tecnico 