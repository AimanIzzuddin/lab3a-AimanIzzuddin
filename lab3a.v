`timescale 1ns/1ps
module lab3a (
    input clk,
    input rst,
    input ld,
    input cin,
    input [7:0] a,  // a[7:4] = tens, a[3:0] = ones
    input [7:0] b,  // b[7:4] = tens, b[3:0] = ones
    output reg [6:0] d2, // overflow indicator
    output reg [6:0] d1, // tens digit
    output reg [6:0] d0  // ones digit
);

    reg [4:0] LSBsum, MSBsum;
    reg LSBcout, greater;
    reg [3:0] d0_val, d1_val;

    // 7-segment conversion function
    function [6:0] bcd_to_7seg;
        input [3:0] bcd;
        begin
            case (bcd)
                4'd0: bcd_to_7seg = 7'b1000000;
                4'd1: bcd_to_7seg = 7'b1111001;
                4'd2: bcd_to_7seg = 7'b0100100;
                4'd3: bcd_to_7seg = 7'b0110000;
                4'd4: bcd_to_7seg = 7'b0011001;
                4'd5: bcd_to_7seg = 7'b0010010;
                4'd6: bcd_to_7seg = 7'b0000010;
                4'd7: bcd_to_7seg = 7'b1111000;
                4'd8: bcd_to_7seg = 7'b0000000;
                4'd9: bcd_to_7seg = 7'b0010000;
                default: bcd_to_7seg = 7'b1111111;
            endcase
        end
    endfunction

    // Convert overflow flag (0/1) to 7-seg
    function [6:0] circuitB_seg;
        input flag;
        begin
            if (flag)
                circuitB_seg = 7'b1111001; // "1"
            else
                circuitB_seg = 7'b1000000; // "0"
        end
    endfunction

    // Sequential process: update outputs when ld is HIGH
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            d0 <= 7'b1111111;
            d1 <= 7'b1111111;
            d2 <= 7'b1111111;
        end
        else if (ld) begin
            // Perform BCD addition
            LSBsum  = a[3:0] + b[3:0] + cin;
            LSBcout = (LSBsum > 9);
            d0_val  = LSBcout ? (LSBsum - 10) : LSBsum[3:0];

            MSBsum  = a[7:4] + b[7:4] + LSBcout;
            greater = (MSBsum > 9);
            d1_val  = greater ? (MSBsum - 10) : MSBsum[3:0];

            // Update outputs (7-segment encoded)
            d0 <= bcd_to_7seg(d0_val);
            d1 <= bcd_to_7seg(d1_val);
            d2 <= circuitB_seg(greater);
        end
    end

endmodule
