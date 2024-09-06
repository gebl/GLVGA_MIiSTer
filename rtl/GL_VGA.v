
module GL_VGA
#(parameter VIDEO_WIDTH = 3,
   parameter TOTAL_COLS  = 800, 
   parameter TOTAL_ROWS  = 520,
   parameter ACTIVE_COLS = 640, 
   parameter ACTIVE_ROWS = 480)
(
	input      clk,
	input      reset,
	
	input      scandouble,

	output reg ce_pix,

	output reg HBlank,
	output reg HSync,
	output reg VBlank,
	output reg VSync,

	output [7:0] vr,
	output [7:0] vg,
	output [7:0] vb
);

/*
// http://www.tinyvga.com/vga-timing/640x480@60Hz

General timing
Screen refresh rate	60 Hz
Vertical refresh	31.46875 kHz
Pixel freq.	25.175 MHz

Horizontal timing (line)
Polarity of horizontal sync pulse is negative.

Visible area	640	25.422045680238
Front porch	16	0.63555114200596
Sync pulse	96	3.8133068520357
Back porch	48	1.9066534260179
Whole line	800	31.777557100298

Vertical timing (frame)
Polarity of vertical sync pulse is negative.

Visible area	480	15.253227408143
Front porch	10	0.31777557100298
Sync pulse	2	0.063555114200596
Back porch	33	1.0486593843098
Whole frame	525	16.683217477656

Components of VGA signal 
http://javiervalcarce.eu/html/vga-signal-format-timming-specs-en.html

HSYNC  Horizontal sync. Make electron beam restart at next screen's scanline (starts a new line).
VSYNC  Vertical sync. Make electron beam restart at first screen's scanline (starts a new frame).
R      Red intensity. 
G      Green intensity.
B      Blue intensity.

Pulses on HSYNC signal mark the start and end of a line and ensure that the monitor displays the pixels between the left and right edges of the visible screen area.
The active region is followed by a blanking region, in which black pixels are transmitted. In the middle of the blanking interval, a horizontal sync pulse is transmitted. The blanking interval before the sync pulse is known as the "front porch", and the blanking interval after the sync pulse is known as the "back porch".

Pulses on VSYNC signal mark the start and end of a frame made up of video lines and ensure that the monitor displays the lines between the top and bottom edges of the visible monitor screen.


The horizontal resolution of each line '''is not actually determined''' and could be anything, this resolution is determined typically by a '''pixel clock'''. Every rising edge of the pixel clock marks the start of a new pixel.
*/

localparam hviz = 640;
localparam hfp = 16;
localparam hsp = 96;
localparam hbp = 48;
localparam htotal = 800;

localparam vviz = 480;
localparam vfp = 10;
localparam vsp = 2;
localparam vbp = 33;
localparam vtotal = 525;

reg   [10:0] hc;
reg   [10:0] vc;

always @(posedge clk) begin
	/*if(scandouble) ce_pix <= 1;
		else ce_pix <= ~ce_pix;
	*/
	ce_pix<=1;

	if(reset) begin
		hc <= 0;
		vc <= 0;
	end
	else if(ce_pix) begin
		if(hc == TOTAL_COLS-1) begin
			hc <= 0;

			if(vc == TOTAL_ROWS-1) begin 
				vc <= 0;

			end else begin
				vc <= vc + 1'd1;
			end
		end else begin
			hc <= hc + 1'd1;
		end
	end
	
	if(hc < ACTIVE_COLS) begin
		HBlank <= 0;
		//HSync <= 1;
	end else begin
		//HSync <= 0;
		HBlank <= 1;
	end

	if (vc < ACTIVE_ROWS) begin
		VBlank <= 0;
		//VSync <= 1;
	end else begin
		//VSync <= 0;
		VBlank <= 1;
	end
end

//assign HBlank = (hc < hviz) ? 0 : 1;
//assign VBlank = (vc < vviz) ? 0 : 1;

assign HSync = (hc >= hviz+hbp && hc<hviz+hbp+hsp) ? 1 : 0;
assign VSync = (vc >= vviz+vbp && vc<vviz+vbp+vsp) ? 1 : 0;

always @(posedge clk) begin
		vr <=  8'b00000000;
		vg <= 8'b00000000;
		vb <= 8'b00000000;

		if (hc[3:3]==1) begin
			vr <= 8'b11111111;
		end else begin
			vr <= 8'b00000000;
		end

		if (vc[3:3]==1) begin
			vb <= 8'b00000000;
		end else begin
			vb <= 8'b11111111;
		end

		//vg <= (vc[3:0]==0) ? 8'b11111111:8'b00000000;
		//vb <= (hc[3:0]==0 ) ? 8'b11111111 : 8'b00000000;

		if (vc[10:3]==0 || vc[10:3]>=59) begin
			vr <= 8'b11111111;
			vg <= 8'b11111111;
			vb <= 8'b11111111;
		end
		if (hc[10:3]==0 || hc[10:3]>=79) begin
			vr <= 8'b11111111;
			vg <= 8'b11111111;
			vb <= 8'b11111111;
		end

		if (hc==32 || hc==40) begin
			vr <= 8'b11111111;
			vg <= 8'b11111111;
			vb <= 8'b11111111;
		end

		if (vc==32 || vc==40) begin
			vr <= 8'b11111111;
			vg <= 8'b11111111;
			vb <= 8'b11111111;
		end
end
endmodule
