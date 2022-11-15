// DESCRIPTION: Verilator: Systemverilog example module
// Roteiro 4 - Registrador Serial | Paralelo - Luana dos Santos Liberato

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

  // Definido fios.
  logic reset;
  logic selecionador;
  logic ent_serial;
  logic [3:0] ent_paralela, saida;

  // Recebendo as entradas.
  always_comb begin
    reset <= SWI[1];
    selecionador <= SWI[2];
    ent_serial <= SWI[3];
    ent_paralela <= SWI[7:4];
  end

  // Lógica do funcionamento de um registrador considerando inicialmente o reset, depois a entrada e saída parelala, e por último a lógica de um deslocamento.
  always_ff @(posedge clk_2 or posedge reset) begin
    if (reset == 'b1) begin
      saida <= 'b0000;
    end

    else if (selecionador == 'b1) begin
      saida <= ent_paralela;
    end

    else begin
      saida[3] <= ent_serial;
      saida[2] <= saida[3];
      saida[1] <= saida[2];
      saida[0] <= saida[1];      
    end
  end

  // Definindo saídas.
  always_comb begin
    LED[7:4] <= saida;

    // Led que marca o clock.
    LED[0] <= clk_2;
  end
endmodule