`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.09.2023 13:50:50
// Design Name: 
// Module Name: TriState
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


module TriState(
    input wire i_Data,
    input wire i_Enable,
    output wire o_Data
);
    assign o_Data = i_Enable ? i_Data : 1'bz;
endmodule
