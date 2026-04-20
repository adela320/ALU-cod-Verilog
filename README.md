# ALU-cod-Verilog

Proiect Verilog care implementează o mini-ALU cu:
- **ADD / SUB** (pe 9 biți intern)
- **DIV unsigned** (algoritm *restoring*)
- **MUL** (Booth Radix-4)

Include și testbench-uri + scripturi TCL pentru simulare.

## Tooling (simulare)
**Testat cu:** *ModelSim Altera Started Edition 6.5b*

---

## Structura repository-ului

- `README.md` – documentația proiectului.
- `.gitignore` – ignoră fișiere generate (biblioteci de simulare, output-uri etc.).
- `src/` – folderul principal cu implementarea Verilog, testbench-uri și scripturi de rulare.

---

## Fișierele din `src/` (rol + ce face fiecare)

### 1) Blocuri aritmetice de bază

#### `adder_rca.v`
Conține:
- `fac` – full adder 1-bit (sum + carry).
- `adder_rca` – **Ripple Carry Adder** parametrizabil (implicit `w=9`).
  - `carry_in = 0` → adunare
  - `carry_in = 1` → scădere (2’s complement, prin `y XOR 1` + carry initial = 1)

Este blocul de bază reutilizat în ALU (ADD/SUB), în DIV (A − M), și în MUL Booth (A ± M / A ± 2M).

#### `adder_rca_sanity_tb.v`
Testbench simplu pentru `adder_rca.v`, folosit pentru verificare rapidă (sanity check) a sumatorului.

#### `addsub.v`
Modul sincron (cu `clk/reset/start`) care folosește `adder_rca` pentru **add/sub unsigned pe 8 biți**, cu extensie la 9 biți (`sum9`).
Semnale:
- `start` declanșează operația
- `busy/done` indică execuția
- `sub` selectează scădere vs adunare

#### `addsub_tb.v`
Testbench pentru `addsub.v`.

---

### 2) ALU (control + datapath + top)

#### `alu_control_unit.v`
**Unitate de control (FSM)** pentru ALU.
- Primește `start`, `opcode`, plus semnale de feedback (`step`, `triplet`, `d_sub_cout`) și generează **semnale de control** pentru:
  - secvența de diviziune restoring (`d_c0..d_c9`, în funcție de implementare)
  - secvența de înmulțire Booth (`m_c0..m_c8`, în funcție de implementare)
  - ADD/SUB (prin `add_en`)
- Mai generează handshake-ul:
  - `busy` (ALU ocupată)
  - `done` (operație finalizată)
- Tratează cazul **DIV0** (divizor = 0), semnalizat prin `d_c9` (propagat ca `error` în `alu_main.v`).

#### `alu_datapath.v`
**Datapath-ul ALU** (partea care face efectiv calculele), controlat de semnalele din control unit.
Elemente cheie (conform codului):
- Registre interne: `A` (9 biți), `M` (9 biți), `Q` (8 biți), `q_minus_1`, `step`
- Instanță `adder_rca #(9)` pentru operațiile aritmetice
- Selecție operanzi în funcție de `opcode`:
  - `00/01` → ADD/SUB (folosește `{1'b0, B_in}` și `opcode[0]` ca select)
  - `10` → DIV: configurează RCA pentru `A - M`
  - `11` → MUL Booth: alege între `M` și `2M` și selectează adunare/scădere prin `m_c3/m_c4`
- Realizează:
  - **shift-uri** pentru diviziune și Booth
  - **latch** pentru valori intermediare la diviziune (`A_pre_sub`, `sub_sum_r`, `cout_r`)
- Ieșiri importante:
  - `d_sub_cout` (carry-out din scăderea din diviziune, folosit la “accept/restore”)
  - `step_out` (contor de pași)
  - `triplet_out` (pentru Booth: `{Q[1:0], q_minus_1}`)
  - `result_out` mapat astfel:
    - DIV (`opcode==2’b10`): `{Q, A[7:0]}` (cat + rest)
    - MUL (`opcode==2’b11`): `{A[7:0], Q}`
    - ADD/SUB: `{7'd0, A[8:0]}`

#### `alu_main.v`
Top-level pentru ALU: conectează `alu_control_unit` cu `alu_datapath`.
- Expune interfața:
  - intrări: `clk, reset, start, opcode, A, B`
  - ieșiri: `result[15:0], done, busy, error`
- `error` este legat de `d_c9` (caz divizare la 0).

#### `alu_top_tb.v`
Testbench de top pentru ALU (`alu_main`):
- generează clock/reset/start
- aplică opcoduri și operanzi
- urmărește `result/busy/done/error` în simulare.

---

### 3) Înmulțire Booth Radix-4 (standalone)

#### `booth_multiplier_datapath.v`
Datapath pentru înmulțitor Booth Radix-4 (registre, formare triplet, actualizare A/Q, etc.).

#### `booth_multiplier_ctrl.v`
Unitate de control (FSM) pentru înmulțitorul Booth:
- generează semnale de control (ex. `c0..c8` în testbench/script).

#### `booth_multiplier_tb.v`
Testbench pentru înmulțitorul Booth:
- aplică stimuli și urmărește `product` + semnale interne.

---

### 4) Împărțire restoring unsigned (standalone)

#### `restoring_div_ctrl.v`
Unitate de control (FSM) pentru algoritmul de împărțire restoring unsigned.

#### `restoring_div_datapath.v`
Datapath pentru restoring division (shift, subtract, restore, registre intermediare).

#### `restoring_div_unsigned.v`
Modul “wrapper” pentru împărțirea unsigned restoring (leagă control + datapath într-un singur modul utilizabil).

#### `restoring_div_unsigned_tb.v`
Testbench pentru `restoring_div_unsigned.v`.

---

## Scripturi de simulare (ModelSim)

Toate scripturile sunt în `src/`. În ModelSim (Transcript) rulează din folderul `src/`:

### ALU (simulare completă)
- `do run_alu.tcl`

Scriptul compilează (în ordine) fișierele necesare pentru ALU și pornește:
- `vsim -voptargs=+acc work.alu_top_tb`
și adaugă semnale în waveform (inclusiv registre interne precum `A` și `Q`).

### Diviziune restoring / addsub
- `do run.tcl`

Scriptul compilează modulele pentru diviziune + testbench-urile și rulează (implicit) `restoring_div_unsigned_tb`
(în script există și opțiunea de a rula `addsub_tb`).

### Booth multiplier
- `do run_booth.tcl`

Compilează modulele Booth + `adder_rca`, pornește `booth_multiplier_tb`, adaugă semnale în Wave și rulează până la final.

### Sanity test RCA
- `run_ex.txt` conține o rețetă simplă pentru a compila `adder_rca` + `adder_rca_sanity_tb` și a rula testul.

---

## Note rapide (definiții utile)
- **Datapath (calea de date):** registre + sumator + logică de shift/actualizare care execută operațiile.
- **Control Unit (unitate de control):** FSM care generează semnalele de control și ordonează pașii operației.
- **Testbench:** modul de simulare care generează stimuli și verifică rezultatele.
