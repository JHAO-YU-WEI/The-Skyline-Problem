//------------------------------------------------------//
//- Digital IC Design 2021                              //
//-                                                     //
//- Lab04b: Verilog Behavioral Level                    //
//------------------------------------------------------//
`timescale 1ns/10ps

module SKETCH
(
   // Output Port
   OUT_VALID,
   OUT_DATA,
   
   // Input Port
   CLK,
   RESET,
   IN_VALID,
   IN_DATA
);

output reg OUT_VALID;
output reg [5:0]OUT_DATA;

input   CLK;
input   RESET;
input   IN_VALID;
input   [5:0]IN_DATA;

// ==========================================
//  Enter your design below
// ==========================================

reg [5:0]   icounter;
reg [5:0] 	alldata[0:7][0:2];
reg [6:0]   sortdata[0:29][0:1];
reg [5:0] 	rightxdata[0:29];
reg [4:0]	i,l,m;
reg [5:0] 	j,k;
reg [5:0]	prehight;
reg [11:0]	xright_y;
reg [191:0]	outputdata;
reg [5:0]   oxcounter;


//counter IN_DATA numbers
always@(posedge CLK)
begin
	if(RESET)
		icounter <= 6'd0;
	else if(IN_VALID)
		icounter <= icounter + 6'd1;
	else 
		icounter <= 6'd0;
end
//store IN_DATA to alldata memory
always@(posedge CLK )
begin
	if(RESET) begin
		for(i = 0; i < 8; i = i +1) begin
			alldata[i][0] <= 0;
			alldata[i][1] <= 0;
			alldata[i][2] <= 0;
		end
	end
	else if((IN_VALID) || (oxcounter < 6'd18)) begin
			alldata[(icounter)/3][(icounter)%3] <= IN_DATA;// x left
	end
	else if(oxcounter > 0)begin	
		for(i = 0; i < 8; i = i +1) begin	
		alldata[i][0] <= 0;
		alldata[i][1] <= 0;
		alldata[i][2] <= 0;
		end
	end
end
//sort alldata memory to sortdata memory
always@(posedge CLK )
begin
	if(RESET) begin
		for(j = 0; j < 30; j = j +1) begin
			sortdata[j][0] <= 0;
			sortdata[j][1] <= 0;
		end
	end
	else if((icounter > 0) || (oxcounter < 6'd21))
	begin
		for(l = 0; l < 8; l = l +1) begin
			if((sortdata[alldata[l][0]][1][5:0] < alldata [l][1]) || (sortdata[alldata[l][2]][1][5:0] < alldata [l][1])) begin//sort special case 
				sortdata[alldata[l][0]][0] <= {1'd0,alldata [l][0]}; //x left
				sortdata[alldata[l][2]][0] <= {1'd0,alldata [l][2]}; //x right
				sortdata[alldata[l][0]][1] <= {1'd1,alldata [l][1]}; //x left, -y
				sortdata[alldata[l][2]][1] <= {1'd0,alldata [l][1]}; //x right, y	
			end
		end
	end
	else if(oxcounter > 6'd29) begin
		for(j = 0; j < 30; j = j +1) begin
			sortdata[j][0] <= 0;
			sortdata[j][1] <= 0;
		end	
	end
end
//ready rightxdata memory to use xright_ycase
always@(posedge CLK )
begin
	if(RESET) begin
		for(k = 0; k < 30; k = k +1)
			rightxdata[k] <= 0;
	end
	else if((icounter > 0) || (oxcounter < 6'd21)) begin
		for(m = 0; m < 8; m = m +1) begin
			if(rightxdata[alldata[m][0]] < alldata[m][2]) //sort special case
				rightxdata[alldata[m][0]] <= alldata[m][2]; //$display("Ans: %d", sortdata[alldata[j][2]][1]);
		end
	end
	else if(oxcounter > 6'd29) begin
		for(k = 0; k < 30; k = k +1)
			rightxdata[k] <= 0;
	end
end

//output OUT_VALID 
always@(posedge CLK )
begin
	if(RESET)
		OUT_VALID <= 1'd0;
	else if(IN_DATA == 6'd0)
		OUT_VALID <= 1'd0;
	else if(IN_VALID)
		OUT_VALID <= 1'd0;
	else if(icounter > 6'd0) 
		OUT_VALID <= 1'd0;
	else if((oxcounter == 6'd0) & ((outputdata[11:6] > 6'd0) || (outputdata[5:0] > 6'd0)))
		OUT_VALID <= 1'd1;
	else
		OUT_VALID <= 1'd0;
end

//ready oxcounter to algorithm
always@(posedge CLK)
begin
	if(RESET)
		oxcounter <= 6'd0;
	else if(icounter > 6'd6)
		oxcounter <= oxcounter + 6'd1;
	else if((oxcounter < 6'd30) && (oxcounter > 6'd17))
		oxcounter <= oxcounter + 6'd1;
	else
		oxcounter <= 6'd0;
end

//use outputdata to OUT_DATA
always@(posedge CLK)
begin
	if(RESET) begin
		OUT_DATA <= 6'd0;
	end
	else if(IN_VALID) begin
		OUT_DATA <= 6'd0;
	end
	else if(oxcounter == 6'd0) begin
		OUT_DATA <= outputdata[11:6];
	end
	else begin
		OUT_DATA <= 6'd0;
	end	
end

//algorithm
always@(posedge CLK)
begin
	if(RESET) begin
		outputdata <= 192'd0;
		prehight <= 6'd0;
		xright_y <= 12'd0;
	end
	else begin
		if((oxcounter < 6'd30) && (oxcounter > 6'd0)) begin
			if(sortdata[oxcounter][0][5:0] > 6'd0) begin//x > 0
				if((sortdata[oxcounter][1][5:0] > prehight) && (sortdata[oxcounter][1][6] == 1'd1)) begin//leftx case y > prehight
					outputdata[179:0] <= outputdata[191:12];		// outputdata shift 12 bit
					outputdata[185:180] <= sortdata[oxcounter][0][5:0];// store left x
					outputdata[191:186] <= sortdata[oxcounter][1][5:0];// store leftx's y
					prehight <= sortdata[oxcounter][1][5:0];		//updata prehight 
					xright_y <= xright_y;	// keep xright_y
				end
				else if((sortdata[oxcounter][1][5:0] <= prehight) && (sortdata[oxcounter][1][6] == 1'd1)) begin//leftx case y < prehight
					outputdata <= outputdata; // keep outputdata
					prehight <= prehight; // keep prehight
					xright_y[11:6] <= rightxdata[oxcounter]; //updata xright_y x
					xright_y[5:0]  <= sortdata[oxcounter][1][5:0]; //updata xright_y y
				end
				else if((sortdata[oxcounter][1][5:0] == prehight) && (sortdata[oxcounter][1][6] == 1'd0)) begin//right case y = prehight				
					if((sortdata[oxcounter][0][5:0] < xright_y[11:6])) begin//case1: x right in xright_y building
						outputdata[179:0] <= outputdata[191:12]; // outputdata shift 12 bit
						outputdata[185:180] <= sortdata[oxcounter][0][5:0]; // store right x
						outputdata[191:186] <= xright_y[5:0]; // store right x's y
						prehight <= xright_y[5:0];	//updata prehight
						xright_y <= xright_y; // keep xright_y
					end
					else begin//if((sortdata[k][0][5:0] >= xright_y[5:0]))  //case2: x right (out or match) xright_y building
						outputdata[179:0] <= outputdata[191:12]; // outputdata shift 12 bit
						outputdata[185:180] <= sortdata[oxcounter][0][5:0]; // store right x
						outputdata[191:186] <= 6'd0; // store right x's y=0
						prehight <= 6'd0;  //updata prehight=0
						xright_y <= xright_y;  // keep xright_y
					end
				end
			end
		end
		else if(oxcounter == 6'd0) begin
			prehight <= 6'd0; //reset prehight
			xright_y <= 12'd0; //reset xright_y
			if((outputdata[11:6] > 6'd0) || (outputdata[5:0] > 6'd0))
				outputdata[185:0] <= outputdata[191:6];
			else if(outputdata > 192'd0)
				outputdata[185:0] <= outputdata[191:6];
		end
	end		
end
endmodule 