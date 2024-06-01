`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2024 10:20:56 PM
// Design Name: 
// Module Name: ArithmeticLogicUnitSystem
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


module ArithmeticLogicUnitSystem(
        RF_OutASel, RF_OutBSel, 
        RF_FunSel,  RF_RegSel,
        RF_ScrSel,  ALU_FunSel,
        ALU_WF,     ARF_OutCSel, 
        ARF_OutDSel, ARF_FunSel,
        ARF_RegSel, IR_LH,
        IR_Write, Mem_WR,
        Mem_CS, MuxASel,
        MuxBSel,MuxCSel,
        Clock,
    //Outputlar    
        OutA, OutB,
        ALUOut,
        Flags,
        OutC,
        Address,
        MemOut,
        IROut,
        MuxAOut, MuxBOut,
        MuxCOut       
        );
        
    input wire[2:0] RF_OutASel;
    input wire[2:0] RF_OutBSel;
    input wire[2:0] RF_FunSel;
    input wire[3:0] RF_RegSel;
    input wire[3:0] RF_ScrSel;
    input wire[4:0] ALU_FunSel;
    input wire ALU_WF; 
    input wire[1:0] ARF_OutCSel;
    input wire[1:0] ARF_OutDSel;
    input wire[2:0] ARF_FunSel;
    input wire[2:0] ARF_RegSel;
    input wire IR_LH; 
    input wire IR_Write;
    input wire Mem_WR; 
    input wire Mem_CS;
    input wire[1:0] MuxASel;
    input wire[1:0] MuxBSel;
    input wire MuxCSel;
    input wire Clock;
    
    
    reg [15:0]input_RF, input_ARF;
    wire [15:0] AOut, BOut, ARF_Cout, OutD;
    reg [7:0] mCOut; //Mux C out
    wire [3:0]FlagOut;
    wire [15:0]OutALU;
    wire [7:0] input_IR;
    wire [15:0] output_IR;
    
    output wire[15:0]OutA, OutB;
    output wire[15:0] ALUOut;
    output wire[3:0]Flags;
    output wire[15:0]OutC;
    output wire [15:0]Address;
    output wire[7:0] MemOut;
    output wire[15:0] IROut;
    output wire [15:0]MuxAOut, MuxBOut;
    output wire [7:0] MuxCOut;    
    
    //Defining Register File
    RegisterFile RF(Clock, input_RF, RF_OutASel, RF_OutBSel, RF_FunSel, RF_RegSel, RF_ScrSel, AOut,BOut);
    //Defining Address Register
    AddressRegisterFile ARF(Clock, input_ARF, ARF_OutCSel, ARF_OutDSel, ARF_FunSel,ARF_RegSel, ARF_Cout, OutD); //En sonda E eyi direkt enable yapt?m do?ru mu bilmiom
    
   // Defining Arithmetic Logic Unit 
     ArithmeticLogicUnit ALU(
            .A(AOut),
            .B(BOut),
            .FunSel(ALU_FunSel),
            .ALUOut(OutALU),
            .FlagsOut(Flags),
            .Clock(Clock),
            .WF(ALU_WF)
        );
    //Defining Instruction Register
    InstructionRegister IR(Clock, input_IR, IR_LH, IR_Write, output_IR);
      
    //Defining Memory
    Memory MEM(OutD,mCOut,Mem_WR,Mem_CS, Clock,input_IR);
    
    
    //Defining multiplexers
     always @* begin
               case(MuxCSel)
                   1'b0: mCOut = OutALU[7:0];    
                   1'b1: mCOut = OutALU[15:8]; 
             
               endcase
               //muxAoUT RF in inputu olacak
               case(MuxASel)
                   2'b00: input_RF = OutALU;
                   2'b01: input_RF = ARF_Cout; 
                   2'b10: input_RF = {8'd0 , input_IR}; //Memory bo? kalan bitler extended with zeroes
                   2'b11: input_RF = {8'd0, output_IR[7:0]};    //degistim
               endcase
               
               case(MuxBSel)
                    2'b00: input_ARF =OutALU;
                    2'b01: input_ARF = ARF_Cout;
                    2'b10: input_ARF = {8'd0, input_IR};
                    2'b11: input_ARF = {8'd0, output_IR[7:0]};
               endcase
           end
    
    assign MemOut= input_IR;   
    assign OutA = AOut; 
    assign OutB = BOut;
    assign ALUOut = OutALU;
    assign Flags = FlagOut;
    assign OutC = ARF_Cout; 
    assign Address = OutD; 
    assign MuxAOut = input_RF;
    assign MuxBOut = input_ARF;
    assign MuxCOut = mCOut;
    assign IROut = output_IR;
 
    
   endmodule

     