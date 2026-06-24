# Datenbeschreibung — UCI Mushroom Dataset

## Überblick

- **Quelle**: [UCI Machine Learning Repository – Mushroom Dataset](https://archive.ics.uci.edu/dataset/73/mushroom)
- **Anzahl Instanzen**: 8.124
- **Anzahl Merkmale**: 22 (alle nominal)
- **Zielvariable**: Binäre Klassifikation — Genießbarkeit (essbar / giftig)
- **Fehlende Werte**: ursprünglich nur in `stalk_root` (Markierung `?`), wurden mit dem Modalwert imputiert

---

## Merkmale im Detail

### `class` — Zielvariable (Genießbarkeit)

| Ausprägung | Bedeutung |
|---|---|
| `edible` | essbar |
| `poisonous` | giftig |

### `cap_shape` — Hutform

| Ausprägung | Bedeutung |
|---|---|
| `bell` | glockenförmig |
| `conical` | kegelförmig |
| `convex` | gewölbt |
| `flat` | flach |
| `knobbed` | knubbelig / mit Höcker |
| `sunken` | eingesenkt |

### `cap_surface` — Hutoberfläche

| Ausprägung | Bedeutung |
|---|---|
| `fibrous` | faserig |
| `grooves` | geriffelt / gefurcht |
| `scaly` | schuppig |
| `smooth` | glatt |

### `cap_color` — Hutfarbe

| Ausprägung | Bedeutung |
|---|---|
| `brown` | braun |
| `buff` | lederfarben / beige |
| `cinnamon` | zimtfarben |
| `gray` | grau |
| `green` | grün |
| `pink` | rosa |
| `purple` | violett |
| `red` | rot |
| `white` | weiß |
| `yellow` | gelb |

### `bruises` — Druckstellen

| Ausprägung | Bedeutung |
|---|---|
| `bruises` | Druckstellen vorhanden |
| `no` | keine Druckstellen |

### `odor` — Geruch

| Ausprägung | Bedeutung |
|---|---|
| `almond` | mandelartig |
| `anise` | anisartig |
| `creosote` | kreosotartig (teerartig) |
| `fishy` | fischig |
| `foul` | faulig / übelriechend |
| `musty` | modrig / muffig |
| `none` | geruchslos |
| `pungent` | stechend / scharf |
| `spicy` | würzig |

### `gill_attachment` — Lamellenansatz

| Ausprägung | Bedeutung |
|---|---|
| `attached` | angewachsen |
| `descending` | herablaufend |
| `free` | frei (nicht angewachsen) |
| `notched` | ausgebuchtet / gekerbt |

### `gill_spacing` — Lamellenabstand

| Ausprägung | Bedeutung |
|---|---|
| `close` | eng stehend |
| `crowded` | gedrängt / sehr eng |
| `distant` | entfernt stehend |

### `gill_size` — Lamellengröße

| Ausprägung | Bedeutung |
|---|---|
| `broad` | breit |
| `narrow` | schmal |

### `gill_color` — Lamellenfarbe

| Ausprägung | Bedeutung |
|---|---|
| `black` | schwarz |
| `brown` | braun |
| `buff` | lederfarben / beige |
| `chocolate` | schokoladenbraun |
| `gray` | grau |
| `green` | grün |
| `orange` | orange |
| `pink` | rosa |
| `purple` | violett |
| `red` | rot |
| `white` | weiß |
| `yellow` | gelb |

### `stalk_shape` — Stielform

| Ausprägung | Bedeutung |
|---|---|
| `enlarging` | zur Basis hin verdickt |
| `tapering` | zur Basis hin verjüngt |

### `stalk_root` — Stielbasis

| Ausprägung | Bedeutung |
|---|---|
| `bulbous` | knollig / zwiebelartig |
| `club` | keulenförmig |
| `cup` | becherförmig |
| `equal` | gleichmäßig / zylindrisch |
| `rhizomorphs` | rhizomartig / wurzelartig |
| `rooted` | wurzelnd / tief verankert |

**Anmerkung**: Dieses Merkmal enthielt ursprünglich fehlende Werte (kodiert als `?`). Diese wurden mit dem Modalwert (`bulbous`) imputiert.

### `stalk_surface_above_ring` — Stieloberfläche oberhalb des Rings

| Ausprägung | Bedeutung |
|---|---|
| `fibrous` | faserig |
| `scaly` | schuppig |
| `silky` | seidig |
| `smooth` | glatt |

### `stalk_surface_below_ring` — Stieloberfläche unterhalb des Rings

| Ausprägung | Bedeutung |
|---|---|
| `fibrous` | faserig |
| `scaly` | schuppig |
| `silky` | seidig |
| `smooth` | glatt |

### `stalk_color_above_ring` — Stielfarbe oberhalb des Rings

| Ausprägung | Bedeutung |
|---|---|
| `brown` | braun |
| `buff` | lederfarben / beige |
| `cinnamon` | zimtfarben |
| `gray` | grau |
| `orange` | orange |
| `pink` | rosa |
| `red` | rot |
| `white` | weiß |
| `yellow` | gelb |

### `stalk_color_below_ring` — Stielfarbe unterhalb des Rings

| Ausprägung | Bedeutung |
|---|---|
| `brown` | braun |
| `buff` | lederfarben / beige |
| `cinnamon` | zimtfarben |
| `gray` | grau |
| `orange` | orange |
| `pink` | rosa |
| `red` | rot |
| `white` | weiß |
| `yellow` | gelb |

### `veil_type` — Velum-Typ (Hülltyp) [ENTFERNT]

| Ausprägung | Bedeutung |
|---|---|
| `partial` | Teilvelum (Ring) |
| `universal` | Universalvelum (Scheide) |

**Anmerkung**: Im Datensatz kommt ausschließlich `partial` vor — dieses Merkmal ist konstant und wurde daher während der Datenaufbereitung (Schritt 5 in `01_preprocessing.R`) gemäß Kapitel 3.1 der Vorlesung (Entfernen irrelevanter Daten) aus dem Datensatz entfernt.

### `veil_color` — Velum-Farbe (Hüllfarbe)

| Ausprägung | Bedeutung |
|---|---|
| `brown` | braun |
| `orange` | orange |
| `white` | weiß |
| `yellow` | gelb |

### `ring_number` — Ringanzahl

| Ausprägung | Bedeutung |
|---|---|
| `none` | kein Ring |
| `one` | ein Ring |
| `two` | zwei Ringe |

### `ring_type` — Ring-Typ

| Ausprägung | Bedeutung |
|---|---|
| `cobwebby` | spinnwebartig |
| `evanescent` | vergänglich / hinfällig |
| `flaring` | ausladend / trichterförmig |
| `large` | groß |
| `none` | kein Ring |
| `pendant` | herabhängend |
| `sheathing` | scheidig |
| `zone` | zonenförmig |

### `spore_print_color` — Sporenpulverfarbe

| Ausprägung | Bedeutung |
|---|---|
| `black` | schwarz |
| `brown` | braun |
| `buff` | lederfarben / beige |
| `chocolate` | schokoladenbraun |
| `green` | grün |
| `orange` | orange |
| `purple` | violett |
| `white` | weiß |
| `yellow` | gelb |

### `population` — Wuchsform / Population

| Ausprägung | Bedeutung |
|---|---|
| `abundant` | massenhaft / sehr zahlreich |
| `clustered` | büschelig / in Gruppen |
| `numerous` | zahlreich |
| `scattered` | verstreut / einzeln |
| `several` | mehrere |
| `solitary` | einzeln stehend |

### `habitat` — Lebensraum

| Ausprägung | Bedeutung |
|---|---|
| `grasses` | Grasland / Wiesen |
| `leaves` | Laub / Blätter |
| `meadows` | Wiesen |
| `paths` | Wege / Wegränder |
| `urban` | urbane Gebiete / Siedlungen |
| `waste` | Ödland / Schuttplätze |
| `woods` | Wälder / Gehölze |
