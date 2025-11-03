# Brain Lesion Segmentation - Guida in Italiano

Una pipeline completa in MATLAB per la segmentazione e l'analisi automatica di lesioni cerebrali (tumori) da scansioni MRI.

## 🎯 Caratteristiche

- **Segmentazione Multi-Piano**: Analisi dei tumori nei piani assiale e sagittale
- **Robustezza al Rumore**: Test della segmentazione con rumore Gaussiano, salt & pepper e speckle
- **Calcolo del Volume**: Stima precisa del volume tumorale in pixel³, mm³ e cm³
- **Predizione Aree Mancanti**: Regressione polinomiale per stimare il tumore nelle slice non rilevate
- **Valutazione dell'Accuratezza**: Calcolo del coefficiente Dice per la validazione della segmentazione
- **Visualizzazione 3D**: Rendering 3D interattivo dei tumori segmentati

## 📁 Struttura del Repository

```
Brain-Lesion-Segmentation/
├── src/                          # Codice sorgente
│   ├── segmentation/             # Algoritmi di segmentazione
│   │   ├── calculateTumorVolume_3.m
│   │   ├── calculateTumorVolume_Noisy.m
│   │   └── predictMissingTumorAreas.m
│   ├── visualization/            # Visualizzazione 3D
│   │   └── visualizeTumorIn3DInteractive.m
│   └── utils/                    # Funzioni di utilità
│       ├── add_noise.m
│       └── calculateDiceCoefficient.m
├── examples/                     # Script di esempio
│   ├── quickstart.m              # Esempio di avvio rapido
│   ├── complete_pipeline.m       # Dimostrazione pipeline completa
│   └── noise_testing.m           # Test robustezza al rumore
├── data/                         # Directory dati (devi aggiungere i tuoi)
│   └── README.md                 # Istruzioni per ottenere dati MRI
├── docs/                         # Documentazione
│   ├── DOCUMENTATION.md          # Documentazione completa (inglese)
│   ├── README_IT.md              # Questo file
│   └── pipeline_guide.m          # Guida passo-passo
├── .gitignore                    # Regole git ignore
├── LICENSE                       # Informazioni licenza
└── README.md                     # README principale (inglese)
```

## 🚀 Avvio Rapido

### Prerequisiti

- MATLAB R2019b o successivo
- Image Processing Toolbox
- (Opzionale) Statistics and Machine Learning Toolbox

### Installazione

1. Clona questo repository:
   ```bash
   git clone https://github.com/FilippoSaccomano/Brain-Lesion-Segmentation.git
   cd Brain-Lesion-Segmentation
   ```

2. **Ottieni Dati MRI** (vedi [Requisiti Dati](#-requisiti-dati))

3. Esegui l'esempio di avvio rapido:
   ```matlab
   run examples/quickstart.m
   ```

## 📊 Requisiti Dati

### ⚠️ Importante: Dati Non Inclusi

Questo repository **NON** include dati MRI per restrizioni di licenza. Devi ottenere i tuoi dati MRI.

### Dove Ottenere i Dati

Dataset MRI pubblici sono disponibili da:

1. **BraTS** (Brain Tumor Segmentation Challenge)
   - Sito: https://www.med.upenn.edu/cbica/brats2020/data.html
   - Formato: NIfTI (.nii, .nii.gz)
   - Contenuto: Scansioni MRI multi-modali con tumori cerebrali
   - Licenza: Gratuito per uso di ricerca (registrazione richiesta)

2. **TCIA** (The Cancer Imaging Archive)
   - Sito: https://www.cancerimagingarchive.net/
   - Collezioni con tumori cerebrali:
     - "TCGA-GBM" (Glioblastoma Multiforme)
     - "TCGA-LGG" (Glioma di Basso Grado)
   - Formato: DICOM o NIfTI
   - Licenza: Dominio pubblico o licenze specifiche per collezione

3. **OpenNeuro**
   - Sito: https://openneuro.org/
   - Formato: NIfTI (.nii, .nii.gz)
   - Contenuto: Vari dataset di neuroimaging
   - Licenza: Varia per dataset (controllare le licenze individuali)

4. **Kaggle Brain MRI Datasets**
   - Sito: https://www.kaggle.com/datasets
   - Cerca: "brain tumor MRI" o "brain lesion"
   - Formato: Vari (PNG, DICOM, NIfTI)
   - Licenza: Varia per dataset

### Formato Richiesto

Il file deve chiamarsi `MRIdata.mat` e trovarsi nella cartella `data/`. Deve contenere:
- Nome variabile: `original_volume`
- Formato: Array 3D (uint8 o double)
- Dimensioni: `[altezza, larghezza, num_slice]`

### Conversione Rapida dei Dati

**Da file NIfTI:**
```matlab
% Installa il toolbox NIfTI da MATLAB File Exchange
nii = load_nii('tua_scansione.nii');
original_volume = uint8(255 * mat2gray(nii.img));
save('data/MRIdata.mat', 'original_volume');
```

**Da file DICOM:**
```matlab
dicomDir = 'percorso/alla/cartella/dicom';
dicomFiles = dir(fullfile(dicomDir, '*.dcm'));

for i = 1:length(dicomFiles)
    filename = fullfile(dicomDir, dicomFiles(i).name);
    slice = dicomread(filename);
    if i == 1
        [rows, cols] = size(slice);
        original_volume = zeros(rows, cols, length(dicomFiles), 'like', slice);
    end
    original_volume(:, :, i) = slice;
end

original_volume = uint8(255 * mat2gray(original_volume));
save('data/MRIdata.mat', 'original_volume');
```

**Vedi `data/README.md` per istruzioni dettagliate** sulla conversione di vari formati.

## 💡 Esempi d'Uso

### Segmentazione Base

```matlab
% Setup
addpath(genpath('src'));
load('data/MRIdata.mat', 'original_volume');

% Segmenta il tumore
voxelVolume = 1;  % mm³
voxelArea = 1;    % mm²

[volume, volume_mm3, volume_cm3, areas, masks, selected_mask] = ...
    calculateTumorVolume_3('sagittal', original_volume, voxelVolume, voxelArea);

fprintf('Volume tumore: %.2f cm³\n', volume_cm3);
```

### Pipeline Completa

```matlab
% Esegui la pipeline completa
run examples/complete_pipeline.m
```

Questo include:
- Caricamento dati
- Segmentazione in entrambi i piani
- Predizione del volume per slice mancanti
- Valutazione dell'accuratezza (se disponibile maschera manuale)
- Visualizzazione 3D

### Test di Robustezza al Rumore

```matlab
% Testa con diversi tipi di rumore
run examples/noise_testing.m
```

## 📖 Documentazione

La documentazione completa è disponibile in:
- `docs/DOCUMENTATION.md` - Riferimento funzioni (inglese)
- `docs/pipeline_guide.m` - Guida passo-passo con commenti dettagliati
- `data/README.md` - Guida alla preparazione dei dati

## 🔧 Funzioni Principali

### Segmentazione

- **`calculateTumorVolume_3`**: Segmentazione principale per dati puliti
- **`calculateTumorVolume_Noisy`**: Segmentazione con filtraggio del rumore
- **`predictMissingTumorAreas`**: Predici aree tumorali usando regressione

### Utilità

- **`add_noise`**: Aggiungi vari tipi di rumore per test di robustezza
- **`calculateDiceCoefficient`**: Valuta accuratezza segmentazione

### Visualizzazione

- **`visualizeTumorIn3DInteractive`**: Visualizzazione 3D del tumore

## 📈 Workflow della Pipeline

1. **Carica dati MRI** da `data/MRIdata.mat`
2. **(Opzionale) Aggiungi rumore** per test di robustezza
3. **Segmenta tumore** nei piani assiale e/o sagittale
4. **Calcola volume** in pixel³, mm³ e cm³
5. **Predici aree mancanti** usando regressione polinomiale
6. **(Opzionale) Valuta accuratezza** con coefficiente Dice
7. **Visualizza risultati** in 3D

## 🎓 Script di Esempio

Sono forniti tre script di esempio:

1. **`quickstart.m`**: Esempio minimo per iniziare rapidamente
2. **`complete_pipeline.m`**: Pipeline completa con tutte le funzionalità
3. **`noise_testing.m`**: Testa robustezza a diversi tipi di rumore

## 🔍 Risoluzione Problemi

### File dati non trovato
- Assicurati che `MRIdata.mat` sia nella directory `data/`
- Verifica che contenga una variabile chiamata `original_volume`
- Vedi `data/README.md` per istruzioni sulla preparazione dati

### Problemi di path
```matlab
% Aggiungi le directory sorgente al path di MATLAB
addpath(genpath('src'));
```

### Nessun tumore rilevato
- Regola i valori di soglia nelle funzioni di segmentazione
- Verifica che il range di slice corrisponda ai tuoi dati
- Controlla che i dati contengano lesioni visibili

### Conversione NIfTI
Se non hai il toolbox NIfTI:
1. Scarica da: https://www.mathworks.com/matlabcentral/fileexchange/8797
2. Oppure usa: https://github.com/NIFTI-Imaging/nifti_matlab

Per ulteriori suggerimenti, vedi `docs/DOCUMENTATION.md`.

## 📝 Licenza

Vedi il file [LICENSE](LICENSE) per i dettagli.

## ⚠️ Disclaimer

Questo software è solo per scopi di ricerca ed educativi. Non è destinato all'uso clinico o alla diagnosi medica. Assicurati sempre la conformità con le normative sui dati medici (HIPAA, GDPR, ecc.) quando lavori con dati di pazienti.

## 🤝 Contributi

I contributi sono benvenuti! Assicurati che:
- Il codice segua le best practice di MATLAB
- La documentazione sia aggiornata
- Gli esempi siano testati
- Non siano inclusi dati di pazienti

## 📧 Contatti

Per domande o problemi, apri un issue su GitHub.

---

**Nota Importante**: Questo è un progetto di ricerca. Assicurati di avere l'autorizzazione appropriata e l'approvazione etica prima di utilizzare dati di imaging medico.

## 🇮🇹 Note per Utenti Italiani

Questa pipeline è stata sviluppata come progetto di ricerca accademica. I file sono organizzati per essere:
- **Funzionali**: Pronti all'uso immediato
- **Documentati**: Con guide complete
- **Estensibili**: Facili da modificare e adattare
- **Conformi**: Senza dati sensibili inclusi

Per iniziare:
1. Ottieni dati MRI da dataset pubblici (vedi sopra)
2. Converti i dati nel formato .mat richiesto
3. Esegui uno degli script di esempio
4. Modifica i parametri secondo necessità

Buona ricerca! 🧠🔬
