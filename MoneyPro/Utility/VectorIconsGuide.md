# Guida per le Icone Vettoriali

## Problemi Comuni e Soluzioni

### 1. Icone Sgranate
**Problema**: Le icone SVG risultano sgranate o pixelate su dispositivi ad alta densità.

**Soluzioni implementate**:
- Aggiunta di configurazioni per diverse densità di pixel (1x, 2x, 3x)
- Proprietà `preserves-vector-representation: true` negli asset catalog
- Proprietà `template-rendering-intent: template` per il rendering ottimizzato
- Configurazione `ASSETCATALOG_COMPILER_PRESERVE_VECTOR_DATA = YES` nel progetto

### 2. Ottimizzazioni nel Codice Swift

#### Estensioni Image
```swift
// Per icone generiche
.optimizedVectorIcon()

// Per icone piccole (22-24px)
.smallIconOptimized()

// Per icone grandi (40px+)
.largeIconOptimized()
```

#### ViewModifier Personalizzati
```swift
// Icona semplice
Image("ic_plus").vectorIcon(size: 24, color: .blue)

// Icona con background
Image("ic_options").vectorIconWithBackground(
    size: 22, 
    color: .gray, 
    backgroundColor: .white, 
    cornerRadius: 12
)
```

### 3. Configurazioni Asset Catalog

Ogni icona deve avere:
- Configurazioni per scale 1x, 2x, 3x
- `preserves-vector-representation: true`
- `template-rendering-intent: template`

### 4. Best Practices

1. **Sempre usare `.renderingMode(.template)`** per icone che cambiano colore
2. **Applicare `.interpolation(.high)`** per migliorare la qualità
3. **Usare `.antialiased(true)`** per bordi più lisci
4. **Specificare sempre le dimensioni** con `.frame()`
5. **Utilizzare `.aspectRatio(contentMode: .fit)`** per mantenere le proporzioni

### 5. Troubleshooting

**Se le icone sono ancora sgranate**:
1. Verificare che l'SVG sia ottimizzato (senza elementi nascosti)
2. Controllare che le dimensioni del frame siano appropriate
3. Assicurarsi che `preserves-vector-representation` sia true
4. Provare a pulire e ricostruire il progetto

**Per icone particolarmente complesse**:
- Considerare la conversione in PNG per dimensioni specifiche
- Utilizzare SF Symbols quando possibile
- Ottimizzare l'SVG rimuovendo elementi non necessari 