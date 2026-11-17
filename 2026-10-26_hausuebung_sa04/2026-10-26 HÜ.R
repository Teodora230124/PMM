# =============================================================================
# SA-04 — Daten einlesen II: die raue Wirklichkeit
# Lösung der Hausübung (Teile 1–3 + Kapitel-Check)
#
# Ausführen:  Rscript SA-04-hausuebung-loesung.R
# (funktioniert aus dem Repo-Root, aus dem Lesson-Ordner und aus diesem Ordner)
#
# Arbeitsweise der Lektion: erst vorhersagen, dann laufen lassen.
# Die "Vorhersage:"-Kommentare sind zum Abhaken gedacht.
# =============================================================================

suppressPackageStartupMessages({
  library(tidyverse)   # readr, dplyr, ggplot2, stringr, tidyr
  library(readxl)      # excel_sheets(), read_excel()
})

# --- Datenordner finden ------------------------------------------------------
# Die Rohdaten bleiben in der Lesson (GRG-PMM); dieses Skript liegt im
# PMM-Repo unter Hausaufgabe/. Deshalb wird auch neben dem Repo gesucht.
daten <- local({
  kandidaten <- c(
    "daten",
    "unterricht/SA-04-daten-einlesen-raue-wirklichkeit/daten",
    "../SA-04-daten-einlesen-raue-wirklichkeit/daten",
    "../../unterricht/SA-04-daten-einlesen-raue-wirklichkeit/daten",
    "../GRG-PMM/unterricht/SA-04-daten-einlesen-raue-wirklichkeit/daten",
    "../../GRG-PMM/unterricht/SA-04-daten-einlesen-raue-wirklichkeit/daten"
  )
  datei_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(datei_arg) == 1) {
    skript_dir <- dirname(normalizePath(sub("^--file=", "", datei_arg)))
    kandidaten <- c(
      kandidaten,
      file.path(skript_dir, "daten"),
      file.path(skript_dir, "../../unterricht/SA-04-daten-einlesen-raue-wirklichkeit/daten"),
      file.path(skript_dir, "../../GRG-PMM/unterricht/SA-04-daten-einlesen-raue-wirklichkeit/daten")
    )
  }
  treffer <- kandidaten[dir.exists(kandidaten)]
  if (length(treffer) == 0) {
    stop("Datenordner nicht gefunden — bitte aus dem Repo-Root starten oder ",
         "den Ordner 'daten/' neben dieses Skript legen.")
  }
  normalizePath(treffer[[1]])
})
message("Datenordner: ", daten)


# =============================================================================
# 1) NASA sauber einlesen
# =============================================================================

# Erst hinschauen: Zeile 1 ist ein Titel, Zeile 2 die echte Kopfzeile.
readLines(file.path(daten, "gistemp_roh.csv"), n = 2)

# Sauber: Preamble überspringen und den NASA-Marker *** als NA deklarieren.
g <- read_csv(
  file.path(daten, "gistemp_roh.csv"),
  skip = 1,                 # Zeile 1 ist Titel, nicht Kopfzeile
  na   = "***",             # "gibt es nicht" -> echtes NA
  show_col_types = FALSE
)

# Typenkontrolle: ohne na = "***" wäre J-D character (und mean() still NA).
class(g$`J-D`)              # "numeric"
sum(is.na(g$`J-D`))         # 1 — nur das laufende Jahr 2026

anomalie <- g |>
  select(jahr = Year, anomalie = `J-D`) |>
  drop_na(anomalie)         # die eine echte Lücke für die Auswertung ausnehmen

nrow(anomalie)              # 146

anomalie |> filter(jahr >= 2022)
# 2022: 0.89 · 2023: 1.17 · 2024: 1.28 · 2025: 1.18

p_anomalie <- ggplot(anomalie, aes(x = jahr, y = anomalie)) +
  geom_line(color = "steelblue") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  labs(
    title = "Globale Temperaturanomalie (GISTEMP, Land-Ocean)",
    subtitle = "Abweichung vom Mittel 1951–1980 in °C",
    x = "Jahr", y = "Anomalie (°C)"
  ) +
  theme_minimal()
print(p_anomalie)
# ggsave("anomalie_zeitreihe.png", p_anomalie, width = 7, height = 4, dpi = 150)


# =============================================================================
# 2) Verurteilungsstatistik lesbar machen (Joins)
# =============================================================================

# Auch hier zuerst hinschauen: kein Preamble-Titel, aber Semikolon-Trenner.
readLines(file.path(daten, "OGD_krimi001_KRIMI_1.csv"), n = 1)

k <- read_csv2(
  file.path(daten, "OGD_krimi001_KRIMI_1.csv"),
  show_col_types = FALSE
)
k                          # 280 × 3, F-KRIM-1 ist numeric

# Dimensions-Datei Jahr: code "A10-2012" -> jahr 2012
jahr_dim <- read_csv2(
  file.path(daten, "OGD_krimi001_KRIMI_1_C-A10-0.csv"),
  show_col_types = FALSE
) |>
  mutate(jahr = as.integer(str_sub(code, 5)))

# Dimensions-Datei Gerichtssprengel: nur die LG-Zeilen (KRIMEA9-*),
# die OLG-Zeilen (KRIMJ93-*) sind Aggregate und kommen später separat.
sprengel <- read_csv2(
  file.path(daten, "OGD_krimi001_KRIMI_1_C-KRIMEA9-0.csv"),
  show_col_types = FALSE
) |>
  filter(str_starts(code, "KRIMEA9")) |>
  select(gericht_code = code, gericht = name, olg = FK)

delikte <- k |>
  left_join(jahr_dim |> select(code, jahr),
            by = c("C-A10-0" = "code")) |>
  left_join(sprengel, by = c("C-KRIMEA9-0" = "gericht_code")) |>
  select(jahr, gericht, olg, delikte = `F-KRIM-1`)

delikte

# --- Achtung Aggregate: erst zählen, dann summieren --------------------------
# OLG-Summenzeilen (KRIMJ93-*) haben keinen LG-Sprengel und bleiben beim Join
# ohne gericht (NA). "Nicht klassifizierbar" (KRIMEA9-0) gibt es in dieser
# Ausprägung nicht — trotzdem sicherheitshalber mitprüfen.
delikte |> count(gericht, sort = TRUE) |> print(n = Inf)
sum(is.na(delikte$gericht))   # 56 = 14 Jahre × 4 OLG-Aggregatzeilen

# Nur die 16 echten LG-Sprengel je Jahr:
# (!is.na(gericht) wirft die OLG-Aggregatzeilen ohne LG-Sprengel raus;
#  str_starts(..., "LG ") lässt "Nicht klassifizierbar" ebenfalls draußen.)
delikte_lg <- delikte |>
  filter(!is.na(gericht), str_starts(gericht, "LG "))

# Gesamtdelikte 2024 (Kontrollwert: 45 958)
delikte_lg |>
  filter(jahr == 2024) |>
  summarise(gesamt = sum(delikte))

# Top 3 Sprengel 2024
delikte_lg |>
  filter(jahr == 2024) |>
  arrange(desc(delikte)) |>
  head(3)
# 1. LG für Strafsachen Wien (11 510)
# 2. LG für Strafsachen Graz ( 4 912)
# 3. LG Linz                ( 3 544)


# =============================================================================
# 3) Werkstatt-Excel retten
# =============================================================================

# Erst hinschauen: Welche Sheets gibt es? Das erste ist NICHT die Tabelle.
excel_sheets(file.path(daten, "betriebsdaten_licht.xlsx"))
# "Notizen"  "Messwerte"

# Vorhersage: Die Masse-Spalte ist character, weil in zwei Zellen
#             "n. gemessen" steht — ein Textwert macht die ganze Spalte Text.
b_naiv <- read_excel(
  file.path(daten, "betriebsdaten_licht.xlsx"),
  sheet = "Messwerte"
)
class(b_naiv$`Masse in mm`)   # "character"

# Deshalb liefert mean() ohne NA-Behandlung nur NA (plus Warnung):
mean(b_naiv$`Masse in mm`)    # NA — die Spalte ist Text!

# Sauber: Marker beim Einlesen als NA deklarieren, Rest in Zahlen wandeln.
# (Die vier leeren Zellen liest readxl ohnehin schon als NA.)
b <- read_excel(
  file.path(daten, "betriebsdaten_licht.xlsx"),
  sheet = "Messwerte",
  na    = "n. gemessen"
) |>
  mutate(`Masse in mm` = as.numeric(`Masse in mm`)) |>
  rename(masse_mm = `Masse in mm`)   # Leerzeichen im Namen loswerden

class(b$masse_mm)              # "numeric"
sum(is.na(b$masse_mm))         # 6 = 4 leere Zellen + 2 × "n. gemessen"

kennzahlen <- b |>
  group_by(Maschine) |>
  summarise(
    n      = sum(!is.na(masse_mm)),
    mittel = mean(masse_mm, na.rm = TRUE)
  )
kennzahlen
# M1 37 / 10.0 · M2 39 / 9.98 · M3 38 / 10.1

# Warum M3 heute n = 38 hat (und SA-03 n = 40 zeigte):
# In der Excel-Datei sind bei M3 zwei Messungen nicht durchgeführt worden;
# in diesen beiden Zellen steht "n. gemessen". Mit na = "n. gemessen" werden
# sie zu echten NA und zählen bei sum(!is.na(...)) nicht mehr mit. Die
# Datenbasis ist damit ehrlicher: n = 38 statt heimlich 40 vorzutäuschen.


# =============================================================================
# Kapitel-Check (R4DS 2e, Kap. 7) — Kurzantworten
# =============================================================================
# skip   : Anzahl der Zeilen, die vor der Kopfzeile übersprungen werden
#          (Preamble/Titelzeilen). skip = 1 -> Zeile 2 wird Kopfzeile.
# na     : Zeichenvektoren, die als fehlender Wert gelesen werden sollen,
#          z. B. na = "***" oder na = c("", "n. gemessen", "???").
# locale : Ländereinstellung für Dezimalzeichen, Gruppierungszeichen,
#          Kodierung, Datumsformat und Zeitzone — z. B.
#          locale(decimal_mark = ".") für Punkt-Dezimalen in einer
#          Semikolon-Datei.
# n_max  : maximale Anzahl einzulesender Datenzeilen (ohne Kopfzeile);
#          praktisch, um große Dateien erst einmal anzuschauen.
