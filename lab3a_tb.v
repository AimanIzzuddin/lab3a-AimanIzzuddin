`timescale 1ns/1ps
module lab3a_tb;

    reg  [7:0] a, b;         // Input stimulus
    reg cin, clk, rst, ld;
    wire [6:0] d2, d1, d0;    // 7-segment outputs (common anode, a->g)

    integer i, j, m, n, k, errors;
    reg [3:0] d0_val, d1_val;
    reg [6:0] exp_d0, exp_d1, exp_d2;
    reg greater;
    reg LSBcout;
	reg [4:0] LSBsum;
    reg [4:0] MSBsum;
    reg [8:0] sum;

    lab3a uut (.clk(clk), .rst(rst), .ld(ld), .cin(cin), .a(a), .b(b), .d2(d2), .d1(d1), .d0(d0) );

    always #5 clk = ~clk;  // 10ns clock period

    //========================================================
    // Convert a 4-bit BCD value to 7-segment (a->g)
    //========================================================
    task bcd_to_7seg;
        input [3:0] bcd;
        output [6:0] seg;
        begin
            case (bcd)
                4'd0: seg = 7'b1000000; // 0
                4'd1: seg = 7'b1111001; // 1
                4'd2: seg = 7'b0100100; // 2
                4'd3: seg = 7'b0110000; // 3
                4'd4: seg = 7'b0011001; // 4
                4'd5: seg = 7'b0010010; // 5
                4'd6: seg = 7'b0000010; // 6
                4'd7: seg = 7'b1111000; // 7
                4'd8: seg = 7'b0000000; // 8
                4'd9: seg = 7'b0010000; // 9 
                default: seg = 7'b1111111; // blank 
            endcase 
        end 
    endtask 
    
    //======================================================== 
    // circuitB output (0 or 1) 
    //======================================================== 
    
    task circuitB_seg; 
        input gr; 
        output [6:0] seg; 
        
        begin if (gr == 1'b1) 
            seg = 7'b1111001; // "1" 
            else seg = 7'b1000000; // "0" 
        end 
    endtask 
    //======================================================== 
    // Test Procedure 
    //======================================================== 
    initial 
        begin 
            errors = 0; 
            $display("======================================================"); 
            $display(" Running Simulation for lab2b (Verilog-2001 Testbench, BCD addition and display)"); 
            $display("======================================================"); 
	    clk = 0;
	    rst = 0; ld = 1; cin = 0;
	    #10;         // Hold reset low
	    rst = 1;     // Release reset
            
	    for (i = 0; i < 10; i = i + 1)
		for (j=0; j< 10; j= j+1)
			for (m = 0; m < 10; m = m + 1)
				for (n=0; n< 10; n= n+1)
					for(k=0; k<2; k=k+1) begin 
					
						a[7:4] = i[3:0]; 
						a[3:0] = j[3:0];
						b[7:4] = m[3:0];
						b[3:0] = n[3:0];
						cin = k[0];
           	            			// Apply load pulse on clock edge
                			        ld = 1; #5;
                            			ld = 0; @(posedge clk);
                            			ld = 1; #5;
						
						LSBsum = a[3:0]+b[3:0]+cin;
						LSBcout = (LSBsum > 9);
						if (LSBcout == 1'b0) 
							d0_val = LSBsum[3:0]; 
                    				else 
							d0_val = LSBsum - 10;
                    				MSBsum = a[7:4] + b[7:4] + LSBcout;
					        greater = (MSBsum > 9); 
                    				if (greater == 1'b0) 
							d1_val = MSBsum[3:0]; 
                    				else 
                        				d1_val = MSBsum - 10; 
                    				// Compute expected outputs using tasks 
                    				bcd_to_7seg(d0_val, exp_d0); 
					        bcd_to_7seg(d1_val, exp_d1);
                    				circuitB_seg(greater, exp_d2); 
                    				if (d0 !== exp_d0 || d1 !== exp_d1 || d2 !== exp_d2) 
                        			begin 
							$display("❌ ERROR for summation %d%d + %d%d + %b ", a[7:4], a[3:0], b[7:4], b[3:0], cin); 
							$display("Expected d2=%b, d1=%b, d0=%b",  exp_d2, exp_d1, exp_d0); 
							$display("Got      d2=%b, d1=%b, d0=%b",  d2, d1, d0); 
                            				errors = errors + 1; 
                        			end 
					        else 
                        			begin 
                            				$display("✅ summation %d%d + %d%d + %b  OK ", a[7:4], a[3:0], b[7:4], b[3:0], cin); 
                        			end
						
					end
				

            if (errors == 0) 
                begin 
                    $display("======================================================"); 
                    $display(" ✅ ALL TESTS PASSED SUCCESSFULLY ✅ "); 
                    $display("======================================================"); 
                end 
            else 
                begin $display("======================================================"); 
                    $display(" ❌ TEST FAILED with %0d error(s)", errors); 
                    $display("======================================================"); 
                end 
            $finish; 
        end 
endmodule








