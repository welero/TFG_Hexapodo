module top(
    input SystemClk_100MHz, // Reloj del sistema
    input SystemRst, // Reset del sistema
    input i_Switch,
    input i_IncSwitch,
    input i_DecSwitch,
    input i_Rx_Serial,
    output o_TxSerial,
    inout o_TxTri,
    output o_Enable,
    output [7:0] o_Tx_Byte,
    output [7:0] o_Rx_Byte,
    output [31:0] o_Delay,
    output [7:0] o_SegmentAnode,
    output [7:0] o_SegmentCathode
);


//////////////////////////////////###CLOCK-CONTROL###//////////////////////////////////////////
wire w_Clk150MHz;                   // Wire for 150 MHz clock distrubition
wire w_Clk100MHz;                   // Wire for 100 MHz clock distrubition
wire w_Clk50MHz;                    // Wire for 50 MHz clock distrubition
wire w_Clk10MHz;                    // Wire for 10 MHz clock distrubition
wire w_ClkLocked;
//-------------------------------------------------------------------------------------------//
wire w_RstDebounced;
wire w_Reset;
wire w_TxDone;
wire [7:0] w_Tx_Byte;
wire w_Tx_Serial;
wire w_Enable;
wire w_Rx_Serial;
wire w_RxDone;
wire [7:0] w_Rx_Byte;
wire w_NextByte;
wire [3:0] w_Contador;
wire w_LastByteTx;
wire w_TxTri;
wire [31:0] w_Delay;
wire w_IncButton;
wire w_DecButton;


assign w_TxTri = o_TxTri;
assign w_Reset = w_RstDebounced | !w_ClkLocked;
assign o_Tx_Byte = w_Tx_Byte;
assign o_TxSerial = w_Tx_Serial;
assign o_Enable = w_Enable;
assign o_Rx_Byte = w_Rx_Byte;
//assign o_Tx_Enable = w_Tx_Enable;
//assign o_Rx_Serial = i_Rx_Serial;
assign o_Delay = w_Delay;


clk_wiz clocks_instance(            // This module receives the system clk with 100 MHz and generates defined user clocks from it
    // Clock out ports
    .clk_150MHz(w_Clk150MHz),       // output clk_150MHz
    .clk_100MHz(w_Clk100MHz),       // output clk_100MHz
    .clk_50MHz(w_Clk50MHz),         // output clk_50MHz
    .clk_10MHz(w_Clk10MHz),         // output clk_10MHz
    // Status and control signals
    .reset(~SystemRst),             // input reset
    .locked(w_ClkLocked),           // output locked
    // Clock in ports
    .clk_in1(SystemClk_100MHz)      // input for SystemClk
);

btn_debouncer Reset_Debouncer(      // This module debounces the reset button
    .i_Clk(w_Clk10MHz),  //w_Clk10MHz           // Input: Clock - 10 MHz
    .i_Btn(~SystemRst),             // Input: Btn to be debounced -> RESET (Active LOW)
    .o_BtnDebounced(w_RstDebounced) // Output: Debounced signal
);

//btn_debouncer IncButton_Debouncer(      // This module debounces the reset button
//    .i_Clk(w_Clk10MHz),  //w_Clk10MHz           // Input: Clock - 100 MHz
//    .i_Btn(i_IncButton),             // Input: Btn to be debounced 
//    .o_BtnDebounced(w_IncButton) // Output: Debounced signal
//);

//btn_debouncer DecButton_Debouncer(      // This module debounces the reset button
//    .i_Clk(w_Clk10MHz),  //w_Clk10MHz           // Input: Clock - 100 MHz
//    .i_Btn(i_DecButton),             // Input: Btn to be debounced 
//    .o_BtnDebounced(w_DecButton) // Output: Debounced signal
//);

Delay delay_inst(
    .i_Clk(w_Clk100MHz),
    .i_Rst(w_Reset),
    .i_IncSwitch(i_IncSwitch),
    .i_DecSwitch(i_DecSwitch),
    .o_DelayValue(w_Delay) //El wire llevará la salida a tx como entrada
);



uart_tx uart_tx(
   .i_Clk(w_Clk100MHz),
   .i_Rst(w_Reset),
   .i_Delay(w_Delay),
   .i_TxStart(i_Switch), 
   .i_TxData(w_Tx_Byte), //Byte completo que se pretende transmitir
   .i_Enable(w_Enable),   
   .o_TxActive(w_Tx_Active), //Si está en 1, la transmisión está activa
   .o_TxDone(w_TxDone),
   .o_TxData(w_Tx_Serial)
);

uart_rx uart_rx(
    .i_Clk(w_Clk100MHz),
    .i_Rst(w_Reset),
    .i_UartRx(w_TxTri),
    .i_Enable(w_Enable),
    .o_RxDone(w_RxDone),
    .o_RxData(w_Rx_Byte)
);

st_pack storageTx(
    .i_Clk(w_Clk100MHz),
    .i_Rst(w_Reset),
    .i_TxDone(w_TxDone),
    .i_Enable(w_Enable),
    .o_LastByte(w_LastByteTx),
    .o_Tx_Byte(w_Tx_Byte)
);

arbiter arbiter(
    .i_Clk(w_Clk100MHz),
    .i_Rst(w_Reset),
    .i_LastByteTx(w_LastByteTx),
    .i_Rx_Done(w_RxDone),
    .o_Enable(w_Enable)
);

TriState TriState(
    .i_Data(w_Tx_Serial),
    .i_Enable(w_Enable),
    .o_Data(w_TxTri)
);    

seven_segment_top I_7_SEGMENT_TOP(      // This module controls the seven segment dispaly
    .i_Clk(w_Clk100MHz),    //w_Clk10MHz             // Input: Clock - 10 MHz
    .i_Rst(w_Reset),                    // Input: Reset as control signal
    .i_DTD(w_Delay), //w_Display
    .o_SegmentAnode(o_SegmentAnode),      // Output: Anode for seven segment display
    .o_SegmentCathode(o_SegmentCathode)  // Output: Cathode for seven segment display

);

endmodule
