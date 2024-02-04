module btn_debouncer(
  input i_Clk,              // Clock - 10 MHz
  input i_Btn,              // Button - Signal which is debounced
  output reg o_BtnDebounced // Signal - Debounced output signal
);

///////////////////////////////###WIRES/REGISTERS/ASSIGNMENTS###///////////////////////////////
parameter DEB_CONSTANT = 20'h61A80;     // Wait 40 ms per button press
//-------------------------------------------------------------------------------------------//
reg [19:0] r_CounterClk = DEB_CONSTANT; // Register to count to defined parameter value
reg [2:0] r_BounceState;                // State register
///////////////////////////////////////////////////////////////////////////////////////////////
always @(posedge i_Clk)
    if ((r_BounceState[2] == r_BounceState[1]) && (r_CounterClk == 0))  // Make sure no debouncing is currently processed
        o_BtnDebounced <= r_BounceState[2];                             // Write final state to the output

always @(posedge i_Clk)
    begin
        r_BounceState[0] <= i_Btn;                                      // Make sure data is saved for more than one clock cycle,
        r_BounceState[1] <= r_BounceState[0];                           // by shifitig it multiple times through the state register
        r_BounceState[2] <= r_BounceState[1];   
    end

always @(posedge i_Clk)
    if (r_BounceState[2] != r_BounceState[1])                           // Check if state register is not equal anymore -> BTN debounced
        r_CounterClk <= DEB_CONSTANT;                                   // Reset counter register
    else
        if (r_CounterClk != 0)                                          // Check if counter register is not empty
            r_CounterClk <= r_CounterClk - 1;                           // Decerement counter
            
endmodule
