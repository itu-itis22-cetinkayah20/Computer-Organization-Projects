`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2024 04:20:27 PM
// Design Name: 
// Module Name: Register
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


module Register(Clock,I,FunSel,E,Q);
    input wire E;
    input wire [2:0] FunSel;
    input wire [15:0] I;
    input wire Clock;
    output reg [15:0] Q;
    
    always @(posedge Clock)
        begin
        if(E)begin
            case(FunSel)
                3'b000: Q <= Q-1;   //Decrement
                3'b001: Q <= Q+1; //Increment
                3'b010: Q <= I;   //Load
                3'b011: Q <= 16'h0000; //Clear
                3'b100: begin
                           Q[15:8] <= 8'b00000000;
                           Q[7:0] <= I[7:0];
                        end
                3'b101: Q[7:0] <= I[7:0]; //Only write low
                3'b110: Q[15:8] <= I[7:0]; //Only write high
                3'b111: begin
                    if(I[7]== 1)
                        Q[15:8] <= 8'b11111111;
                    else
                        Q[15:0] <= 8'b00000000;
                        
                        Q[7:0] <= I[7:0];
                    end
                 
            default  : Q <=Q;
            endcase
         end
         else
            begin
                Q<=Q;
            end
         end
    endmodule   
