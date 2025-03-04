

# CPUSystem Project

## Overview

This project involves the implementation of a basic CPU system using Verilog. The project includes various modules such as the Arithmetic Logic Unit (ALU), Register File (RF), Address Register File (ARF), Arithmetic Logic Unit System (ALUSys). The CPU system is designed to execute a set of instructions and manage the state transitions based on clock cycles and reset signals. ALU, ARF, RF and ALUSys are designed or Project 1 and CPU System is designed for Project 2. Note that Project 2 is designed utilizing Project 1. 

---
## Features

- **Clock and Reset Management**: Handles clock and reset signals to control the CPU operations.
- **Instruction Fetch and Decode**: Fetches and decodes instructions from memory.
- **ALU Operations**: Performs arithmetic and logic operations.
- **Register File Operations**: Manages data storage and retrieval in registers.
- **Memory Operations**: Reads from and writes to memory.
- **State Machine**: Implements a state machine to manage instruction execution cycles.

---

## **Project Structure**

```
/Computer-Organization-Projects/
│── Projects/
│   │── ArithmeticLogicUnit.v      # ALU implementation
|   |── ArithmeticLogicUnitSystem  # Merge components for Project 1
│   │── CPUSystem.v                # Main CPU system implementation
│   │── RegisterFile.v             # Register file implementation
│   │── AddressRegisterFile.v      # Address register file implementation
│── README.md                      # Documentation
```

---

## **Getting Started**

### **Prerequisites**

- **Simulation Tool**: Make sure you have a simulation tool for testing the Verilog code (e.g., GTKWave). We have used Vivado 2017.4 to simulate our code. 

---

### **Installation**

1. **Clone the repository**
    - You can clone the repository using git or download it from Code, Download ZIP
    ```sh
    git clone https://github.com/irem-kalay/Computer-Organization-Projects.git
    ```

2. **Add verilog files as design sources or simulation sources**
    - Add the files which project structure includes as design sources. Add files which named Simulation as simulation sources. 

3. **Add simulation set**
    - Add simulation sets in the Simulation Sources to test each component of the system seperately. 

4. **Run the simulation**
    - Set the desired simulation set as active simulation set.
    - Run the active simulation set to see the results. 

---

## **Technologies Used**

- **Verilog**: Hardware description language for designing and modeling the CPU system.
- **Vivado 2017.4**: Verilog simulation and synthesis tool.

## **Usage**

- **Simulate CPU Operations**: Run the simulation to observe the CPU operations and state transitions.
- **Modify Verilog Code**: Update the Verilog files to implement new features or fix issues and re-run the simulation to see the changes.

---

## **Contributors**

- İrem Kalay
- Hakan Çetinkaya 
---

## **Results**
- First project grade: 96.34
- Second project grade: 100

---
## **License**

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.

In jurisdictions that recognize copyright laws, the author or authors of this software dedicate any and all copyright interest in the software to the public domain. We make this dedication for the benefit of the public at large and to the detriment of our heirs and successors. We intend this dedication to be an overt act of relinquishment in perpetuity of all present and future rights to this software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <https://unlicense.org>

