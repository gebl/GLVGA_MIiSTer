
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

parameter hbp = 8;        // end of horizontal back porch
parameter hfp = 632;        // beginning of horizontal front porch
parameter vbp = 8;         // end of vertical back porch
parameter vfp = 472;        // beginning of vertical front porch

/*
parameter hbp = (TOTAL_COLS-ACTIVE_COLS)/2;        // end of horizontal back porch
parameter hfp = ACTIVE_COLS+hbp;        // beginning of horizontal front porch
parameter vbp = (TOTAL_ROWS-ACTIVE_ROWS)/2;         // end of vertical back porch
parameter vfp = ACTIVE_ROWS+vbp;        // beginning of vertical front porch
*/

reg   [10:0] hc;
reg   [10:0] vc;

wire h_active;
wire v_active;


assign h_active = (hc >= hbp && hc < hfp);
assign v_active = (vc >= vbp && vc < vfp);

/*
always @(posedge clk) begin
	ce_pix <= ~ce_pix;
	if(reset) begin
		ce_pix <= 0;
		hc <= 0;
		vc <= 0;
		hedge <= 0;
		vedge <= 0;
		hgrid<=0;
		vgrid<=0;
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
	if(h_active) begin
		HBlank <= 0;
		HSync <= 1;
	end else begin
		HSync <= 0;
		HBlank <= 1;
	end

	if (v_active) begin
		VBlank <= 0;
		VSync <= 1;
	end else begin
		VSync <= 0;
		VBlank <= 1;
	end

	if (h_active) begin
		hedge <= hedge + 1'd1;
		if(hedge == 7) begin
			hgrid <= hgrid + 1'd1;
		end
	end else begin
		hedge <= 0;
		hgrid <= 0;
	end

	if (v_active) begin
		vedge <= vedge + 1'd1;
		if(vedge == 7) begin
			vgrid <= vgrid + 1'd1;
		end
	end else begin
		vedge <= 0;
		vgrid <= 0;
	end
end
*/
always @(posedge clk) begin
	if(scandouble) ce_pix <= 1;
		else ce_pix <= ~ce_pix;


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
		HSync <= 1;
	end else begin
		HSync <= 0;
		HBlank <= 1;
	end

	if (vc < ACTIVE_ROWS) begin
		VBlank <= 0;
		VSync <= 1;
	end else begin
		VSync <= 0;
		VBlank <= 1;
	end
end


/*
always @(posedge clk) begin
	if (hc == 529) HBlank <= 1;
		else if (hc == 0) HBlank <= 0;

	if (hc == 544) begin
		HSync <= 1;

		if(vc == 490 ) VSync <= 1;
			else if (vc == (scandouble ? 496 : 248)) VSync <= 0;

		if(vc == 480) VBlank <= 1;
			else if (vc == 0) VBlank <= 0;
	end
	
	if (hc == 590) HSync <= 0;
end
*/
/*
always @(posedge clk) begin
	if (h_active && v_active) begin
		video <= 8'b00000000;
		vr <=  (hgrid==79 || hgrid==0 || vgrid==0 || vgrid==24) ? 8'b11111111:8'b00000000;
		vg <= (vedge==7) ? 8'b11111111:8'b00000000;
		vb <= (hedge==7 ) ? 8'b11111111 : 8'b00000000;
	end else begin
		video <= 8'b11111111;
		vr <= 8'b11111111;
		vg <= 8'b11111111;
		vb <= 8'b11111111;
	end
end
*/

always @(posedge clk) begin
		vr <=  8'b00000000;
		vg <= 8'b00000000;
		vb <= 8'b00000000;

		//vg <= (vc[3:0]==0) ? 8'b11111111:8'b00000000;
		//vb <= (hc[3:0]==0 ) ? 8'b11111111 : 8'b00000000;
		if (vc[10:3]==1) begin
			if (hc[3:3]==1) begin
				vr <= 8'b11111111;
				vg <= 8'b11111111;
				vb <= 8'b11111111;
			end else begin
				vr <= 8'b00000000;
				vg <= 8'b11111111;
				vb <= 8'b11111111;
			end
		end
		if (vc[10:3]==3) begin
			vr <= 8'b11111111;
			vg <= 8'b11111111;
			vb <= 8'b11111111;
		end
		if (vc[10:3]==2) begin
			vr <= 8'b00000000;
			vg <= 8'b00000000;
			vb <= 8'b11111111;
		end
		
end
endmodule
