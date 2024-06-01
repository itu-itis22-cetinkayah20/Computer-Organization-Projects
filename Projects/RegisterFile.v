`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2024 08:37:48 PM
// Design Name: 
// Module Name: RegisterFile
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RegisterFile(Clock, I, OutASel, OutBSel, FunSel, RegSel, ScrSel, OutA, OutB);
    input wire Clock;
    input wire[15:0] I;
    input wire[2:0] OutASel;
    input wire[2:0] OutBSel;
    input wire[2:0] FunSel;
    input wire[3:0] RegSel;
    input wire[3:0] ScrSel;
    output reg[15:0] OutA;
    output reg[15:0] OutB;
    
    wire [15:0]Reg1,Reg2, Reg3, Reg4, Scr1, Scr2, Scr3, Scr4;
    
   // Instantiate general-purpose registers
   //Takes one bit of RegSel for enabling it has reversed logic in pdf
   Register R1(Clock,I,FunSel,~RegSel[3],Reg1);
   Register R2(Clock,I,FunSel,~RegSel[2],Reg2);
   Register R3(Clock,I,FunSel,~RegSel[1],Reg3);
   Register R4(Clock,I,FunSel,~RegSel[0],Reg4);
   
    
    // Instantiate scratch registers
    Register S1(Clock,I,FunSel,~ScrSel[3],Scr1);
    Register S2(Clock,I,FunSel,~ScrSel[2],Scr2);
    Register S3(Clock,I,FunSel,~ScrSel[1],Scr3);
    Register S4(Clock,I,FunSel,~ScrSel[0],Scr4);
   
    
    // Output selection logic
    always @* begin
        case(OutASel)
            4'b000: OutA = Reg1;
            4'b001: OutA = Reg2;
            4'b010: OutA = Reg3;
            4'b011: OutA = Reg4;
            4'b100: OutA = Scr1;
            4'b101: OutA = Scr2;
            4'b110: OutA = Scr3;
            4'b111: OutA = Scr4;
        endcase
    
        case(OutBSel)
            4'b000: OutB = Reg1;
            4'b001: OutB = Reg2;
            4'b010: OutB = Reg3;
            4'b011: OutB = Reg4;
            4'b100: OutB = Scr1;
            4'b101: OutB = Scr2;
            4'b110: OutB = Scr3;
            4'b111: OutB = Scr4;
        endcase
    end  
    
      
endmodule
