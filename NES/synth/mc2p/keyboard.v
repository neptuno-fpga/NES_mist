

module keyboard
(
    input  clk,
    input  reset,
    input  ps2_kbd_clk,
    input  ps2_kbd_data,

    output [7:0] joystick_0,
    output [7:0] joystick_1,
    
    output reg [11:0] powerpad,
    output reg fds_eject,

    output reg [7:0] osd_o,

    input osd_enable
);

reg        pressed;
reg        e0;
wire [7:0] keyb_data;
wire       keyb_valid;

// PS/2 interface
ps2_intf ps2(
    clk,
    !reset,
        
    ps2_kbd_clk,
    ps2_kbd_data,

    // Byte-wide data interface - only valid for one clock
    // so must be latched externally if required
    keyb_data,
    keyb_valid
);

reg joy_num;
reg [7:0] buttons;
assign joystick_0 = joy_num ? 7'b0 : buttons;
assign joystick_1 = joy_num ? buttons : 7'b0;

always @(posedge reset or posedge clk) begin
    
    if(reset) begin
        pressed <= 1'b0;
        e0 <= 1'b0;
        joy_num <= 1'b0;
        buttons <= 8'd0;
    end else begin
        if (keyb_valid) begin
            if (keyb_data == 8'HE0)
                e0 <=1'b1;
            else if (keyb_data == 8'HF0)
                pressed <= 1'b0;
            else begin

                osd_o[4:0] <= 5'b11111;

                case({e0, keyb_data})
                    9'H016: if(pressed) joy_num <= 1'b0; // 1
                    9'H01E: if(pressed) joy_num <= 1'b1; // 2

                    9'H175: begin buttons[4] <= pressed; if(pressed) osd_o[4:0] <= 5'b11110; end// arrow up
                    9'H172: begin buttons[5] <= pressed; if(pressed) osd_o[4:0] <= 5'b11101; end// arrow down
                    9'H16B: begin buttons[6] <= pressed; if(pressed) osd_o[4:0] <= 5'b11011; end// arrow left
                    9'H174: begin buttons[7] <= pressed; if(pressed) osd_o[4:0] <= 5'b10111; end// arrow right
                    
                    9'H029: buttons[0] <= pressed; // Space
                    9'H011: buttons[1] <= pressed; // Left Alt
                    9'H00d: buttons[2] <= pressed; // Tab
                    9'H076: buttons[3] <= pressed; // Escape
                    
                    9'H024: powerpad[0] <= pressed; // E
                    9'H02D: powerpad[1] <= pressed; // R
                    9'H02C: powerpad[2] <= pressed; // T
                    9'H035: powerpad[3] <= pressed; // Y
                    9'H023: powerpad[4] <= pressed; // D
                    9'H02B: powerpad[5] <= pressed; // F
                    9'H034: powerpad[6] <= pressed; // G
                    9'H033: powerpad[7] <= pressed; // H
                    9'H021: powerpad[8] <= pressed; // C
                    9'H02A: powerpad[9] <= pressed; // V
                    9'H032: powerpad[10] <= pressed;    // B
                    9'H031: powerpad[11] <= pressed;    // N

                    9'H17D: fds_eject <= pressed; //PgUp

                    //OSD
                    9'H05A: if(pressed) osd_o[4:0] <= 5'b01111; // enter

                    9'h01c: if(pressed) osd_o[4:0] <= 5'b00000; // A
                    9'h032: if(pressed) osd_o[4:0] <= 5'b00001; // B
                    9'h021: if(pressed) osd_o[4:0] <= 5'b00010; // C
                    9'h023: if(pressed) osd_o[4:0] <= 5'b00011; // D
                    9'h024: if(pressed) osd_o[4:0] <= 5'b00100; // E
                    9'h02b: if(pressed) osd_o[4:0] <= 5'b00101; // F
                    9'h034: if(pressed) osd_o[4:0] <= 5'b00110; // G
                    9'h033: if(pressed) osd_o[4:0] <= 5'b00111; // H
                    9'h043: if(pressed) osd_o[4:0] <= 5'b01000; // I
                    9'h03b: if(pressed) osd_o[4:0] <= 5'b01001; // J
                    9'h042: if(pressed) osd_o[4:0] <= 5'b01010; // K
                    9'h04b: if(pressed) osd_o[4:0] <= 5'b01011; // L
                    9'h03a: if(pressed) osd_o[4:0] <= 5'b01100; // M
                    9'h031: if(pressed) osd_o[4:0] <= 5'b01101; // N
                    9'h044: if(pressed) osd_o[4:0] <= 5'b01110; // O
                    9'h04d: if(pressed) osd_o[4:0] <= 5'b10000; // P
                    9'h015: if(pressed) osd_o[4:0] <= 5'b10001; // Q
                    9'h02d: if(pressed) osd_o[4:0] <= 5'b10010; // R
                    9'h01b: if(pressed) osd_o[4:0] <= 5'b10011; // S
                    9'h02c: if(pressed) osd_o[4:0] <= 5'b10100; // T
                    9'h03c: if(pressed) osd_o[4:0] <= 5'b10101; // U
                    9'h02a: if(pressed) osd_o[4:0] <= 5'b10110; // V
                    9'h01d: if(pressed) osd_o[4:0] <= 5'b11000; // W
                    9'h022: if(pressed) osd_o[4:0] <= 5'b11001; // X
                    9'h035: if(pressed) osd_o[4:0] <= 5'b11010; // Y
                    9'h01a: if(pressed) osd_o[4:0] <= 5'b11100; // Z

                    9'h007: if(pressed) osd_o[7:5] <= 3'b011; else osd_o[7:5] <= 3'b111; // F12
                endcase;

                pressed <= 1'b1;
                e0 <= 1'b0;



    


         end 
      end 
   end 
end 

endmodule
