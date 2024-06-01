`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Irem Kalay
// 
// Create Date: 30.03.2024 15:19:15
// Design Name: 
// Module Name: ArithmeticLogicUnit
// Project Name: Project 1
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



module ArithmeticLogicUnit(
    input wire [15:0] A,         
    input wire [15:0] B,         
    input wire [4:0] FunSel,     
    input wire WF,               
    input wire Clock,            
    output reg [15:0] ALUOut,    
    output reg [3:0] FlagsOut   
);

    reg  carry;
    reg  of;
    
    always @(*) begin
            
            //Conditions for FunSel from the table given
            case (FunSel)
            
                5'b00000: begin// Pass B (8-bit) to ALUOut
                            ALUOut[15:8]<={8'd0}; //Make the MSB bits zero first
                            ALUOut[7:0] <= A[7:0];
                            carry=FlagsOut[2];//To hold prev carry
                            of=FlagsOut[0]; //To hold prev O     
                          end
                          
                5'b00001: begin // Pass B (8-bit) to ALUOut
                            ALUOut[15:8]<={8'd0}; //Make the MSB bits zero first
                            ALUOut[7:0] <= B[7:0];
                            carry=FlagsOut[2];//To hold prev carry
                            of=FlagsOut[0]; //To hold prev O 
                          end
                5'b00010: begin // NOT A (8-bit)
                            ALUOut[15:8]<={8'd0}; //Make the MSB bits zero first
                            ALUOut[7:0] <= ~A[7:0]; 
                            carry=FlagsOut[2];
                            of=FlagsOut[0]; //To hold prev O 
                          end
                     
                5'b00011: begin// NOT B (8-bit)
                            ALUOut[15:8]<={8'd0}; //Make the MSB bits zero first
                            ALUOut[7:0] <= ~B[7:0]; 
                            carry=FlagsOut[2];
                            of=FlagsOut[0]; //To hold prev O 
                          end
                5'b00100: begin // A + B (8-bit)
                     ALUOut[15:8]<={8'd0}; //Make the MSB bits zero first
                    {carry, ALUOut[7:0]} <= A[7:0] + B[7:0]; // Sum with carry
                     of = ((~A[7]) & (~B[7]) & ALUOut[7]) | (A[7] & B[7] & (~ALUOut[7])); //Detect if there is overflow             
                        end
                        
                5'b00101: begin // A + B + Carry (8-bit)
                        ALUOut[15:8]<={8'd0}; //Make the MSB bits zero first
                        {carry, ALUOut[7:0]} <= A[7:0] + B[7:0] + FlagsOut[2]; // Sum with carry in
                        of = ((~A[7]) & (~B[7]) & ALUOut[7]) | (A[7] & B[7] & (~ALUOut[7])); //Detect if there is overflow
                        end
                        
                5'b00110:begin// A - B (8-bit
                        ALUOut[15:8]<={8'd0}; //Make the MSB bits zero first
                    {carry, ALUOut[7:0]} <= A[7:0] - B[7:0]; 
                    of = ((A[7] != B[7]) && (A[7] != ALUOut[7]));
                        end
                        
                5'b00111:begin// AND (8-bit)
                        ALUOut[15:8]<={8'd0}; //Make the MSB bits zero first
                        ALUOut[7:0] <= A[7:0] & B[7:0]; 
                        carry=FlagsOut[2];
                        of=FlagsOut[0]; //To hold prev O 
                        end
                        
                5'b01000: begin// OR (8-bit)
                            ALUOut[15:8]<={8'd0}; //Make the MSB bits zero first
                            ALUOut[7:0] <= A[7:0] | B[7:0]; 
                            carry=FlagsOut[2];
                            of=FlagsOut[0]; //To hold prev O 
                          end
                          
                5'b01001: begin //XOR (8-bit)
                            ALUOut[15:8]<={8'd0}; //Make the MSB bits zero first
                            ALUOut[7:0] <= A[7:0] ^ B[7:0];
                            of=FlagsOut[0]; //To hold prev O
                            carry=FlagsOut[2];
                          end
                          
                5'b01010: begin // NAND (8-bit)
                            ALUOut[15:8]<={8'd0}; //Make the MSB bits zero first
                            ALUOut[7:0] <= ~(A[7:0] & B[7:0]); 
                            carry=FlagsOut[2];
                           of=FlagsOut[0]; //To hold prev O 
                          end
                          
                5'b01011: begin // LSL A (8-bit)
                    ALUOut[15:8]<={8'd0}; //Make the MSB bits zero first
                    ALUOut[7:0] <= {A[6:0], 1'b0};
                    carry= A[7];
                    of=FlagsOut[0]; //To hold prev O
                end
    
                5'b01100: begin // LSR A (8-bit)
                    ALUOut[15:8]<={8'd0}; //Make the MSB bits zero first
                    ALUOut[7:0] <= {1'b0, A[7:1]};
                    carry = A[0];    
                    of=FlagsOut[0]; //To hold prev O               
                end
                
                5'b01101: begin// ASR A (8-bit)
                            ALUOut[15:8]<={8'd0}; //Make the MSB bits zero first
                            ALUOut[7:0] <= {A[7], A[7:1]};
                            carry= A[0];
                            of=FlagsOut[0]; //To hold prev O
                          end
                5'b01110:   begin   //CSL A
                    ALUOut[15:8]<={8'd0}; //Make the MSB bits zero first
                    ALUOut[7:0] <= {A[6:0], FlagsOut[2]};
                    carry = A[7]; 
                    of=FlagsOut[0]; //To hold prev O
                end
                
                5'b01111:  begin    //CSR A
                    ALUOut[15:8]<={8'd0}; //Make the MSB bits zero first
                    ALUOut[7:0] <= {FlagsOut[2], A[7:1]};
                    carry = A[0];
                    of=FlagsOut[0]; //To hold prev O 
                end
                
//Start of 16 bits                
               
                5'b10000: begin
                            ALUOut <= A; // Pass-through A (16-bit)
                            carry=FlagsOut[2];
                            of=FlagsOut[0]; //To hold prev O                           
                            end
                            
                5'b10001:begin
                            ALUOut <= B; // Pass-through B (16-bit)
                            carry=FlagsOut[2];
                            of=FlagsOut[0]; //To hold prev O 
                         end
                5'b10010: begin
                            ALUOut <= ~A; // NOT A (16-bit)
                            carry=FlagsOut[2];
                            of=FlagsOut[0]; //To hold prev O 
                            end
                5'b10011: begin
                            ALUOut <= ~B; // NOT B (16-bit)
                            carry=FlagsOut[2];
                            of=FlagsOut[0]; //To hold prev O 
                            end
                            
                5'b10100: begin // A + B (16-bit)
                    {carry, ALUOut} = A + B; // Corrected variable name
                    of = ((~A[15]) & (~B[15]) & ALUOut[15]) | (A[15] & B[15] & (~ALUOut[15]));
                    
                end


                5'b10101: begin // A + B + Carry (16-bit)
           
                    {carry, ALUOut} <= A + B + FlagsOut[2]; // Perform the addition with carry-in
                     of = ((~A[15]) & (~B[15]) & ALUOut[15]) | (A[15] & B[15] & (~ALUOut[15]));
                end

                5'b10110:begin // A - B (16-bit)
                       {carry, ALUOut[15:0]} <= A[15:0] - B[15:0]; 
                       of = ((A[15] != B[15]) && (A[15] != ALUOut[15]));
                 end
                 
                5'b10111: begin // AND (16-bit)
                            ALUOut <= A & B;
                            carry=FlagsOut[2];
                            of=FlagsOut[0]; //To hold prev O 
                          end
                          
                5'b11000: begin// OR (16-bit)
                            ALUOut <= A | B;
                            carry=FlagsOut[2];
                            of=FlagsOut[0]; //To hold prev O 
                          end
                5'b11001: begin // XOR (16-bit)
                             ALUOut <= A ^ B; 
                             carry=FlagsOut[2];
                             of=FlagsOut[0]; //To hold prev O 
                             end
                5'b11010: begin //NAND 16 bit
                            ALUOut <= ~(A & B);
                            carry=FlagsOut[2];
                            of=FlagsOut[0]; //To hold prev O 
                          end
                
                5'b11011: begin // LSL A (16-bit)
                    ALUOut[15:0] <= {A[14:0], 1'b0};
                    carry= A[15];
                    of=FlagsOut[0];
                end
                
                5'b11100: begin // LSR A (16-bit)
                    ALUOut[15:0] <= {1'b0, A[15:1]};
                    carry = A[0];
                    of=FlagsOut[0];                   
                end
                
                5'b11101: begin // ASR A (16-bit)
                          ALUOut[15:0] <= {A[15], A[15:1]};
                          carry= A[0];
                          of=FlagsOut[0];   //To hold the prev Overflow
                end
                
                5'b11110:begin  // CSL A (16-bit)
                            ALUOut[15:0] <= {A[14:0], FlagsOut[2]};
                            carry = A[15];
                            of=FlagsOut[0];
                         end
                            
                5'b11111: begin
                   // CSR A (16-bit)
                    ALUOut[15:0] <= {FlagsOut[2], A[15:1]};
                          carry = A[0];  
                          of=FlagsOut[0];             
                        end
    
            endcase
            end
            
            always @(posedge Clock) begin
                //Assigning overflow and carry to the flags 
            if(WF)begin //Kontrol?
                FlagsOut[0]=of;
                FlagsOut[2]= carry;
            
             // Controlling Being Negative
            if(FunSel!= 5'b01101 && FunSel!= 5'b11101)
            begin
                if(FunSel[4]==0)  
                    FlagsOut[1]=ALUOut[7];
                else FlagsOut[1] = ALUOut[15];
            end
            //Controlling Being Zero                           
             if(ALUOut == 0) 
                   FlagsOut[3]=1; 
                else FlagsOut[3]=0;      
            end
        end
        endmodule