`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/23 17:10:04
// Design Name: 
// Module Name: source
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


module source#(
    parameter  integer   ROW   = 1024 ,
    parameter  integer   COL   = 1280 ,
	parameter  integer   pixel = 24   
)
(
  input   wire                  clkin       ,    // 50M
  input   wire                  rst_n       ,

  output  wire   [23 : 0]       din         ,           
  input   wire                  din_rd      ,  
  output  wire                  value   
);

/*ce shi*/
reg  [20 : 0]  data_cnt;
wire           data_en   ;
reg  [11 : 0]  row_cnt_o_ceshi   ;
reg  [11 : 0]  col_cnt_o_ceshi   ;
reg  [23  : 0]  data_temp         ;



assign   value  =  'd1  ; 
//assign din  = ( data_en == 1 ) ?  {data_temp[7 : 0],data_temp[7 : 0],data_temp[7 : 0]} : 24'd0 ;
assign din  = ( data_en == 1 ) ?  data_temp : 24'd0 ;
assign data_en   =   value && din_rd ;

 always @(posedge clkin)
 begin
     if (!rst_n)
     begin
         data_cnt <= 17'b0;
     end
     else if  ( data_en )
     begin
         if (data_cnt >= COL * ROW - 1'd1 )
             data_cnt <= 17'b0;
         else
             data_cnt <= data_cnt + 17'b1;        
     end
     else
        data_cnt  <=  data_cnt  ;
 end


always @(*)
 begin

    if (col_cnt_o_ceshi  <=  200)   
        data_temp  =  'd10284002  ;  
    else if (col_cnt_o_ceshi  <=  400) 
        data_temp  =  'd8897478  ;
    else if (col_cnt_o_ceshi  <=  600) 
        data_temp  =  'd7859320  ;
    else if (col_cnt_o_ceshi  <=  800) 
        data_temp  =  'd1573558  ;
    else if (col_cnt_o_ceshi  <=  1000) 
        data_temp  =  'd10005783  ;
    else if (col_cnt_o_ceshi  <=  1279) 
        data_temp  =  'd5216785  ;
 
 end

  always @(posedge clkin)
 begin
    if (!rst_n) begin
        row_cnt_o_ceshi  <=  'd0  ;
        col_cnt_o_ceshi  <=  'd0  ; 
    end 
    else if (data_en) begin
        if ((row_cnt_o_ceshi >= ROW - 1'd1) && (col_cnt_o_ceshi >= COL - 1'd1))  begin
            row_cnt_o_ceshi   <=  'd0  ;
            col_cnt_o_ceshi   <=  'd0  ;
        end
        else  begin
            if (col_cnt_o_ceshi >= COL - 1'd1 ) begin
                col_cnt_o_ceshi  <=  'd0 ;
                row_cnt_o_ceshi  <=  row_cnt_o_ceshi + 1'd1  ;
            end
            else begin
                col_cnt_o_ceshi  <=  col_cnt_o_ceshi + 1'd1  ;
                row_cnt_o_ceshi  <=  row_cnt_o_ceshi    ;   
            end    
        end
    end
    else begin
        if ( row_cnt_o_ceshi == ROW && col_cnt_o_ceshi == COL ) begin
            row_cnt_o_ceshi  <=  'd0  ;
            col_cnt_o_ceshi  <=  'd0  ;
        end
        else begin
            row_cnt_o_ceshi  <=  row_cnt_o_ceshi  ;
            col_cnt_o_ceshi  <=  col_cnt_o_ceshi  ;
        end
    end
 end



endmodule
