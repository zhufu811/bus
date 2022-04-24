`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/23 19:50:54
// Design Name: 
// Module Name: bus
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


module bus(
  input   wire                  clkin       ,    // 50M
  input   wire                  rst_n       ,

  output  wire                  clkout_p    ,
  output  wire                  clkout_n    ,
  output  wire   [3 : 0]        dout_p      ,
  output  wire   [3 : 0]        dout_n      
);

wire   [23 : 0]   din   ;
wire              value ;
wire              din_rd ;




destination  #(
    .ROW   ( 1024 ) ,
    .COL   ( 1280 ) ,
    .pixel ( 24   ) 
) u_destination(
  .clkin     ( clkin  )  ,   
  .rst_n     ( rst_n  )  ,
  .din       ( din    )  ,
  .value     ( value  )  ,           
  .din_rd    ( din_rd )  ,
  .clkout_p  ( clkout_p )  ,
  .clkout_n  ( clkout_n )  ,
  .dout_p    ( dout_p )  ,
  .dout_n    ( dout_n )     
);


source #(
    .ROW   ( 1024 ) ,
    .COL   ( 1280 ) ,
    .pixel ( 24   ) 
) u_source(
  .clkin     ( clkin )    ,    // 50M
  .rst_n     ( rst_n )    ,
  .din       ( din )    ,           
  .din_rd    ( din_rd )    ,  
  .value     ( value )
);


endmodule
