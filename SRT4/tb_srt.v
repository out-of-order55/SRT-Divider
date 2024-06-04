`timescale 1ns/1ps
module tb_srt();
parameter WID=8;
reg            clk;
reg            rst;
wire[WID-1:0]  rem_ref;
wire[WID-1:0]  q_ref;
wire[WID-1:0]  rem_d;
wire[WID-1:0]  q_d;
reg[WID-1:0]   dividend;
reg start;
reg[WID-1:0]  divisor;
reg valid;
parameter    MAX_NUM = 64'hff;
parameter    MIN_NUM = 64'h7f;

initial begin
    clk <= 1'b0;
    rst <= 1'b1;
    start <= 1'b0;
    #60
    rst <= 1'b0;
    #20
    start <= 1'b1;
    #20
    start <= 1'b0;
end
always #10 clk <= ~clk;
always @(posedge clk) begin
    if(rst)begin
        dividend <= 'b1;
        divisor  <= 'b1;
        valid    <= 'b0;
    end
    else if(start)begin
        dividend <= MIN_NUM + {$random()} % (MAX_NUM-MIN_NUM+1);
        divisor  <= {$random()} % MIN_NUM+1;
        valid    <= 1'b1;
    end
    else if(ready)begin
        dividend <= MIN_NUM + {$random()} % (MAX_NUM-MIN_NUM+1);
        divisor  <= {$random()} % MIN_NUM+1;
        valid    <= 1'b1;
    end
    else begin
        valid <= 1'b0;
    end
end
assign rem_ref = dividend%divisor;
assign q_ref   = dividend/divisor;
always @(*) begin
    if(ready)begin
        if((rem_ref!=rem_d)|(q_ref!=q_d))begin
            $stop;
        end
    end
end
wire ready;
SRT4 #(
    .WID(WID)
) SRT4(
    .clk         (clk),
    .rst         (rst),
    .dividend    (dividend),
    .divisor     (divisor),
    .valid       (valid),
    .ready       (ready),
    .quotient    (q_d),
    .remainder   (rem_d)   
);
endmodule