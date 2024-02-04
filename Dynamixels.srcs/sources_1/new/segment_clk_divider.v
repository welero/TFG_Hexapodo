///////////////////////////////////////////////////////////////////////////////////////////////
// 
// Company: Frankfurt University of Applied Sciences
// Author: René Harmann
// 
// Last-modified Date: 01.04.2023
// Project Name: neuromorphic_test_bench
// Target Devices: Nexys A7-100T
// Tool Versions: Vivado 2022.2
// 
///////////////////////////////////////////////////////////////////////////////////////////////

module segment_clk_divider(
    input i_Clk,                // Clock - 10 MHz
    input i_Rst,                // Reset - Control signal
    output reg o_NewClk         // Clock - 10 kHz output to drive according modules
);

/////////////////////////////###PARAMETERS/REGISTERS###////////////////////////////////////////
parameter Divisor10kHz = 499;   // Parameter value corresponds to 0.1ms - Divisor = 10MHz/(2*desired frequency)-1
//-------------------------------------------------------------------------------------------//
reg [9:0] r_CounterClk = 0;     // Register to count to defined parameter value 
///////////////////////////////////////////////////////////////////////////////////////////////

always @ (posedge i_Clk or posedge i_Rst)        // Everytime the event inside the brackets occurs the following lines are executed
    begin
        if(i_Rst)               // Check if reset is pressed
            r_CounterClk <= 0;  // Set counter to zero
        else
            begin
                if(r_CounterClk == Divisor10kHz)    // The counter-register is compared to the defined parameter
                    begin
                        o_NewClk <= ~o_NewClk;      // Signal is flipped to generated a clocklike output signal
                        r_CounterClk <= 0;          // Set counter to zero
                    end
                else
                    begin
                        o_NewClk <= o_NewClk;               // Make sure the signal is stored until its flipped again
                        r_CounterClk <= r_CounterClk + 1;   // Increment counter
                    end     
            end  
    end
    
endmodule
