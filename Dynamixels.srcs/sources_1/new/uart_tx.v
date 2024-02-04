module uart_tx#(
   parameter CYCLES_PER_BIT = 100 // Value - Clock cycles per received bit
)(
   input i_Clk,                 // Clock - 100 MHz
   input i_Rst,                 // Reset - Control signal
   input i_TxStart,             // Signal - Input to start transmission
   input [7:0] i_TxData,        // Value - 8 Bit data to be sent
   input i_Enable,
   input [31:0] i_Delay,        //Valor delay que viene del módulo delay
   output reg o_TxActive,       // Signal - Marks activity of transmission sequence
   output reg o_TxDone,
   output reg o_TxData          // Signal - Pin on which the transmission takes place
);
 
//////////////////////////////////###PARAMETERS/REGISTERS###///////////////////////////////////
localparam IDLE = 3'b000;       // Parameters for state machine
localparam START_BIT = 3'b001;
localparam DATA_BITS = 3'b010;
localparam STOP_BIT = 3'b011;
localparam RESET = 3'b100;
//-------------------------------------------------------------------------------------------//                            
reg [$clog2(CYCLES_PER_BIT)-1:0] r_ClkCounter;    // Register to count to clks-per-bit according to defined baudrate
reg [2:0] r_BitsIndex;                          // Register to count transmitted data bits
reg [2:0] r_StateMachine;                       // Register for state machine
reg [7:0] r_TxData;
reg [31:0] r_Delay;
reg r_First;
///////////////////////////////////////////////////////////////////////////////////////////////


always @(posedge i_Clk or posedge i_Rst)    
  begin
    if (i_Rst) 
      begin        
        r_StateMachine <= RESET;
        o_TxDone <= 0;
        r_ClkCounter <= 0;
        r_BitsIndex <= 0;
        r_TxData <= 0;
        r_Delay <= 0;
        r_First <= 0;
      end
    else
      begin
        if (i_Enable) begin
            case (r_StateMachine)   
              IDLE:                
                begin
                  o_TxData <= 1;       
                  r_ClkCounter <= 0;   
                  r_BitsIndex <= 0;     
                  if (i_TxStart == 1 && o_TxActive == 0)   
                    begin     
                      if (r_Delay < i_Delay && r_First==0) begin
                        r_Delay <= r_Delay + 1;
                      end else begin
                        o_TxActive <= 1;
                        r_First <= 1;             
                        r_TxData <= i_TxData;         
                        r_StateMachine <= START_BIT;
                      end                 
                                             
                    end
                  else
                    r_StateMachine <= IDLE;         
                end
              START_BIT :           
                begin
                  o_TxData <= 0;    
                  if (r_ClkCounter < CYCLES_PER_BIT-1) 
                    begin
                      r_ClkCounter <= r_ClkCounter + 1; 
                      r_StateMachine <= START_BIT;      
                    end                                
                  else
                    begin
                      r_ClkCounter <= 0;                
                      r_StateMachine <= DATA_BITS;      
                    end
                end    
              DATA_BITS:            
                begin
                  o_TxData <= r_TxData[r_BitsIndex];    
                  if (r_ClkCounter < CYCLES_PER_BIT-1)  
                    begin
                      r_ClkCounter <= r_ClkCounter + 1; 
                      r_StateMachine <= DATA_BITS;      
                    end                                 
                  else  
                    begin
                      r_ClkCounter <= 0;                   
                      if (r_BitsIndex < 7)                  
                        begin
                          r_BitsIndex <= r_BitsIndex + 1;  
                          r_StateMachine <= DATA_BITS;      
                        end                                 
                      else
                        begin
                          r_BitsIndex <= 0;                 
                          r_StateMachine <= STOP_BIT;       
                        end 
                    end 
                end
              STOP_BIT:         
                begin
                  o_TxData <= 1;                        
                  if (r_ClkCounter < CYCLES_PER_BIT-1)  
                    begin
                      r_ClkCounter <= r_ClkCounter + 1; 
                      r_StateMachine <= STOP_BIT;       
                    end                                 
                  else
                    begin
                      r_ClkCounter <= 0;                
                      o_TxDone <= 1;
                      r_StateMachine <= RESET;         
                    end 
                end
              RESET:               
                begin  
                  o_TxDone <= 0;
                  o_TxActive <= 0;                  
                  r_StateMachine <= IDLE;               
                end
              default :
                r_StateMachine <= IDLE;                 
              endcase
        end else begin
            r_StateMachine <= RESET;
            o_TxDone <= 0;
            r_ClkCounter <= 0;
            r_BitsIndex <= 0;
            r_TxData <= 0;  
            r_First <= 0;
            r_Delay <= 0;
        end
        
      end
  end 
  
endmodule
