#include <stdio.h>
#include <stdlib.h>

int blop(char s[20])
{
	if (s=="JAN") { return 1; }
	return 0;		
}



int main(int argc, char *argv[])
{
	FILE *entrada, *salida;
	entrada = fopen (argv[1],"r");
	salida  = fopen (argv[2],"w");

	char comando[950];	
	char comando2[950];
			
	char ca[4];
	char p11[20],p12[20],p13[20],p14[20];
	char p21[20],p22[20],p23[20],p24[20],p25[20],p26[20];
	char p31[20],p32[20],p33[20],p34[20],p35[20];	
	char crap[20];
						
	long int i=0;

	ca[i]='\n'; i++;
		
  fscanf(entrada,"%s %s %s %s %s\n",&crap,&p11,&p12,&p13,&p14);
  fscanf(entrada,"%s %s %s %s %s %s\n",&p21,&p22,&p23,&p24,&p25,&p26);
  fscanf(entrada,"%s %s %s %s %s\n",&p31,&p32,&p33,&p34,&p35);
  fprintf(salida,"%s%s%02d%s    ",p14,p13,atoi(p12),p11);
  while (fscanf(entrada,"%c",&ca[0])!=EOF)
	{	
		if (ca[0]=='\n')
		{
			fscanf(entrada,"%c",&ca[1]);
		        fscanf(entrada,"%c",&ca[2]);
		        fscanf(entrada,"%c",&ca[3]);					
		 if ((ca[3]=='4')
		    && ( ca[2]=='5' )
		    && ( ca[1]=='2' )
		    && ( ca[0]=='\n' ))
		 {	// Si aquí empieza un header
			
		  fscanf(entrada,"%s %s %s %s\n",&p11,&p12,&p13,&p14);
		  fscanf(entrada,"%s %s %s %s %s %s\n",&p21,&p22,&p23,&p24,&p25,&p26);
  		  fscanf(entrada,"%s %s %s %s %s\n",&p31,&p32,&p33,&p34,&p35);
		  fscanf(entrada,"%c",&ca[0]); 
		  fprintf(salida,"\n");
  		  fprintf(salida,"%s%s%02d%s    ",p14,p13,atoi(p12),p11);
		 }
		 else
	 	 { 
			fprintf(salida,"%c",ca[0]);
			fprintf(salida,"%s%s%02d%s  ",p14,p13,atoi(p12),p11);
			fprintf(salida,"%c",ca[1]);
			fprintf(salida,"%c",ca[2]);
			fprintf(salida,"%c",ca[3]);						
			continue;
		 }
		}
		
		
		  fprintf(salida,"%c",ca[0]);
			
	}
	fclose(salida);
	strcpy(comando,"sed 's/JAN/01/g;s/FEB/02/g;s/MAR/03/g;s/APR/04/g;s/MAY/05/g;s/JUN/06/g;s/JUL/07/g;s/AUG/08/g;s/SEP/09/g;s/OCT/10/g;s/NOV/11/g;s/DEC/12/g;' ");
	strcat(comando,argv[2]);
	strcat(comando," > TMPFILE && sed '$d' TMPFILE > ");
	strcat(comando,argv[2]);
	
	
	
	system(comando);


}