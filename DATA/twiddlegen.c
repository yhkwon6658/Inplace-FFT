#include <math.h>
#include <stdio.h>
unsigned int float2hex(float val)
{
	union converter {
		float f_val;
		unsigned int u_val;
	};

	union converter var;
	var.f_val = val;
	return var.u_val;
}
int main(void)
{
int N = 32;
const double pi = 3.141592653589793238462643;
float t_cos = 0;
float t_sin = 0;
FILE *fp = NULL;
fopen_s(&fp,"twiddle.txt","w");
for(int i=0;i<N/2;i++)
{
    t_cos = cos(2*pi/N*i);
    t_sin = -1.0*sin(2*pi /N* i);
	printf("%f\n", t_cos);
	printf("%f\n", t_sin);
	printf("\n");
    //fprintf(fp,"%08x",float2hex(t_cos));
    //fprintf(fp,"%08x\n",float2hex(t_sin));
    //printf("%08x",float2hex(t_cos));
    //printf("%08x\n",float2hex(t_sin));
}
fclose(fp);
return 0;
}