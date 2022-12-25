module bwMUX
(
    input in1,
    input in2,  
    input sel,
    output out
);
assign out = sel ? in1 : in2;
endmodule