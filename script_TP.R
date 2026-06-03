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

# C. Análisis de Frecuencias: Variable Cualitativa Ordinal (Categoría de Duración)
tabla_categorias <- datos_tp %>%
  count(categoria_duracion, name = "frecuencia_absoluta") %>%
  mutate(porcentaje = (frecuencia_absoluta / sum(frecuencia_absoluta)) * 100)

print(tabla_categorias)

# D. Análisis Numérico/Frecuencias: Variable Cuantitativa Discreta (Cantidad de Géneros)
tabla_cant_generos <- datos_tp %>%
  count(cant_generos, name = "frecuencia_absoluta") %>%
  mutate(porcentaje = (frecuencia_absoluta / sum(frecuencia_absoluta)) * 100)

print(tabla_cant_generos)

# --- C. Visualización de Datos (ggplot2) ---

# 1. Gráfico de Barras para Variable Cualitativa Nominal (Género)
grafico_generos <- ggplot(data = tabla_generos, mapping = aes(x = reorder(genero_principal, frecuencia_absoluta), y = frecuencia_absoluta)) +
  geom_col(fill = "steelblue", color = "black") +
  coord_flip() + # Invierte los ejes (X pasa a ser Y)
  labs(
    title = "Distribución de Títulos por Género Principal (2023)",
    x = "Género Cinematográfico",
    y = "Frecuencia Absoluta"
  ) +
  theme_minimal()

print(grafico_generos)

# 2. Histograma para Variable Cuantitativa Continua (Duración)
grafico_histograma <- ggplot(data = datos_tp, mapping = aes(x = runtimeMinutes)) +
  geom_histogram(fill = "darkorange", color = "black", bins = 20) +
  labs(
    title = "Distribución Empírica de la Duración de los Títulos",
    x = "Duración (minutos)",
    y = "Frecuencia Absoluta"
  ) +
  theme_minimal()

print(grafico_histograma)

# 3. Boxplot para Variable Cuantitativa Continua (Duración)
grafico_boxplot <- ggplot(data = datos_tp, mapping = aes(y = runtimeMinutes)) +
  geom_boxplot(fill = "lightgreen", color = "black") +
  labs(
    title = "Dispersión y Valores Atípicos de la Duración",
    y = "Duración (minutos)",
    x = ""
  ) +
  theme_minimal()

print(grafico_boxplot)

# =====================================================
# SEGUNDA PARTE - ESTIMACIÓN (Intervalos de Confianza)
# =====================================================

# a) Variable cualitativa elegida: categoria_duracion
# Justificación: permite comparar el comportamiento de la cantidad de géneros
# entre cortometrajes y largometrajes, dos subpoblaciones con lógicas
# de producción distintas. Es relevante porque se espera que el mercado
# cinematográfico de 2023 muestre diferencias estructurales entre ambos formatos.

# b) Parámetro de interés: media poblacional de cant_generos
#    µ_corto  = media de cant_géneros en la subpoblación de Cortometrajes
#    µ_largo  = media de cant_géneros en la subpoblación de Largometrajes

# Filtramos los dos grupos principales (descartamos Mediometraje si n es pequeño)
grupos_ic <- datos_tp %>%
  filter(categoria_duracion %in% c("Cortometraje", "Largometraje"))

# c) Construcción de ICs al 95% para cada grupo

ic_por_grupo <- grupos_ic %>%
  group_by(categoria_duracion) %>%
  summarise(
    n         = n(),
    media     = mean(cant_generos, na.rm = TRUE),
    desvio_s  = sd(cant_generos, na.rm = TRUE),
    error_est = desvio_s / sqrt(n),
    t_critico = qt(0.975, df = n - 1),   # t bilateral al 95%
    lim_inf   = media - t_critico * error_est,
    lim_sup   = media + t_critico * error_est,
    .groups = "drop"
  )

print(ic_por_grupo)

# Visualización: ICs con punto (media) y barras de error
grafico_ic <- ggplot(ic_por_grupo, aes(x = categoria_duracion, y = media, color = categoria_duracion)) +
  geom_point(size = 4) +
  geom_errorbar(aes(ymin = lim_inf, ymax = lim_sup), width = 0.2, linewidth = 1.2) +
  labs(
    title    = "IC 95% para la Cantidad Media de Géneros por Categoría de Duración",
    subtitle = "Estimación puntual ± margen de error (t de Student)",
    x        = "Categoría de Duración",
    y        = "Cantidad Media de Géneros",
    color    = "Categoría"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

print(grafico_ic)

# Boxplot comparativo: duración por categoría (opcional pero valorado)
grafico_boxplot_grupos <- ggplot(datos_tp, aes(x = categoria_duracion, y = cant_generos, fill = categoria_duracion)) +
  geom_boxplot(color = "black") +
  labs(
    title = "Distribución de Cantidad de Géneros por Categoría de Duración",
    x = "Categoría",
    y = "Cantidad de Géneros"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

print(grafico_boxplot_grupos)