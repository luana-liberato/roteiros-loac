// DESCRIPTION: Verilator: Systemverilog example module
// Roteiro 4 - Registrador Serial e Paralelo - Luana dos Santos Liberato

parameter divide_by=100000000;  // divisor do clock de referência
// A frequencia do clock de referencia é 50 MHz.
// A frequencia de clk_2 será de  50 MHz / divide_by

parameter NBITS_INSTR = 32;
parameter NBITS_TOP = 8, NREGS_TOP = 32, NBITS_LCD = 64;
module top(input  logic clk_2,
           input  logic [NBITS_TOP-1:0] SWI,
           output logic [NBITS_TOP-1:0] LED,
           output logic [NBITS_TOP-1:0] SEG,
           output logic [NBITS_LCD-1:0] lcd_a, lcd_b,
           output logic [NBITS_INSTR-1:0] lcd_instruction,
           output logic [NBITS_TOP-1:0] lcd_registrador [0:NREGS_TOP-1],
           output logic [NBITS_TOP-1:0] lcd_pc, lcd_SrcA, lcd_SrcB,
             lcd_ALUResult, lcd_Result, lcd_WriteData, lcd_ReadData, 
           output logic lcd_MemWrite, lcd_Branch, lcd_MemtoReg, lcd_RegWrite);

  always_comb begin
    //SEG <= SWI;
    lcd_WriteData <= SWI;
    lcd_pc <= 'h12;
    lcd_instruction <= 'h34567890;
    lcd_SrcA <= 'hab;
    lcd_SrcB <= 'hcd;
    lcd_ALUResult <= 'hef;
    lcd_Result <= 'h11;
    lcd_ReadData <= 'h33;
    lcd_MemWrite <= SWI[0];
    lcd_Branch <= SWI[1];
    lcd_MemtoReg <= SWI[2];
    lcd_RegWrite <= SWI[3];
    for(int i=0; i<NREGS_TOP; i++)
       if(i != NREGS_TOP/2-1) lcd_registrador[i] <= i+i*16;
       else                   lcd_registrador[i] <= ~SWI;
    lcd_a <= {56'h1234567890ABCD, SWI};
    lcd_b <= {SWI, 56'hFEDCBA09876543};
  end

  parameter ZERO = 'b00111111;
  parameter UM = 'b00000110;
  parameter DOIS = 'b01011011;
  parameter TRES = 'b01001111;
  parameter QUATRO = 'b01100110;
  parameter CINCO = 'b01100101;
  parameter SEIS = 'b01111101;
  parameter SETE = 'b00000111;
  parameter OITO = 'b01111111;
  parameter NOVE = 'b01101111;
  parameter LETRA_A = 'b01110111;
  parameter LETRA_B = 'b01111100;
  parameter LETRA_C = 'b00111001;
  parameter LETRA_D = 'b01011110;
  parameter LETRA_E = 'b01111001;
  parameter LETRA_F = 'b01110001;

  //SWI 0 CRESCENTE 1 DECRESCENTE
  //SEG7 vai ser LED7
  logic reset;
  logic selecionador;
  logic ent_serial;
  logic [3:0] ent_paralela, saida;

  always_comb begin
    reset <= SWI[0];
    selecionador <= SWI[1];
    ent_serial <= SWI[3];
    ent_paralela <= SWI[7:4];
  end

  always_ff @(posedge clk_2) begin
    if (reset == 'b0) saida <= 'b0000;
    else if (selecionador == 'b1) saida <= ent_paralela;
    else begin
      saida[0] <= saida[1];
      saida[1] <= saida[2];
      saida[2] <= saida[3];
      saida[3] <= ent_serial;
    end

    LED[7:4] <= saida;
  end
endmodule