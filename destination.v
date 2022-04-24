`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/28 10:22:34
// Design Name: 
// Module Name: stream_clink
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


module destination #(
    parameter  integer   ROW   = 1024 ,
    parameter  integer   COL   = 1280 ,
	parameter  integer   pixel = 24   
)
(
  input   wire                  clkin       ,   
  input   wire                  rst_n       ,

  input   wire   [23 : 0]       din         ,
  input   wire                  value       ,           
  output  wire                  din_rd      ,

  output  wire                  clkout_p    ,
  output  wire                  clkout_n    ,
  output  wire   [3 : 0]        dout_p      ,
  output  wire   [3 : 0]        dout_n         
);

localparam integer hsync_a   =    10     ;      
localparam integer hsync_b   =    20     ;    
localparam integer hsync_c   =    1300   ;   
localparam integer hsync_d   =    1310   ;   

localparam integer vsync_o   =     3     ;      
localparam integer vsync_p   =     10    ;  
localparam integer vsync_q   =     1034  ;  
localparam integer vsync_r   =     1035  ;  


reg    [23 : 0]    din_1           ;
reg                pixel_en_1      ;
reg                rst_n_1         ;
reg                vsync_1         ;
reg                hsync_1         ;
reg                dvalue_1        ;
reg                rd_en_1         ;
reg                prog_full_1     ;
reg    [23 : 0]    fifo_data_o_1   ;

wire               process_clk   ;
wire               bin_clk       ;

wire               pixel_en      ; 

wire   [7 : 0]     porta         ;
wire   [7 : 0]     portb         ;
wire   [7 : 0]     portc         ; 

wire   [6 : 0]     shift_tx1     ;     // R0 - R5 、G0      
wire   [6 : 0]     shift_tx2     ;     // G1 - G5 、B0 - B1
wire   [6 : 0]     shift_tx3     ;     // B2 - B5 、H 、V 、D
wire   [6 : 0]     shift_tx4     ;     // R6 - R7 、G6 - G7 、B6 - B7 、space

wire               tx1           ;
wire               tx2           ;
wire               tx3           ;
wire               tx4           ;
wire               cml_clk       ;

reg                vsync         ;
reg                hsync         ;
reg                dvalue        ;
wire               space         ;

reg    [3 : 0]     bit_cnt       ;
reg    [3 : 0]     cml_bit_cnt   ;
reg    [6 : 0]     cml_clk_reg   ;

reg    [10 : 0]    hsync_cnt      ;
reg    [10 : 0]    vsync_cnt      ;  

wire               rd_en         ;
wire               wr_en         ;
wire               prog_full     ;
wire               full          ;
wire               empty         ;
wire   [23 : 0]    fifo_data_o   ;
wire   [10 : 0]    wr_water_level ;

assign   pixel_en    =   din_rd         ;
assign   porta       =   fifo_data_o_1[7  : 0 ]       ;
assign   portb       =   fifo_data_o_1[15 : 8 ]       ;
assign   portc       =   fifo_data_o_1[23 : 16]       ;

assign   shift_tx1   = {portb[0]       ,  porta[5 : 0]}                        ;
assign   shift_tx2   = {portc[1 : 0]   ,  portb[5 : 1]}                        ;
assign   shift_tx3   = {dvalue_1 , vsync_1 , hsync_1 , portc[5 : 2]}                 ;
assign   shift_tx4   = {space , portc[7 : 6] , portb[7 : 6] , porta[7 : 6]}    ;

assign   tx1         =    shift_tx1[6 - cml_bit_cnt]    ;
assign   tx2         =    shift_tx2[6 - cml_bit_cnt]    ;
assign   tx3         =    shift_tx3[6 - cml_bit_cnt]    ;
assign   tx4         =    shift_tx4[6 - cml_bit_cnt]    ;
assign   cml_clk     =    cml_clk_reg[cml_bit_cnt] ;
assign   prog_full   =   ( wr_water_level  >=  'd1000  ) ? 'd1  :  'd0  ;

assign   space       =      'd0          ;
assign   rd_en       =   dvalue && ~empty ;
assign   wr_en       =   pixel_en_1  && ~prog_full_1  ; 
assign   din_rd      =   ~prog_full_1     ;

/*打拍*/
always @(posedge clkin or negedge rst_n) begin
    if(!rst_n) begin
        din_1      <=  'd0           ;
        cml_clk_reg  <=  7'b11_000_11  ;
        prog_full_1   <=  'd0               ;
        pixel_en_1   <= 'd0            ;
    end
    else begin
        din_1      <=  din         ;     //给数据做是时钟同步处理，在上升沿采样数据   
        prog_full_1      <=    prog_full           ;
        pixel_en_1   <=  pixel_en      ;  
    end 
end

always @(posedge bin_clk or negedge rst_n) begin
    if(!rst_n) begin
        rst_n_1    <=  'd0           ;
        fifo_data_o_1  <=   'd0        ;
        vsync_1     <=   'd0           ;
        hsync_1     <=   'd0           ;
        dvalue_1    <=   'd0           ;  
        rd_en_1     <=      'd0         ;      
    end
    else begin   
        rst_n_1    <=  rst_n       ;
        fifo_data_o_1  <=  fifo_data_o  ;
        vsync_1      <=   vsync        ;
        hsync_1      <=   hsync         ;
        dvalue_1     <=   dvalue        ;
        rd_en_1     <=    rd_en        ;
    end 
end

always @(posedge process_clk or negedge rst_n ) begin
    if ( !rst_n )  begin
        cml_bit_cnt   <=  'd0  ;
    end
    else begin
        if ( rst_n_1 ) begin
            if ( cml_bit_cnt == 4'd6 ) 
                cml_bit_cnt  <=  'd0   ;
            else
                cml_bit_cnt  <=  cml_bit_cnt + 'd1  ; 
        end 
    end
end

always @(posedge bin_clk  or negedge rst_n ) begin
    if ( !rst_n ) 
        hsync_cnt <= 'd0  ;
    else if ( !empty ) begin
        if ( hsync_cnt  >=  hsync_d - 'd1 )
            hsync_cnt   <=  'd0  ;
        else  
            hsync_cnt <= hsync_cnt + 'd1  ;
    end
    else
        hsync_cnt  <=  hsync_cnt  ;
end

always @(posedge bin_clk  or negedge rst_n ) begin
    if ( !rst_n ) 
        vsync_cnt <= 'd0  ;
    else if ( !empty ) begin
        if ( (vsync_cnt  >=  vsync_r - 'd1) && (hsync_cnt ==  hsync_d - 1'd1) )
            vsync_cnt   <=  'd0  ;
        else if ( hsync_cnt ==  hsync_d - 1'd1) 
            vsync_cnt <= vsync_cnt + 'd1  ;
        else 
            vsync_cnt  <=  vsync_cnt  ;
    end
    else
        vsync_cnt  <=  vsync_cnt  ;
end


always @( * ) begin
    if ( vsync_cnt <= vsync_o - 1'd1 )
        vsync  = 'd0  ;
    else if ( vsync_cnt <= vsync_r - 1'd1 )
        vsync  =  'd1  ;
    else 
        vsync  =  'd0  ;
end
  
always @( * ) begin
    if ( hsync_cnt <= hsync_a - 'd1)
        hsync  = 'd0  ;
    else if ( hsync_cnt <= hsync_d - 1'd1 )
        hsync  =  'd1  ;
    else 
        hsync  =  'd0  ;
end

always @( * ) begin
     if ( vsync_cnt >= vsync_p && vsync_cnt <= vsync_q - 'd1 ) begin
         if  ( hsync_cnt >= hsync_b && hsync_cnt <= hsync_c - 'd1 )
              dvalue  =  'd1  ;
         else
              dvalue  = 'd0 ;
     end
     else
        dvalue   =  'd0  ;    
 end

 
fifo_generator_0 u_fifo (
  .wr_clk(clkin),      // input wire clk
  .rd_clk(bin_clk),  // input wire rd_clk
  .din(din_1),      // input wire [23 : 0] din
  .wr_en(pixel_en_1),  // input wire wr_en
  .rd_en(rd_en),  // input wire rd_en
  .dout(fifo_data_o),    // output wire [23 : 0] dout
  .full(full),    // output wire full
  .empty(empty) ,  // output wire empty
  .wr_data_count(wr_water_level)  // output wire [10 : 0] wr_data_count
);


clk_wiz_0 u_clk(
    // Clock out ports
    .clk_out1(process_clk),     // output clk_out1 280M
    .clk_out2(bin_clk),     // output clk_out2  40M
    // Status and control signals
   // Clock in ports
    .clk_in1(clkin)
); 

OBUFDS #(
   .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
   .SLEW("SLOW")           // Specify the output slew rate
) u_tx1 (
   .O(dout_p[0]),     // Diff_p output (connect directly to top-level port)
   .OB(dout_n[0]),   // Diff_n output (connect directly to top-level port)
   .I(tx1)      // Buffer input
);

OBUFDS #(
   .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
   .SLEW("SLOW")           // Specify the output slew rate
) u_tx2 (
   .O(dout_p[1]),     // Diff_p output (connect directly to top-level port)
   .OB(dout_n[1]),   // Diff_n output (connect directly to top-level port)
   .I(tx2)      // Buffer input
);

OBUFDS #(
   .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
   .SLEW("SLOW")           // Specify the output slew rate
) u_tx3 (
   .O(dout_p[2]),     // Diff_p output (connect directly to top-level port)
   .OB(dout_n[2]),   // Diff_n output (connect directly to top-level port)
   .I(tx3)      // Buffer input
);

OBUFDS #(
   .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
   .SLEW("SLOW")           // Specify the output slew rate
) u_tx4 (
   .O(dout_p[3]),     // Diff_p output (connect directly to top-level port)
   .OB(dout_n[3]),   // Diff_n output (connect directly to top-level port)
   .I(tx4)      // Buffer input
);

OBUFDS #(
   .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
   .SLEW("SLOW")           // Specify the output slew rate
) u_xclk (
   .O(clkout_p),     // Diff_p output (connect directly to top-level port)
   .OB(clkout_n),   // Diff_n output (connect directly to top-level port)
   .I(cml_clk)      // Buffer input
);


endmodule
