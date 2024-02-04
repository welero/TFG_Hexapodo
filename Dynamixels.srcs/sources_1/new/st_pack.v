
module st_pack(
    input i_Clk,
    input i_Rst,
    input i_TxDone, //Cada vez que se envíe un byte completo, se pone en 1 durante un ciclo de reloj (de 10MHz)
    input i_Enable,
    input [2:0] i_StateMachine,
    output reg o_LastByte,
    output [7:0] o_Tx_Byte //Byte completo que se pretende transmitir
    );

/////////////////////////////////////////////////////
//////////////////// HEADERS  ///////////////////////
/////////////////////////////////////////////////////
localparam IN1=8'hFF; //Header 1. 0xFF
localparam IN2=8'hFF; //Header 2. 0xFF
/////////////////////////////////////////////////////
/////////////////////// IDs /////////////////////////
/////////////////////////////////////////////////////
localparam ID_0=8'h00; 
localparam ID_1=8'h01; 
localparam ID_2=8'h02; 
localparam ID_3=8'h03;
localparam ID_4=8'h04;
localparam ID_5=8'h05;
localparam ID_6=8'h06;
localparam ID_7=8'h07;
localparam ID_8=8'h08;
localparam ID_9=8'h09;
localparam ID_10=8'h0A;
localparam ID_11=8'h0B;
localparam ID_12=8'h0C;
localparam ID_13=8'h0D;
localparam ID_14=8'h0E;
localparam ID_15=8'h0F;
localparam ID_16=8'h10;
localparam ID_17=8'h11;
localparam BC_ID=8'hFE; //ID de BroadCast.
/////////////////////////////////////////////////////
////////////////// PACKET LENGTHS ///////////////////
/////////////////////////////////////////////////////
localparam LEN=8'h13; //Longitud del paquete de instrucción TOTAL. VALOR FIJO. 13 pa 3 motores. 0E pa 2. 09 para 1
localparam LEN_F=8'h22; //Longitud para cuando 0-9-15 retroceden y 6-3-12 avanzan
localparam SLEN=8'h04; //Longitud del paquete de cada motor. VALOR FIJO.
/////////////////////////////////////////////////////
//////////////////// PARAMETERS /////////////////////
/////////////////////////////////////////////////////
localparam INS=8'h83; //Instrucción que se envía (3 es WRITE). VALOR FIJO.
localparam DIR=8'h1E; //Dirección en la que escribir (Goal Pos_L, seguido de GP_H, Movement speed_L, MS_H). VALOR FIJO. 
localparam MS_L=8'h00; //Byte bajo de Movement Speed. 
localparam MS_H=8'h00; //Byte alto de Movement Speed. 
/////////////////////////////////////////////////////
/////////////////// ADDRESS #1 STAND BY /////////////////////
/////////////////////////////////////////////////////
localparam GP_1_L_A=8'h00; //512 en decimal. Los motores medios de cada pata se colocan en posición media, de forma que todas 
localparam GP_1_H_A=8'h02; //   las patas están en el suelo

localparam GP_7_L_A=8'h00; 
localparam GP_7_H_A=8'h02;

localparam GP_4_L_A=8'h00; 
localparam GP_4_H_A=8'h02;

localparam GP_10_L_A=8'h00; 
localparam GP_10_H_A=8'h02;

localparam GP_16_L_A=8'h00; 
localparam GP_16_H_A=8'h02;

localparam GP_13_L_A=8'h00; 
localparam GP_13_H_A=8'h02;

localparam GP_0_L_A=8'h00; //También los motores de la cadera
localparam GP_0_H_A=8'h02;

localparam GP_6_L_A=8'h00; 
localparam GP_6_H_A=8'h02;

localparam GP_3_L_A=8'h00; 
localparam GP_3_H_A=8'h02;

localparam GP_9_L_A=8'h00; 
localparam GP_9_H_A=8'h02;

localparam GP_15_L_A=8'h00; 
localparam GP_15_H_A=8'h02;

localparam GP_12_L_A=8'h00; 
localparam GP_12_H_A=8'h02;

/////////////////////////////////////////////////////
////////////////// ADDRESS #2  LEVANTA GRUPO 1 PATA//////////////////////
/////////////////////////////////////////////////////
localparam GP_1_L_B=8'h26; //550 en decimal. Los motores medios de TRES patas se colocan en posición alta, de forma que tres 
localparam GP_1_H_B=8'h02; //  patas están levantadas

localparam GP_10_L_B=8'h26; 
localparam GP_10_H_B=8'h02;

localparam GP_16_L_B=8'h26; 
localparam GP_16_H_B=8'h02;

/////////////////////////////////////////////////////
////////////////// ADDRESS #3  AVANZA GRUPO 1 PATA//////////////////////
/////////////////////////////////////////////////////
localparam GP_0_L_C=8'h64; //612 en decimal. Los motores de cadera de TRES patas se colocan en posición adelante, de forma que tres 
localparam GP_0_H_C=8'h02; //  patas están avanzadas

localparam GP_9_L_C=8'h9C; 
localparam GP_9_H_C=8'h01;

localparam GP_15_L_C=8'h64; 
localparam GP_15_H_C=8'h02;
/////////////////////////////////////////////////////
////////////////// ADDRESS #4  BAJA GRUPO 1 PATA//////////////////////
/////////////////////////////////////////////////////
localparam GP_1_L_D=8'h00; //512 en decimal. Los motores medios de TRES patas se colocan en posición MEDIA, de forma que tres 
localparam GP_1_H_D=8'h02; //  patas están BAJAS

localparam GP_10_L_D=8'h00; 
localparam GP_10_H_D=8'h02;

localparam GP_16_L_D=8'h00; 
localparam GP_16_H_D=8'h02;
/////////////////////////////////////////////////////
////////////////// ADDRESS #5  LEVANTA GRUPO 2 PATA//////////////////////
/////////////////////////////////////////////////////
localparam GP_7_L_E=8'h26; //550 en decimal. Los motores medios de TRES patas se colocan en posición alta, de forma que tres 
localparam GP_7_H_E=8'h02; //  patas están levantadas

localparam GP_4_L_E=8'h26; 
localparam GP_4_H_E=8'h02;

localparam GP_13_L_E=8'h26; 
localparam GP_13_H_E=8'h02;

////////////////////////////////////////////
////////////ADDRESS #6 RETROCEDE GRUPO 1 Y AVANZA GRUPO 2////////////////////////////////
////////////////////////////////////////////
localparam GP_0_L_F=8'h00; //612  en decimal para los motores 0-3-15. Los motores 0-9-15 vuelven a su sitio 
localparam GP_0_H_F=8'h02; //412  en decimal para los motores 6-9-12. Los motores 6-3-12 avanzan. 

localparam GP_9_L_F=8'h00;
localparam GP_9_H_F=8'h02;

localparam GP_15_L_F=8'h00;
localparam GP_15_H_F=8'h02;

localparam GP_6_L_F=8'h9C;
localparam GP_6_H_F=8'h01;

localparam GP_3_L_F=8'h64;
localparam GP_3_H_F=8'h02;

localparam GP_12_L_F=8'h9C;
localparam GP_12_H_F=8'h01;

////////////////////////////////////////////
////////////ADDRESS #7 BAJA GRUPO 2////////////////////////////////
////////////////////////////////////////////
localparam GP_7_L_G=8'h00;
localparam GP_7_H_G=8'h02;

localparam GP_4_L_G=8'h00;
localparam GP_4_H_G=8'h02;

localparam GP_13_L_G=8'h00;
localparam GP_13_H_G=8'h02;

////////////////////////////////////////////
////////////ADDRESS #8 SUBE GRUPO 1////////////////////////////////
////////////////////////////////////////////
localparam GP_1_L_H=8'h26; //550 en decimal. Los motores medios de TRES patas se colocan en posición alta, de forma que tres 
localparam GP_1_H_H=8'h02; //  patas están levantadas

localparam GP_10_L_H=8'h26; 
localparam GP_10_H_H=8'h02;

localparam GP_16_L_H=8'h26; 
localparam GP_16_H_H=8'h02;

////////////////////////////////////////////
////////////ADDRESS #9 RETROCEDE GRUPO 2 Y AVANZA GRUPO 1////////////////////////////////
////////////////////////////////////////////
localparam GP_0_L_I=8'h64; //612  en decimal para los motores 0-3-15. Los motores 0-9-15 vuelven a su sitio 
localparam GP_0_H_I=8'h02; //412  en decimal para los motores 6-9-12. Los motores 6-3-12 avanzan. 

localparam GP_9_L_I=8'h9C;
localparam GP_9_H_I=8'h01;

localparam GP_15_L_I=8'h64;
localparam GP_15_H_I=8'h02;

localparam GP_6_L_I=8'h00;
localparam GP_6_H_I=8'h02;

localparam GP_3_L_I=8'h00;
localparam GP_3_H_I=8'h02;

localparam GP_12_L_I=8'h00;
localparam GP_12_H_I=8'h02;


reg [7:0] r_Tx_Byte;
reg [4:0] r_Contador;
reg [1:0] r_Dir;
reg [1:0] r_Last_Dir; //de 00 a 11 (00, 01, 10, 11) 
reg [7:0] CS;

assign o_Tx_Byte = r_Tx_Byte;

always @ (posedge i_Clk or posedge i_Rst) begin
    if (i_Rst) begin
        r_Tx_Byte <= 0;
        o_LastByte <= 0;
        r_Contador <= 0;
        r_Dir <= 2'b00;
        r_Last_Dir <= 2'b00;
        CS <= 0;
    end else begin
        if (i_Enable) begin   
            //r_Dir <= !r_Last_Dir;
            if (i_TxDone) begin
                r_Contador <= r_Contador + 1;
                case (r_Contador)         
                    0: begin
                        r_Tx_Byte <= IN1;
                    end 
                    1: begin
                        r_Tx_Byte <= IN2;
                    end
                    2: begin
                        r_Tx_Byte <= BC_ID;
                        CS <= CS + BC_ID;
                    end
                    3: begin
                       if (r_Dir == 5 || r_Dir == 8) begin //Para valores 5 u 8, cuando los dos grupos de patas se mueven a la vez
                            r_Tx_Byte <= LEN_F;
                            CS <= CS + LEN_F;
                       end else begin // Cualquier otro valor
                            r_Tx_Byte <= LEN;
                            CS <= CS + LEN;
                        end
                    end
                    4: begin
                        r_Tx_Byte <= INS;
                        CS <= CS + INS;
                    end
                    5: begin
                        r_Tx_Byte <= DIR;
                        CS <= CS + DIR;
                    end
                    6: begin
                        r_Tx_Byte <= SLEN;
                        CS <= CS + SLEN;
                    end
                    ///////////////////////////////
                    //////     SERVO    0   ///////
                    ///////////////////////////////
                    7: begin
                        r_Tx_Byte <= ID_0;
                        CS <= CS + ID_0;                     
                    end
                    8: begin                            //Motor 0 byte bajo
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_0_L_A; 
                            CS <= CS + GP_0_L_A;
                        end else if (r_Dir == 1) begin  
                            r_Tx_Byte <= GP_0_L_A;
                            CS <= CS + GP_0_L_A;
                        end else if (r_Dir == 2) begin //AVANCE
                            r_Tx_Byte <= GP_0_L_C;
                            CS <= CS + GP_0_L_C;
                        end else if (r_Dir == 3) begin
                            r_Tx_Byte <= GP_0_L_C;
                            CS <= CS + GP_0_L_C;
                        end else if (r_Dir == 4) begin
                            r_Tx_Byte <= GP_0_L_C;
                            CS <= CS + GP_0_L_C;
                        end else if (r_Dir == 5) begin //RETROCEDE
                            r_Tx_Byte <= GP_0_L_A;
                            CS <= CS + GP_0_L_A;
                        end else if (r_Dir == 6) begin  
                            r_Tx_Byte <= GP_0_L_A;
                            CS <= CS + GP_0_L_A;
                        end else if (r_Dir == 7) begin  
                            r_Tx_Byte <= GP_0_L_A;
                            CS <= CS + GP_0_L_A;
                        end else if (r_Dir == 8) begin //AVANZA
                            r_Tx_Byte <= GP_0_L_C;
                            CS <= CS + GP_0_L_C;
                        end
                    end
                    9: begin                            //Motor 0 byte alto
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_0_H_A; 
                            CS <= CS + GP_0_H_A;
                        end else if (r_Dir == 1) begin  
                            r_Tx_Byte <= GP_0_H_A;
                            CS <= CS + GP_0_H_A;
                        end else if (r_Dir == 2) begin //AVANCE
                            r_Tx_Byte <= GP_0_H_C;
                            CS <= CS + GP_0_H_C;
                        end else if (r_Dir == 3) begin
                            r_Tx_Byte <= GP_0_H_C;
                            CS <= CS + GP_0_H_C;
                        end else if (r_Dir == 4) begin
                            r_Tx_Byte <= GP_0_H_C;
                            CS <= CS + GP_0_H_C;
                        end else if (r_Dir == 5) begin //RETROCEDE
                            r_Tx_Byte <= GP_0_H_A;
                            CS <= CS + GP_0_H_A;
                        end else if (r_Dir == 6) begin  
                            r_Tx_Byte <= GP_0_H_A;
                            CS <= CS + GP_0_H_A;
                        end else if (r_Dir == 7) begin  
                            r_Tx_Byte <= GP_0_H_A;
                            CS <= CS + GP_0_H_A;
                        end else if (r_Dir == 8) begin //AVANZA
                            r_Tx_Byte <= GP_0_H_C;
                            CS <= CS + GP_0_H_C;
                        end
                    end
                    10: begin                        
                        r_Tx_Byte <= MS_L;                             
                        CS <= CS + MS_L;
                    end
                    11: begin                        
                        r_Tx_Byte <= MS_H;                             
                        CS <= CS + MS_H;
                    end
                    ///////////////////////////////
                    //////     SERVO    1   ///////
                    ///////////////////////////////
                    12: begin                        
                        r_Tx_Byte <= ID_1;                             
                        CS <= CS + ID_1;
                    end
                    13: begin                            //Motor 1 byte bajo
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_1_L_A; 
                            CS <= CS + GP_1_L_A;
                        end else if (r_Dir == 1) begin  //LEVANTA
                            r_Tx_Byte <= GP_1_L_B;
                             CS <= CS + GP_1_L_B;
                         end else if (r_Dir == 2) begin 
                            r_Tx_Byte <= GP_1_L_B;
                            CS <= CS + GP_1_L_B;
                        end else if (r_Dir == 3) begin //BAJA
                            r_Tx_Byte <= GP_1_L_A; 
                            CS <= CS + GP_1_L_A;
                        end else if (r_Dir == 4) begin
                            r_Tx_Byte <= GP_1_L_A; 
                            CS <= CS + GP_1_L_A;
                        end else if (r_Dir == 5) begin 
                            r_Tx_Byte <= GP_1_L_A;
                            CS <= CS + GP_1_L_A;
                        end else if (r_Dir == 6) begin  
                            r_Tx_Byte <= GP_1_L_A;
                            CS <= CS + GP_1_L_A;
                        end else if (r_Dir == 7) begin  //LEVANTA
                            r_Tx_Byte <= GP_1_L_B;
                            CS <= CS + GP_1_L_B;
                        end else if (r_Dir == 8) begin 
                            r_Tx_Byte <= GP_1_L_B;
                            CS <= CS + GP_1_L_B;
                        end
                    end
                    14: begin                            //Motor 1 byte alto
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_1_H_A; 
                            CS <= CS + GP_1_H_A;
                        end else if (r_Dir == 1) begin  //LEVANTA
                            r_Tx_Byte <= GP_1_H_B;
                            CS <= CS + GP_1_H_B;
                        end else if (r_Dir == 2) begin 
                            r_Tx_Byte <= GP_1_H_B;
                            CS <= CS + GP_1_H_B;
                        end else if (r_Dir == 3) begin //BAJA
                            r_Tx_Byte <= GP_1_H_A; 
                            CS <= CS + GP_1_H_A;
                        end else if (r_Dir == 4) begin
                            r_Tx_Byte <= GP_1_H_A; 
                            CS <= CS + GP_1_H_A;
                        end else if (r_Dir == 5) begin 
                            r_Tx_Byte <= GP_1_H_A;
                            CS <= CS + GP_1_H_A;
                        end else if (r_Dir == 6) begin  
                            r_Tx_Byte <= GP_1_H_A;
                            CS <= CS + GP_1_H_A;
                        end else if (r_Dir == 7) begin  //LEVANTA
                            r_Tx_Byte <= GP_1_H_B;
                                CS <= CS + GP_1_H_B;
                        end else if (r_Dir == 8) begin 
                            r_Tx_Byte <= GP_1_H_B;
                                CS <= CS + GP_1_H_B;
                        end
                    end
                    15: begin                        
                        r_Tx_Byte <= MS_L;                             
                        CS <= CS + MS_L;
                    end
                    16: begin                        
                        r_Tx_Byte <= MS_H;                             
                        CS <= CS + MS_H;
                    end
                    
                    ///////////////////////////////
                    //////     SERVO    3   ///////
                    ///////////////////////////////
                    17: begin
                        r_Tx_Byte <= ID_3;                             
                        CS <= CS + ID_3;
                    end
                    18: begin                            //Motor 3 byte bajo
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_3_L_A; 
                            CS <= CS + GP_3_L_A;
                        end else if (r_Dir == 1) begin  
                            r_Tx_Byte <= GP_3_L_A;
                            CS <= CS + GP_3_L_A;
                        end else if (r_Dir == 2) begin 
                            r_Tx_Byte <= GP_3_L_A;
                            CS <= CS + GP_3_L_A;
                        end else if (r_Dir == 3) begin
                            r_Tx_Byte <= GP_3_L_A;
                            CS <= CS + GP_3_L_A;
                        end else if (r_Dir == 4) begin
                            r_Tx_Byte <= GP_3_L_A;
                            CS <= CS + GP_3_L_A;
                        end else if (r_Dir == 5) begin //AVANZA
                            r_Tx_Byte <= GP_3_L_F;
                            CS <= CS + GP_3_L_F;
                        end else if (r_Dir == 6) begin  
                            r_Tx_Byte <= GP_3_L_F;
                            CS <= CS + GP_3_L_F;
                        end else if (r_Dir == 7) begin  
                            r_Tx_Byte <= GP_3_L_F;
                            CS <= CS + GP_3_L_F;
                        end else if (r_Dir == 8) begin //RETROCEDE
                            r_Tx_Byte <= GP_3_L_A;
                            CS <= CS + GP_3_L_A;
                        end
                    end
                    19: begin                            //Motor 3 byte alto
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_3_H_A; 
                            CS <= CS + GP_3_H_A;
                        end else if (r_Dir == 1) begin  
                            r_Tx_Byte <= GP_3_H_A;
                            CS <= CS + GP_3_H_A;
                        end else if (r_Dir == 2) begin 
                            r_Tx_Byte <= GP_3_H_A;
                            CS <= CS + GP_3_H_A;
                        end else if (r_Dir == 3) begin
                            r_Tx_Byte <= GP_3_H_A;
                            CS <= CS + GP_3_H_A;
                        end else if (r_Dir == 4) begin
                            r_Tx_Byte <= GP_3_H_A;
                            CS <= CS + GP_3_H_A;
                        end else if (r_Dir == 5) begin //AVANZA
                            r_Tx_Byte <= GP_3_H_F;
                            CS <= CS + GP_3_H_F;
                        end else if (r_Dir == 6) begin  
                            r_Tx_Byte <= GP_3_H_F;
                            CS <= CS + GP_3_H_F;
                        end else if (r_Dir == 7) begin  
                            r_Tx_Byte <= GP_3_H_F;
                            CS <= CS + GP_3_H_F;
                        end else if (r_Dir == 8) begin //RETROCEDE
                            r_Tx_Byte <= GP_3_H_A;
                            CS <= CS + GP_3_H_A;
                        end 
                    end
                    20: begin
                        r_Tx_Byte <= MS_L;                             
                        CS <= CS + MS_L;
                    end
                    21: begin
                        r_Tx_Byte <= MS_H;                             
                        CS <= CS + MS_H;
                    end
                    ///////////////////////////////
                    //////     SERVO    4   ///////
                    ///////////////////////////////
                    22: begin
                        r_Tx_Byte <= ID_4;                             
                        CS <= CS + ID_4;
                    end
                    23:  begin                            //Motor 4 byte bajo
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_4_L_A; 
                            CS <= CS + GP_4_L_A;
                        end else if (r_Dir == 1) begin  
                            r_Tx_Byte <= GP_4_L_A;
                             CS <= CS + GP_4_L_A;
                         end else if (r_Dir == 2) begin 
                            r_Tx_Byte <= GP_4_L_A;
                            CS <= CS + GP_4_L_A;
                        end else if (r_Dir == 3) begin 
                            r_Tx_Byte <= GP_4_L_A; 
                            CS <= CS + GP_4_L_A;
                        end else if (r_Dir == 4) begin  //LEVANTA
                            r_Tx_Byte <= GP_4_L_E; 
                            CS <= CS + GP_4_L_E;
                        end else if (r_Dir == 5) begin 
                            r_Tx_Byte <= GP_4_L_E;
                            CS <= CS + GP_4_L_E;
                        end else if (r_Dir == 6) begin  //BAJA
                            r_Tx_Byte <= GP_4_L_A;
                            CS <= CS + GP_4_L_A;
                        end else if (r_Dir == 7) begin  
                            r_Tx_Byte <= GP_4_L_A;
                            CS <= CS + GP_4_L_A;
                        end else if (r_Dir == 8) begin 
                            r_Tx_Byte <= GP_4_L_A;
                            CS <= CS + GP_4_L_A;
                        end
                    end
                    24: begin                            //Motor 4 byte alto
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_4_H_A; 
                            CS <= CS + GP_4_H_A;
                        end else if (r_Dir == 1) begin  
                            r_Tx_Byte <= GP_4_H_A;
                            CS <= CS + GP_4_H_A;
                        end else if (r_Dir == 2) begin 
                            r_Tx_Byte <= GP_4_H_A;
                            CS <= CS + GP_4_H_A;
                        end else if (r_Dir == 3) begin 
                            r_Tx_Byte <= GP_4_H_A; 
                            CS <= CS + GP_4_H_A;
                        end else if (r_Dir == 4) begin  //LEVANTA
                            r_Tx_Byte <= GP_4_H_E; 
                            CS <= CS + GP_4_H_E;
                        end else if (r_Dir == 5) begin 
                            r_Tx_Byte <= GP_4_H_E;
                            CS <= CS + GP_4_H_E;
                        end else if (r_Dir == 6) begin  //BAJA
                            r_Tx_Byte <= GP_4_H_A;
                            CS <= CS + GP_4_H_A;
                        end else if (r_Dir == 7) begin  
                            r_Tx_Byte <= GP_4_H_A;
                            CS <= CS + GP_4_H_A;
                        end else if (r_Dir == 8) begin 
                            r_Tx_Byte <= GP_4_H_A;
                            CS <= CS + GP_4_H_A;
                        end
                    end   
                    25: begin
                        r_Tx_Byte <= MS_L;                             
                        CS <= CS + MS_L;
                    end
                    26: begin
                       r_Tx_Byte <= MS_H;                             
                        CS <= CS + MS_H;
                    end
                       
                    ///////////////////////////////
                    //////     SERVO    6   ///////
                    ///////////////////////////////
                    27: begin
                        r_Tx_Byte <= ID_6;                             
                        CS <= CS + ID_6;
                    end
                    28: begin                            //Motor 6 byte bajo
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_6_L_A; 
                            CS <= CS + GP_6_L_A;
                        end else if (r_Dir == 1) begin  
                            r_Tx_Byte <= GP_6_L_A;
                            CS <= CS + GP_6_L_A;
                        end else if (r_Dir == 2) begin 
                            r_Tx_Byte <= GP_6_L_A;
                            CS <= CS + GP_6_L_A;
                        end else if (r_Dir == 3) begin
                            r_Tx_Byte <= GP_6_L_A;
                            CS <= CS + GP_6_L_A;
                        end else if (r_Dir == 4) begin
                            r_Tx_Byte <= GP_6_L_A;
                            CS <= CS + GP_6_L_A;
                        end else if (r_Dir == 5) begin //AVANZA
                            r_Tx_Byte <= GP_6_L_F;
                            CS <= CS + GP_6_L_F;
                        end else if (r_Dir == 6) begin  
                            r_Tx_Byte <= GP_6_L_F;
                            CS <= CS + GP_6_L_F;
                        end else if (r_Dir == 7) begin  
                            r_Tx_Byte <= GP_6_L_F;
                            CS <= CS + GP_6_L_F;
                        end else if (r_Dir == 8) begin //RETROCEDE
                            r_Tx_Byte <= GP_6_L_A;
                            CS <= CS + GP_6_L_A;
                        end
                    end
                    29: begin                           //Motor 6 byte alto
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_6_H_A; 
                            CS <= CS + GP_6_H_A;
                        end else if (r_Dir == 1) begin  
                            r_Tx_Byte <= GP_6_H_A;
                            CS <= CS + GP_6_H_A;
                        end else if (r_Dir == 2) begin 
                            r_Tx_Byte <= GP_6_H_A;
                            CS <= CS + GP_6_H_A;
                        end else if (r_Dir == 3) begin
                            r_Tx_Byte <= GP_6_H_A;
                            CS <= CS + GP_6_H_A;
                        end else if (r_Dir == 4) begin
                            r_Tx_Byte <= GP_6_H_A;
                            CS <= CS + GP_6_H_A;
                        end else if (r_Dir == 5) begin //AVANZA
                            r_Tx_Byte <= GP_6_H_F;
                            CS <= CS + GP_6_H_F;
                        end else if (r_Dir == 6) begin  
                            r_Tx_Byte <= GP_6_H_F;
                            CS <= CS + GP_6_H_F;
                        end else if (r_Dir == 7) begin  
                            r_Tx_Byte <= GP_6_H_F;
                            CS <= CS + GP_6_H_F;
                        end else if (r_Dir == 8) begin //RETROCEDE
                            r_Tx_Byte <= GP_6_H_A;
                            CS <= CS + GP_6_H_A;
                        end  
                    end
                    30: begin
                        r_Tx_Byte <= MS_L;                             
                        CS <= CS + MS_L;
                    end
                    31: begin
                        r_Tx_Byte <= MS_H;                             
                        CS <= CS + MS_H;
                    end
                    ///////////////////////////////
                    //////     SERVO    7   ///////
                    ///////////////////////////////
                    32: begin
                        r_Tx_Byte <= ID_7;                             
                        CS <= CS + ID_7;
                    end
                    33: begin                           //Motor 7 byte bajo
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_7_L_A; 
                            CS <= CS + GP_7_L_A;
                        end else if (r_Dir == 1) begin  
                            r_Tx_Byte <= GP_7_L_A;
                            CS <= CS + GP_7_L_A;
                        end else if (r_Dir == 2) begin 
                            r_Tx_Byte <= GP_7_L_A;
                            CS <= CS + GP_7_L_A;
                        end else if (r_Dir == 3) begin 
                            r_Tx_Byte <= GP_7_L_A; 
                            CS <= CS + GP_7_L_A;
                        end else if (r_Dir == 4) begin  //LEVANTA
                            r_Tx_Byte <= GP_7_L_E; 
                            CS <= CS + GP_7_L_E;
                        end else if (r_Dir == 5) begin 
                            r_Tx_Byte <= GP_7_L_E;
                            CS <= CS + GP_7_L_E;
                        end else if (r_Dir == 6) begin  //BAJA
                            r_Tx_Byte <= GP_7_L_A;
                            CS <= CS + GP_7_L_A;
                        end else if (r_Dir == 7) begin  
                            r_Tx_Byte <= GP_7_L_A;
                            CS <= CS + GP_7_L_A;
                        end else if (r_Dir == 8) begin 
                            r_Tx_Byte <= GP_7_L_A;
                            CS <= CS + GP_7_L_A;
                        end  
                    end
                    34: begin                           //Motor 7 byte alto
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_7_H_A; 
                            CS <= CS + GP_7_H_A;
                        end else if (r_Dir == 1) begin  
                            r_Tx_Byte <= GP_7_H_A;
                            CS <= CS + GP_7_H_A;
                        end else if (r_Dir == 2) begin 
                            r_Tx_Byte <= GP_7_H_A;
                            CS <= CS + GP_7_H_A;
                        end else if (r_Dir == 3) begin 
                            r_Tx_Byte <= GP_7_H_A; 
                            CS <= CS + GP_7_H_A;
                        end else if (r_Dir == 4) begin  //LEVANTA
                            r_Tx_Byte <= GP_7_H_E; 
                            CS <= CS + GP_7_H_E;
                        end else if (r_Dir == 5) begin 
                            r_Tx_Byte <= GP_7_H_E;
                            CS <= CS + GP_7_H_E;
                        end else if (r_Dir == 6) begin  //BAJA
                            r_Tx_Byte <= GP_7_H_A;
                            CS <= CS + GP_7_H_A;
                        end else if (r_Dir == 7) begin  
                            r_Tx_Byte <= GP_7_H_A;
                            CS <= CS + GP_7_H_A;
                        end else if (r_Dir == 8) begin 
                            r_Tx_Byte <= GP_7_H_A;
                            CS <= CS + GP_7_H_A;
                        end   
                    end
                    35: begin
                        r_Tx_Byte <= MS_L;                             
                        CS <= CS + MS_L;
                    end
                    36: begin
                        r_Tx_Byte <= MS_H;                             
                        CS <= CS + MS_H;
                    end
                    
                    ///////////////////////////////
                    //////     SERVO    9   ///////
                    ///////////////////////////////
                    37: begin
                        r_Tx_Byte <= ID_9;                             
                        CS <= CS + ID_9;
                    end
                    38: begin                           //Motor 9 byte bajo
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_9_L_A; 
                            CS <= CS + GP_9_L_A;
                        end else if (r_Dir == 1) begin  
                            r_Tx_Byte <= GP_9_L_A;
                            CS <= CS + GP_9_L_A;
                        end else if (r_Dir == 2) begin //AVANCE
                            r_Tx_Byte <= GP_9_L_C;
                            CS <= CS + GP_9_L_C;
                        end else if (r_Dir == 3) begin
                            r_Tx_Byte <= GP_9_L_C;
                            CS <= CS + GP_9_L_C;
                        end else if (r_Dir == 4) begin
                            r_Tx_Byte <= GP_9_L_C;
                            CS <= CS + GP_9_L_C;
                        end else if (r_Dir == 5) begin //RETROCEDE
                            r_Tx_Byte <= GP_9_L_A;
                            CS <= CS + GP_9_L_A;
                        end else if (r_Dir == 6) begin  
                            r_Tx_Byte <= GP_9_L_A;
                            CS <= CS + GP_9_L_A;
                        end else if (r_Dir == 7) begin  
                            r_Tx_Byte <= GP_9_L_A;
                            CS <= CS + GP_9_L_A;
                        end else if (r_Dir == 8) begin //AVANZA
                            r_Tx_Byte <= GP_9_L_C;
                            CS <= CS + GP_9_L_C;
                        end  
                    end
                    39: begin                           //Motor 9 byte alto
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_9_H_A; 
                            CS <= CS + GP_9_H_A;
                        end else if (r_Dir == 1) begin  
                            r_Tx_Byte <= GP_9_H_A;
                            CS <= CS + GP_9_H_A;
                        end else if (r_Dir == 2) begin //AVANCE
                            r_Tx_Byte <= GP_9_H_C;
                            CS <= CS + GP_9_H_C;
                        end else if (r_Dir == 3) begin
                            r_Tx_Byte <= GP_9_H_C;
                            CS <= CS + GP_9_H_C;
                        end else if (r_Dir == 4) begin
                            r_Tx_Byte <= GP_9_H_C;
                            CS <= CS + GP_9_H_C;
                        end else if (r_Dir == 5) begin //RETROCEDE
                            r_Tx_Byte <= GP_9_H_A;
                            CS <= CS + GP_9_H_A;
                        end else if (r_Dir == 6) begin  
                            r_Tx_Byte <= GP_9_H_A;
                            CS <= CS + GP_9_H_A;
                        end else if (r_Dir == 7) begin  
                            r_Tx_Byte <= GP_9_H_A;
                            CS <= CS + GP_9_H_A;
                        end else if (r_Dir == 8) begin //AVANZA
                            r_Tx_Byte <= GP_9_H_C;
                            CS <= CS + GP_9_H_C;
                        end   
                    end
                    40: begin
                        r_Tx_Byte <= MS_L;                             
                        CS <= CS + MS_L;
                    end
                    41: begin
                        r_Tx_Byte <= MS_H;                             
                        CS <= CS + MS_H;
                    end
                    ///////////////////////////////
                    //////     SERVO    10  ///////
                    ///////////////////////////////
                    42: begin
                        r_Tx_Byte <= ID_10;                             
                        CS <= CS + ID_10;
                    end
                    43: begin                           //Motor 10 byte bajo
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_10_L_A; 
                            CS <= CS + GP_10_L_A;
                        end else if (r_Dir == 1) begin  //LEVANTA
                            r_Tx_Byte <= GP_10_L_B;
                             CS <= CS + GP_10_L_B;
                         end else if (r_Dir == 2) begin 
                            r_Tx_Byte <= GP_10_L_B;
                            CS <= CS + GP_10_L_B;
                        end else if (r_Dir == 3) begin //BAJA
                            r_Tx_Byte <= GP_10_L_A; 
                            CS <= CS + GP_10_L_A;
                        end else if (r_Dir == 4) begin
                            r_Tx_Byte <= GP_10_L_A; 
                            CS <= CS + GP_10_L_A;
                        end else if (r_Dir == 5) begin 
                            r_Tx_Byte <= GP_10_L_A;
                            CS <= CS + GP_10_L_A;
                        end else if (r_Dir == 6) begin  
                            r_Tx_Byte <= GP_10_L_A;
                            CS <= CS + GP_10_L_A;
                        end else if (r_Dir == 7) begin  //LEVANTA
                            r_Tx_Byte <= GP_10_L_B;
                            CS <= CS + GP_10_L_B;
                        end else if (r_Dir == 8) begin 
                            r_Tx_Byte <= GP_10_L_B;
                            CS <= CS + GP_10_L_B;
                        end  
                    end
                    44: begin                           //Motor 10 byte alto
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_10_H_A; 
                            CS <= CS + GP_10_H_A;
                        end else if (r_Dir == 1) begin  //LEVANTA
                            r_Tx_Byte <= GP_10_H_B;
                             CS <= CS + GP_10_H_B;
                         end else if (r_Dir == 2) begin 
                            r_Tx_Byte <= GP_10_H_B;
                            CS <= CS + GP_10_H_B;
                        end else if (r_Dir == 3) begin //BAJA
                            r_Tx_Byte <= GP_10_H_A; 
                            CS <= CS + GP_10_H_A;
                        end else if (r_Dir == 4) begin
                            r_Tx_Byte <= GP_10_H_A; 
                            CS <= CS + GP_10_H_A;
                        end else if (r_Dir == 5) begin 
                            r_Tx_Byte <= GP_10_H_A;
                            CS <= CS + GP_10_H_A;
                        end else if (r_Dir == 6) begin  
                            r_Tx_Byte <= GP_10_H_A;
                            CS <= CS + GP_10_H_A;
                        end else if (r_Dir == 7) begin  //LEVANTA
                            r_Tx_Byte <= GP_10_H_B;
                            CS <= CS + GP_10_H_B;
                        end else if (r_Dir == 8) begin 
                            r_Tx_Byte <= GP_10_H_B;
                            CS <= CS + GP_10_H_B;
                        end  
                    end
                    45: begin
                        r_Tx_Byte <= MS_L;                             
                        CS <= CS + MS_L;
                    end
                    46: begin
                        r_Tx_Byte <= MS_H;                             
                        CS <= CS + MS_H;
                    end
                    
                    ///////////////////////////////
                    //////     SERVO    12  ///////
                    ///////////////////////////////
                    47: begin
                        r_Tx_Byte <= ID_12;                             
                        CS <= CS + ID_12;
                    end
                    48: begin                            //Motor 12 byte bajo
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_12_L_A; 
                            CS <= CS + GP_12_L_A;
                        end else if (r_Dir == 1) begin  
                            r_Tx_Byte <= GP_12_L_A;
                            CS <= CS + GP_12_L_A;
                        end else if (r_Dir == 2) begin 
                            r_Tx_Byte <= GP_12_L_A;
                            CS <= CS + GP_12_L_A;
                        end else if (r_Dir == 3) begin
                            r_Tx_Byte <= GP_12_L_A;
                            CS <= CS + GP_12_L_A;
                        end else if (r_Dir == 4) begin
                            r_Tx_Byte <= GP_12_L_A;
                            CS <= CS + GP_12_L_A;
                        end else if (r_Dir == 5) begin //AVANZA
                            r_Tx_Byte <= GP_12_L_F;
                            CS <= CS + GP_12_L_F;
                        end else if (r_Dir == 6) begin  
                            r_Tx_Byte <= GP_12_L_F;
                            CS <= CS + GP_12_L_F;
                        end else if (r_Dir == 7) begin  
                            r_Tx_Byte <= GP_12_L_F;
                            CS <= CS + GP_12_L_F;
                        end else if (r_Dir == 8) begin //RETROCEDE
                            r_Tx_Byte <= GP_12_L_A;
                            CS <= CS + GP_12_L_A;
                        end
                    end
                    49: begin                           //Motor 12 byte alto
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_12_H_A; 
                            CS <= CS + GP_12_H_A;
                        end else if (r_Dir == 1) begin  
                            r_Tx_Byte <= GP_12_H_A;
                            CS <= CS + GP_12_H_A;
                        end else if (r_Dir == 2) begin 
                            r_Tx_Byte <= GP_12_H_A;
                            CS <= CS + GP_12_H_A;
                        end else if (r_Dir == 3) begin
                            r_Tx_Byte <= GP_12_H_A;
                            CS <= CS + GP_12_H_A;
                        end else if (r_Dir == 4) begin
                            r_Tx_Byte <= GP_12_H_A;
                            CS <= CS + GP_12_H_A;
                        end else if (r_Dir == 5) begin //AVANZA
                            r_Tx_Byte <= GP_12_H_F;
                            CS <= CS + GP_12_H_F;
                        end else if (r_Dir == 6) begin  
                            r_Tx_Byte <= GP_12_H_F;
                            CS <= CS + GP_12_H_F;
                        end else if (r_Dir == 7) begin  
                            r_Tx_Byte <= GP_12_H_F;
                            CS <= CS + GP_12_H_F;
                        end else if (r_Dir == 8) begin //RETROCEDE
                            r_Tx_Byte <= GP_12_H_A;
                            CS <= CS + GP_12_H_A;
                        end  
                    end
                    50: begin
                        r_Tx_Byte <= MS_L;                             
                        CS <= CS + MS_L;
                    end
                    51: begin
                        r_Tx_Byte <= MS_H;                             
                        CS <= CS + MS_H;
                    end
                    ///////////////////////////////
                    //////     SERVO    13  ///////
                    ///////////////////////////////
                    52: begin
                        r_Tx_Byte <= ID_13;                             
                        CS <= CS + ID_13;
                    end
                    53: begin                           //Motor 13 byte bajo
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_13_L_A; 
                            CS <= CS + GP_13_L_A;
                        end else if (r_Dir == 1) begin  
                            r_Tx_Byte <= GP_13_L_A;
                            CS <= CS + GP_13_L_A;
                        end else if (r_Dir == 2) begin 
                            r_Tx_Byte <= GP_13_L_A;
                            CS <= CS + GP_13_L_A;
                        end else if (r_Dir == 3) begin 
                            r_Tx_Byte <= GP_13_L_A; 
                            CS <= CS + GP_13_L_A;
                        end else if (r_Dir == 4) begin  //LEVANTA
                            r_Tx_Byte <= GP_13_L_E; 
                            CS <= CS + GP_13_L_E;
                        end else if (r_Dir == 5) begin 
                            r_Tx_Byte <= GP_13_L_E;
                            CS <= CS + GP_13_L_E;
                        end else if (r_Dir == 6) begin  //BAJA
                            r_Tx_Byte <= GP_13_L_A;
                            CS <= CS + GP_13_L_A;
                        end else if (r_Dir == 7) begin  
                            r_Tx_Byte <= GP_13_L_A;
                            CS <= CS + GP_13_L_A;
                        end else if (r_Dir == 8) begin 
                            r_Tx_Byte <= GP_13_L_A;
                            CS <= CS + GP_13_L_A;
                        end  
                    end
                    54: begin                           //Motor 13 byte alto
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_13_H_A; 
                            CS <= CS + GP_13_H_A;
                        end else if (r_Dir == 1) begin  
                            r_Tx_Byte <= GP_13_H_A;
                            CS <= CS + GP_13_H_A;
                        end else if (r_Dir == 2) begin 
                            r_Tx_Byte <= GP_13_H_A;
                            CS <= CS + GP_13_H_A;
                        end else if (r_Dir == 3) begin 
                            r_Tx_Byte <= GP_13_H_A; 
                            CS <= CS + GP_13_H_A;
                        end else if (r_Dir == 4) begin  //LEVANTA
                            r_Tx_Byte <= GP_13_H_E; 
                            CS <= CS + GP_13_H_E;
                        end else if (r_Dir == 5) begin 
                            r_Tx_Byte <= GP_13_H_E;
                            CS <= CS + GP_13_H_E;
                        end else if (r_Dir == 6) begin  //BAJA
                            r_Tx_Byte <= GP_13_H_A;
                            CS <= CS + GP_13_H_A;
                        end else if (r_Dir == 7) begin  
                            r_Tx_Byte <= GP_13_H_A;
                            CS <= CS + GP_13_H_A;
                        end else if (r_Dir == 8) begin 
                            r_Tx_Byte <= GP_13_H_A;
                            CS <= CS + GP_13_H_A;
                        end   
                    end

                    55: begin
                        r_Tx_Byte <= MS_L;                             
                        CS <= CS + MS_L;
                    end
                    56: begin
                        r_Tx_Byte <= MS_H;                             
                        CS <= CS + MS_H;
                    end
                    
                    ///////////////////////////////
                    //////     SERVO    15  ///////
                    ///////////////////////////////
                    57: begin
                        r_Tx_Byte <= ID_15;                             
                        CS <= CS + ID_15;
                    end
                    58: begin                            //Motor 15 byte bajo
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_15_L_A; 
                            CS <= CS + GP_15_L_A;
                        end else if (r_Dir == 1) begin  
                            r_Tx_Byte <= GP_15_L_A;
                            CS <= CS + GP_15_L_A;
                        end else if (r_Dir == 2) begin //AVANCE
                            r_Tx_Byte <= GP_15_L_C;
                            CS <= CS + GP_15_L_C;
                        end else if (r_Dir == 3) begin
                            r_Tx_Byte <= GP_15_L_C;
                            CS <= CS + GP_15_L_C;
                        end else if (r_Dir == 4) begin
                            r_Tx_Byte <= GP_15_L_C;
                            CS <= CS + GP_15_L_C;
                        end else if (r_Dir == 5) begin //RETROCEDE
                            r_Tx_Byte <= GP_15_L_A;
                            CS <= CS + GP_15_L_A;
                        end else if (r_Dir == 6) begin  
                            r_Tx_Byte <= GP_15_L_A;
                            CS <= CS + GP_15_L_A;
                        end else if (r_Dir == 7) begin  
                            r_Tx_Byte <= GP_15_L_A;
                            CS <= CS + GP_15_L_A;
                        end else if (r_Dir == 8) begin //AVANZA
                            r_Tx_Byte <= GP_15_L_C;
                            CS <= CS + GP_15_L_C;
                        end
                    end
                    59: begin                            //Motor 15 byte alto
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_15_H_A; 
                            CS <= CS + GP_15_H_A;
                        end else if (r_Dir == 1) begin  
                            r_Tx_Byte <= GP_15_H_A;
                            CS <= CS + GP_15_H_A;
                        end else if (r_Dir == 2) begin //AVANCE
                            r_Tx_Byte <= GP_15_H_C;
                            CS <= CS + GP_15_H_C;
                        end else if (r_Dir == 3) begin
                            r_Tx_Byte <= GP_15_H_C;
                            CS <= CS + GP_15_H_C;
                        end else if (r_Dir == 4) begin
                            r_Tx_Byte <= GP_15_H_C;
                            CS <= CS + GP_15_H_C;
                        end else if (r_Dir == 5) begin //RETROCEDE
                            r_Tx_Byte <= GP_15_H_A;
                            CS <= CS + GP_15_H_A;
                        end else if (r_Dir == 6) begin  
                            r_Tx_Byte <= GP_15_H_A;
                            CS <= CS + GP_15_H_A;
                        end else if (r_Dir == 7) begin  
                            r_Tx_Byte <= GP_15_H_A;
                            CS <= CS + GP_15_H_A;
                        end else if (r_Dir == 8) begin //AVANZA
                            r_Tx_Byte <= GP_15_H_C;
                            CS <= CS + GP_15_H_C;
                        end
                    end

                    60: begin
                        r_Tx_Byte <= MS_L;                             
                        CS <= CS + MS_L;
                    end
                    61: begin
                        r_Tx_Byte <= MS_H;                             
                        CS <= CS + MS_H;
                    end
                    ///////////////////////////////
                    //////     SERVO    16  ///////
                    ///////////////////////////////
                    62: begin
                        r_Tx_Byte <= ID_16;                             
                        CS <= CS + ID_16;
                    end
                    43: begin                           //Motor 16 byte bajo
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_16_L_A; 
                            CS <= CS + GP_16_L_A;
                        end else if (r_Dir == 1) begin  //LEVANTA
                            r_Tx_Byte <= GP_16_L_B;
                             CS <= CS + GP_16_L_B;
                         end else if (r_Dir == 2) begin 
                            r_Tx_Byte <= GP_16_L_B;
                            CS <= CS + GP_16_L_B;
                        end else if (r_Dir == 3) begin //BAJA
                            r_Tx_Byte <= GP_16_L_A; 
                            CS <= CS + GP_16_L_A;
                        end else if (r_Dir == 4) begin
                            r_Tx_Byte <= GP_16_L_A; 
                            CS <= CS + GP_16_L_A;
                        end else if (r_Dir == 5) begin 
                            r_Tx_Byte <= GP_16_L_A;
                            CS <= CS + GP_16_L_A;
                        end else if (r_Dir == 6) begin  
                            r_Tx_Byte <= GP_16_L_A;
                            CS <= CS + GP_16_L_A;
                        end else if (r_Dir == 7) begin  //LEVANTA
                            r_Tx_Byte <= GP_16_L_B;
                            CS <= CS + GP_16_L_B;
                        end else if (r_Dir == 8) begin 
                            r_Tx_Byte <= GP_16_L_B;
                            CS <= CS + GP_16_L_B;
                        end  
                    end
                    44: begin                           //Motor 16 byte alto
                        if (r_Dir == 0) begin           
                            r_Tx_Byte <= GP_16_H_A; 
                            CS <= CS + GP_16_H_A;
                        end else if (r_Dir == 1) begin  //LEVANTA
                            r_Tx_Byte <= GP_16_H_B;
                             CS <= CS + GP_16_H_B;
                         end else if (r_Dir == 2) begin 
                            r_Tx_Byte <= GP_16_H_B;
                            CS <= CS + GP_16_H_B;
                        end else if (r_Dir == 3) begin //BAJA
                            r_Tx_Byte <= GP_16_H_A; 
                            CS <= CS + GP_16_H_A;
                        end else if (r_Dir == 4) begin
                            r_Tx_Byte <= GP_16_H_A; 
                            CS <= CS + GP_16_H_A;
                        end else if (r_Dir == 5) begin 
                            r_Tx_Byte <= GP_16_H_A;
                            CS <= CS + GP_16_H_A;
                        end else if (r_Dir == 6) begin  
                            r_Tx_Byte <= GP_16_H_A;
                            CS <= CS + GP_16_H_A;
                        end else if (r_Dir == 7) begin  //LEVANTA
                            r_Tx_Byte <= GP_16_H_B;
                            CS <= CS + GP_16_H_B;
                        end else if (r_Dir == 8) begin 
                            r_Tx_Byte <= GP_16_H_B;
                            CS <= CS + GP_16_H_B;
                        end  
                    end

                    65: begin
                        r_Tx_Byte <= MS_L;                             
                        CS <= CS + MS_L;
                    end
                    66: begin
                        r_Tx_Byte <= MS_H;                             
                        CS <= CS + MS_H;
                    end
                   

                    67: begin                        
                        r_Tx_Byte <= ~CS;                             
                        r_Dir <= r_Dir + 1; // Incrementa r_Dir
                        if (r_Dir == 8) begin // Si ya no necesitas incrementar r_Dir
                            r_Dir <= 0; // Reinicia r_Dir
                        end
                    end
                    default: begin
                        o_LastByte <= 1;   
                        //r_Dir <= 0;   
                        CS <= 0;              
                    end
                endcase                 
            end else begin
                r_Contador <= r_Contador;
                r_Tx_Byte <= r_Tx_Byte;
                CS <= CS;
            end  
                                        
        end else begin
            o_LastByte <= 0;
            r_Contador <= 0;
            r_Tx_Byte <= 0;
            CS <= 0;
        end                           
    end       
end   

endmodule
