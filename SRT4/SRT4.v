module SRT4 #(
    parameter WID=8
) (
    clk         ,
    rst         ,
    dividend    ,
    divisor     ,
    valid       ,
    ready       ,
    quotient    ,
    error       ,
    remainder      
);
input           clk;
input           rst;
input[WID-1:0]  dividend;
input[WID-1:0]  divisor;
input           valid;
output          error;
output          ready; 
output[WID-1:0]  quotient;
output[WID-1:0]  remainder;

wire [2*WID:0]  rem;//only use [2*WID:WID]
reg             ready_o;
wire[WID-1:0]     pos_1;
wire[1:0]       q;
wire            neg;
reg[WID-1:0]      div_shift;
reg             dividend_sign;
wire[3:0]       qds_table;
always @(posedge clk) begin
    if(rst)begin
        dividend_sign <= 'b0;
    end
    else if(valid)begin
        dividend_sign <= dividend[WID-1];
    end
end
find_1#
(
    .WID(WID)
)
find_1(
    .d_i     (divisor),
    .pos_o   (pos_1)
);
q_sel #(
    .WIDTH(WID)
)q_sel (
    .rem     (shift_rem[2*WID:2*WID-5]),
    .d       (qds_table),
    .q       (q),
    .neg     (neg)
);
always @(posedge clk) begin
    if(rst)begin
        div_shift <= 'b0;
    end
    else if(state==IDLE&&valid)begin
        div_shift <= pos_1+1;
    end
end
wire[WID:0]     shift_divisor_X2;
wire[WID:0]     shift_divisor;
wire[WID:0]     shift_divisor_X2n;
wire[WID:0]     shift_divisor_n;

reg[WID:0]      Q;
reg[WID:0]      QM;  
reg[2*WID:0]    shift_rem;
reg[WID-1:0]    shift_dividend;
reg[WID:0]      div_cnt;

assign rem              = {{(WID+1){0}},dividend}<<div_shift;
assign shift_divisor    = divisor<<div_shift;
assign qds_table        = shift_divisor[WID-1:WID-4];


assign shift_divisor_n  = (~shift_divisor)+1;
assign shift_divisor_X2 = shift_divisor<<1;
assign shift_divisor_X2n=(~shift_divisor_X2)+1; 

parameter       IDLE = 3'b000,
                DIV_PRE = 3'b001,
                DIV_WORKING = 3'b010,
                DIV_END = 3'b011,
                DIV_1   = 3'b100,
                DIV_ERROR=3'b101;

reg[2:0]    state;
always @(posedge clk) begin
    if(rst)begin
        state <= IDLE;
    end
    else begin
        case (state)
            IDLE:begin
                if(valid)begin
                    if(divisor==0)begin
                        state <= DIV_ERROR;
                    end
                    else if(divisor==1)begin
                        state <= DIV_1; 
                    end
                    else begin
                        state <= DIV_PRE;
                    end
                end
            end
            DIV_PRE:state <= DIV_WORKING;
            DIV_WORKING:begin
                if(div_cnt=='b0)
                    state <= DIV_END;
            end
            DIV_END:begin
                state <= IDLE;
            end
            DIV_ERROR:begin
                state <= IDLE;
            end  
            DIV_1:begin
                state <= IDLE;
            end
            default: state <= IDLE;
        endcase
    end
end

always @(posedge clk) begin
    if(rst)begin
        shift_rem <= 'b0;
    end
    else if(state==DIV_PRE)begin
        shift_rem <= rem;
    end
    else begin
        case ({neg,q})
            3'b000:shift_rem <= {shift_rem[2*WID-2:WID-2]+0                 ,shift_rem[WID-3:0],2'b0};
            3'b001:shift_rem <= {shift_rem[2*WID-2:WID-2]+shift_divisor_n   ,shift_rem[WID-3:0],2'b0};
            3'b010:shift_rem <= {shift_rem[2*WID-2:WID-2]+shift_divisor_X2n ,shift_rem[WID-3:0],2'b0};
            3'b100:shift_rem <= {shift_rem[2*WID-2:WID-2]+0                 ,shift_rem[WID-3:0],2'b0};
            3'b101:shift_rem <= {shift_rem[2*WID-2:WID-2]+shift_divisor     ,shift_rem[WID-3:0],2'b0};
            3'b110:shift_rem <= {shift_rem[2*WID-2:WID-2]+shift_divisor_X2  ,shift_rem[WID-3:0],2'b0};
            default: ;
        endcase 
    end
end
always @(posedge clk) begin
    if(rst)begin
        Q <= 'b0;
        QM<= 'b0;
    end
    else if(state==DIV_WORKING)begin
        if(~neg)begin
            Q <= {Q[WID-3:0],q};
        end
        else begin
            Q <= {QM[WID-3:0],1'b1,q[0]};
        end
        if ((~neg)&(|q))begin
            QM <= {Q[WID-3:0],1'b0,q[1]};
        end
        else begin
            QM <= {QM[WID-3:0],~q};
        end
    end
    else begin
        Q <= 'b0;
        QM<= 'b0;
    end
end

////////////////////////
reg[WID:0]    fin_q;
reg[WID:0]    fin_rem;
always @(posedge clk) begin
    if(rst)begin
        fin_q   <= 'b0;
        fin_rem <= 'b0;
    end
    else if(state==DIV_END)begin
        if((shift_rem[2*WID]))begin
            fin_rem <= shift_rem[2*WID:WID] + shift_divisor;
            fin_q   <= Q-1;
        end
        else begin
            fin_rem <= shift_rem[2*WID:WID];
            fin_q   <= Q ;
        end
    end
end
always @(posedge clk) begin
    if(rst)begin
        div_cnt <= 'b0;
    end
    else if(valid)begin
        div_cnt <= (WID>>1)-1;
    end
    else if(state==DIV_WORKING)begin
        div_cnt <= div_cnt - 1 ;
    end
end

always @(posedge clk) begin
    if(rst)begin
        ready_o <= 'b0;
    end
    else if(state==DIV_END)begin
        ready_o <= 1'b1;
    end
    else begin
        ready_o <= 1'b0;
    end
end
assign  ready    = state==DIV_1?1'b1:ready_o;
assign  quotient = state==DIV_1?dividend:fin_q;
assign  remainder= state==DIV_1?1'b0:fin_rem>>div_shift;
assign  error    = state==DIV_ERROR;
endmodule