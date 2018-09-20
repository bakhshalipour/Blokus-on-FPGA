# Blokus-on-FPGA

This project provides an implementation of [Blokus](https://en.wikipedia.org/wiki/Blokus) game in FPGA. The code is written in Verilog and deals with interfaces of [Altera DE2](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=183&No=30&PartNo=1) board. 

As Blokus is a complicated game, designing a sound AI algorithm for it is challenging work. The algorithm should analysis *many* potential places for a specific shape, and put the shape in the best position. As a consequence, most of the algorithms exhibit an undesirable execution latency. Fortunately, such algorithms exhibit abundant parallelism which can be exploited by FPGA.

This project implements an efficient AI algorithm for Blokus game on FPGA. The code uses *UART* for sending commands to and receiving states from Altera DE2 board. The maximum acceptable response time is 10 seconds, but the response usually is provided within 1 second.

The code was developed for the fourth [FPGA Challenge](http://fpga.sharif.edu/) of Sharif University of Technology and ranked 3rd among 30+ participants.

## Acknowledgments
This project is a joint work: **Mohammad Bakhshalipour**, Mostafa Karimi, and Hamed Sadat-Hosseini.
