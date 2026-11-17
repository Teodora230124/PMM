
library(ggplot2)
library(palmerpenguins) # Wichtig: Lädt den Pinguin-Datensatz

ggplot(penguins,
       aes(x = year, y = body_mass_g)) +
  geom_point() +       # Optional, aber empfohlen: Zeigt die einzelnen Datenpunkte
  geom_smooth() +
  labs(x = "Geburtsjahr (J)", y = "Körpermasse (g)")
  