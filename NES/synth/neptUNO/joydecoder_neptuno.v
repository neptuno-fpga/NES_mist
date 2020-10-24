`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:00:25 07/20/2018 
// Design Name: 
// Module Name:    joydecoder 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module joydecoder_neptuno (
  input wire clk_i,
  input wire joy_data_i,
  output wire joy_clk_o,
  output wire joy_load_o,
  output wire joy1_up_o,
  output wire joy1_down_o,
  output wire joy1_left_o,
  output wire joy1_right_o,
  output wire joy1_fire1_o,
  output wire joy1_fire2_o,
  output wire joy1_fire3_o,
  output wire joy1_start_o,
  output wire joy2_up_o,
  output wire joy2_down_o,
  output wire joy2_left_o,
  output wire joy2_right_o,
  output wire joy2_fire1_o,
  output wire joy2_fire2_o,
  output wire joy2_fire3_o,
  output wire joy2_start_o 
  );
  
  reg [7:0] clkdivider = 8'h00;
  //assign joy_clk_o = clkdivider[7];
  
  
  // clkdivider[0] = clk_i/2
  // clkdivider[1] = clk_i/4
  // ...
  //clkdivider[n] = clk_i /  2^(n+1)
  // 
  // Entre 1 y 4 mhz es suficiente para que el instanciado de 6 botones funcione bien
  //
  // Ej: usando un reloj de entrada de 50mhz 

  //  50,000,000 / (2^5)   // 2^(4+1)
  //  50,000,000 / 32  = 1,562500 Mhz
  //  assign joy_clk_o = clkdivider[4];
  
  assign joy_clk_o = clkdivider[3];  
  
  
  always @(posedge clk_i)
    clkdivider <= clkdivider + 8'd1;
  wire clkenable = (clkdivider == 8'h00);

  reg [15:0] joyswitches = 16'hFFFF;//16'h0000;
  assign joy1_up_o    = joyswitches[7];
  assign joy1_down_o  = joyswitches[6];
  assign joy1_left_o  = joyswitches[5];
  assign joy1_right_o = joyswitches[4];
  assign joy1_fire1_o = joyswitches[3];
  assign joy1_fire2_o = joyswitches[2];
  assign joy1_fire3_o = joyswitches[1];
  assign joy1_start_o = joyswitches[0];
  assign joy2_up_o    = joyswitches[15];
  assign joy2_down_o  = joyswitches[14];
  assign joy2_left_o  = joyswitches[13];
  assign joy2_right_o = joyswitches[12];
  assign joy2_fire1_o = joyswitches[11];
  assign joy2_fire2_o = joyswitches[10];
  assign joy2_fire3_o = joyswitches[9];
  assign joy2_start_o = joyswitches[8];
  
  reg [3:0] state = 4'd0;
  assign joy_load_o = ~(state == 4'd0);
  
  always @(posedge clk_i) begin
    if (clkenable == 1'b1) begin
      state <= state + 4'd1;
      //joyswitches[state] <= ~joy_data_i;
      case (state)
//        4'd0:  joyswitches[0]  <= ~joy_data_i;
//        4'd1:  joyswitches[1]  <= ~joy_data_i;
//        4'd2:  joyswitches[2]  <= ~joy_data_i;
//        4'd3:  joyswitches[3]  <= ~joy_data_i;
//        4'd4:  joyswitches[4]  <= ~joy_data_i;
//        4'd5:  joyswitches[5]  <= ~joy_data_i;
//        4'd6:  joyswitches[6]  <= ~joy_data_i;
//        4'd7:  joyswitches[7]  <= ~joy_data_i;
//        4'd8:  joyswitches[8]  <= ~joy_data_i;
//        4'd9:  joyswitches[9]  <= ~joy_data_i;
//        4'd10: joyswitches[10] <= ~joy_data_i;
//        4'd11: joyswitches[11] <= ~joy_data_i;
//        4'd12: joyswitches[12] <= ~joy_data_i;
//        4'd13: joyswitches[13] <= ~joy_data_i;
//        4'd14: joyswitches[14] <= ~joy_data_i;
//        4'd15: joyswitches[15] <= ~joy_data_i;
        4'd0:  joyswitches[0]  <= joy_data_i;
        4'd1:  joyswitches[1]  <= joy_data_i;
        4'd2:  joyswitches[2]  <= joy_data_i;
        4'd3:  joyswitches[3]  <= joy_data_i;
        4'd4:  joyswitches[4]  <= joy_data_i;
        4'd5:  joyswitches[5]  <= joy_data_i;
        4'd6:  joyswitches[6]  <= joy_data_i;
        4'd7:  joyswitches[7]  <= joy_data_i;
        4'd8:  joyswitches[8]  <= joy_data_i;
        4'd9:  joyswitches[9]  <= joy_data_i;
        4'd10: joyswitches[10] <= joy_data_i;
        4'd11: joyswitches[11] <= joy_data_i;
        4'd12: joyswitches[12] <= joy_data_i;
        4'd13: joyswitches[13] <= joy_data_i;
        4'd14: joyswitches[14] <= joy_data_i;
        4'd15: joyswitches[15] <= joy_data_i;		  
		  
		  
      endcase
    end
  end
endmodule
