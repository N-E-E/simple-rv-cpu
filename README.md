## Summary

This project is from the final course lab of Computer Organization. In this lab, I build a Risc-V CPU

using Logisim and  Verilog HDL. The ISA is this lab is RV32-I, and the address is 4-byte aligned.

 ## Single-Cycle CPU

First, I build a single-cycle cpu, which is simple and fast. And the structure is simple. There are some of the design points:

- According to the lab command, register file and data memory(ram) is Asynchronous Read and Synchronous Write
- memory address is 4-byte aligned.
- Use Hardwired Controller

### structure

![single-cycle cpu](/img/single-cycle-cpu-struc.png) 

The only difficulty is building decoding unit and controller.

### Logisim

![single-cycle-cpu](/img/single-cycle-cpu.png)

### Verilog

![](/img/single-cycle-verilog.png)



## 5-stage Pipeline CPU with Forwarding

- add a hazzard detector module.

###  structure

![](/img/pipeline-cpu-struc.png)

### Verilog

![](/img/forward-verilog.jpg)

### Branch Prediction module