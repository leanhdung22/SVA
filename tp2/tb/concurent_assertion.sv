//+++++++++++++++++++++++++++++++++++++++++++++++++
//   DUT With assertions
//+++++++++++++++++++++++++++++++++++++++++++++++++
module concurrent_assertion(
  input wire clk,req,reset, 
  output reg gnt);
//=================================================
// Sequence Layer
//=================================================
sequence req_gnt_seq;
  // (~req & gnt) and (~req & ~gnt) is Boolean Layer
  (~req & gnt) ##1 (~req & ~gnt);
endsequence
//=================================================
// Property Specification Layer
//=================================================
property req_gnt_prop;
  @ (posedge clk) 
    disable iff (reset)
      req |-> req_gnt_seq;
endproperty
//=================================================
// Assertion Directive Layer
//=================================================
req_gnt_assert : assert property (req_gnt_prop)
                 else
                 $display("@%0dns Assertion Failed", $time);
//=================================================
// Actual DUT RTL
//=================================================
always @ (posedge clk)
  gnt <= req;

endmodule

//+++++++++++++++++++++++++++++++++++++++++++++++
//   Testbench Code
//+++++++++++++++++++++++++++++++++++++++++++++++
module concurrent_assertion_tb();

reg clk = 0;
reg reset, req = 0;
wire gnt;

always #3 clk ++;

initial begin
  reset <= 1;
  #20 reset <= 0;
  // Make the assertion pass
  #100 @ (posedge clk) req  <= 1;
  @ (posedge clk) req <= 0;
  // Make the assertion fail
  #100 @ (posedge clk) req  <= 1;
  repeat (5) @ (posedge clk);
  req <= 0;
  #10 $finish;
end

concurrent_assertion dut (clk,req,reset,gnt);

endmodule
