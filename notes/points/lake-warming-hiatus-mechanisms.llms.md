# Lake Warming Hiatus: Physical Mechanisms

Understanding the physical mechanisms behind hiatus-period lake temperature response is essential — changepoint detection tells us *when* and *how much*, but not *why*.

## Surface energy balance framework

Lake surface temperature is governed by (O’Reilly et al. 2015):

\\\Delta T\_{\text{surface}} \propto Q^\* - Q_H - Q_E - \Delta Q_S\\

where \\Q^\*\\ = net radiation, \\Q_H\\ = sensible heat, \\Q_E\\ = latent heat (evaporation), \\\Delta Q_S\\ = heat storage change. Any climate factor altering these four fluxes affects lake warming rate.

## Mechanisms

### 1. Air temperature conduction (primary driver)

Lake SST is highly coupled to air temperature (O’Reilly et al. 2015: global lake summer SST warming at ~0.34 °C/decade). During the hiatus (1998–2012), global mean air warming slowed to ~0.05 °C/decade (long-term ~0.18 °C/decade). 83% of 155 lakes slowed warming accordingly (Winslow et al. 2018).

But conduction is not 1:1 — lakes have their own buffering and amplification.

### 2. Evaporative cooling feedback ⭐⭐⭐

**Zhou et al. (2023, Nature Communications)** found: *“the rate of lake heating slows as air warms”*

Mechanism chain:

1.  Air warms → lake-air vapour pressure deficit increases
2.  Evaporation intensifies (Clausius-Clapeyron: ~7% per °C)
3.  Evaporation consumes latent heat (~2.45 MJ/kg) → surface cooling
4.  Evaporative cooling partially offsets radiative heating → net warming slows

Implication for hiatus: if hiatus-era lakes were already warm, evaporative cooling acts as a negative feedback amplifying the hiatus signal.

### 3. Solar dimming/brightening

- 1950s–1980s: global dimming (aerosols reduce surface shortwave)
- 1980s–2000s: global brightening (clean air legislation)
- Post-2000s: regional divergence (China brightening, India dimming)

During hiatus, partial dimming return (post-1998 volcanic activity, China coal aerosols) reduced \\Q^\*\\ → weakened lake surface heating.

### 4. Wind stilling

Global terrestrial near-surface wind speed has declined ~0.1 m/s/decade since 1980s.

Effects on lakes:

- Weakened turbulent mixing → shallower thermocline
- More heat concentrated at surface → apparent surface warming may increase
- But reduced wind also reduces evaporation → net effect is ambiguous

Woolway et al. (2017): wind stilling extends stratification period and increases surface warming in UK lakes.

### 5. Ice cover feedback

For seasonally frozen lakes (Magnuson et al. 2000):

1.  Reduced winter/spring ice → earlier ice-off
2.  Low-albedo water surface exposed → more solar absorption
3.  Earlier heating → higher summer temperatures
4.  Later freeze-up → shorter ice season → positive feedback loop

If hiatus period saw continued ice reduction (winter temperatures did not stagnate), ice feedback may partially offset hiatus cooling.

### 6. Large-scale teleconnections

| Index | Key phase during hiatus | Lake response |
|----|----|----|
| **PDO** | Negative (La Niña-like) from 1998 | Cooler tropical Pacific → lower global temps |
| **AMO** | Positive from mid-1990s | Warmer North Atlantic → offsets hiatus in N. Atlantic lakes |
| **ENSO** | La Niña dominant 1998–2012 | Cooler global temps, esp. tropics/subtropics |
| **NAO** | Variable | Dominant control on European winter lake temperature |

CP years (e.g. 1998) align with PDO phase transitions — detected changepoints may capture natural variability phase shifts, not just “global warming hiatus”.

### 7. Lake morphometry modulation

| Factor | Effect | Mechanism |
|----|----|----|
| Depth | Deep lakes warm slower | Greater thermal inertia |
| Area | Large lakes: more evaporation | Longer fetch → stronger latent heat loss |
| Transparency | Clear lakes warm faster | Shortwave penetrates deeper |
| Altitude | High-altitude lakes more sensitive | Thinner atmosphere → stronger LW exchange |
| Trophic state | Eutrophic: complex response | Algae absorb shortwave → surface heating |

Winslow et al. (2018): hiatus response showed no significant clustering by lake attributes — climate signal is strong enough to override morphometric differences.

## Integrated framework

              Global radiative forcing (CO₂ + aerosols)
                         │
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
      Atmospheric      Surface        Cloud/radiation
      circulation      air temp       changes
     (PDO/NAO/ENSO)      │              │
          │              │              │
          ▼              ▼              ▼
    ┌──────────── Lake surface energy balance ────────────┐
    │  Q* (radiation)  Q_H (sensible)  Q_E (latent)  ΔQ_S │
    └──────────────────────┬──────────────────────────────┘
                           │
                ┌──────────┼──────────┐
                ▼          ▼          ▼
            Acceleration  Steady    Deceleration

## Sensitivity analysis implications

Based on the mechanism framework:

- **Evaporation**: ERA5 evaporation trends → test if enhanced evaporation correlates with more significant changepoints
- **Wind**: ERA5 u10/v10 → wind trends vs hiatus response
- **Radiation**: ERA5 surface downward shortwave → radiation changes vs CP spatial consistency
- **PDO/AMO**: test CP significance after removing natural variability
- **Ice cover**: GLAST/ERA5 ice data → do frozen lakes differ?

## Key references

| Reference | Core finding | Relevance |
|----|----|----|
| Winslow et al. (2018) ERL | 155 lakes, 83% slowed during hiatus | Direct predecessor |
| Zhou et al. (2023) Nature Comms | Lake warming slows as air warms (evaporative cooling) | Core mechanism |
| O’Reilly et al. (2015) GRL | Global lake SST +0.34 °C/decade | GLAST dataset origin |
| Woolway et al. (2017) Climatic Change | Wind stilling → extended stratification | Wind stilling mechanism |
| Magnuson et al. (2000) Science | Northern hemisphere ice season shortening | Ice cover feedback |
| Medhaug et al. (2017) Nature | Hiatus multi-mechanism review | Climate background |
| Lund et al. (2023) J. Climate | Climate changepoint best practices | Methodology |

Back to top
