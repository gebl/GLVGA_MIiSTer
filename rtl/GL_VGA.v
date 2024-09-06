/**
* Sample module for MiSTer for exploing VGA output.
*
* The module generates a VGA signal with a resolution of 640x480 pixels at 60Hz. The module generates
* the horizontal and vertical sync signals, as well as the red, green and blue signals for the VGA output.
* 
* It generates a pattern on the screen based on the hc/vc counters, creating vertical and horizontal bars and 
* highlighting the boundary of a specific column and row.
*/
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
http://www.tinyvga.com/vga-timing/640x480@60Hz

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

/**
* Handles the generation of the horizontal and vertical counters, tracking the current pixel position on the screen.
*/
always @(posedge clk) begin
	/*if(scandouble) ce_pix <= 1;
		else ce_pix <= ~ce_pix;
	*/
	ce_pix<=1;

    // Reset horizontal and vertical counters if reset signal is high
    if(reset) begin
        hc <= 0; // Reset horizontal counter
        vc <= 0; // Reset vertical counter
    end
    // If pixel clock enable is high, update counters
    else if(ce_pix) begin
        // If horizontal counter reaches the total number of columns
        if(hc == TOTAL_COLS-1) begin
            hc <= 0; // Reset horizontal counter

            // If vertical counter reaches the total number of rows
            if(vc == TOTAL_ROWS-1) begin 
                vc <= 0; // Reset vertical counter
            end else begin
                vc <= vc + 1'd1; // Increment vertical counter
            end
        end else begin
            hc <= hc + 1'd1; // Increment horizontal counter
        end
    end
end

/**
* Continuous assignment of HBlank and VBlank signals based on the 
* current horizontal and vertical counters and the visible area
*/
assign HBlank = (hc < hviz) ? 0 : 1;
assign VBlank = (vc < vviz) ? 0 : 1;

/**
* Continuous assignment of HSync and VSync signals based on the
* current horizontal and vertical counters after the back porch for the timing of 
* horizontal and vertical sync pulses
*/
assign HSync = (hc >= hviz+hbp && hc<hviz+hbp+hsp) ? 1 : 0;
assign VSync = (vc >= vviz+vbp && vc<vviz+vbp+vsp) ? 1 : 0;

/**
* Handles VGA signal generation, setting the values for the red (vr), green (vg) and blue (vb) signals based on 
* the current horizontal and vertical counters tracking the pixel position on the screen.
*
* The the enclosed logic is executed on the rising edge of the clock signal (posedge clk). At the start of each 
* clock cycle, vr, vg and vb are set to 0, effectively setting the color to black. 
* 
* The logic then sets the color values based on the current horizontal and vertical counters. Creating vertical 
* and horizontal bars 8 pixels wide/tall alternating every other bar.
*/
always @(posedge clk) begin
		vr <=  8'b00000000;
		vg <= 8'b00000000;
		vb <= 8'b00000000;

		//create red vertical bar every other row
		if (hc[3:3]==1) begin
			vr <= 8'b11111111;
		end else begin
			vr <= 8'b00000000;
		end

		//create blue vertical bar every other row
		if (vc[3:3]==1) begin
			vb <= 8'b00000000;
		end else begin
			vb <= 8'b11111111;
		end

		//create white bar on the first and last columns
		if (vc[10:3]==0 || vc[10:3]>=59) begin
			vr <= 8'b11111111;
			vg <= 8'b11111111;
			vb <= 8'b11111111;
		end

		//create white bar on the first and last rows
		if (hc[10:3]==0 || hc[10:3]>=79) begin
			vr <= 8'b11111111;
			vg <= 8'b11111111;
			vb <= 8'b11111111;
		end

		//create a white border around a column and row
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
