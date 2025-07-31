# Views Architecture

## Struttura Organizzata

Il progetto è stato refactorizzato per seguire principi di clean architecture e separazione delle responsabilità.

### Componenti Principali

- **MainView.swift** - View principale semplificata e pulita
- **MainHeader.swift** - Header con pulsanti impostazioni, periodo e aggiungi transazione
- **MainScrollContent.swift** - Contenuto scrollabile principale
- **CategoryDistributionBar.swift** - Barra di distribuzione delle categorie
- **TransactionRow.swift** - Riga singola transazione
- **PeriodSelectionSheet.swift** - Sheet per selezione periodo
- **SectionHeader.swift** - Header delle sezioni
- **EmptyStateView.swift** - Vista stato vuoto
- **CategoryItems.swift** - Componenti per gli elementi categoria

### Managers

- **TransactionManager.swift** - Gestione delle transazioni
- **SettingsManager.swift** - Gestione delle impostazioni

### Models

- **Period.swift** - Enum per i periodi con logica di business

### Utilities

- **Extensions.swift** - Extensions comuni
- **CategoryUtilities.swift** - Funzioni utili per le categorie

## Benefici della Nuova Architettura

1. **Separazione delle Responsabilità** - Ogni file ha una responsabilità specifica
2. **Riusabilità** - I componenti possono essere riutilizzati
3. **Manutenibilità** - Più facile da mantenere e debuggare
4. **Testabilità** - Ogni componente può essere testato singolarmente
5. **Leggibilità** - Codice più pulito e comprensibile

## MVVM Pattern

Il progetto segue il pattern MVVM con:
- **Model**: Transaction, Period, CategoryItem
- **ViewModel**: TransactionManager, SettingsManager
- **View**: Tutti i componenti UI

Questa struttura rende il codice più professionale, scalabile e facile da mantenere.