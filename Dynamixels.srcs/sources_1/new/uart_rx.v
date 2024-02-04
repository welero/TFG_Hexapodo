module uart_rx#(
   parameter CYCLES_PER_BIT = 100 // Value - Clock cycles per received bit
)(
   input i_Clk,                 // Clock - 100 MHz
   input i_Rst,                 // Reset - Control signal
   input i_UartRx,              // Signal - Input uart signal from predefined pin
   input i_Enable,
   output reg o_RxDone,         // Signal - Output control signal for successful data reception
   output reg [7:0] o_RxData    // Value - Output 8 bit uart signal 
);

//////////////////////////////////###PARAMETERS/REGISTERS###///////////////////////////////////
localparam IDLE = 3'b000;           // Parameters for state machine 
localparam START_BIT = 3'b001;
localparam DATA_BITS = 3'b010;
localparam STOP_BIT = 3'b011;
localparam RESET = 3'b100;
//-------------------------------------------------------------------------------------------//  
reg [$clog2(CYCLES_PER_BIT)-1:0] r_ClkCounter;  // Register to count to clks-per-bit according to defined baudrate
reg [2:0] r_BitsIndex;                          // Register to count received data bits
reg [2:0] r_StateMachine;                       // Register for state machine
///////////////////////////////////////////////////////////////////////////////////////////////

always @(posedge i_Clk or posedge i_Rst) // Everytime the event inside the brackets occurs the following lines are executed
  begin
    if (i_Rst)         // Check if reset is pressed
      begin
        // This module uses a state machine to organize the data reception
        r_StateMachine <= RESET;   // Reset state machine 
        o_RxDone <= 0;         // Reset data-reception control signal
        r_BitsIndex <= 0;
        r_ClkCounter <= 0;
        o_RxDone <= 0;
        o_RxData <= 0;
      end
    else
      begin
        if (!i_Enable) begin
            case (r_StateMachine)   // Check state machine
              IDLE:                 // If status IDLE
                begin
                  o_RxDone <= 0;    // Reset all values and wait for next data reception
                  r_ClkCounter <= 0;
                  r_BitsIndex <= 0;
                  if (i_UartRx == 0)                // If start bit detected, change state machine status to START_BIT
                    r_StateMachine <= START_BIT;
                  else                              // Else stay in IDLE state
                    r_StateMachine <= IDLE;
                  end   
               START_BIT:   // If status START_BIT
                 begin
                   if (r_ClkCounter == (CYCLES_PER_BIT-1)/2)// Make sure start bit is detected by looking in the middle of the clks-per-bit counter
                     begin
                       if (i_UartRx == 0)                   // If start bit detected successfully, change state machine status to DATA_BITS
                         begin
                            r_ClkCounter <= 0;
                            r_StateMachine <= DATA_BITS; 
                         end
                       else                                 // Else return to IDLE state
                         r_StateMachine <= IDLE;
                     end
                   else
                     begin
                       r_ClkCounter <= r_ClkCounter + 1;    // Increment counter
                       r_StateMachine <= START_BIT;         // Keep status for counting process to determin middle of start bit according to clks-per-bit
                     end
                 end
               DATA_BITS:   // If status DATA_BITS
                 begin
                   if (r_ClkCounter < CYCLES_PER_BIT-1)     // Make sure every data bit is received completely by matching the clks-per-bit parameter with the counter
                     begin
                       r_ClkCounter <= r_ClkCounter + 1;    // Increment counter 
                       r_StateMachine <= DATA_BITS;         // Keep status DATA_BITS until all data bits are received
                     end
                   else
                     begin
                       r_ClkCounter <= 0;                   // Reset counter for next data bit
                       o_RxData[r_BitsIndex] <= i_UartRx;   // Store received bit in output register
                       if (r_BitsIndex < 7)                 // Check if all 8 data bits are received
                         begin
                           r_BitsIndex <= r_BitsIndex + 1;  // Increment bit counter
                           r_StateMachine <= DATA_BITS;     // Keep status DATA_BITS 
                         end
                       else                                 // If all data bits are received continue with status STOP_BIT
                         begin
                           r_BitsIndex <= 0;                // Reset bit counter
                           r_StateMachine <= STOP_BIT;      // Change state to STOP_BIT
                         end
                     end
                 end 
               STOP_BIT:    // If status STOP_BIT
                 begin
                   if (r_ClkCounter < CYCLES_PER_BIT-1)     // Make sure that stop data bit is received completely by matching the clks-per-bit parameter with the counter
                     begin
                       r_ClkCounter <= r_ClkCounter + 1;    // Increment counter
                       r_StateMachine <= STOP_BIT;          // Keep status until bit received
                     end
                   else
                     begin
                       o_RxDone <= 1;                       // Set control output to high, to mark reception finished successfully
                       r_ClkCounter <= 0;                   // Reset counter
                       r_StateMachine <= RESET;             // Change state to RESET_STATE
                     end
                 end
               RESET:       // If status RESET_STATE  
                 begin
                   r_StateMachine <= IDLE;  // Change state to IDLE 
                   o_RxDone <= 0;           // Reset control output
                 end 
               default:
                 r_StateMachine <= IDLE;    // Default state is IDLE
             endcase
        end else begin
            r_StateMachine <= RESET;   // Reset state machine 
            o_RxDone <= 0;         // Reset data-reception control signal
            r_BitsIndex <= 0;
            r_ClkCounter <= 0;
            o_RxDone <= 0;
            o_RxData <= 0;        
        end
        
      end
end
  
endmodule