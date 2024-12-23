# UART Controller in TL-Verilog

This repository contains implementations of a UART Controller in TL-Verilog and SystemVerilog. It includes parametrized modules for the transmitter and receiver and demonstrates how to integrate the controller in your project.

---

## Directory Structure

- **[/src/uart_rtl](./src/uart_rtl):** Contains SystemVerilog implementations for the UART Receiver and Transmitter. The modules are parametrized for baud rate and clock frequency.
- **[/src/uart_tlv](./src/uart_tlv):** Provides TL-Verilog examples showcasing how to integrate and use the UART Controller in your project.

---

## TT Board Pinout

![TT Board Pinout](https://github.com/user-attachments/assets/bab92238-9a97-4806-8d85-1d792bf07ad9)

---

## UART PMOD interfacing with the board
![image](https://github.com/user-attachments/assets/bc3a497b-3d3b-4e47-b657-20b18083b830)

- The peripheral (FPGA) receives data from the host (PC) via the TxD port of the USB-UART PMOD.
- The peripheral sends data to the host through the RxD port of the USB-UART PMOD.

---

## PuTTY Configuration

To interact with the UART Controller using a serial terminal, follow these steps to configure PuTTY:

1. **Open PuTTY**
   - Open the PuTTY application on your computer.

2. **Go to Serial Configuration**
   - Navigate to the **Serial** section in the PuTTY interface.

   ![Serial Configuration](https://github.com/user-attachments/assets/65dcf1c3-18d6-44b8-8c61-a368443573c2)

3. **Set the Parameters**
   - Specify the following:
     - **Serial line:** Enter the port (e.g., `/dev/ttyUSB0`).
     - **Baudrate:** Set the appropriate baud rate as configured in your UART design.
     - **Flow control:** Set it to "None" (to operate without handshaking).

   ![Serial Parameters](https://github.com/user-attachments/assets/0eb55e19-f7f6-48b1-9cce-56d2e4c0b740)

---
