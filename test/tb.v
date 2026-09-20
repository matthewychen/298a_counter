`default_nettype none
`timescale 1ns / 1ps

module tb ();

  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  reg clk;
  reg rst_n;
  reg ena;
  reg  [7:0] ui_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // Bus model: the testbench and the chip share eight pins.
  reg  [7:0] tb_drive;   // value the testbench pushes
  reg        tb_oe;      // 1 = testbench drives, 0 = testbench lets go
  wire [7:0] uio_pin;

  assign uio_pin = tb_oe       ? tb_drive : 8'bz;
  assign uio_pin = uio_oe[0]   ? uio_out  : 8'bz;
  wire [7:0] uio_in = uio_pin;

`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // Clock: separate always block, runs forever on its own.
  // 10 ns high + 10 ns low = 20 ns period = 50 MHz.
  initial clk = 0;
  always #10 clk = ~clk;

  // Stimulus: a plain sequence, no forever.
  initial begin
    ena   = 1;
    rst_n = 0;
    ui_in = 8'b00;
    tb_oe = 0;
    tb_drive = 8'h00;

    #50 rst_n = 1;          // release reset

    // Count for a while with the chip driving the bus.
    ui_in = 8'b10;          // load=0, oe=1
    #100;

    // Load 7. oe must be 0 so the testbench owns the pins.
    ui_in    = 8'b01;       // load=1, oe=0
    tb_drive = 8'd7;
    tb_oe    = 1;
    #20;                    // one clock edge passes

    tb_oe = 0;
    ui_in = 8'b10;          // load=0, oe=1
    #100;

    // Release both sides: the bus must float.
    ui_in = 8'b00;
    #40;

    $finish;
  end

  async_counter user_project (
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif
      .ui_in  (ui_in),
      .uo_out (uo_out),
      .uio_in (uio_in),
      .uio_out(uio_out),
      .uio_oe (uio_oe),
      .ena    (ena),
      .clk    (clk),
      .rst_n  (rst_n)
  );

endmodule