# --- TP ESTADÍSTICA TUIA 2026 ---
# Carga de librerías
library(tidyverse)

# 2. Planificación: Fijar la semilla de aleatoriedad
set.seed(2026)

# 3. Lectura de la población (N) asumiendo que el archivo está en su directorio
datos_poblacion <- read_tsv("title.basics.tsv", na = "\\N")

# 4. Filtrado y extracción de la muestra (n)
muestra_cruda <- datos_poblacion %>%
  filter(startYear == 2023) %>%             # Garantiza análisis transversal
  filter(!is.na(runtimeMinutes)) %>%        # Elimina registros sin duración
  filter(!is.na(genres)) %>%                # Elimina registros sin género
  slice_sample(n = 500)                     # Extrae una muestra aleatoria simple de tamaño n=500

# 5. Generación de las 4 variables de interés (D/A)
datos_tp <- muestra_cruda %>%
  mutate(
    # Variable Cualitativa Nominal: Extrae el primer género antes de la coma
    genero_principal = str_extract(genres, "[^,]+"),
    
    # Variable Cuantitativa Discreta: Cuenta comas y suma 1
    cant_generos = str_count(genres, ",") + 1,
    
    # Variable Cualitativa Ordinal: Discretización de la variable continua
    categoria_duracion = case_when(
      runtimeMinutes <= 30 ~ "Cortometraje",
      runtimeMinutes > 30 & runtimeMinutes <= 60 ~ "Mediometraje",
      runtimeMinutes > 60 ~ "Largometraje"
    ),
    
    # Estructuración matemática del orden (Factor)
    categoria_duracion = factor(categoria_duracion, 
                                levels = c("Cortometraje", "Mediometraje", "Largometraje"), 
                                ordered = TRUE)
  )

# --- ETAPA DE DATOS Y ANÁLISIS (D/A) ---

# A. Análisis Numérico: Variable Cuantitativa Continua (Duración)
# Se calculan los estimadores de posición y dispersión.
resumen_duracion <- datos_tp %>%
  summarise(
    tamano_muestra = n(),
    media_x = mean(runtimeMinutes, na.rm = TRUE),
    mediana = median(runtimeMinutes, na.rm = TRUE),
    varianza_s2 = var(runtimeMinutes, na.rm = TRUE),
    desvio_s = sd(runtimeMinutes, na.rm = TRUE),
    cv_porcentaje = (sd(runtimeMinutes, na.rm = TRUE) / mean(runtimeMinutes, na.rm = TRUE)) * 100
  )

# Mostrar el resultado numérico en la consola
print(resumen_duracion)

# B. Análisis de Frecuencias: Variable Cualitativa Nominal (Género)
# Se calcula la distribución para estimar proporciones poblacionales (pi)
tabla_generos <- datos_tp %>%
  count(genero_principal, name = "frecuencia_absoluta") %>%
  mutate(
    frecuencia_relativa = frecuencia_absoluta / sum(frecuencia_absoluta),
    porcentaje = frecuencia_relativa * 100
  ) %>%
  arrange(desc(frecuencia_absoluta)) # Ordena de mayor a menor frecuencia

# Mostrar la tabla en la consola
print(tabla_generos)