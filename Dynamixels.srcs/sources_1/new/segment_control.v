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

module segment_control(
    input i_Clk,                        // Clock - 10 MHz
    input i_Rst,                        // Reset - Control signal
    input [31:0] i_BCDValue,            // Value - Input from BCD-module 
    output reg [7:0] o_SegmentAnode,    // Pins - Output to drive the Anode pins of the 7S-Display
    output reg [7:0] o_SegmentCathode   // Pins - Output to drive the Cathode pins of the 7S-Display
);

///////////////////////////////////////###REGISTERS###/////////////////////////////////////////
reg [2:0] r_Trigger;        // Register which is incremented with 10 kHz - Triggers the Anode output and the SingleDigit allocation
reg [3:0] r_SingleDigit;    // Register to split the generated BCD-value for futher processing
///////////////////////////////////////////////////////////////////////////////////////////////

always @ (posedge i_Clk or posedge i_Rst)    // Everytime the event inside the brackets occurs the following lines are executed                
    begin
        if(i_Rst)           // Check if reset is pressed
            r_Trigger <= 0;                 // Reset Trigger value
        else
            r_Trigger <= r_Trigger + 1;     // Increment Trigger
    end


always @ (*)    // Everytime any of the following elements changes the value the following lines are executed
    begin
        case (r_Trigger)
            3'b000:
                begin
                    o_SegmentAnode = 8'b11111110;           // Turn on digit 1 - (most right display)
                    if(!i_Rst)                              // Check reset isn't pressed
                        r_SingleDigit = i_BCDValue[3:0];    // Deliver single digit value to display 1 - (most right display)
                    else                                    // If condition is false, set digit to zero
                        r_SingleDigit = 4'b0000;
                end
            3'b001:
                begin
                    o_SegmentAnode = 8'b11111101;           // Turn on digit 2
                    if(!i_Rst)                              // Check if reset isn't pressed
                        r_SingleDigit = i_BCDValue[7:4];    // Deliver single digit value to display 2
                    else                                    // If condition is false, set digit to zero
                        r_SingleDigit = 4'b0000;
                end
            3'b010:
                begin
                    o_SegmentAnode = 8'b11111011;           // Turn on digit 3
                    if(!i_Rst)                              // Check if reset isn't pressed
                        r_SingleDigit = i_BCDValue[11:8];   // Deliver single digit value to display 3
                    else                                    // If condition is false, set digit to zero
                        r_SingleDigit = 4'b0000;
                end
            3'b011:
                begin
                    o_SegmentAnode = 8'b11110111;           // Turn on digit 4
                    if(!i_Rst)                              // Check if reset isn't pressed
                        r_SingleDigit = i_BCDValue[15:12];  // Deliver single digit value to display 4
                    else                                    // If condition is false, set digit to zero
                        r_SingleDigit = 4'b0000;
                end
            3'b100: 
                begin
                    o_SegmentAnode = 8'b11101111;           // Turn on digit 5
                    if(!i_Rst)                              // Check if reset isn't pressed
                        r_SingleDigit = i_BCDValue[19:16];  // Deliver single digit value to display 5
                    else                                    // If condition is false, set digit to zero
                        r_SingleDigit = 4'b0000;
                end
            3'b101:
                begin
                    o_SegmentAnode = 8'b11011111;           // Turn on digit 6
                    if(!i_Rst)                              // Check if reset isn't pressed
                        r_SingleDigit = i_BCDValue[23:20];  // Deliver single digit value to display 6
                    else                                    // If condition is false, set digit to zero
                        r_SingleDigit = 4'b0000;   
                end
            3'b110: 
                begin
                    o_SegmentAnode = 8'b10111111;           // Turn on digit 7
                    if(!i_Rst)                              // Check if reset isn't pressed
                        r_SingleDigit = i_BCDValue[27:24];  // Deliver single digit value to display 7
                    else                                    // If condition is false, set digit to zero
                        r_SingleDigit = 4'b0000;
                end
            3'b111:
                begin
                    o_SegmentAnode = 8'b01111111;           // Turn on digit 8 - (most left display)
                    if(!i_Rst)                              // Check if reset isn't pressed
                        r_SingleDigit = i_BCDValue[31:28];  // Deliver single digit value to display 8 - (most left display)
                    else                                    // If condition is false, set digit to zero
                        r_SingleDigit = 4'b0000;
                end
        endcase
    end

always @ (r_SingleDigit)            // Everytime the event inside the brackets occurs the following lines are executed
    begin
        case (r_SingleDigit)        // Depending on the single digit value, the according combination of pins is send to the pins for the right number to be displayed
            4'd0:
                o_SegmentCathode = 8'b1100_0000;   // Displays a zero a the according display
            4'd1:
                o_SegmentCathode = 8'b1111_1001;   // Displays a one a the according display
            4'd2:
                o_SegmentCathode = 8'b1010_0100;   // Displays a two a the according display
            4'd3:
                o_SegmentCathode = 8'b1011_0000;   // Displays a three a the according display                            
            4'd4:
                o_SegmentCathode = 8'b1001_1001;   // Displays a four a the according display
            4'd5:
                o_SegmentCathode = 8'b1001_0010;   // Displays a five a the according display
            4'd6:
                o_SegmentCathode = 8'b1000_0010;   // Displays a six a the according display
            4'd7:
                o_SegmentCathode = 8'b1111_1000;   // Displays a seven a the according display
            4'd8:
                o_SegmentCathode = 8'b1000_0000;   // Displays a eight a the according display
            4'd9:
                o_SegmentCathode = 8'b1001_0000;   // Displays a nine a the according display
            default:
                o_SegmentCathode = 8'b1100_0000;   // Displays a zero a the according display
        endcase
    end
    
endmodule