`timescale 1 ns/ 1 ps
module bus_all_tb;
    
reg            reset_n;
reg            video_clk;

initial
begin
     reset_n = 1'b0;
     #7
     video_clk = 1'b0;
     #1000;
     reset_n = 1'b1;
end

 always #10 video_clk = ~video_clk ; 


 bus_all u_bus_all(
  .clk         (  video_clk         )    ,
  .rst_n       (  reset_n           )    
);
                                              
endmodule