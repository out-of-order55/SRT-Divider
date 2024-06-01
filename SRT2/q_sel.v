module q_sel #(
    parameter WIDTH = 8
) (
    rem     ,
    d       ,
    q       ,
    neg
);
input[2:0]  rem;
input       d;
output reg  q;
output      neg;

always @(*) begin
    if(rem<3'b010|rem>=3'b110)begin
        q = 1'b0;
    end
    else begin
        q = 1'b1;
    end
end
assign neg = q&(d!=rem[2]);
endmodule