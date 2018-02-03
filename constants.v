`ifndef CONSTANTS
	`define UART_CLOCK_DIVIDE	21 //  clock rate (50Mhz) / (baud rate (9600) * 4)
	`define BOARD_SIZE 14           //board size
	`define MAX_X_Y 13				//max x or y position
	`define X_Y_BIT 4               //boars size bits e.g    =log2(13)
	`define NUMBER_OF_PIECES 21     //number of pieces, last match it was 12, now it's going to be 14
	`define PIECE_SIZE_BIT 5        //number of pieces bits e.g 	=log2(21)
	`define ZERO_ASCII 	8'h30		//ASCI representation of '0'
	`define A_ASCII		8'h61		//ASCI representation of 'a'
	`define FIRST_PIECE_REAL 8'h75   		// ASCI representation of first piece = t
	`define FIRST_ROTATION_REAL 8'h30		// ASCI representation of first move rotation = '0'
	`define TEAM_CODE	16'h4141			// team code 

`endif