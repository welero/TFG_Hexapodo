`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.08.2023 19:54:03
// Design Name: 
// Module Name: arbiter
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


module arbiter(
        input i_Clk,
        input i_Rst,
        input i_LastByteTx,
        input i_Rx_Done,
        output reg o_Enable
    );

reg [3:0] r_Contador_Tx;
reg [3:0] r_Contador_Rx;
reg [31:0] r_Delay;
            
    always @ (posedge i_Clk or posedge i_Rst) begin 
        if (i_Rst) begin
            o_Enable <= 1;
            r_Contador_Rx <= 0;
            r_Delay <= 0;
        end else begin
            if (i_LastByteTx) begin                
                o_Enable <= 0;
                r_Contador_Rx <= 0;
                r_Delay <= 0;
            end else if (i_Rx_Done) begin
                r_Contador_Rx <= r_Contador_Rx + 1;
                r_Delay <= 0;
                if (r_Contador_Rx == 5) begin
                    o_Enable <= 1;
                end else begin
                    o_Enable <= o_Enable;
                end
            end else if (r_Delay < 10000000) begin
                r_Delay <= r_Delay + 1;
                o_Enable <= o_Enable;            
            end else begin
                r_Delay <= 0;
                o_Enable <= 1;
            end
        end
    end            
            
endmodule
