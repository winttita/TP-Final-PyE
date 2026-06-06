# Radiografia del cine en 2023: Un análisis estadístico basado en IMDb

Trabajo Práctico de **Probabilidad y Estadística** | TUIA 2026  
Universidad Tecnológica Nacional · Facultad Regional Rosario

---

## Descripción

Informe estadístico basado en el ciclo **PPDAC** (Problema → Plan → Datos → Análisis → Conclusión) sobre una muestra aleatoria simple de títulos cinematográficos del año 2023 extraídos de la base de datos pública de IMDb.

El objetivo es aplicar técnicas de análisis descriptivo y estimación por intervalos de confianza sobre variables de interés del mercado audiovisual.

---

## Variables de interés

| Variable | Tipo | Descripción |
|---|---|---|
| `genero_principal` | Cualitativa Nominal | Primer género listado en el título |
| `categoria_duracion` | Cualitativa Ordinal | Cortometraje / Mediometraje / Largometraje |
| `runtimeMinutes` | Cuantitativa Continua | Duración del título en minutos |
| `cant_generos` | Cuantitativa Discreta | Cantidad de géneros asignados al título |

---

## Estructura del repositorio

```
TP/
├── script_TP.R              # Script principal (ciclo PPDAC completo)
├── Consigna e Informe.docx  # Informe final en formato PDF/Word
└── README.md
```

 El archivo `title.basics.tsv` (1 GB) **no está incluido** en el repositorio por su tamaño. Ver instrucciones de descarga abajo.

---

## Dataset

**Fuente:** [IMDb Non-Commercial Datasets](https://developer.imdb.com/non-commercial-datasets/)  
**Archivo:** `title.basics.tsv.gz`  
**Descarga:** [https://datasets.imdbws.com/title.basics.tsv.gz](https://datasets.imdbws.com/title.basics.tsv.gz)

Una vez descargado, descomprimí el archivo y colocá `title.basics.tsv` en la misma carpeta que `script_TP.R`.

---

## Cómo reproducir el análisis

### Requisitos

- [R](https://cran.r-project.org/) ≥ 4.0
- [RStudio](https://posit.co/download/rstudio-desktop/)
- Paquete `tidyverse`

### Pasos

```r
# 1. Instalar dependencias (solo la primera vez)
install.packages("tidyverse")

# 2. Setear el directorio de trabajo a la carpeta del proyecto
# En RStudio: Session → Set Working Directory → To Source File Location

# 3. Correr el script completo
# Ctrl + Shift + Enter
```

---

## Contenido del análisis

### Parte 1 — Análisis Descriptivo
- Medidas de posición y dispersión para la duración (`runtimeMinutes`)
- Distribución de frecuencias para género principal y categoría de duración
- Gráfico de barras, histograma y boxplot

### Parte 2 — Estimación
- Intervalos de confianza al 95% (t de Student) para la media de cantidad de géneros
- Comparación entre subpoblaciones: **Cortometraje** vs **Largometraje**
- Gráfico de ICs y boxplot comparativo

---

## Reproducibilidad

La semilla de aleatoriedad está fijada al inicio del script:

```r
set.seed(2026)
```

Esto garantiza que la muestra de 500 títulos sea idéntica en cualquier ejecución.

---

## Integrantes

- Ayala, Juan Manuel
- De Lorenzi, Guadalupe
- Ibarbia, Manuel
- Winter. Federico

**Materia:** Probabilidad y Estadística  
**Carrera:** Tecnicatura Universitaria en Inteligencia Artificial (TUIA)  
**Fecha de entrega:** 04/06/2026
