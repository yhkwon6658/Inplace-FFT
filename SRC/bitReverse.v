module bitReverse #(
    parameter R = 5
) (
    input [R-1:0] i_addr,
    output reg [R-1:0] o_addr
);
reg [R-1:0] r_addr;
integer i;
always @(*)
begin
    for(i=0;i<R;i=i+1)
    begin
        if(i==0)
        begin
            o_addr = 0;
            r_addr = i_addr;       
        end
        o_addr = o_addr << 1;
        if(r_addr[0]) o_addr = o_addr + 1'b1;
        r_addr = r_addr >> 1;
    end
end
    
endmodule