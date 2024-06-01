`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2024 12:48:05 PM
// Design Name: 
// Module Name: AddressRegisterFile
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


module AddressRegisterFile(Clock, I, OutCSel, OutDSel, FunSel, RegSel, OutC, OutD);
    input wire Clock;
    input wire [15:0] I;
    input wire [1:0] OutCSel;
    input wire [1:0] OutDSel;
    input wire [2:0]FunSel;
    input wire [2:0] RegSel;
    output reg [15:0] OutC;
    output reg [15:0] OutD;
    
    wire [15:0] PC1, AR1, SP1;
    
    Register PC (Clock,I ,FunSel,~RegSel[2], PC1); 
    Register AR(Clock,I, FunSel,~RegSel[1],AR1); 
    Register SP(Clock,I, FunSel,~RegSel[0],SP1); 
    
    
     always@* begin
           case (OutCSel)
               2'b00: OutC = PC1;
               2'b01: OutC = PC1;
               2'b10: OutC = AR1;      
               2'b11: OutC = SP1;
           endcase
               
            case (OutDSel)
               2'b00: OutD = PC1;
               2'b01: OutD = PC1;                 
               2'b10: OutD = AR1;
               2'b11: OutD = SP1;
                      
               endcase
       end

endmodule
