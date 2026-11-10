# PBL-CORE

SAP-ABAP-Kernkomponente für **Pick-by-Light (PbL)** von **GPIO Solutions** im Namensraum `/GPIOS/`.

Das Paket steuert PbL-Steuergeräte (Controller) aus SAP heraus: Stammdaten und Stücklisten synchronisieren, LEDs/IO-Einheiten ansteuern, Geräte-Callbacks entgegennehmen und Ereignisse in Echtzeit in den Dialog bringen.

## Überblick

```
SAP GUI / Reports
        │
        ▼
 /GPIOS/CL_PBL_CONTROLLER  ◄── HTTP (GET/POST/DELETE) ──►  PbL-Steuergerät
        ▲
        │ Callbacks (JSON)
 /GPIOS/CL_PBL_HTTP_HANDLER  ◄── SICF /gpios/pbl_callback/...
        │
        ▼
 /GPIOS/CL_PBL_CALLBACK  ──►  Realtime (AMC / HTML-Socket / Timer)
```

Zentrale Idee: Ein **Controller** (`/GPIOS/CL_PBL_CONTROLLER`) spricht lokal (SAP-Tabellen) und remote (HTTP zum Gerät) denselben Datenbestand an — Geräte, Benutzer, Komponenten, Stücklistenköpfe/-positionen, IO-Einheiten.

## Architektur

| Schicht | Objekte | Rolle |
|---|---|---|
| API / Typen | `/GPIOS/IF_PBL_*`, `/GPIOS/IF_PBL_TYPES` | Schnittstellen und gemeinsame Tabellentypen |
| Steuerung | `/GPIOS/CL_PBL_CONTROLLER`, `/GPIOS/CL_PBL_CTRL_MANAGER` | HTTP-Kommunikation, Pflege/Transfer/Receive |
| Fachobjekte | `/GPIOS/CL_PBL_BOM`, `_BOM_ITEM`, `_IO_UNIT` | Stückliste starten/stoppen, LED-Farbe setzen |
| Einstellungen | `/GPIOS/CL_PBL_SETTINGS(_CORE)` | Customizing aus `/GPIOS/PBL_*`-Tabellen |
| Callbacks | `/GPIOS/CL_PBL_HTTP_HANDLER`, `/GPIOS/CL_PBL_CALLBACK` | SICF-Eingang, JSON → ABAP, Event-Handling |
| Realtime | `/GPIOS/CL_PBL_REALTIME`, `_RT_TIMER`, `_RT_HTML_SOCKET`, `_RT_DATA` | Push von Callbacks in laufende Dialoge |
| Hilfen | `/GPIOS/CL_PBL_JSON`, `/GPIOS/CL_PBL_DOCU`, `/GPIOS/CX_PBL*` | Serialisierung, PDF-Doku, Exceptions |

### Controller-Aktionen (Auszug)

Über `TRIGGER_ACTION` u. a.:

- `SET_COLOR` / `TOG_C` / `TOG_C_ALL` — LED-Farben
- `START_BOM` / `STOP_BOM` / `GET_RUN_BO` — Pick-Vorgang
- `TOG_BOMI_I` — IO einer Stücklistenposition
- `PING` — Erreichbarkeit

### Datenarten (lokal ↔ remote)

`DEVICES`, `USERS`, `COMPONENTS`, `BOMHDR`, `BOMITM`, `IO_UNITS`

Kommunikationsrichtung wird über Customizing in `/GPIOS/PBL_COM` (Daten) und `/GPIOS/PBL_ACT` (Aktionen) gesteuert.

## Callbacks (SICF)

HTTP-Handler: `/GPIOS/CL_PBL_HTTP_HANDLER` (`IF_HTTP_EXTENSION`)

| Pfad | Typ | Bedeutung |
|---|---|---|
| `/gpios/pbl_callback/picking_change/` | `PC` | Pick-Änderung |
| `/gpios/pbl_callback/io_change/` | `IC` | IO geändert |
| `/gpios/pbl_callback/ioassign_change/` | `IAC` | IO-Zuordnung geändert |
| `/gpios/pbl_callback/io_touched/` | `IT` | Touch an der LED/IO |
| `/gpios/pbl_callback/ir_changed/` | `IRC` | IR-Änderung |

Payload kommt als JSON; Deserialisierung über `/GPIOS/CL_PBL_JSON` in Strukturen `/GPIOS/PBL_CB_DATA_*`.

## Transaktionen & Programme

| Transaktion | Inhalt |
|---|---|
| `/GPIOS/PBL_CTRL` | Steuergeräteverwaltung (Report `/GPIOS/PBL_CONTROLLER_MAINT`) |
| `/GPIOS/PBL_VCT` | View-Cluster Steuergeräte |
| `/GPIOS/PBL_SET` | Grundeinstellungen |
| `/GPIOS/PBL_COM` | Kommunikationspfade für Daten |
| `/GPIOS/PBL_ACT` | Kommunikationspfade für Aktionen |
| `/GPIOS/PBL_CB` | Callback-Typen |
| `/GPIOS/PBL_RT` | Echtzeit-Typen (`TIMER`, `HTML_SOCK`) |
| `/GPIOS/PBL_SET_COLOR` | LED-Farbe setzen (Demo/Utility) |
| `/GPIOS/PBL_GET_EVENT` | Touch-/Callback-Ereignis im Dialog empfangen |
| `/GPIOS/PBL_DOCU` | Eingebettete PDF-Dokumentation |

Einstiegsmenü: Area-Menü `/GPIOS/PBL_SETTINGS` („Einstellungen“).

Pflege-Modi in der Steuergeräteverwaltung:

- **MAINTAIN** — Dialogpflege (Screen 100 / SALV)
- **RECEIVE** — Daten vom Remote-Controller holen
- **TRANSFER** — lokale Daten zum Remote-Controller senden

## Wichtige Tabellen

| Tabelle | Inhalt |
|---|---|
| `/GPIOS/PBL_CTL` / `_CTT` | Steuergerät Zugangsdaten + Texte |
| `/GPIOS/PBL_DEV` | Geräte-/Arbeitsplatz-Einstellungen inkl. Callback-URLs |
| `/GPIOS/PBL_USR` | Benutzer |
| `/GPIOS/PBL_CPN` | Komponenten |
| `/GPIOS/PBL_BH` / `_BI` | Stücklistenköpfe / -positionen |
| `/GPIOS/PBL_SET` | Globale Einstellungen |
| `/GPIOS/PBL_COM` / `_ACT` | Kommunikationspfade Daten / Aktionen |
| `/GPIOS/PBL_CB*` | Callback-Typen und Payload-Strukturen |
| `/GPIOS/PBL_RT` | Realtime-Typen |

## Installation (abapGit)

1. Namensraum `/GPIOS/` und Paket importieren (dieses Repo, Ordner `src/`).
2. Objekte aktivieren.
3. SICF-Knoten unter `/gpios/…` aktivieren.
4. Customizing über Area-Menü `/GPIOS/PBL_SETTINGS` bzw. die Pflege-Transaktionen pflegen (Controller, Kommunikationspfade, Callbacks, Realtime).
5. Optional: Dokumentation prüfen (`/GPIOS/PBL_DOCU`).

Voraussetzung: SAP-System mit HTTP-Client, SICF und (für Realtime) AMC bzw. HTML-Control-Umgebung.

## Repository-Struktur

```
.
├── .abapgit.xml          # abapGit-Metadaten (Master Language D)
├── README.md
└── src/                  # abapGit-Objekte (PREFIX-Logik)
    ├── #gpios#…          # Klassen, Interfaces, DDIC, Reports, FUGR
    ├── package.devc.xml  # Paket „PBL: Core“
    └── *.sicf.xml        # HTTP-Services
```

## Lizenz / Herkunft

© GPIO Solutions GmbH — Namensraum `/GPIOS/` („GPIO Solutions Namensraum“).

Dieses Repository enthält den abapGit-Export des Pakets **PBL: Core**.
