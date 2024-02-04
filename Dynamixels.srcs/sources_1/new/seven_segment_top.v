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

module seven_segment_top(
    input i_Clk,                        // Clock - 10 MHz
    input i_Rst,                        // Reset - Control signal -> (Active LOW)
    input [31:0] i_DTD,
//    input i_SwitchDISPLAY,              // Button - Switch between different values for 7S-display
//    input [17:0] i_SensorData,          // Sensordata - Data from laser module
//    input [17:0] i_SetValueData,        // SetValuedata - Data from pc communication module
//    input [25:0] i_VoltageData,         // Voltagedata - Data from SpiNNaker module
    output [7:0] o_SegmentAnode,        // Anodes - Output pins to drive anodes for 7S-display
    output [7:0] o_SegmentCathode      // Cathodes - Output pins to drive cathodes for 7S-display
//    output reg [2:0] o_LedDISPLAY           // Pins - Output marks the display status
);

///////////////////////////////###PARAMETERS/WIRES/REGISTERS###////////////////////////////////
parameter LaserDATA = 0;        // Parameters for statemachine
parameter SetVALUE = 1;
parameter VoltageDATA = 2;
//-------------------------------------------------------------------------------------------//
wire w_BtnDebounced;                    // Wire to connect debounced signal to condition
wire w_Clk10kHz;                        // Wire to connect generated 10 kHz clock to modules
wire [31:0] w_BCDValue;                 // Wire to connect BCDValue to modules
wire [25:0] w_DividedValue;             // Wire to connect DividedValue with the Decision calulation
//-------------------------------------------------------------------------------------------//
reg [2:0] r_StateMachineDISP;           // Register to indicate display state
reg [25:0] r_DataToDisplay;             // Register to connect the derived DATA to the BCDValue module
///////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////###DISPLAY_DECISION###/////////////////////////////////////
//always @ (posedge w_BtnDebounced)       // Everytime the event inside the brackets occurs the following lines are executed
//    begin
//        if(r_StateMachineDISP == 2)     // Check if statemachine value is 2
//            r_StateMachineDISP = 0;     // if true reset statemachine
//        else
//            r_StateMachineDISP <= r_StateMachineDISP + 1;   // if false increment statemachine
//    end
always @ (posedge i_Clk or posedge i_Rst)
    begin
        if (i_Rst)
            r_DataToDisplay = 26'd0;
        else 
            r_DataToDisplay = i_DTD/1000000; //Dividido entre 1 millón. Aparecería 100,125,75...
    end
//always @ (posedge i_Clk)                // Everytime the event inside the brackets occurs the following lines are executed
//    begin
//        case(r_StateMachineDISP)        // Check state of statemachine
//            0: 
//                begin
//                    r_DataToDisplay <= i_SensorData;     // Set DATA to SensorData
//                    o_LedDISPLAY <= 3'b001;              // Turn on LED indicators for state
//                end
//            1:                
//                begin
//                    r_DataToDisplay <= i_SetValueData;   // Set DATA to SensorData
//                    o_LedDISPLAY <= 3'b011;              // Turn on LED indicators for state
//                end
//            2: 
//                begin
//                    r_DataToDisplay <= i_VoltageData;    // Set DATA to divided Voltagedata ######MUSS ANGEPASST WERDEN#########
//                    o_LedDISPLAY <= 3'b111;              // Turn on LED indicators for state
//                end
//        endcase
//    end

///////////////////////////////////////////////////////////////////////////////////////////////
//btn_debouncer I_7S_BTN_DEBOUNCER(       // This module debounces the display switch button
//    .i_Clk(i_Clk),                      // Input: Clock - 10 MHz
//    .i_Btn(i_SwitchDISPLAY),            // Input: Btn to be debounced -> Display switch button
//    .o_BtnDebounced(w_BtnDebounced)     // Output: Debounced signal
//);

segment_clk_divider I_7S_CLOCK (        // This module generates a 10 kHz clock from the 10 MHz clock
    .i_Clk(i_Clk),                      // Input: Clock - 10 MHz
    .i_Rst(i_Rst),                      // Input: Reset as control signal 
    .o_NewClk(w_Clk10kHz)               // Output: New 10 kHz clock
);

//voltage_value_divider I_VV_DIVIDER(     // This module divides the voltage value to show the exact percentage a the display
//    .i_Clk(w_Clk10kHz),                 // Input: Clock - 10 kHz
//    .i_Divident(i_VoltageData),         // Input: 26 Bit voltage value
//    .o_Result(w_DividedValue)           // Output: 8 Bit percentage value (0-100%)
//);

binary_to_BCD I_7S_BINARY_TO_BCD (      // This module generates a Binary-Codede-Dezimal value from a 18 bit register
    .i_Clk(i_Clk),                      // Input: Clock - 10 MHz
    .i_Rst(i_Rst),                      // Input: Reset - control signal
    .i_BinValue(r_DataToDisplay),       // Input: 18 bit register 
    .o_BCDValue(w_BCDValue)             // Output: Binary-Coded-Dezimal value for representation on the seven segment display
);

segment_control I_7S_CTRL (             // This module takes the BCD-value as an input and creates single digits for the seven segment display representation
    .i_Clk(w_Clk10kHz),                 // Input: Clock - 10 kHz
    .i_Rst(i_Rst),                      // Input: Reset - control signal
    .i_BCDValue(w_BCDValue),            // Input: BCD-value 
    .o_SegmentAnode(o_SegmentAnode),    // Output: Value to according anode 
    .o_SegmentCathode(o_SegmentCathode) // Output: Value to according cathode 
);
    
endmodule
