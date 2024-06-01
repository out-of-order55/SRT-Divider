module SRT2 #(
    parameter WID=8
) (
    clk         ,
    rst         ,
    dividend    ,
    divisor     ,
    valid       ,
    ready       ,
    quotient    ,
    remainder      
);
input           clk;
input           rst;
input[WID-1:0]  dividend;
input[WID-1:0]  divisor;
input           valid;
output          ready; 
output[WID-1:0]  quotient;
output[WID-1:0]  remainder;

reg             ready_o;
wire[WID-1:0]   pos_1;
wire            q;
wire            neg;
reg[WID-1:0]    div_shift;
reg             dividend_sign;
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
    .rem     (shift_rem[WID:WID-2]),
    .d       (1'b0),
    .q       (q),
    .neg     (neg)
);
always @(posedge clk) begin
    if(rst)begin
        div_shift <= 'b0;
    end
    else if(valid)begin
        div_shift <= pos_1+2;//to allow op1 in{-1/2,1/2}
    end
end
wire[WID+1:0]     shift_divisor;
wire[WID+1:0]     shift_divisor_n;
reg[WID+1:0]      Q;
reg[WID+1:0]      QM;  
reg[WID+1:0]      shift_rem;
reg[WID+1:0]      div_cnt;  
assign shift_divisor   = divisor<<div_shift;
assign shift_divisor_n = (~shift_divisor)+1;

parameter   IDLE = 2'b00,
                DIV_WORKING = 2'b01,
                DIV_END = 2'b11;
reg[1:0]    state;
always @(posedge clk) begin
    if(rst)begin
        state <= IDLE;
    end
    else begin
        case (state)
            IDLE:begin
                if(valid)begin
                    state <= DIV_WORKING;
                end
            end
            DIV_WORKING:begin
                if(div_cnt=='b0)
                    state <= DIV_END;
            end
            DIV_END:begin
                state <= IDLE;
            end 
            default: state <= IDLE;
        endcase
    end
end
reg[WID+1:0]      Q1;
reg[WID+1:0]      QM1;  
//on-the-fly-convert
// always @(posedge clk) begin
//     if(rst)begin
//         Q <= 'b0;
//         QM<= 'b0;
//     end
//     else if(state==DIV_WORKING)begin
//         case ({q,neg})
//             2'b00:begin
//                 Q <= {Q[WID:0],1'b0};
//                 QM <= {QM[WID:0],1'b0};
//             end
//             2'b01:begin
//                 Q  <= {Q[WID:0],1'b0};
//                 QM <= {QM[WID:0],1'b0};
//             end
//             2'b10:begin
//                 Q  <= {Q[WID:0],q};
//                 QM <= {QM[WID:0],1'b0};
//             end
//             2'b11: begin
//                 Q  <= {Q[WID:0],1'b0};
//                 QM <= {QM[WID:0],q};
//             end 
//             default: ;
//         endcase
//     end
//     else begin
//         Q <= 'b0;
//         QM<= 'b0;
//     end
// end
always @(posedge clk) begin
    if(rst)begin
        Q <= 'b0;
        QM<= 'b0;
    end
    else if(state==DIV_WORKING)begin
        if(~neg)begin
            Q <= {Q[WID:0],q};
        end
        else begin
            Q <= {QM[WID:0],q};
        end
        if ((~neg)&&(q))begin
            QM <= {Q[WID:0],~q};
        end
        else begin
            QM <= {QM[WID:0],~q};
        end
    end
    else begin
        Q <= 'b0;
        QM<= 'b0;
    end
end
////////////////////////
reg[WID+1:0]    fin_q;
reg[WID+1:0]    fin_rem;
always @(posedge clk) begin
    if(rst)begin
        fin_q   <= 'b0;
        fin_rem <= 'b0;
    end
    else if(state==DIV_END)begin
        if((shift_rem[WID+1]))begin
            fin_rem <= shift_rem + shift_divisor;
            fin_q   <= Q-1;
        end
        else begin
            fin_rem <= shift_rem;
            fin_q   <= Q ;
        end
    end
end
always @(posedge clk) begin
    if(rst)begin
        div_cnt <= 'b0;
    end
    else if(valid)begin
        div_cnt <= pos_1+1;
    end
    else if(state==DIV_WORKING)begin
        div_cnt <= div_cnt - 1 ;
    end
end
always @(posedge clk) begin
    if(rst)begin
        shift_rem <= 'b0;
    end
    else if(valid)begin
        shift_rem <= dividend;
    end
    else begin
        case ({q,neg})
            2'b00:shift_rem <= {shift_rem[WID:0],1'b0};
            2'b01:shift_rem <= {shift_rem[WID:0],1'b0};
            2'b10:shift_rem <= {shift_rem[WID:0],1'b0}+shift_divisor_n;
            2'b11:shift_rem <= {shift_rem[WID:0],1'b0}+shift_divisor;
            default: ;
        endcase 
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
assign  ready = ready_o;
assign  quotient = fin_q;
assign  remainder= fin_rem>>div_shift;
endmodule