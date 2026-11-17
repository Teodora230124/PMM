# Feedback zur Lektion KM7-01 — Mittelwertsvergleich: z-Test und t-Test

**Von:** Teodora, 4AHWIT · **Datum:** 2026-11-17 · **Bearbeitung:** ca. 90 Minuten
**Lektion:** `unterricht/KM7-01-mittelwertsvergleich-t-test`
**Bearbeitet:** `aufgabe.md` (Teile 1–5), „Jetzt du!" und die Quizfragen

## Gesamteindruck

Die Lektion ist didaktisch sehr gut aufgebaut. Der rote Faden — Effekt gegen
Rauschen, dann Hypothesen, dann z-Test, dann t-Test, dann gepaart — trägt.
Besonders hilfreich: Alle Beispiele rechnen mit **denselben** Betriebsdaten,
und die Kontrollwerte stehen direkt im Text. Dadurch kann man jede Zahl
selbst nachvollziehen und merkt sofort, ob man richtig liegt.

## Was gut funktioniert hat

- **Die Leitfrage** „Sind das echte Unterschiede — oder Zufall?" ist ein guter
  Einstieg und bleibt bis Teil 5 der Aufgabe präsent.
- **Die Trennung z-Test → t-Test** ist klar: erst das Prinzip mit bekanntem
  σ, dann die realistische Schätzung. Der Satz „in der Praxis kennt nie
  jemand σ" hat bei mir den Knoten gelöst.
- **Die Quizze mit Begründungen** (`data-grund`) sind stärker als reine
  Richtig/Falsch-Fragen, weil sie auch die typischen Fehlschlüsse erklären.
- **„Typische Fehler"** (paired + Formel-Syntax, `na.rm`, p-Wert als
  Qualitätsurteil) waren für mich der praktischste Teil.
- **Die Kontrollwerte** (t = −5,1132, df = 55,272, p = 4,092e-06) machen das
  Nachrechnen sehr effizient.

## Was unklar war / verbessert werden könnte

1. **Einseitiger Test, Richtung (Schritt 2):** Im Beispiel steht
   `alternative = "less"` mit der Frage „ist M3 jetzt GRÖSSER als M1?".
   Das ist zwar korrekt — die Formel vergleicht `M1 − M3`, weil M1 die erste
   Faktorstufe ist —, aber genau diese Umkehrung ist verwirrend. Ein Satz
   wie „`less`/`greater` beziehen sich auf *erste minus zweite Gruppe*"
   (oder ein Beispiel mit `levels = c("M3", "M1")`) würde helfen.

2. **Aufgabe 3d, „t über die Messwerte":** Die Formel ist nicht
   ausgeschrieben. Ich war unsicher, ob der Standardfehler der Differenz
   (`s1²/n1 + s3²/n3`) oder etwas anderes gemeint ist. Mit der Formel im
   Aufgabentext wäre die Lernintention klarer.

3. **Freiheitsgrade, Zahlenbeispiel:** Im Kasten „Warum df = 9?" steht
   „Beim ungepaarten Test waren es 37 + 39 − 2 = 74". Das laufende Beispiel
   ist aber M1 gegen M3 (37 + 40 − 2 = 75). Die 74 gehören zu M1/M2 — das
   ist vermutlich ein Copy-Paste-Rest und stiftet kurz Verwirrung.

4. **Konfidenzintervall und Toleranz:** Das KI der *Differenz* wird mit der
   Toleranz von *Einzelteilen* verglichen. Das ist didaktisch gewollt, aber
   es sollte explizit dastehen, dass ein enges Differenz-KI nicht garantiert,
   dass jedes einzelne Teil in der Toleranz liegt (Stichwort
   Vorhersageintervall).

5. **„Jetzt du!":** Die drei Schritte sind gut, aber es gibt keine
   Lösungs-/Kontrollwerte. Ich habe sie selbst gerechnet
   (M1/M2: t = 2,8658, p = 0,005456; gepaart: t = −3,1823, df = 9,
   p = 0,01114). Ein ausklappbarer Lösungsteil würde das Selbststudium
   abrunden.

6. **Datenpfad:** `read_csv("assets/betriebsdaten.csv")` gilt nur ab
   Repo-Root. In einem eigenen R-Projektordner (wie verlangt) liegt die
   Datei woanders. Ein Hinweis auf `here::here()` oder „Kopie in `daten/`"
   wäre praktisch.

7. **Ordner-/Abgabekonvention:** Unten steht nur „Commit in deinem
   PMM-Repo". Die ISO-8601-Ordnernamen und „der Ordner ist ein
   R-Projektordner" waren nicht Teil der Lektion — das kam separat. Schön
   wäre, die Abgabekonvention direkt bei der Aufgabe zu nennen.

## Konkrete Vorschläge

- Formelkarte am Anfang oder Ende: `t = (x̄1 − x̄2) / sqrt(s1²/n1 + s2²/n2)`,
  `t_paar = mean(d) / (sd(d)/sqrt(n))`, `df_gepaart = n − 1`.
- Beim einseitigen Test die Richtung immer relativ zur Faktor-Reihenfolge
  erklären.
- Bei „Jetzt du!" kurze Erwartungswerte als `<details>`-Lösung ergänzen.
- Den df-Kasten auf das durchgerechnete Beispiel (M1/M3: 75 bzw. 55,272)
  korrigieren.
- Ein Satz zu Unabhängigkeit/Pseudoreplikation (mehrere Teile pro Charge)
  würde Teil 5c vorbereiten — das war inhaltlich der anspruchsvollste Teil.

## Fazit

**5 von 5 Sternen** für Aufbau und Verständlichkeit. Die Lektion hat mir
gezeigt, dass „signifikant" und „relevant" zwei verschiedene Dinge sind —
genau das nehme ich mit. Die Punkte oben sind Feinschliff, keine
inhaltlichen Lücken.
