# AXI4 Protocol – RTL Design & UVM Verification

## 1. Project Overview

This project implements a complete UVM-based verification environment for a custom AXI4 Slave RTL design.

The objective is to verify protocol compliance, burst functionality, response behavior, reset robustness, and memory correctness using a structured UVM architecture with assertions and functional coverage.

---

## 2. Design Under Test (DUT)

The AXI4 Slave RTL supports:

- Burst Types:
  - FIXED (2'b00)
  - INCR  (2'b01)
  - WRAP  (2'b10)

- Response Types:
  - OKAY   (2'b00)
  - SLVERR (2'b10)

- 32-bit Data Width
- 32-bit Address Width
- 4KB Internal Memory
- Single ID Mode (No multi-ID support)
- Reset Support
- Error Generation for illegal conditions

---

## 📂 3. Project Directory Structure

```
AXI4_UVM_Verification/
├── docs/
│   ├── coverage_summary.png
│   ├── axi4_sim_log.txt
│   └── axi4_waveform.png
│
├── rtl/
│   └── slave.sv
│
├── sim/
│	   ├── axi4_virtual_test.txt
│	   ├── axi4_fixed_test.txt
│    ├── axi4_incr_test.txt
│    ├── axi4_wrap_test.txt
│    ├── axi4_error_test.txt
│    └── axi4_reset_test.txt
│
├── tb/
│      ├──tb_top.sv
│	     │
│      ├── agent/
│ 	   │       ├── axi4_sequecncer.sv
│ 	   │       ├── axi4_driver.sv
│ 	   │       ├── axi4_monitor.sv
│ 	   │       └── axi4_agent.sv
│	     │
│      ├── env
│ 	   │       ├── axi4_scoreboard.sv
│ 	   │       ├── axi4_coverage.sv
│ 	   │       └── axi4_env.sv
│ 	   │
│      ├── interface
│ 	   │       └── axi4_if.sv
│ 	   │
│      ├── sequences
│ 	   │       ├── axi4_fixed_wr_rd_seq.sv
│ 	   │       ├── axi4_incr_wr_rd_seq.sv
│ 	   │       ├── axi4_wrap_wr_rd_seq.sv
│ 	   │       ├── axi4_error_wr_rd_seq.sv
│ 	   │       ├── axi4_reset_wr_rd_seq.sv
│ 	   │       ├── axi4_virtual_seq.sv
│ 	   │       └── axi4_sequences.sv
│ 	   │
│      ├── tests
│ 	   │       ├── axi4_fixed_wr_rd_test.sv
│ 	   │       ├── axi4_incr_wr_rd_test.sv
│ 	   │       ├── axi4_wrap_wr_rd_test.sv
│ 	   │       ├── axi4_error_wr_rd_test.sv
│ 	   │       ├── axi4_reset_wr_rd_test.sv
│ 	   │       ├── axi4_virtual_test.sv
│ 	   │       ├── axi4_base_test.sv
│ 	   │       └── axi4_package.sv
│ 	   │
│      └── transaction
│ 	           └── axi4_txn.sv
│
├── waves/
│	   ├── axi4_fixed_waveform.png
│    ├── axi4_incr_waveform.png
│    ├── axi4_wrap_waveform.png
│    ├── axi4_error_waveform.png
│    └── axi4_reset_waveform.png
│
└── README.md
```

---

## 🏗️ 4. Verification Architecture

The verification environment follows standard UVM layered architecture.

### Components

- **Transaction**  
  Defines AXI attributes: address, burst type, length, size, data, and response.

- **Sequencer**  
  Generates constrained-random stimulus.

- **Driver**  
  Converts transactions into pin-level AXI protocol activity.

- **Monitor**  
  Observes DUT signals and reconstructs transactions.

- **Agent**  
  Encapsulates driver, sequencer, and monitor.

- **Environment**  
  Integrates agent, scoreboard, and coverage components.

- **Scoreboard**  
  Implements reference memory model and compares read data with expected data.

- **Coverage Component**  
  Collects functional coverage on burst types, responses, sizes, and address ranges.

- **Interface Assertions**  
  Protocol assertions embedded inside the AXI interface validate handshake, alignment, and response correctness.

---

## 5. Assertions & Coverage

### Protocol Assertions

Assertions are implemented in `axi4_interface.sv` for:

- AW channel handshake behavior
- WLAST alignment with burst length
- RLAST alignment with burst length
- Address alignment to transfer size
- BRESP validity checking
- Cover properties for assertion coverage measurement

---

### Functional Coverage

Covergroups implemented in `axi4_coverage.sv` capture:

- Burst type (FIXED, INCR, WRAP)
- Burst length (AWLEN)
- Transfer size (AWSIZE)
- Address ranges (valid and out-of-range)
- BRESP bins (OKAY, SLVERR)
- RRESP bins (OKAY, SLVERR)
- Key protocol control signals (VALID, READY, LAST)

---

### Cross Scenario Validation

The verification environment ensures:

- Burst type behavior correctness
- Error response for illegal size
- Error response for invalid address
- Reset recovery behavior
- Write-read data consistency

---

## 🧪 6. Test Scenarios

The following directed and random tests are implemented:

- Base functionality test
- FIXED burst test
- INCR burst test
- WRAP burst test
- Error injection test
- Reset during transaction test
- Mixed constrained-random test

---

## 7. Simulation Flow

### Compile
vlog -f filelist.f

### Run
vsim -c top_tb -do "run -all"



---

## 📊 08. Regression Summary

| Test | Transactions | Status |
|------|--------------|--------|
| FIXED Burst Test | 3 | ✅ PASS |
| INCR Burst Test | 3 | ✅ PASS |
| WRAP Burst Test | 3 | ✅ PASS |
| Error Injection Test | 1 | ✅ PASS |
| Reset During Transfer | 1 | ✅ PASS |
| Multiple randomized transactions | 11 | ✅ PASS |

- Zero scoreboard mismatches observed
- All protocol assertions passed
- 100% Functional coverage achieved in regression
- Stable behavior under reset and error conditions

---

## 🎯 09. Learning Outcomes

- Strong understanding of AXI4 protocol
- Burst address generation logic
- UVM agent architecture design
- Assertion-based protocol checking
- Functional coverage modeling
- Scoreboard memory verification
- Debugging handshake and burst-related issues

---

## 🚀 10. Project Status

✔ RTL verified for supported modes  
✔ Protocol assertions integrated  
✔ Functional coverage implemented  
✔ Regression runs passing  
✔ Ready for demonstration and interview discussion  

---

## 👤 Author

**Brahma Ganesh Katrapalli**

ASIC Design Verification  
SystemVerilog | UVM | Assertions | Coverage

---
