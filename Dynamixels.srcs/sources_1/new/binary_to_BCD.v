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

module binary_to_BCD(
    input i_Clk,                    // Clock - 10 MHz
    input i_Rst,                    // Reset - Control signal
    input [25:0] i_BinValue,        // Value - 26 bit input which should be converted into a BCD value
    output reg [31:0] o_BCDValue    // Value - 32 bit BCD value output for the seven segement display
);

////////////////////////////////////////###REGISTERS###////////////////////////////////////////
reg [5:0] r_Counter = 0;                // Register to count the converted values
reg [57:0] r_ShiftRegister = 0;         // Register needed for conversion process
reg [3:0] r_TempOnes = 0;               // Register to store the converted ONES
reg [3:0] r_TempTens = 0;               // Register to store the converted TENS
reg [3:0] r_TempHundreds = 0;           // Register to store the converted HUNDREDS
reg [3:0] r_TempThousands = 0;          // Register to store the converted THOUSANDS
reg [3:0] r_TempTenThousands = 0;       // Register to store the converted TEN_THOUSANDS
reg [3:0] r_TempHundredThousands = 0;   // Register to store the converted HUNDRED_THOUSANDS
reg [3:0] r_TempMillions = 0;           // Register to store the converted TEN_THOUSANDS
reg [3:0] r_TempTenMillions = 0;        // Register to store the converted HUNDRED_THOUSANDS
reg [25:0] r_BinValueOld = 0;           // Register to store the previous unconverted value
///////////////////////////////////////////////////////////////////////////////////////////////

always @ (posedge i_Clk or posedge i_Rst)            // Everytime the event inside the brackets occurs the following lines are executed
    begin                           
        if(i_Rst)                   // Check if reset is pressed or laser-module is disabled
            begin
                r_Counter = 0;      // Reset counter value
            end
        else
            begin
                if (r_Counter == 0 & (r_BinValueOld != i_BinValue)) // Check if counter is zero, previous value isnt current value and laser-module is enabled
                    begin
                        r_ShiftRegister = 0;                // Reset all values before the converting process is started               
                        r_TempOnes = 0;                  
                        r_TempTens = 0;
                        r_TempHundreds = 0;
                        r_TempThousands = 0;
                        r_TempTenThousands = 0;
                        r_TempHundredThousands = 0;
                        r_TempTenMillions = 0;
                        r_TempMillions = 0;
                        r_BinValueOld = i_BinValue;         // Store current value
                        r_ShiftRegister[25:0] = i_BinValue; // Load current value into the first 18 bit of the shift-register
                        r_Counter = r_Counter + 1;          // Increment counter
                    end
                if (r_Counter < 27 & r_Counter > 0)         // Check if counter is between 1 and 26
                    begin
                        // According to the algorithm (double dabble) which is used to generate the BCD values,
                        // every digit (is represented as 4 bit) is checked if its equal or larger then 5
                        // if this turns true, the 4 bit values is increased by 3.
                        if (r_TempTenMillions >= 5) 
                            r_TempTenMillions = r_TempTenMillions + 3;
                        if (r_TempMillions >= 5) 
                            r_TempMillions = r_TempMillions + 3;
                        if (r_TempHundredThousands >= 5) 
                            r_TempHundredThousands = r_TempHundredThousands + 3;
                        if (r_TempTenThousands >= 5) 
                            r_TempTenThousands = r_TempTenThousands + 3;
                        if (r_TempThousands >= 5) 
                            r_TempThousands = r_TempThousands + 3;
                        if (r_TempHundreds >= 5) 
                            r_TempHundreds = r_TempHundreds + 3;
                        if (r_TempTens >= 5) 
                            r_TempTens = r_TempTens + 3;
                        if (r_TempOnes >= 5) 
                            r_TempOnes = r_TempOnes + 3;
                            
                        // After the above procedure is completed, the shift-register (42 bit) is composed of 
                        // the individual 4 bit registers.
                        r_ShiftRegister[57:26] = {r_TempTenMillions,
                                                  r_TempMillions,
                                                  r_TempHundredThousands,
                                                  r_TempTenThousands,
                                                  r_TempThousands,
                                                  r_TempHundreds,
                                                  r_TempTens,
                                                  r_TempOnes};
                                                  
                        //  Afterwards the complete register is shifted to the left by 1.                    
                        r_ShiftRegister = r_ShiftRegister << 1;
                        
                        // After the shift, the values are stored again in the seperated 4 bit registers for the next iteration.
                        r_TempOnes = r_ShiftRegister[29:26];
                        r_TempTens = r_ShiftRegister[33:30];
                        r_TempHundreds = r_ShiftRegister[37:34];
                        r_TempThousands = r_ShiftRegister[41:38];
                        r_TempTenThousands = r_ShiftRegister[45:42];
                        r_TempHundredThousands = r_ShiftRegister[49:46];
                        r_TempMillions = r_ShiftRegister[53:50];
                        r_TempTenMillions = r_ShiftRegister[57:54];
                        
                        // Increment counter for next iteration
                        r_Counter = r_Counter + 1; 
                    end 
                if (r_Counter == 27)
                    begin
                        // After the convertig process is finished, all seperated values are written to the output.
                        o_BCDValue = {r_TempTenMillions,
                                      r_TempMillions,
                                      r_TempHundredThousands,
                                      r_TempTenThousands,
                                      r_TempThousands,
                                      r_TempHundreds,
                                      r_TempTens,
                                      r_TempOnes};
                        
                        // Reset values for next BCD conversation
                        r_Counter = 0;          
                        r_ShiftRegister = 0;
                    end
            end
    end
endmodule
