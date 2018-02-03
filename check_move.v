task check_move(
  input [31:0]player,
  input [31:0]y,
  input [31:0]x,
  input [31:0]piecee,
  input [31:0]rotatee,
  output m);
  
  integer c, r, xx, yy, x_offset, y_offset;
  integer got_it;  
  integer b,xxx,yyy;
  /*******************code***********************/
  begin
  m=1;
  got_it=0;
  c = piecee;
  r = rotatee;
  x_offset = x-2;
  y_offset = y-2;
  // Check availability
  if(available[c] == 0)begin
    m=0;
  end

  // No piece on already occupied grid
  for(yy=0; yy<5; yy=yy+1)begin
    for(xx=0; xx<5; xx=xx+1)begin
      b = pieces[c][rotate[r][yy][xx]/5][rotate[r][yy][xx]%5];
      if (b==1)begin
        if (board[y_offset+yy][x_offset+xx] != 0 ||
            y_offset+yy <= 0 || 15 <= y_offset+yy ||
            x_offset+xx <= 0 || 15 <= x_offset+xx
            )begin
		  //$display ("Current Value of xx = %d , yy = %d", xx,yy);	
          m=0;
        end
		xxx = x_offset+xx;
        yyy = y_offset+yy;
        if (board[yyy][xxx-1] == player || board[yyy][xxx+1] == player ||
            board[yyy-1][xxx] == player || board[yyy+1][xxx] == player )begin
			// $display ("Current Value of xx2 = %d , yy2 = %d", xx,yy);
          m=0;
		  
        end
		xxx = x_offset+xx;
        yyy = y_offset+yy;
		   //$display ("Current Value of xxx = %d , yyy = %d", xxx,yyy);
          if (board[yyy-1][xxx-1] == player || board[yyy+1][xxx-1] == player ||
              board[yyy-1][xxx+1] == player || board[yyy+1][xxx+1] == player)begin
           // $display ("Current Value of xxx = %d , yyy = %d", xxx,yyy);
			got_it = 1;
          end
      end
    end
  end
    if(!got_it)begin
      m=0;
    end

  end
endtask