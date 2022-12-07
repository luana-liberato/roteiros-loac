// DESCRIPTION: Verilator: Systemverilog example module
// Roteiro 3 - Luana dos Santos Liberato

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

  logic signed [2:0] A;
  logic signed [2:0] B;
  logic [1:0] F;
  logic signed [3:0] Y;

  parameter ZERO = 'b00111111;
  parameter UM = 'b00000110;
  parameter DOIS = 'b01011011;
  parameter TRES = 'b01001111;
  parameter MENOS_QUATRO = 'b11100110;
  parameter MENOS_TRES = 'b11001111;
  parameter MENOS_DOIS = 'b11011011;
  parameter MENOS_UM = 'b10000110;
  parameter VAZIO = 'b00000000;
  
  function void uverUnder();
    SEG = VAZIO;
    LED[7] = 'b1;
    LED[2:0] = 'b000;
  endfunction
  
  function void binarioParaDecimal(logic [2:0] binario);
    LED[7] = 'b0;
    LED[2:0] = binario;

    if (binario == 'b000) begin
      SEG = ZERO;
    end
      
    else if (binario == 'b001) begin
      SEG = UM;
    end

    else if (binario == 'b010) begin
      SEG = DOIS;
    end

    else if (binario == 'b011) begin
      SEG = TRES;
    end

    else if (binario == 'b100) begin
      SEG = MENOS_QUATRO;
    end

    else if (binario == 'b101) begin
      SEG = MENOS_TRES;
    end

    else if (binario == 'b110) begin
      SEG = MENOS_DOIS; 
    end

    else begin
      SEG = MENOS_UM;
    end
  endfunction
 
  always_comb begin
    A <= SWI[7:5];
    B <= SWI[2:0];
    F <= SWI[4:3];

    if (F == 'b10) begin
      Y <= A & B;

      binarioParaDecimal(Y[2:0]);
    end

    else if (F =='b11) begin
      Y <= A | B;

      binarioParaDecimal(Y[2:0]);
    end
    
    else if (F == 'b00) begin
      Y <= A + B;
      
      if ((Y >= -4) & (Y <= 3)) begin
        binarioParaDecimal(Y[2:0]);
      end 
      
      else begin
        uverUnder;
      end
    end 
    
    else begin
      Y <= A - B;
      
      if ((Y >= -4) & (Y <= 3)) begin
        binarioParaDecimal(Y[2:0]);
      end 
      
      else begin
        uverUnder;
      end
    end
  end
endmodule