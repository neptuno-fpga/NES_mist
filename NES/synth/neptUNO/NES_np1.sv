// Copyright (c) 2012-2013 Ludvig Strigeus
// This program is GPL Licensed. See COPYING for the full license.

`timescale 1ns / 1ps

//============================================================================
//
//  Multicore 2+ Top by Victor Trucco
//
//============================================================================
//
//============================================================================
//
//  neptUNO adapted by Delgrom
//
//============================================================================
`default_nettype none

module NES_np1(  
   // Clocks
    input wire  clock_50_i,

    // Buttons
    //input wire [4:1]    btn_n_i,

    // SRAM (IS61WV102416BLL-10TLI)
    output wire [19:0]sram_addr_o  = 20'b00000000000000000000,
    inout wire  [15:0]sram_data_io   = 8'bzzzzzzzzbzzzzzzzz,
    output wire sram_we_n_o     = 1'b1,
    output wire sram_oe_n_o     = 1'b1,
    output wire sram_ub_n_o     = 1'b1,
	output wire sram_lb_n_o     = 1'b1,
        
    // SDRAM (W9825G6KH-6)
    output [12:0] SDRAM_A,
    output  [1:0] SDRAM_BA,
    inout  [15:0] SDRAM_DQ,
    output        SDRAM_DQMH,
    output        SDRAM_DQML,
    output        SDRAM_CKE,
    output        SDRAM_nCS,
    output        SDRAM_nWE,
    output        SDRAM_nRAS,
    output        SDRAM_nCAS,
    output        SDRAM_CLK,

    // PS2
    inout wire  ps2_clk_io        = 1'bz,
    inout wire  ps2_data_io       = 1'bz,
    inout wire  ps2_mouse_clk_io  = 1'bz,
    inout wire  ps2_mouse_data_io = 1'bz,

    // SD Card
    output wire sd_cs_n_o         = 1'bZ,
    output wire sd_sclk_o         = 1'bZ,
    output wire sd_mosi_o         = 1'bZ,
    input wire  sd_miso_i,

    // Joysticks
    output wire joy_clock_o       = 1'b1,
    output wire joy_load_o        = 1'b1,
    input  wire joy_data_i,
    output wire joy_p7_o          = 1'b1,

    // Audio
    output      AUDIO_L,
    output      AUDIO_R,
    //input wire  ear_i,
    //output wire mic_o             = 1'b0,

    // VGA
    output  [4:0] VGA_R,
    output  [4:0] VGA_G,
    output  [4:0] VGA_B,
    output        VGA_HS,
    output        VGA_VS,

    //STM32
    input wire  stm_tx_i,
    output wire stm_rx_o,
    output wire stm_rst_o           = 1'bz, // '0' to hold the microcontroller reset line, to free the SD card
   
    input         SPI_SCK,
    output        SPI_DO,
    input         SPI_DI,
    input         SPI_SS2,
    //output wire   SPI_nWAIT        = 1'b1, // '0' to hold the microcontroller data streaming

    //inout [31:0] GPIO,

    output LED                    = 1'b1, // '0' is LED on
	 
	// SONIDO I2S
	output SCLK,
	output LRCLK,
	output MCLK,
	output SDIN	 	
);


//---------------------------------------------------------
//-- MC2+ defaults
//---------------------------------------------------------
//assign GPIO = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
assign stm_rst_o    = 1'bZ;
assign stm_rx_o = 1'bZ;

//no SRAM for this core
assign sram_we_n_o  = 1'b1;
assign sram_oe_n_o  = 1'b1;

//all the SD reading goes thru the microcontroller for this core
assign sd_cs_n_o = 1'bZ;
assign sd_sclk_o = 1'bZ;
assign sd_mosi_o = 1'bZ;

wire joy1_up_i, joy1_down_i, joy1_left_i, joy1_right_i, joy1_p6_i, joy1_p9_i;
wire joy2_up_i, joy2_down_i, joy2_left_i, joy2_right_i, joy2_p6_i, joy2_p9_i;

joydecoder joystick_serial  (
    .clk          ( clk ), 	
    .joy_data     ( joy_data_i ),
    .joy_clk      ( joy_clock_o ),
    .joy_load     ( joy_load_o ),
	 .clock_locked ( clock_locked ),

    .joy1up       ( joy1_up_i ),
    .joy1down     ( joy1_down_i ),
    .joy1left     ( joy1_left_i ),
    .joy1right    ( joy1_right_i ),
    .joy1fire1    ( joy1_p6_i ),
    .joy1fire2    ( joy1_p9_i ),

    .joy2up       ( joy2_up_i ),
    .joy2down     ( joy2_down_i ),
    .joy2left     ( joy2_left_i ),
    .joy2right    ( joy2_right_i ),
    .joy2fire1    ( joy2_p6_i ),
    .joy2fire2    ( joy2_p9_i )
); 




reg [7:0] pump_s = 8'b11111111;
PumpSignal PumpSignal (clk, ~clock_locked, downloading, pump_s);

//-----------------------------------------------------------------


// the configuration string is returned to the io controller to allow
// it to control the menu on the OSD 
parameter CONF_STR = {
            "P,CORE_NAME.ini;",
            "S0,NES,Load NES Game...;",
//            "S1,FDS,Load FDS Game...;",
//            "S2,NSF,Load NSF Sound...;",
//            "S3,BIN,Load FDS BIOS...;",
            "OEF,System Type,NTSC,PAL,Dendy;",
            "OG,Scandoubler,On,Off;",
            "OCD,Scanlines,OFF,25%,50%,75%;",
            "O5,Joystick swap,OFF,ON;",
            "O6,Invert mirroring,OFF,ON;",
            "O7,Hide overscan,OFF,ON;",
            "OHK,Palette,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15;",		
 //           "O9B,Disk side,Auto,A,B,C,D,None;",
            "T0,Reset;",
            "V,v2.0-test1;"
};

wire [31:0] status;

wire arm_reset = status[0];
wire [1:0] system_type = status[15:14];
wire pal_video = |system_type;
wire [1:0] scanlines = status[13:12];
wire joy_swap = status[5];
wire mirroring_osd = status[6];
wire overscan_osd = status[7];
wire [3:0] palette2_osd = status[20:17];
wire [2:0] diskside_osd = status[11:9];

wire scandoubler_disable;
wire ypbpr;
wire no_csync;
//wire ps2_kbd_clk, ps2_kbd_data;

wire [7:0] core_joy_A;
wire [7:0] core_joy_B;
wire [1:0] buttons;
wire [1:0] switches;

/*
user_io #(.STRLEN($size(CONF_STR)>>3)) user_io(
   .clk_sys(clk),
   .conf_str(CONF_STR),
   // the spi interface

   .SPI_CLK(SPI_SCK),
   .SPI_SS_IO(CONF_DATA0),
   .SPI_MISO(SPI_DO),   // tristate handling inside user_io
   .SPI_MOSI(SPI_DI),

   .switches(switches),
   .buttons(buttons),
   .scandoubler_disable(scandoubler_disable),
   .ypbpr(ypbpr),
   .no_csync(no_csync),

   .joystick_0(core_joy_A),
   .joystick_1(core_joy_B),

   .status(status),

   .ps2_kbd_clk(ps2_kbd_clk),
   .ps2_kbd_data(ps2_kbd_data)
);
*/


wire [7:0] joyA = joy_swap ? core_joy_B : core_joy_A;
wire [7:0] joyB = joy_swap ? core_joy_A : core_joy_B;

//wire [7:0] nes_joy_A = { joyA[0], joyA[1], joyA[2], joyA[3], joyA[7], joyA[6], joyA[5], joyA[4] } | kbd_joy0;
//wire [7:0] nes_joy_B = { joyB[0], joyB[1], joyB[2], joyB[3], joyB[7], joyB[6], joyB[5], joyB[4] } | kbd_joy1;

//                         R          L       U        D      START                      SELECT                    B1 (CORRER)       B2 (salto)
wire [7:0] nes_joy_A = { joyA[0], joyA[1], joyA[2], joyA[3], m_fireE | m_fireG,    joyA[6] | m_fireF    , joyA[4] | joyA[7], joyA[5] | m_fireD};
wire [7:0] nes_joy_B = { joyB[0], joyB[1], joyB[2], joyB[3], m_fire2E | m_fire2G,  joyB[6] | m_fire2F,    joyB[4] | joyB[7], joyB[5] | m_fire2D};

 
  wire clock_locked;
  wire clk85;
  wire clk;
  clk clock_21mhz(.inclk0(clock_50_i), .c0(clk85), .c1(clk), .c2(SDRAM_CLK), .locked(clock_locked));
  //assign SDRAM_CLK = clk85;

  // reset after download
  reg [7:0] download_reset_cnt;
  wire download_reset = download_reset_cnt != 0;
  always @(posedge clk) begin
    if(downloading)
        download_reset_cnt <= 8'd255;
    else if(!loader_busy && download_reset_cnt != 0)
        download_reset_cnt <= download_reset_cnt - 8'd1;
 end

  // hold machine in reset until first download starts
  reg init_reset = 1;
  always @(posedge clk) begin
    if(downloading) init_reset <= 1'b0;
  end
  
  wire [8:0] cycle;
  wire [8:0] scanline;
  wire [15:0] sample;
  wire [5:0] color;
  wire joypad_strobe;
  wire [1:0] joypad_clock;
  wire [21:0] memory_addr_cpu, memory_addr_ppu;
  wire memory_read_cpu, memory_read_ppu;
  wire memory_write_cpu, memory_write_ppu;
  wire [7:0] memory_din_cpu, memory_din_ppu;
  wire [7:0] memory_dout_cpu, memory_dout_ppu;
  reg [7:0] joypad_bits, joypad_bits2;
  reg [7:0] powerpad_d3, powerpad_d4;
  reg [1:0] last_joypad_clock;
  wire [31:0] dbgadr;
  wire [1:0] dbgctr;

  wire [1:0] nes_ce;

    always @(posedge clk) begin
        if (reset_nes) begin
            joypad_bits <= 8'd0;
            joypad_bits2 <= 8'd0;
            powerpad_d3 <= 8'd0;
            powerpad_d4 <= 8'd0;
            last_joypad_clock <= 2'b00;
        end else begin
            if (joypad_strobe) begin
                joypad_bits <= nes_joy_A;
                joypad_bits2 <= nes_joy_B;
                powerpad_d4 <= {4'b0000, powerpad[7], powerpad[11], powerpad[2], powerpad[3]};
                powerpad_d3 <= {powerpad[6], powerpad[10], powerpad[9], powerpad[5], powerpad[8], powerpad[4], powerpad[0], powerpad[1]};
            end
            if (!joypad_clock[0] && last_joypad_clock[0]) begin
                joypad_bits <= {1'b0, joypad_bits[7:1]};
            end 
            if (!joypad_clock[1] && last_joypad_clock[1]) begin
                joypad_bits2 <= {1'b0, joypad_bits2[7:1]};
                powerpad_d4 <= {1'b0, powerpad_d4[7:1]};
                powerpad_d3 <= {1'b0, powerpad_d3[7:1]};
            end 
            last_joypad_clock <= joypad_clock;
        end
  end
  
  // Loader
  wire [7:0] loader_input =  (loader_busy && !downloading) ? nsf_data : ioctl_dout;
  wire       loader_clk;
  wire [21:0] loader_addr;
  wire [7:0] loader_write_data;
  wire loader_reset = !download_reset; //loader_conf[0];
  wire loader_write;
  wire [31:0] loader_flags;
  reg [31:0] mapper_flags;
  wire loader_done, loader_fail;
    wire loader_busy;
    wire type_bios = (menu_index == 8'd3);
    wire is_bios = 0;//type_bios;
//    wire type_nes = (menu_index == 0) || (menu_index == {2'd0, 6'h1});
//    wire type_fds = (menu_index == {2'd1, 6'h1});
//    wire type_nsf = (menu_index == {2'd2, 6'h1});
    wire type_nes = (menu_index == 8'd0);
    wire type_fds = (menu_index == 8'd1);
    wire type_nsf = (menu_index == 8'd2);

GameLoader loader
(
    .clk              ( clk85 ),//  clk               ),
    .reset            ( loader_reset      ),
    .downloading      ( downloading       ),
    .filetype         ( {4'b0000, type_nsf, type_fds, type_nes, type_bios} ),
    .is_bios          ( is_bios           ),
    .indata           ( loader_input      ),
    .indata_clk       ( loader_clk        ),
    .invert_mirroring ( mirroring_osd     ),
    .mem_addr         ( loader_addr       ),
    .mem_data         ( loader_write_data ),
    .mem_write        ( loader_write      ),
    .bios_download    (                   ),
    .mapper_flags     ( loader_flags      ),
    .busy             ( loader_busy       ),
    .done             ( loader_done       ),
    .error            ( loader_fail       ),
    .rom_loaded       (                   )
);

  always @(posedge clk)
    if (loader_done)
    mapper_flags <= loader_flags;
     
    // LED displays loader status
    reg [23:0] led_blink;   // divide 21MHz clock to around 1Hz
    always @(posedge clk) begin
        led_blink <= led_blink + 13'd1;
    end

// Loopy's NSF player ROM
reg [7:0] nsf_player [4096];
reg [7:0] nsf_data;
initial begin
  $readmemh("nsf.hex", nsf_player);
end
always @(posedge clk) nsf_data <= nsf_player[loader_addr[11:0]];

assign LED = downloading ? 1'b0 : loader_fail ? led_blink[23] : 1'b1;

//wire reset_nes = (init_reset || ~btn_n_i[4] || arm_reset || download_reset || loader_fail);
wire reset_nes = (init_reset || arm_reset || download_reset || loader_fail);

wire ext_audio = 1;
wire int_audio = 1;

wire [1:0] diskside_req;
wire [1:0] diskside = (diskside_osd == 0) ? diskside_req : (diskside_osd - 1'd1);

NES nes(
    .clk(clk),
    .reset_nes(reset_nes),
    .cold_reset(downloading & (type_fds | type_nes)),
    .sys_type(system_type),
    .nes_div(nes_ce),
    .mapper_flags(mapper_flags),
    .sample(sample),
    .color(color),
    .joypad_strobe(joypad_strobe),
    .joypad_clock(joypad_clock),
    .joypad_data({powerpad_d4[0],powerpad_d3[0],joypad_bits2[0],joypad_bits[0]}),
    .mic(),
    .fds_busy(),
    .fds_eject(fds_eject),
    .diskside_req(diskside_req),
    .diskside(diskside),
    .audio_channels(5'b11111),  // enable all channels
    .cpumem_addr(memory_addr_cpu),
    .cpumem_read(memory_read_cpu),
    .cpumem_din(memory_din_cpu),
    .cpumem_write(memory_write_cpu),
    .cpumem_dout(memory_dout_cpu),
    .ppumem_addr(memory_addr_ppu),
    .ppumem_read(memory_read_ppu),
    .ppumem_write(memory_write_ppu),
    .ppumem_din(memory_din_ppu),
    .ppumem_dout(memory_dout_ppu),
    .cycle(cycle),
    .scanline(scanline),
    .int_audio(int_audio),
    .ext_audio(ext_audio)
);

assign SDRAM_CKE         = 1'b1;

// loader_write -> clock when data available
reg loader_write_mem;
reg [7:0] loader_write_data_mem;
reg [21:0] loader_addr_mem;

reg loader_write_triggered;

always @(posedge clk) begin
    if(loader_write) begin
        loader_write_triggered <= 1'b1;
        loader_addr_mem <= loader_addr;
        loader_write_data_mem <= loader_write_data;
    end

    // signal write in the PPU memory phase
    if(nes_ce == 3) begin
        loader_write_mem <= loader_write_triggered;
        if(loader_write_triggered)
            loader_write_triggered <= 1'b0;
    end
end

sdram sdram (
    // interface to the MT48LC16M16 chip
    .sd_data        ( SDRAM_DQ                 ),
    .sd_addr        ( SDRAM_A                  ),
    .sd_dqm         ( {SDRAM_DQMH, SDRAM_DQML} ),
    .sd_cs          ( SDRAM_nCS                ),
    .sd_ba          ( SDRAM_BA                 ),
    .sd_we          ( SDRAM_nWE                ),
    .sd_ras         ( SDRAM_nRAS               ),
    .sd_cas         ( SDRAM_nCAS               ),

    // system interface
    .clk            ( clk85                    ),
    .clkref         ( nes_ce[1]                ),
    .init           ( !clock_locked            ),

    // cpu/chipset interface
    .addrA          ( (downloading | loader_busy) ? {3'b000, loader_addr_mem} : {3'b000, memory_addr_cpu} ),
    .addrB          ( {3'b000, memory_addr_ppu} ),
    
    .weA            ( loader_write_mem || memory_write_cpu ),
    .weB            ( memory_write_ppu ),

    .dinA           ( (downloading | loader_busy) ? loader_write_data_mem : memory_dout_cpu ),
    .dinB           ( memory_dout_ppu ),

    .oeA            ( ~(downloading | loader_busy) & memory_read_cpu ),
    .doutA          ( memory_din_cpu  ),

    .oeB            ( memory_read_ppu ),
    .doutB          ( memory_din_ppu  )
);

wire downloading;
wire [7:0] menu_index;
wire [7:0] ioctl_dout;
wire [7:0] osd_s;

data_io #(
    .STRLEN(($size(CONF_STR)>>3)))
data_io(
    .clk_sys        ( clk          ),

    .SPI_SCK        ( SPI_SCK      ),
    .SPI_SS2        ( SPI_SS2      ),
    .SPI_DI         ( SPI_DI       ),
    .SPI_DO         ( SPI_DO       ),
    
    .data_in        ( pump_s & osd_s ),
    .conf_str       ( CONF_STR     ),
    .status         ( status       ),

    .ioctl_download ( downloading  ),
    .ioctl_index    ( menu_index   ),

   // ram interface
    .ioctl_wr       ( loader_clk   ),
    .ioctl_dout     ( ioctl_dout   )
);

wire nes_hs, nes_vs;
wire [4:0] nes_r;
wire [4:0] nes_g;
wire [4:0] nes_b;

video video (
    .clk(clk),
    .color(color),
    .count_v(scanline),
    .count_h(cycle),
    .pal_video(pal_video),
    .overscan(overscan_osd),
    .palette(palette2_osd),

    .sync_h(nes_hs),
    .sync_v(nes_vs),
    .r(nes_r),
    .g(nes_g),
    .b(nes_b)
);

assign scandoubler_disable = ~status[16] ^ direct_video;

mist_video #(.COLOR_DEPTH(5), .OSD_COLOR(3'd1), .SD_HCNT_WIDTH(10)) mist_video (
    .clk_sys     ( clk        ),

    // OSD SPI interface
    .SPI_SCK     ( SPI_SCK    ),
    .SPI_SS3     ( SPI_SS2    ),
    .SPI_DI      ( SPI_DI     ),

    // scanlines (00-none 01-25% 10-50% 11-75%)
    .scanlines   ( scanlines  ),

    // non-scandoubled pixel clock divider 0 - clk_sys/4, 1 - clk_sys/2
    .ce_divider  ( 1'b0       ),

    // 0 = HVSync 31KHz, 1 = CSync 15KHz
    .scandoubler_disable ( scandoubler_disable ),

    // Rotate OSD [0] - rotate [1] - left or right
    .rotate      ( 2'b00      ),
    // composite-like blending
    .blend       ( 1'b0       ),

    // video in
    .R           ( nes_r      ),
    .G           ( nes_g      ),
    .B           ( nes_b      ),

    .HSync       ( ~nes_hs    ),
    .VSync       ( ~nes_vs    ),

    // MiST video output signals
    .VGA_R       ( VGA_R      ),
    .VGA_G       ( VGA_G      ),
    .VGA_B       ( VGA_B      ),
    .VGA_VS      ( VGA_VS     ),
    .VGA_HS      ( VGA_HS     ),

    .osd_enable ( osd_enable )
);

assign AUDIO_R = audio;
assign AUDIO_L = audio;
wire audio;
sigma_delta_dac sigma_delta_dac (
    .DACout(audio),
    .DACin(sample[15:8]),
    .CLK(clk),
    .RESET(reset_nes)
);

// i2s audio
assign sram_ub_n_o = 1'b1;

i2s_audio_out i2s_audio_out
(
	.reset       (reset_nes ),
	.clk         (clock_50_i), //CLOCK_50 o clk_50
	.sample_rate (1'b0        ), //1=96Khz
	.left_in     (sample),
	.right_in    (sample),
	.i2s_bclk    (SCLK        ),
	.i2s_lrclk   (LRCLK       ),
	.i2s_data    (SDIN        )
   );	
assign MCLK = clock_50_i; //CLOCK_50 o clk_50

// /////////

wire [7:0] kbd_joy0;
wire [7:0] kbd_joy1;
wire [11:0] powerpad;
wire fds_eject,osd_enable;

/*
keyboard keyboard (
    .clk(clk),
    .reset(reset_nes),
    .ps2_kbd_clk(ps2_clk_io),
    .ps2_kbd_data(ps2_data_io),

    .joystick_0(kbd_joy0),
    .joystick_1(kbd_joy1),
    
    .powerpad(powerpad),
    .fds_eject(fds_eject),

    .osd_o (osd_s),
    .osd_enable ( osd_enable )
);
*/
//------------------------------------------

wire m_up, m_down, m_left, m_right, m_fireA, m_fireB, m_fireC, m_fireD, m_fireE, m_fireF, m_fireG;
wire m_up2, m_down2, m_left2, m_right2, m_fire2A, m_fire2B, m_fire2C, m_fire2D, m_fire2E, m_fire2F, m_fire2G;
wire m_tilt, m_coin1, m_coin2, m_coin3, m_coin4, m_one_player, m_two_players, m_three_players, m_four_players;

wire m_right4, m_left4, m_down4, m_up4, m_right3, m_left3, m_down3, m_up3;

// wire btn_one_player  = ~btn_n_i[1] | m_one_player;
// wire btn_two_players = ~btn_n_i[2] | m_two_players;
// wire btn_coin        = ~btn_n_i[3] | m_coin1;

wire btn_one_player  = m_one_player;
wire btn_two_players = m_two_players;
wire btn_coin        = m_coin1;


wire kbd_intr;
wire [7:0] kbd_scancode;

wire [1:0] clk_cnt;

always @(posedge clk)
begin
    clk_cnt <= clk_cnt + 1'b1;
end

//get scancode from keyboard
io_ps2_keyboard keyboard 
 (
  .clk       ( clk_cnt[0] ),
  .kbd_clk   ( ps2_clk_io ),
  .kbd_dat   ( ps2_data_io ),
  .interrupt ( kbd_intr ),
  .scancode  ( kbd_scancode )
);

wire [15:0]joy1_s;
wire [15:0]joy2_s;
wire [8:0]controls_s;
wire direct_video;
wire [1:0]osd_rotate;

//translate scancode to joystick
//kbd_joystick #( .OSD_CMD    ( 3'b011 ), .CLK_SPEED (10738)) k_joystick
kbd_joystick_ua #( .OSD_CMD ( 3'b011 )) k_joystick
(
    .clk          ( clk_cnt[0] ),
    .kbdint       ( kbd_intr ),
    .kbdscancode  ( kbd_scancode ), 

    .joystick_0   ({ joy1_p9_i, joy1_p6_i, joy1_up_i, joy1_down_i, joy1_left_i, joy1_right_i }),
    .joystick_1   ({ joy2_p9_i, joy2_p6_i, joy2_up_i, joy2_down_i, joy2_left_i, joy2_right_i }),
      
    //-- joystick_0 and joystick_1 should be swapped
    .joyswap      ( 0 ),

    //-- player1 and player2 should get both joystick_0 and joystick_1
    .oneplayer    ( 0 ),

    //-- tilt, coin4-1, start4-1
    .controls     ( {m_tilt, m_coin4, m_coin3, m_coin2, m_coin1, m_four_players, m_three_players, m_two_players, m_one_player} ),

    //-- fire12-1, up, down, left, right

    .player1      ( {m_fireG,  m_fireF, m_fireE, m_fireD, core_joy_A} ),
    .player2      ( {m_fire2G, m_fire2F, m_fire2E, m_fire2D, core_joy_B} ),

    .direct_video ( direct_video ),
    .osd_rotate   ( osd_rotate ),

    //-- keys to the OSD
    .osd_o        ( osd_s ),
    .osd_enable   ( osd_enable ),

    //-- sega joystick
    .sega_clk     ( nes_hs ),		
    .sega_strobe  ( joy_p7_o )
);
            
endmodule
