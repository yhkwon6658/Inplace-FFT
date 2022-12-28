## What's Implemented
1. Resmapler, TwiddleGenerator Implementation for Data Processing
2. Hardware Version Spectrogram GUI Implementation based on Qt
3. In-place FFT Architecture Implementation with Verilog HDL

## Reference paper
In-Place FFT Architecture are designed by [L. G. Johnson's Conflict Free Memory Addressing for Dedicated FFT Hardware](https://ieeexplore.ieee.org/document/142032).
Johnson presented only DIT architecture. He didn't prove DIF algorithm.
However, we proved, designed and implemented DIF architecture.
Compared two architectures(In the paper : DIT, Ours : DIF), you can understand conflict free addressing technique well.

## Block Diagram
![image](https://user-images.githubusercontent.com/120978778/209828748-8ab29ef1-223e-47ca-92ff-32fba7c2438e.png)

## DEMO VIDEO
Our architecture is setted on FFT-Point : 32, #(num) Sample data : 256.  
Our system uses IEEE 754 floating point single precision(32-bits).   

https://user-images.githubusercontent.com/109369687/204363690-38570695-cc74-4868-a109-0807d4b00894.mp4

## You can modify
You can generate data file from DATA/resample.m.  
You can generate twiddle factor table from DATA/twiddlegen.c.  
You can't modify radix. Only use radix-2.  

1. TOP module's parameter.
CLKS_PER_BIT = system clks / bitrate (For UART Communication).  
DATA_LENGTH = #(num) test data sample.  
N = FFT-point.  
R = log2(N).  
ROMFILE = test data sample file(data must be written for hexadecimal).  
TWIDDLEFILE = twiddle factor table file(data must be written for hexadecimal).  

2. ADDRgen
If you change N and R, then, You have to change the number of instantiated ADDRgen_element module.  
