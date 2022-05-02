`timescale 1ns / 100ps

module bus_ready (
    input   clk  ,
    input   rst_n  
);

reg     [7 : 0]     clk_cnt     ;

always @(posedge clk or negedge rst_n) begin
    if ( !rst_n ) begin
        clk_cnt  <=  'd0  ;
    end 
    else  if ( clk_cnt == 20 ) begin
        clk_cnt  <=  'd0  ;
    end
    else  
        clk_cnt  <=  clk_cnt + 'd1  ;
end


wire                s_ready_o   ;
/*source*/
wire                m_valid_o   ;
reg     [7 : 0]     m_data_o    ;
wire                m_ready_i   ;

reg                 m_ready_i_1  ;

wire                data_en_o   ;
wire                m_ready_i_pos  ;
wire                m_ready_i_neg  ;

wire                ready   ;

assign  m_ready_i  =  s_ready_o  ;
assign  m_ready_i_pos  =  m_ready_i && ~m_ready_i_1  ;
assign  m_ready_i_neg  =  ~m_ready_i && m_ready_i_1  ;
assign  m_valid_o  =  clk_cnt >= 'd2 && clk_cnt <= 'd18  ;  //输出有效产生一个延时
assign  ready  =  (m_ready_i_1 || m_ready_i_pos) ^ m_ready_i_neg  ;
assign  data_en_o  =  ready && m_valid_o  ;
//assign  m_data_o   =  data_en_o ? clk_cnt : 'd0  ;

always @(posedge clk or negedge rst_n) begin
    if ( !rst_n ) begin
        m_ready_i_1  <=  'd0  ;
    end 
    else begin
        m_ready_i_1  <=  m_ready_i  ;
    end
end


always @(posedge clk or negedge rst_n) begin
    if ( !rst_n ) begin
        m_data_o  <=  'd0  ;
    end 
    else if (data_en_o) begin
        m_data_o  <=  clk_cnt ;
    end
    else 
        m_data_o  <=  'd0  ;
end

/*destination*/
wire                s_valid_i   ;
wire    [7 : 0]     s_data_i    ;

wire                data_en_i   ;
reg     [7 : 0]     data_rec    ;


assign  s_valid_i  =  m_valid_o  ;
assign  s_data_i   =  m_data_o  ;

assign #5 s_ready_o  =  clk_cnt >= 'd4 && clk_cnt <= 'd16  ;
assign  data_en_i  =  s_valid_i && m_ready_i_1  ;


always @(negedge clk or rst_n) begin
    if ( !rst_n ) begin
        data_rec  <=  'd0  ; 
    end 
    else if (data_en_i) begin
        data_rec  <=   s_data_i  ;  
    end
    else 
        data_rec  <=  'd0  ;
end

endmodule


