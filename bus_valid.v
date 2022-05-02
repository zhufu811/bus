`timescale 1ns / 100ps

module bus_valid (
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

wire                data_en_o   ;

assign  m_ready_i  =  s_ready_o  ;
assign #5 m_valid_o  =  clk_cnt >= 'd4 && clk_cnt <= 'd16  ;  //输出有效产生一个延时
assign  data_en_o  =  m_ready_i && m_valid_o  ;
//assign  m_data_o   =  data_en_o ? clk_cnt : 'd0  ;

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

reg                 s_valid_i_1  ;
reg                 s_valid_i_2  ;

wire                data_en_i   ;
reg     [7 : 0]     data_rec    ;
wire                s_valid_i_pos  ;
wire                s_valid_i_neg  ;


assign  s_valid_i  =  m_valid_o  ;
assign  s_data_i   =  m_data_o  ;
assign  s_valid_i_pos  =  s_valid_i && ~s_valid_i_1  ;
assign  s_valid_i_neg  =  ~s_valid_i && s_valid_i_1  ;

assign  s_ready_o  =  clk_cnt >= 'd2 && clk_cnt <= 'd18  ;
assign  data_en_i  =  s_valid_i_1 && s_ready_o  ;
//assign  data_rec   =  data_en_i ? s_data_i : 'd0  ;

always @(posedge clk or negedge rst_n) begin
    if ( !rst_n ) begin
        s_valid_i_1  <=  'd0  ; 
    end 
    else begin
        s_valid_i_1  <=  s_valid_i  ;   
    end
end

always @(negedge clk or negedge rst_n) begin
    if ( !rst_n ) begin
        s_valid_i_2  <=  'd0  ; 
    end 
    else begin
        s_valid_i_2  <=  s_valid_i  ;   
    end    
end

always @(negedge clk or rst_n) begin
    if ( !rst_n ) begin
        data_rec  <=  'd0  ; 
    end 
    else if (data_en_i) begin
        if (s_valid_i_neg) 
            data_rec  <= 'd0  ;
        else
            data_rec  <=   s_data_i  ;  
    end
    else 
        data_rec  <=  'd0  ;
end

endmodule


