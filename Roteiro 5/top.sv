// DESCRIPTION: Verilator: Systemverilog example module
// Roteiro 5 - Luana dos Santos Liberato

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
  parameter CINCO = 'b01101101;
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
  logic [7:0] saida;
  logic [3:0] contador;
  logic ent_serial;
  logic [1:0] contador_sequencial;
  logic saida_led;

  always_comb begin
    reset <= SWI[0];
    selecionador <= SWI[1];
    ent_serial <= SWI[2];
  end

  function logic[7:0] conversor (logic[3:0] cont);
    logic[7:0] y;

    case (cont)
      4'b0000: y = ZERO;
      4'b0001: y = UM;
      4'b0010: y = DOIS;
      4'b0011: y = TRES;
      4'b0100: y = QUATRO;
      4'b0101: y = CINCO;
      4'b0110: y = SEIS;
      4'b0111: y = SETE;
      4'b1000: y = OITO;
      4'b1001: y = NOVE;
      4'b1010: y = LETRA_A;
      4'b1011: y = LETRA_B;
      4'b1100: y = LETRA_C;
      4'b1101: y = LETRA_D;
      4'b1110: y = LETRA_E;
      4'b1111: y = LETRA_F;
    endcase 

    return y;
  endfunction

  function logic[1:0] verificarContSequencia (logic[1:0] cont);
    logic [1:0] c;

    if (cont == 'b11) begin
      c = cont;
    end
    else begin
      c = cont + 1;
    end

    return c;
  endfunction

  function logic verificarSequencia (logic[1:0] cont_seq);
    logic l;

    if (cont_seq == 'b11) begin
      l = 'b1;
    end
    else begin
      l = 'b0;
    end

    return l;
  endfunction

  always_ff @(posedge clk_2) begin
    if (reset == 'b1) begin
      contador <= 'b0000;
      saida <= 'b00000000;
    end
    else if (selecionador == 'b0) begin
      contador <= contador + 1;
      saida <= conversor(contador);
    end
    else begin
      contador <= contador - 1;
      saida <= conversor(contador);
    end

    contador_sequencial <= verificarContSequencia(contador_sequencial);
    
    if (reset == 'b1) begin
      contador_sequencial <= 'b00;
      saida_led <= 'b0;
    end
    else if (ent_serial == 'b1) begin
      contador_sequencial <= verificarContSequencia(contador_sequencial);
      saida_led <= verificarSequencia(contador_sequencial);
    end 
    else begin
      contador_sequencial <= 'b00;
      saida_led <= 'b0;
    end
  end

  always_comb begin
    LED[7] <= clk_2;
    SEG <= saida;
    LED[0] <= saida_led;
  end
endmodule