# =============================================================================
# KM7-01 — Mittelwertsvergleich: z-Test und t-Test
# Selbststudium 2026-11-17
#
# Lektion: unterricht/KM7-01-mittelwertsvergleich-t-test
# Aufgabe: aufgabe.md (Teile 1–5) + "Jetzt du!" aus der Lektion
# Daten:   daten/betriebsdaten.csv (120 Messungen, 3 Maschinen,
#          Sollmaß 10,00 mm, Toleranz ± 0,15 mm; 4 Werte fehlen)
#
# Arbeitsweise der Lektion: erst vorhersagen, dann rechnen.
# Die Vorhersagen stehen als Kommentar VOR dem jeweiligen Code.
# =============================================================================

library(tidyverse)

daten <- read_csv("daten/betriebsdaten.csv", show_col_types = FALSE)
daten
# 120 × 3: maschine, charge, masse_mm


# =============================================================================
# 1. Vorhersagen
# =============================================================================

# a) Vorhersage: M1 = 37, M2 = 39, M3 = 40 gültige Messungen.
#    Begründung: 40 Teile pro Maschine, vier fehlen – drei bei M1, eine bei M2.
kennzahlen <- daten |>
  group_by(maschine) |>
  summarise(
    n        = sum(!is.na(masse_mm)),
    mittel   = mean(masse_mm, na.rm = TRUE),
    streuung = sd(masse_mm, na.rm = TRUE)
  )

kennzahlen
# Ergebnis: M1 37 / 10,00054 / 0,03150
#           M2 39 /  9,97692 / 0,04000
#           M3 40 / 10,06275 / 0,06960
# → Vorhersage stimmt.

# b) Vorhersage: M3 hat den größten Abstand zum Sollmaß, ca. 0,06 mm
#    (rund 6 Hundertstel). M2 liegt bei ca. 0,02 mm (2 Hundertstel).
kennzahlen |>
  mutate(
    abstand_mm  = abs(mittel - 10),
    hundertstel = round(abstand_mm * 100, 2)
  )
# Ergebnis: M1 0,05 · M2 2,31 · M3 6,27 Hundertstel
# → M3, rund 6,3 Hundertstel (0,0627 mm). Vorhersage stimmt.

# c) Vorhersage: M1 gegen M3 fällt statistisch leichter durch. Der Effekt
#    wächst viel schneller als das Rauschen: 0,062 mm gegen 0,024 mm ist
#    etwa 2,6-mal so groß, der Standardfehler wächst aber nur von 0,0108
#    auf 0,0122 mm. Beim t-Wert (Effekt ÷ Rauschen) gewinnt deshalb der
#    größere Unterschied – trotz der größeren Streuung von M3.
#
#    Kontrolle (folgt unten): t(M1/M2) = 2,87 · t(M1/M3) = 5,11.
# → Vorhersage stimmt.


# =============================================================================
# 2. Der ungepaarte Vergleich: M1 gegen M3 (Welch-t-Test)
# =============================================================================

# H0: M1 und M3 haben denselben Mittelwert (μ_M1 = μ_M3, Differenz = 0).
# H1: Die Mittelwerte unterscheiden sich (μ_M1 ≠ μ_M3), zweiseitig.

vergleich <- daten |> filter(maschine %in% c("M1", "M3"))

t_m13 <- t.test(masse_mm ~ maschine, data = vergleich)
t_m13
# Welch Two Sample t-test
# t = -5,1132 · df = 55,272 · p = 4,092e-06
# 95-%-KI der Differenz (M1 − M3): −0,08659 bis −0,03783
# Mittelwerte: M1 = 10,00054 · M3 = 10,06275

# Lesart des Intervalls:
# Das Intervall ist für M1 − M3 negativ, also liegt M3 über M1. Umgdreht
# beträgt der Unterschied M3 − M1 zwischen 0,0378 und 0,0866 mm: M3 liegt
# mit 95 % Sicherheit mindestens 0,038 mm und höchstens 0,087 mm über M1.
# Der gesamte Bereich liegt innerhalb der Toleranz von ± 0,15 mm
# (0,0866 < 0,15). Der Unterschied ist also statistisch klar nachweisbar,
# ragt aber nicht aus der Toleranz heraus.


# =============================================================================
# 3. Der gepaarte Vergleich: M3 gegen M1 über die 10 Chargen
# =============================================================================

chargen <- daten |>
  group_by(maschine, charge) |>
  summarise(mm = mean(masse_mm, na.rm = TRUE), .groups = "drop") |>
  pivot_wider(names_from = maschine, values_from = mm)

chargen

d <- chargen$M3 - chargen$M1
d
# 0,0625  0,0375  0,1308  0,0275  0,0375  0,1100  0,0450  0,0475  0,0750  0,0600

# a) Alle 10 Differenzen sind positiv, keine ist negativ.
#    M3 liegt also in jeder einzelnen Charge über M1 – nicht nur im Mittel.
sum(d > 0)   # 10
sum(d < 0)   # 0

# b) Gepaarter t-Test
t_paar <- t.test(chargen$M3, chargen$M1, paired = TRUE)
t_paar
# Paired t-test
# t = 5,9822 · df = 9 · p = 0,000207
# 95-%-KI: 0,03938 bis 0,08728 · mittlere Differenz 0,06333 mm

# c) Warum df = 9, obwohl 37 bzw. 40 Messungen dahinterstehen?
#    Der gepaarte Test rechnet nicht mit den Einzelmessungen, sondern mit
#    den 10 Chargen-Differenzen. Deren Anzahl bestimmt die Freiheitsgrade:
#    n − 1 = 10 − 1 = 9. Die 77 Einzelwerte werden vorher zu 10 Mitteln
#    zusammengefasst – das ist der bewusste Tausch: weniger Werte, aber
#    bessere (die Chargen-Streuung fällt aus der Differenz heraus).

# d) t-Wert von Hand nachrechnen
#    über die Differenzen:        mean(d) / (sd(d) / sqrt(10))
mean(d) / (sd(d) / sqrt(length(d)))
# [1] 5,9822  → stimmt mit R überein

#    über die Gruppenmittel:      (Mittel M3 − Mittel M1) / Standardfehler
(kennzahlen$mittel[3] - kennzahlen$mittel[1]) /
  sqrt(kennzahlen$streuung[1]^2 / kennzahlen$n[1] +
       kennzahlen$streuung[3]^2 / kennzahlen$n[3])
# [1] 5,1132  → das ist der ungepaarte Welch-t-Wert

#    Welcher stimmt? Der Wert über die Differenzen (5,9822). Die Formel
#    über die Gruppenmittel ignoriert die Paarung und nimmt die Streuung
#    der Messwerte statt der Streuung der Differenzen. Beim gepaarten Test
#    verschwindet die Charge-zu-Charge-Streuung, deshalb wird t größer und
#    das Konfidenzintervall enger.


# =============================================================================
# 4. Kapitel-Check (Navarro, Kap. 13)
# =============================================================================

# a) Der t-Test wird verwendet, weil σ der Grundgesamtheit in der Praxis
#    unbekannt ist und aus der Stichprobe geschätzt werden muss (s). Diese
#    Schätzung ist selbst unsicher; die t-Verteilung mit ihren schwereren
#    Rändern und den Freiheitsgraden rechnet diese Unsicherheit mit. Der
#    z-Test tut so, als wäre σ exakt bekannt, und liefert deshalb zu enge
#    Intervalle und zu optimistische p-Werte.

# b) Nein, der Kollege hat nicht recht. p = 0,42 bedeutet nur: H0 wurde
#    nicht verworfen, die Daten liefern keinen Nachweis für einen
#    Unterschied. Das ist kein Beweis für Gleichheit. Es kann ein Fehler
#    2. Art sein (H0 behalten, obwohl sie falsch ist), etwa weil die
#    Stichprobe zu klein oder die Streuung zu groß ist. Fehler 1. Art
#    wäre, H0 zu verwerfen, obwohl sie stimmt (α).

# c) Drei gepaarte Situationen aus der Fertigung:
#    1. Vorher/Nachher nach einem Werkzeugwechsel am selben Bauteil:
#       Das Rohteil und die Charge sind identisch, nur der Werkzeugeinfluss
#       ändert sich.
#    2. Linkes und rechtes Bauteil aus derselben Schicht und Rohcharge:
#       Beide Paare kommen aus demselben Material und denselben
#       Maschineneinstellungen.
#    3. Zwei Messgeräte oder zwei Prüfer am selben Werkstück: Gemessen wird
#       dasselbe Teil, paired eliminiert die Teile-zu-Teile-Streuung.
#    (Auch hier: M1 und M3 am selben Tag aus derselben Charge.)


# =============================================================================
# 5. Die Frage hinter der Aufgabe (M1 gegen M2, 0,024 mm)
# =============================================================================

t_m12 <- t.test(masse_mm ~ maschine, data = daten |> filter(maschine %in% c("M1", "M2")))
t_m12
# t = 2,8658 · df = 71,633 · p = 0,005456
# 95-%-KI: 0,007188 bis 0,040047

# a) Nein, allein der p-Wert ist keine Basis für eine Prozessänderung.
#    Die Differenz beträgt 0,024 mm – etwa ein Sechstel der Toleranz von
#    ± 0,15 mm; das 95-%-KI (0,007 bis 0,040 mm) liegt vollständig weit
#    innerhalb der Toleranz. Der Test zeigt, dass der Unterschied
#    systematisch und nicht bloß Zufall ist, aber nicht, dass er
#    fertigungstechnisch relevant ist. Für eine Änderung bräuchte es
#    zusätzlich Ausschuss-, Kosten- oder Fähigkeitskennzahlen (Cp/Cpk).

# b) "Signifikant" heißt: Der beobachtete Unterschied ist mit hoher
#    Wahrscheinlichkeit nicht nur Zufall (p < α). "Wirtschaftlich nicht
#    relevant" heißt: Der Unterschied ist so klein, dass er für Toleranz,
#    Funktion und Kosten keine Rolle spielt. Das sind zwei verschiedene
#    Aussagen, weil der p-Wert die Effektgröße nicht enthält: Bei großem n
#    wird auch ein winziger Effekt signifikant, bei kleinem n auch ein
#    großer nicht. Die Stärke des Tests ist, systematische Unterschiede
#    aufzudecken; seine Grenze ist, dass er nichts über die praktische
#    Bedeutung sagt.

# c) Wenn der 0,024-mm-Unterschied belegt werden muss, braucht es mehr
#    unabhängige Chargen, nicht mehr Teile pro Charge. Teile aus derselben
#    Charge sind nicht unabhängig (gleiche Rohcharge, gleicher Tag); mehr
#    Teile pro Charge verkleinern nur den Messfehler, nicht die
#    Chargen-Streuung. Mehr Chargen erhöhen die effektive Stichprobe und
#    verkleinern den Standardfehler genau dort, wo die relevante Streuung
#    sitzt – die Power steigt.
#    Grobe Orientierung (α = 0,05, Power 80 %, s ≈ 0,036):
#    n ≈ 2 · (1,96 + 0,84)² · (0,036 / 0,024)² ≈ 35 unabhängige Einheiten
#    pro Maschine – also nicht mehr Teile, sondern rund 35 verschiedene
#    Chargen. Bei kleinerem Effekt wächst n quadratisch mit s/Δ.


# =============================================================================
# 6. Zusatz: "Jetzt du!" aus der Lektion (M1 gegen M2)
# =============================================================================

# 1) Vorhersage: Der Unterschied ist mit p < 0,05 signifikant, weil
#    0,024 mm bei Streuungen von 0,032/0,040 und n ≈ 38 einen t von rund
#    2,9 ergeben – das liegt über der 2er-Grenze. Ausführen bestätigt es:
t_m12
# t = 2,8658 · df = 71,633 · p = 0,005456 → signifikant.

# 2) Beurteilung über das Konfidenzintervall, nicht über p:
#    KI der Differenz M1 − M2: 0,00719 bis 0,04005 mm.
#    M1 liegt also 0,007 bis 0,040 mm über M2. Die Intervallbreite ist
#    0,033 mm und damit viel kleiner als die Toleranz von 0,30 mm
#    (± 0,15). Statistisch nachweisbar, praktisch aber unbedeutend –
#    keine Maschine ist damit "besser".

# 3) Gepaarter Vergleich M1 gegen M2 aus den Chargenmitteln:
t_paar12 <- t.test(chargen$M2, chargen$M1, paired = TRUE)
t_paar12
# 10 Paare · df = 9 · t = −3,1823 · p = 0,01114
# 95-%-KI: −0,04063 bis −0,00687 · mittlere Differenz −0,02375 mm
# Nur 1 der 10 Differenzen ist positiv; M2 liegt in 9 von 10 Chargen
# unter M1. Auch dieses Intervall liegt vollständig innerhalb der Toleranz.
