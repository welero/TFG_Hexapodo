//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.09.2023 17:13:17
// Design Name: 
// Module Name: Delay
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


module Delay(
    input i_Clk,
    input i_Rst,
    input i_IncSwitch,
    input i_DecSwitch,
    output [31:0] o_DelayValue
    );
 
localparam MAX_DELAY = 500000000; // Valor máximo de delay: 5 segundos
localparam MIN_DELAY = 25000000;  // Valor mínimo de delay: 0.25 segundos 
    
reg [31:0] delay_counter = 100000000; // Valor inicial de delay: 1 segundo    
//reg incbutton_sync, decbutton_sync;



always @(posedge i_Clk or posedge i_Rst) begin
    if (i_Rst) begin
        delay_counter <= 100000000; // Reiniciar a 1 segundo
//        incbutton_sync <= 0;
//        decbutton_sync <= 0;
    end else begin 
//        incbutton_sync <= i_IncButton;
//        decbutton_sync <= i_DecButton;
        if (i_IncSwitch == 1 && i_DecSwitch == 0 && (delay_counter < MAX_DELAY)) begin //Si switch 1 arriba y switch 2 abajo
        delay_counter <= 150000000; // Incrementar en 0.25 segundos
    end else if (i_DecSwitch == 1 && i_IncSwitch == 0 && (delay_counter > MIN_DELAY)) begin //Si switch 1 abajo y switch 2 arriba
        delay_counter <= 75000000; // Decrementar en 0.25 segundos
        end else begin
            delay_counter <=100000000;  //Cualquier otro caso
            end
    end
end

assign o_DelayValue = delay_counter;   //Asigna el registro con el valor del delay a la salida 
    
    
endmodule
