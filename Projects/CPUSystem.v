`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: irem Kalay and Hakan Cetinkaya
// 
// Create Date: 04/12/2024 05:13:48 PM
// Design Name: 
// Module Name: CPUSystem
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


module CPUSystem(Clock, Reset,T );
input wire Clock;
input wire Reset;
input wire [7:0]T;



 reg internal_Reset;
        
        //The inputs
         reg[2:0] RF_OutASel;     
         reg[2:0] RF_OutBSel;
         reg[2:0] RF_FunSel;
        reg[3:0] RF_RegSel;
        reg[3:0] RF_ScrSel;
         reg[4:0] ALU_FunSel;
         wire ALU_WF;    //Degistim
         reg[1:0] ARF_OutCSel;  //Reg yapt?m bilmiyorum
         reg[1:0] ARF_OutDSel;
          reg[2:0] ARF_FunSel;
          reg[2:0] ARF_RegSel;
           reg IR_LH; 
          reg IR_Write;
           reg Mem_WR; 
           reg Mem_CS;
          reg[1:0] MuxASel;
         reg[1:0] MuxBSel;
          reg MuxCSel;
            
            //The Outputs
         wire[15:0]OutA, OutB;
          wire[15:0] ALUOut;
         wire[3:0]Flags;
         wire[15:0]OutC;
          wire [15:0]Address;
         wire[7:0] MemOut;
         wire[15:0] IROut;
         wire [15:0]MuxAOut, MuxBOut;
          wire [7:0] MuxCOut;  
            
           

//I take the existing part4 connections here
ArithmeticLogicUnitSystem _ALUSystem(
    .RF_OutASel(RF_OutASel),
    .RF_OutBSel(RF_OutBSel),
    .RF_FunSel(RF_FunSel),
    .RF_RegSel(RF_RegSel),
    .RF_ScrSel(RF_ScrSel),
    .ALU_FunSel(ALU_FunSel),
    .ALU_WF(ALU_WF),
    .ARF_OutCSel(ARF_OutCSel),
    .ARF_OutDSel(ARF_OutDSel),
    .ARF_FunSel(ARF_FunSel),
    .ARF_RegSel(ARF_RegSel),
    .IR_LH(IR_LH),
    .IR_Write(IR_Write),
    .Mem_WR(Mem_WR),
    .Mem_CS(Mem_CS),
    .MuxASel(MuxASel),
    .MuxBSel(MuxBSel),
    .MuxCSel(MuxCSel),
    .Clock(Clock),
    .OutA(OutA),
    .OutB(OutB),
    .ALUOut(ALUOut),
    .Flags(Flags),
    .OutC(OutC),
    .Address(Address),
    .MemOut(MemOut),
    .IROut(IROut),
    .MuxAOut(MuxAOut),
    .MuxBOut(MuxBOut),
    .MuxCOut(MuxCOut)
);


reg [2:0] state_reg;
reg S;




decoderForTime Decoder(1'b1, state_reg, T);



always @(negedge Clock or negedge Reset) begin
    if (!Reset) begin
        // Reset logic
         _CPUSystem._ALUSystem.RF.R1.Q = 16'h6; 
         _CPUSystem._ALUSystem.RF.R2.Q = 16'h9;
         _CPUSystem._ALUSystem.RF.R3.Q = 16'h0;
         _CPUSystem._ALUSystem.RF.R4.Q = 16'h0;
         _CPUSystem._ALUSystem.RF.S1.Q = 16'h0;
         _CPUSystem._ALUSystem.RF.S2.Q = 16'h0;
         _CPUSystem._ALUSystem.RF.S3.Q = 16'h0;
         _CPUSystem._ALUSystem.RF.S4.Q = 16'h0;
         _CPUSystem._ALUSystem.ARF.PC.Q = 16'h0;
         _CPUSystem._ALUSystem.ARF.AR.Q = 16'h0;
         _CPUSystem._ALUSystem.ARF.SP.Q = 16'h0;
         _CPUSystem._ALUSystem.IR.IROut = 16'h0; 
         //Disable all
         RF_RegSel = 4'b1111;
         RF_ScrSel = 4'b1111;
         ARF_RegSel = 3'b111;
         IR_Write =1'b0;
         S=1'b0;      
         Mem_CS = 1'b1;
         Mem_WR =1'b0; 
        state_reg <= 3'b000; // Reset to T0 state
        // Additional reset logic for other signals if needed
    end else begin
        // Fetch operation and PC increment logic based on the current state
        case(state_reg)
            3'b000: begin // T0 state
                // Fetch operation when T0 is active
                RF_RegSel <= 4'b1111; //All are disabled
                
                ARF_OutDSel <=2'b00;   
                ARF_OutCSel <=2'bZZ; //It is not needed here?
             
                Mem_CS <= 1'b0;
                Mem_WR <= 1'b0;
                ARF_FunSel <=3'b001; //Increment PC 1
                ARF_RegSel <=3'b011; //PC enabled
                IR_LH <= 1'b0;
                IR_Write <=1'b1;
                // Update state to transition to T1
                state_reg <= 3'b001;
            end
            
            3'b001: begin // T1 state
                // Fetch operation when T1 is active
                ARF_OutDSel <=2'b00;
                       
                ARF_OutCSel <=2'bZZ; //It is not needed here?
                       
                Mem_CS <= 1'b0;
                Mem_WR <= 1'b0;
                ARF_FunSel <=3'b001; //Increment PC 1
                ARF_RegSel <=3'b011; //PC enabled
                IR_LH <= 1'b1;
                IR_Write <=1'b1;
                
                // Update state to transition to T2
                state_reg <= 3'b010;
            end
            
            
            
            
            3'b010: begin // T2 state
                 
                //SREG1=IROUT[5:3], SREG2= IROut[2:0], DSTREG = IROut[8:6]
                IR_Write <=1'b0; //IR Remains as it is
                S <= IROut[9];
                ARF_RegSel <=3'b111; //ALL are disabled         
                
                
                
                //BRA BNE BEQ : 00 01 02 PC<= PC+ VALUE
                if(IROut[15:10]==6'h00 || (IROut[15:10]==6'h01 && Flags[2]==0) || (IROut[15:10]==6'h02 && Flags[2]==1) )
                begin
                     MuxASel<= 2'b11;    //IR Out[7:0] was selected to go to S1
                     RF_ScrSel<=4'b0111; //Only S1 enabled
                     RF_FunSel<=3'b010;  //Load was selected as RF
                     RF_OutASel <= 3'b100; //S1 is at OutA 
                     ARF_OutCSel<=2'b00; //PC is at OutC at next clock cycle
                     
                     state_reg<=3'b011;               
                     end  
                     
                     
                     
                     
                else if(IROut[15:10]==6'h03)//POP
                begin
                    //SP<-SP+1
                    ARF_RegSel<= 3'b110; //SP enable
                    ARF_FunSel<=3'b001;//Increment applies to SP
                    state_reg <= 3'b011; //It will continue at T3 state
                end
                
                
                
                
                else if(IROut[15:10] == 6'h04)//PSH
                begin
                    //M[SP] <= Rx , for Rx's low bits , in the next cycle high bits will be taken
                    RF_OutASel <= {1'b0, IROut[9:8]}; //Rx selected due to RSEL in instruction
                    ALU_FunSel <= 5'b10000;
                    
                    ARF_OutDSel <=2'b11; //OutD is SP
                    MuxCSel <= 2'b0; //ALU out[7:0]
                    Mem_WR <= 1'b1; //Write
                    Mem_CS <= 1'b0;
                    
                    ARF_RegSel <= 3'b110; //SP enable
                    ARF_FunSel <= 3'b001; //SP increment
                    
                    state_reg <= 3'b011; //go to T3 state
                    
                end
                
                
                
                else if(IROut[15:10] == 6'h12)// LDR
                begin //Rx <- M[AR](this is for low bits)
                    ARF_OutDSel <= 2'b10;
                    Mem_WR <= 1'b0; //Memory read mode
                    Mem_CS <= 1'b0; //chip selected ?
                    MuxASel <= 2'b10; //Memory output
                    case(IROut[9:8])//Rx
                      2'b00: RF_RegSel <= 4'b0111; //R1 enable
                      2'b01: RF_RegSel <= 4'b1011; //R2 enable
                      2'b10: RF_RegSel <= 4'b1101; //R3 enable
                      2'b11: RF_RegSel <= 4'b1110; //R4 enable
                    endcase
                    RF_FunSel <= 3'b101; //Only write low
                    ARF_RegSel <=3'b101; //AR enabled
                    ARF_FunSel <=3'b001; //Increment AR for taking the 15:8 bits in next clock cycle
                    
                    state_reg <= 3'b011; //Go to T3 to take the high bits                   
                end
                
                
                
                else if(IROut[15:10] == 6'h13) //STR 
                begin //M[AR] <= Rx , for low bits 7:0 of Rx
                    RF_OutASel <= {1'b0, IROut[9:8]};
                    ALU_FunSel <= 5'b10000;//ALU out is OutA 's value
                    MuxCSel <= 1'b0; //ALUOut 7:0 bits are taken with MuxC
                    
                    Mem_WR <= 1'b1; //write mode active
                    Mem_CS <= 1'b0;                   
                    ARF_OutDSel <= 2'b10; // AR is at outD
                    
                    ARF_RegSel <=3'b101; //AR is enabled
                    ARF_FunSel <=3'b001; // Increment AR for writing high bits of Rx to memory in the next clock cycle
                    
                    state_reg <= 3'b011; //In T3 state the high bits of Rx will be taken
                end
                
                
               
               else if(IROut[15:10] == 6'h1E) //BX
               begin    //M[SP] <- PC
                ARF_OutCSel <= 2'b00; //PC at OutC
                MuxASel <= 2'b01; //ARF OutC selected
                RF_ScrSel <= 4'b0111; //S1 enabled
                RF_FunSel <= 3'b010; //Load applies
                
                RF_OutASel <=3'b100; //S1 is at OutA
                ALU_FunSel <= 5'b10000;
                
                state_reg <= 3'b011;//I take PC at ALUOut here, in T3 state i will write to memory the low bits of PC, and in T4 state i will write to memory the high bits 
               
               end
                 
                 
                 
                 
               else if(IROut[15:10] == 6'h1F) //BL  : PC <- M[SP]
               begin 
                Mem_WR <= 1'b0; //Read mode
                Mem_CS <= 1'b0;
                ARF_OutDSel <= 2'b11; //SP is at OutD
                
                MuxBSel <= 2'b10; //MemOut was selected 
                
                ARF_RegSel <= 3'b011; //PC enable
                ARF_FunSel <= 3'b101; //Only write low
                
                state_reg <= 3'b011; //Go T3 for writing PC's high bits 15:8 but before it , i will increment SP by one 
               
               
               end  
                 
                 
                 
               else if(IROut[15:10] == 6'h20) //LDRIM  :  Rx <- VALUE (VALUE defined in address bits)
               begin
                MuxASel <= 2'b11;
                
                case(IROut[9:8])
                2'b00: RF_RegSel <= 4'b0111; //R1 enabled
                2'b01: RF_RegSel <= 4'b1011; //R2 enabled
                2'b10: RF_RegSel <= 4'b1101;//R3 enabled
                2'b11: RF_RegSel <= 4'b1110;//R4 enabled
                endcase
               RF_FunSel <= 3'b100; //MSB 15:8 clear , 7:0 write low
               
               state_reg <=3'b000; //End of instruction
               
               end   
                 
                 
                 
                 
              else if(IROut[15:10]==6'h21)//STRIM : M[AR + OFFSET] <= Rx
              begin //AR <- AR + OFFSET
              ARF_OutCSel <= 2'b10; //AR is at OutC
              MuxASel <= 2'b01; //OutC is selected
              RF_ScrSel <= 4'b0111; //S1 enabled
              RF_FunSel <= 3'b010;
              RF_OutASel <= 3'b100; //S1 is at outA
              
              state_reg <= 3'b011; //Go to T3 state
              
              end 
                 
                 
                 
                
                     //The operations which uses only SREG1 and DSTREG for : DSTREG <- operation SREG1
               else if(IROut[15:10] ==6'h06 || IROut[15:10] == 6'h05)begin
                case(IROut[5:3])    //For SREG1
                    3'b000: ARF_RegSel <=3'b011;//PC enabled
                    3'b001: ARF_RegSel <=3'b011;//PC enabled
                    3'b010: ARF_RegSel <=3'b110; //SP enabled
                    3'b011: ARF_RegSel <=3'b101; //AR enabled
                    
                    3'b100: RF_RegSel <=4'b0111;//R1 enabled
                    3'b101: RF_RegSel <=4'b1011;//R2 enabled
                    3'b110: RF_RegSel <=4'b1101;//R3 enabled
                    3'b111: RF_RegSel <=4'b1110; //R4 enabled                  
                endcase
                
        
                
                    if(IROut[15:10]==6'h06)begin    //DEC
                  RF_FunSel <= 3'b000; //Decrement
                  ARF_FunSel <= 3'b000; //Decrement
                  RF_OutASel <= {1'b0, IROut[4:3]}; //Secilen register OutA'da
                  ALU_FunSel <= 5'b10000;
                  state_reg <= 3'b011;
                  end
                    if(IROut[15:10] == 6'h05)begin  //INC
                        RF_FunSel <= 3'b001; //Increment
                        ARF_FunSel <= 3'b001; //Increment
                        RF_OutASel <= {1'b0, IROut[4:3]}; //Secilen register OutA'da
                        ALU_FunSel <= 5'b10000;
                        state_reg <= 3'b011;
                    end                                           
 
 
               end
               
               
               
               else if(IROut[15:10] == 6'h07 || IROut[15:10] == 6'h08 || IROut[15:10] == 6'h09 || IROut[15:10] == 6'h0A || IROut[15:10] == 6'h0B || IROut[15:10] == 6'h0E)
               begin
               //SREG1 from RF
                 if(IROut[5] == 1)
                 begin
                    RF_OutASel<= {1'b0, IROut[4:3]};
                    state_reg <= 3'b011;
                    
                    
                      case(IROut[15:10])
                      6'h07: ALU_FunSel <= 5'b11011; //LSL A
                      6'h08: ALU_FunSel <= 5'b11100; //LSR A
                      6'h09: ALU_FunSel <= 5'b11101;//ASR A
                      6'h0A: ALU_FunSel <= 5'b11110; //CSL A
                      6'h0B: ALU_FunSel <= 5'b11111; //CSR A
                      6'h0E: ALU_FunSel <= 5'b10010; //NOT A
                      endcase                         
                  state_reg<= 3'b011;  
                    
                 end
               //SREG1 from ARF
                if(IROut[5] == 0)
                begin
                    case(IROut[4:3])
                    2'b00: ARF_OutCSel <= 2'b00;
                    2'b01: ARF_OutCSel <= 2'b00;
                    2'b10: ARF_OutCSel <= 2'b11;
                    2'b11: ARF_OutCSel <= 2'b10;   
                    endcase
                    MuxASel <= 2'b01;
                    RF_ScrSel <= 4'b0111; //S1 enabled
                    RF_FunSel <= 3'b010;
                    RF_OutASel <= 3'b100; //S1 out Ada
                    
                case(IROut[15:10])
                    6'h07: ALU_FunSel <= 5'b11011; //LSL A
                    6'h08: ALU_FunSel <= 5'b11100; //LSR A
                    6'h09: ALU_FunSel <= 5'b11101;//ASR A
                    6'h0A: ALU_FunSel <= 5'b11110; //CSL A
                    6'h0B: ALU_FunSel <= 5'b11111; //CSR A
                    6'h0E: ALU_FunSel <= 5'b10010; //NOT A
                   endcase                         
                    
                    //ALU Funsel zaten yukarda case ile secmistim
                    state_reg <= 3'b011;
                end
               
               state_reg <= 3'b011;
               end
               
               
               
               
               else if(IROut[15:10] == 6'h11 || IROut[15:10] == 6'h14) //MOVL and MOVH
               begin
                MuxASel <=2'b11; //Address bits are going to RF RSEL <- ADDRESS
                
                case(IROut[9:8])    //RSEL bits
                3'b00: RF_RegSel <=4'b0111;//R1 enabled
                3'b01: RF_RegSel <=4'b1011;//R2 enabled
                3'b10: RF_RegSel <=4'b1101;//R3 enabled
                3'b11: RF_RegSel <=4'b1110; //R4 enabled                  
                endcase               
                 
                    if(IROut[15:10] == 6'h14)
                    begin
                        RF_FunSel <= 3'b101; //Only write low
                        state_reg <= 3'b000;
                    end
                    
                    if(IROut[15:10] == 6'h11)
                    begin 
                        RF_FunSel <= 3'b110; //Only write high
                        state_reg <= 3'b000;
                    end
                    
                    
               end
               
  //The ones which uses SREG1
                else if(IROut[15:10] == 6'h0F || IROut[15:10] == 6'h0C ||IROut[15:10] == 6'h0D ||IROut[15:10] == 6'h10 ||IROut[15:10] == 6'h15 ||IROut[15:10] == 6'h16 ||IROut[15:10] == 6'h17 
                || IROut[15:10] == 6'h18 || IROut[15:10] == 6'h19 || IROut[15:10] == 6'h1A || IROut[15:10] == 6'h1B ||IROut[15:10] == 6'h1C ||IROut[15:10] == 6'h1D)
                begin
                //SREG1 from RF
                     if(IROut[5] == 1)
                     begin
                     //ALU_A<= SREG1
                     RF_OutASel <= {1'b0, IROut[4:3]};
                     state_reg <= 3'b011;
                     end
                     
 
                     
               //SREG1 from ARF
                     if(IROut[5]== 0) 
                     begin
                     case(IROut[4:3])
                         2'b00: ARF_OutCSel <= 2'b00; //ARF Output is PC
                         2'b01: ARF_OutCSel <= 2'b00;//ARF Output is PC
                         2'b10: ARF_OutCSel <= 2'b11;//ARF Output is SP
                         2'b11: ARF_OutCSel <= 2'b10;//ARF Output is AR               
                     endcase
                         MuxASel <= 2'b01; //OutC is selected
                         RF_ScrSel <= 4'b0111; //S1 enable
                         RF_FunSel <= 3'b010; // Load
                         RF_OutASel <= 3'b100; // S1 is selected.
                         state_reg <= 3'b011; //Continue at T3
                        
                     end
                     state_reg<=3'b011;
 
                end

                             
               
               
               
               else
                state_reg<=3'b011;                          
            end
            
  //T3 State
            3'b011: begin
            
                    if(IROut[15:10]==6'h00 || (IROut[15:10]==6'h01 && Flags[2]==0) || (IROut[15:10]==6'h02 && Flags[2]==1))
                    begin   //BRA
                    
                        MuxASel<=2'b01;
                        RF_ScrSel<=4'b1011; //Only S2 is enabled
                        RF_FunSel<=3'b010; //Load they are ready to perform at next cycle now
                        RF_OutBSel<=3'b101; //S2 is at OutB
                        ALU_FunSel<=5'b10100;
                        
                        state_reg<=3'b100; //bir sonrakine gec
                        end 
                        
                        
                        
                    else if(IROut[15:10]==6'h03)//POP
                    begin
                        //Rx<-M[SP] for the low bits of Rx
                        ARF_OutDSel <= 2'b11; //SP is selected at OutD
                        Mem_WR <=1'b0;//Read is active
                        Mem_CS <= 1'b0; //chip enable
                        MuxASel <=2'b10; //Memory output
                        case(IROut[9:8])//Rx
                            2'b00: RF_RegSel <= 4'b0111; //R1 enable
                            2'b01: RF_RegSel <= 4'b1011; //R2 enable
                            2'b10: RF_RegSel <= 4'b1101; //R3 enable
                            2'b11: RF_RegSel <= 4'b1110; //R4 enable
                        endcase
                        RF_FunSel <= 3'b101; //Only write low 
                        
                        ARF_RegSel <=3'b110;//SP enable
                        ARF_FunSel <=3'b001;//Increment SP
                        state_reg<=3'b100; //Go to T4 for writing Rx's high bits 15:8
                    end    
                    
                    
                    
                    
                else if(IROut[15:10] == 6'h04)//PSH
                    begin
                        //M[SP] <= Rx , for Rx's high bits 
                        RF_OutASel <= {1'b0, IROut[9:8]}; //Rx selected due to RSEL in instruction
                        ALU_FunSel <= 5'b10000;
                        
                        ARF_OutDSel <=2'b11; //OutD is SP
                        MuxCSel <= 2'b1; //ALU out[15:8]
                        Mem_WR <= 1'b1; //Write
                        Mem_CS <= 1'b0;
                        
                        //SP <- SP-1
                        ARF_RegSel <= 3'b110; //SP enable
                        ARF_FunSel <= 3'b000; //SP decrement
                        
                        state_reg <= 3'b000; //end of instruction
                        
                    end
                    
                        
                  
                    
                    else if(IROut[15:10] == 6'h12)// LDR
                    begin //Rx <- M[AR](this is for high bits)
                        ARF_OutDSel <= 2'b10;//AR is at OutD
                        Mem_WR <= 1'b0; //Memory read mode
                        Mem_CS <= 1'b0; //chip selected ?
                        MuxASel <= 2'b10; //Memory output
                        case(IROut[9:8])//Rx
                          2'b00: RF_RegSel <= 4'b0111; //R1 enable
                          2'b01: RF_RegSel <= 4'b1011; //R2 enable
                          2'b10: RF_RegSel <= 4'b1101; //R3 enable
                          2'b11: RF_RegSel <= 4'b1110; //R4 enable
                        endcase
                        RF_FunSel <= 3'b110; //Only write high
                        ARF_RegSel <=3'b111; //All are disabled
           
                        
                        state_reg <= 3'b000; //End of instruction
                        
                    end
                    
                    
                    
                    
                   else if(IROut[15:10] == 6'h13) //STR 
                    begin //M[AR] <= Rx , for high bits 15:8 of Rx
                        RF_OutASel <= {1'b0, IROut[9:8]};
                        ALU_FunSel <= 5'b10000;//ALU out is OutA 's value
                        MuxCSel <= 1'b1; //ALUOut 15:8 bits are taken with MuxC
                        
                        Mem_WR <= 1'b1; //write mode active
                        Mem_CS <= 1'b0;                   
                        ARF_OutDSel <= 2'b10; // AR is at outD
                        
                        ARF_RegSel <=3'b111; //ALL of them are disabled
                        
                        state_reg <= 3'b000; //End of instruction
                    end

                    
                    
                   else if(IROut[15:10] == 6'h1E) //BX 
                   begin //M[SP] <- PC
                    MuxCSel <= 1'b0; //Low bits of PC 7:0
                    ARF_OutDSel <= 2'b11; //SP at OutD
                    Mem_WR <= 1'b1; //Write mode active
                    Mem_CS <= 1'b0;
                    
                    ARF_RegSel <= 3'b110; //SP enable
                    ARF_FunSel <=3'b001; //SP increment for next cycle high bits 15:8
                    
                    state_reg <=3'b100; //Go to state T4 for having high bits in the memory                                 
                   end                   
                    
                    
               
            
                  else if(IROut[15:10] == 6'h1F) //BL  : PC <- M[SP]
                   begin 
                    ARF_RegSel <= 3'b110; //SP enabled
                    ARF_FunSel <= 3'b001; //Increment
                    
                    state_reg <= 3'b100; //Go to T4 for having the high bits of PC
                   
                   end  
                   
                   
                   
                   else if(IROut[15:10]==6'h21)//STRIM : M[AR + OFFSET] <= Rx
                   begin
                   MuxASel<= 2'b11; //Address bits OFFSET
                   RF_ScrSel <= 4'b1011; //S2 enable
                   RF_FunSel <= 3'b010; //Load
                   RF_OutBSel <= 3'b101; // OutB S2
                   
                   state_reg <= 3'b100;
                   end
                                    
            
            
                    
                        
                     else if(IROut[15:10] ==6'h06 || IROut[15:10] == 6'h05 ) //INC and DEC
                     begin //DEC
                       // ARF_FunSel <= 3'b000;  //Decrement will be applied wether SREG1 is selected from ARF or RF registers
                       // RF_FunSel <=3'b000;
                      //  RF_OutASel <= {1'b0, IROut[4:3]}; //Secilen register OutA'da
                      //  ALU_FunSel <= 5'b10000;
                        
                        if(IROut[8]== 1 && IROut[5] == 1) //DSTREG is from RF, SREG1 is from RF
                            begin
                                MuxASel<= 2'b00; //ALU Out was selected
                                case(IROut[8:6])
                                3'b100: RF_RegSel <=4'b0111;//R1 enabled
                                3'b101: RF_RegSel <=4'b1011;//R2 enabled
                                3'b110: RF_RegSel <=4'b1101;//R3 enabled
                                3'b111: RF_RegSel <=4'b1110; //R4 enabled                  
                             endcase
                             RF_FunSel <= 3'b010; //Load
                        end
                        if(IROut[8] == 0 && IROut[5] == 1) //DSTREG is from ARF, SREG1 is from RF
                        begin
                            MuxBSel <=2'b00;
                            
                             case(IROut[8:6])
                             3'b000: ARF_RegSel <=3'b011;//PC enabled
                             3'b001: ARF_RegSel <=3'b011;//PC enabled
                             3'b010: ARF_RegSel <=3'b110; //SP enabled
                             3'b011: ARF_RegSel <=3'b101; //AR enabled
                            endcase
                            ARF_FunSel <= 3'b010; // Load
                        end
                        
                        if(IROut[8]== 1 && IROut[5] == 0)//DSTREG is from RF, SREG1 is from ARF
                        begin 
                            MuxASel<=2'b01; //OutC was selected
                            
                             case(IROut[8:6])
                              3'b100: RF_RegSel <=4'b0111;//R1 enabled
                              3'b101: RF_RegSel <=4'b1011;//R2 enabled
                              3'b110: RF_RegSel <=4'b1101;//R3 enabled
                              3'b111: RF_RegSel <=4'b1110; //R4 enabled                  
                             endcase
                         RF_FunSel <= 3'b010; //Load                            
                        end
                        
                        if(IROut[8]== 0 && IROut[5] == 0) //DSTERG from ARF, SREG1 from ARF
                        begin
                            MuxBSel <=2'b01;
                            
                           case(IROut[8:6])
                            3'b000: ARF_RegSel <=3'b011;//PC enabled
                            3'b001: ARF_RegSel <=3'b011;//PC enabled
                            3'b010: ARF_RegSel <=3'b110; //SP enabled
                            3'b011: ARF_RegSel <=3'b101; //AR enabled
                           endcase
                           ARF_FunSel <= 3'b010; // Load                                                     
                        end
                        
                        state_reg <=3'b000; // sc zeroed
                    end
                    
                    
                   else if(IROut[15:10] == 6'h07 || IROut[15:10] == 6'h08 || IROut[15:10] == 6'h09 || IROut[15:10] == 6'h0A || IROut[15:10] == 6'h0B || IROut[15:10] == 6'h0E)
                   begin
                   //DSTREG from RF
                    if(IROut[8] == 1)
                    begin
                        MuxASel <= 2'b00;
                        case(IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111;//R1 enable
                        2'b01: RF_RegSel <= 4'b1011;//R2
                        2'b10: RF_RegSel <= 4'b1101;//R3
                        2'b11: RF_RegSel <= 4'b1110;//R4
                        endcase
                        RF_FunSel <= 3'b010; //Load 
                        state_reg <= 3'b000;                      
                    end
                   //DSTREG from ARF
                  if(IROut[8] == 0)
                   begin
                   MuxBSel <= 2'b00;
                   case(IROut[7:6])
                   2'b00: ARF_RegSel <= 4'b011;//PC enable
                   2'b01: ARF_RegSel <= 4'b011;//PC
                   2'b10: ARF_RegSel <= 4'b110;//SP
                   2'b11: ARF_RegSel <= 4'b101;//AR                   
                   endcase
                   ARF_FunSel <= 3'b010; //Load
                   
                   end
                   state_reg <= 3'b000;
                   
                  end 
                    
                    
                    
                    
                    
                    
                    
                    
 //SREG2's will be selected here in T3                    
                    else if(IROut[15:10] == 6'h0F || IROut[15:10] == 6'h0C ||IROut[15:10] == 6'h0D ||IROut[15:10] == 6'h10 ||IROut[15:10] == 6'h15 ||IROut[15:10] == 6'h16 ||IROut[15:10] == 6'h17 
                            || IROut[15:10] == 6'h18 || IROut[15:10] == 6'h19 || IROut[15:10] == 6'h1A || IROut[15:10] == 6'h1B ||IROut[15:10] == 6'h1C ||IROut[15:10] == 6'h1D)//Burada sreg operasyonlar?
                    begin  //If SREG2 is from ARF
                          if(IROut[2] == 0)  
                          begin
                          case(IROut[1:0])
                            2'b00: ARF_OutCSel <= 2'b00; //ARF Output is PC
                            2'b01: ARF_OutCSel <= 2'b00;//ARF Output is PC
                            2'b10: ARF_OutCSel <= 2'b11;//ARF Output is SP
                            2'b11: ARF_OutCSel <= 2'b10;//ARF Output is AR
                          endcase
                          
                            MuxASel <= 2'b01; //OutC was selected
                            RF_FunSel <=3'b010; //Load
                            RF_ScrSel <=4'b1011;//S2 is enabled
                            RF_OutBSel<=3'b101;//OutB is S2
                          
                            state_reg <= 3'b100; //Operation will be at T4                          
                          end
                        //if SREG2 is from RF
                          if(IROut[2]== 1)
                          begin
                          //ALU_B <- SREG2
                            RF_OutBSel <={1'b0, IROut[1:0]};
                            
                            state_reg <= 3'b100; //Operation will be at T4
                          end
                          
                      state_reg <=3'b100; //T4'e ge ti
                    
                        
                    end
                                              
                       //Next comes here 
                    else
                        state_reg<=3'b100;             
               
            end            
            
                     
           
            3'b100: begin // T4 state
                    
                    if(IROut[15:10]==6'h00 || (IROut[15:10]==6'h01 && Flags[2]==0) || (IROut[15:10]==6'h02 && Flags[2]==1))
                    begin
                    
                        RF_ScrSel <=4'b0011; //s1 and s2 enabled
                        RF_FunSel<= 3'b011; //zero the used registers
                        MuxBSel<= 2'b00; //Select ALU Out to load into PC
                        ARF_RegSel<=3'b011; //PC enable
                        ARF_FunSel<=3'b010; //LOAD                    
                        state_reg <= 3'b000; //Resetted
                    end
                    
                    
                   else if(IROut[15:10]==6'h03)//POP
                    begin
                        //Rx<-M[SP] for the high bits of Rx
                        ARF_OutDSel <= 2'b11; //SP is selected at OutD
                        Mem_WR <=1'b0;//Read is active
                        Mem_CS <= 1'b0; //chip enable
                        MuxASel <=2'b10; //Memory output
                        case(IROut[9:8])//Rx
                            2'b00: RF_RegSel <= 4'b0111; //R1 enable
                            2'b01: RF_RegSel <= 4'b1011; //R2 enable
                            2'b10: RF_RegSel <= 4'b1101; //R3 enable
                            2'b11: RF_RegSel <= 4'b1110; //R4 enable
                        endcase
                        RF_FunSel <= 3'b110; //Only write high
                        state_reg<=3'b000; //Instruction ended
                    end   
                    
                    
                    
                   else if(IROut[15:10] == 6'h1E) //BX 
                   begin //M[SP] <- PC
                        MuxCSel <= 1'b1; //Hig bits of PC 15:8
                        ARF_OutDSel <= 2'b11; //SP at OutD
                        Mem_WR <= 1'b1; //Write mode active
                        Mem_CS <= 1'b0;
                     
                        ARF_RegSel <= 3'b111; //disable all
                     
                        state_reg <=3'b101; //Go to state T5 to perform PC <- Rx                                 
                    end                   
                    
                    
                    
               else if(IROut[15:10] == 6'h1F) //BL  : PC <- M[SP]
                    begin //Write high bits of PC , info comes from M[SP]
                     Mem_WR <= 1'b0; //Read mode
                     Mem_CS <= 1'b0;
                     ARF_OutDSel <= 2'b11; //SP is at OutD
                     
                     MuxBSel <= 2'b10; //MemOut was selected 
                     
                     ARF_RegSel <= 3'b011; //PC enable
                     ARF_FunSel <= 3'b110; //Only write high
                     
                     state_reg <= 3'b000; //End of instruction
                    
                    
                    end  
                    
                    
                 else if(IROut[15:10]==6'h21)//STRIM : M[AR + OFFSET] <= Rx
                 begin
                 ALU_FunSel <= 5'b10100; //ADD
                 MuxBSel <= 2'b00; //ALU selected
                 ARF_RegSel <= 3'b101; //AR enable
                 ARF_FunSel <= 3'b010; //Load
                 
                 state_reg <= 3'b101;//GO to T5
                 
                 end
                                
                   
                   
                   
 //For DSTREG
    else if(IROut[15:10] == 6'h0F || IROut[15:10] == 6'h0C ||IROut[15:10] == 6'h0D ||IROut[15:10] == 6'h10 ||IROut[15:10] == 6'h15 ||IROut[15:10] == 6'h16 ||IROut[15:10] == 6'h17 
    || IROut[15:10] == 6'h18 || IROut[15:10] == 6'h19 || IROut[15:10] == 6'h1A || IROut[15:10] == 6'h1B ||IROut[15:10] == 6'h1C ||IROut[15:10] == 6'h1D) //SREG operasyonlar 
    begin
         case(IROut[15:10])
                  6'h0C: ALU_FunSel <= 5'b10111; //AND
                  6'h0D: ALU_FunSel <= 5'b11000; //OR 
                  6'h0E: ALU_FunSel <= 5'b10010; //NOT
                  6'h0F: ALU_FunSel <= 5'b11001; //XOR
                  6'h10: ALU_FunSel <= 5'b11010; //NAND
                  6'h15: ALU_FunSel <= 5'b10100; //ADD
                  6'h16: ALU_FunSel <= 5'b10101; //ADC
                  6'h17: ALU_FunSel <= 5'b10110; //SUB 
                  6'h18: begin 
                  ALU_FunSel <= 5'b10000; //MOVS
                  S <=1'b1;
                  end
                  6'h19: begin 
                  ALU_FunSel <= 5'b10100; //ADDS
                  S <=1'b1;
                  end
                  6'h1A: begin
                  ALU_FunSel <= 5'b10110; //SUBS
                  S <=1'b1;
                  end
                  6'h1B: begin 
                  ALU_FunSel <= 5'b10111; //ANDS
                  S <=1'b1;
                  end
                  6'h1C: begin 
                  ALU_FunSel <= 5'b11000; //ORRS
                  S <=1'b1;
                  end
                  6'h1D: begin 
                  ALU_FunSel <= 5'B11001; //XORS
                  S <=1'b1;
                  end
                 endcase
    
    
       //DSTREG is for ARF 
                 if(IROut[8] == 0)
                 begin
                    MuxBSel <= 2'b00; //ALUOut was seleced
                    case(IROut[7:6])
                    2'b00: ARF_RegSel<= 3'b011; //PC enable
                    2'b01: ARF_RegSel<= 3'b011; //PC enable
                    2'b10: ARF_RegSel<= 3'b110; //SP enable
                    2'b11: ARF_RegSel<= 3'b101; //AR enable                 
                    endcase
                    
                    ARF_FunSel <=3'b010;    //The value at ALU out now being loaded to selected ARF Register
                    state_reg <= 3'b000;                
                 end
                 
                 
       //DSTREG is for RF
                if(IROut[8]== 1)
                begin
                    MuxASel <= 2'b00; //ALUOut is selected
                    
                    case(IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111; //R1 enabled
                        2'b01: RF_RegSel <= 4'b1011;//R2 enabled
                        2'b10: RF_RegSel <= 4'b1101;//R3 enabled
                        2'b11: RF_RegSel <= 4'b1110;//R4 enabled                
                    endcase
                    RF_FunSel <= 3'b010; //Load
                    
                    state_reg <= 3'b000; //end of instruction
                
                end          
                 
 state_reg <= 3'b000; //End of instruction
 end
                                                            
                    else
                        state_reg <=3'b101;
                
                    end
                    
                    
           3'b101: begin // T5 state
           
                if(IROut[15:10] == 6'h1E) //BX 
                begin
                    //PC <- Rx
                    RF_OutASel <= {1'b0, IROut[9:8]};
                    ALU_FunSel <= 5'b10000;
                    
                    MuxBSel <= 2'b00; //ALU Out is selected by Mux B
                    ARF_RegSel <= 3'b011; //PC enabled
                    ARF_FunSel<= 3'b010; //Load
                    
                    state_reg <= 3'b000; //End of instruction, SC is zero
                
                end
                
                    else if(IROut[15:10]==6'h21)//STRIM : M[AR + OFFSET] <= Rx
                    begin
                        RF_OutASel <= {1'b0, IROut[9:8]};
                        ALU_FunSel <= 5'b10000; //OutA is at ALUOut
                        MuxCSel <= 1'b0; //low bits are selected
                        Mem_WR <= 1'b1; //Write mode 
                        Mem_CS <= 1'b0;
                        ARF_OutDSel <= 2'b10; //AR is at OutD
                
                        ARF_RegSel <= 3'b101; //AR enabled
                        ARF_FunSel <= 3'b001; //Increment
                
                        state_reg <= 3'b110; //Go to T6 for having the high bits           
                    end          
           
           
           else
           
            state_reg <= 3'b110;//Go to T6
          end
           
           
            
            
            3'b110: begin // T6 state
            
            
                        if(IROut[15:10]==6'h21)//STRIM : M[AR + OFFSET] <= Rx
                        begin
                            RF_OutASel <= {1'b0, IROut[9:8]};
                            ALU_FunSel <= 5'b10000; //OutA is at ALUOut
                            MuxCSel <= 1'b1; //high bits are selected
                            Mem_WR <= 1'b1; //Write mode 
                            Mem_CS <= 1'b0;
                            ARF_OutDSel <= 2'b10; //AR is at OutD
            
                            ARF_RegSel <= 3'b111; //all are disabled
            
                            state_reg <= 3'b000; //End of Instrction
            
                    end    
            
            else
            state_reg <= 3'b111;//Go to T7
            end
                  
            
            3'b111: begin // T7 state
            state_reg <= 3'b000; //Go to T0
            end
        endcase
        
    end
end
  


assign ALU_WF= S;

   
endmodule



//Decoder for 3 bit for timing signals 
module decoderForTime(enable,Input,Output);
    input wire enable;
    input wire [2:0] Input;
    output reg [7:0] Output;
    
    always @(*)
    begin
        if(enable) begin
        case(Input) //It decodes as making the Tth bit 1. so that
            3'h0 : Output = 8'b00000001;   //T0
            3'h1 : Output = 8'b00000010;//T1
            3'h2 : Output = 8'b00000100;//T2
            3'h3 : Output = 8'b00001000;//T3
            3'h4 : Output = 8'b00010000;//T4
            3'h5 : Output = 8'b00100000;//T5
            3'h6 : Output = 8'b01000000;//T6
            3'h7 : Output = 8'b10000000;//T7
            default : Output = 8'b00000000;
        endcase
        end
        else
        begin
            Output = 8'b00000000;
        end
    end
endmodule



