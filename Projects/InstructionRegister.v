`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2024 07:45:54 PM
// Design Name: 
// Module Name: IR_Register
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


module InstructionRegister(Clock, I, LH, Write, IROut);
    input wire Clock;
    input wire [7:0] I;
    input wire LH;
    input wire Write;
    output reg [15:0] IROut;


always @(posedge Clock ) begin
    if(Write==0) begin
        IROut <= IROut;    //IR Retain value
    end
    else begin
        if(LH) begin
            IROut[15:8]<= I;
        end else begin
            IROut[7:0] <= I;
        end
     end
 end  
    
    
  endmodule
    