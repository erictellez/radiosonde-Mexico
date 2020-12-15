%PROGRAMA PARA ANALIZAR LOS DATOS QUE SE OBTIENEN CON LA SONDA METEOROLOGICA, EN ESPECIAL PARA CALCULAR LA ISOTERMA CERO
%REALIZADO POR ERIC BENJAM�?N TÉLLEZ UGALDE  erictellez@gmail.com erictellez@hotmail.com
%CON LA AYUDA DE VICTOR MIRELES CHAVEZ
%INICIADO EN MARZO DEL 2009 Y FINALIZADO EN OCTUBRE DEL 2009

%***************% 1. NOMBRE DEL PROGRAMA Y ENTRADA DE DATOS **********************
function [Mediciones,Ceros] = CalcularRegresion(NombreArchivo)


%***************% 2. ANALISIS DE DATOS *******************************************
Archivo = load (NombreArchivo);   % carga el archivo
Fechas = Archivo(:,1);        % asigna todos los renglones de la columna 1 al vector fechas
totalarchivo=length(Fechas);  %longitud de Fechas

% ciclo para homologar el formato de las fechas
for p=1:totalarchivo
	if (Fechas(p) < 1000000000)  %Este condicional lo puse para poder hacer el promedio de todas las fechas de manera mas fácil, ya que el archivo que generó el otro programa arroja las fechas y las horas de la medición pegadas en un sólo numero de la forma aaaammddhh, pero si una medición se había realizado a las 6 de la mañana el numero que resultaba era aaaammdd6 y si la medición se había realizado a las 3 de la tarde entonces arroja aaaammdd15, dando un número 10 veces mas grande. Entonces la siguiente operación cambia por ejemplo aaaammdd6 por aaaammdd06	
	   Fechas(p)=10*Fechas(p)-9*rem(Fechas(p),10);
	end       
end

FechasUnicas = unique(Fechas);  % busca dentro de fechas, las fechas que son diferentes o únicas y lo asigna a FechasUnicas, es decir, FechasUnicas es un vector en el que cada entrada contiene cada fecha diferente del archivo
totfechas = length(FechasUnicas);  % busca la longitud del vector FechasUnicas y el total se lo asigna a totfechas

Mediciones=[];        % se crea el vector mediciones vacío
Ceros=[];             % se crea el vector ceros vacío
MedicionesRed=[];
CerosReducidos=[]; %vector de ceros construido a partir de los dos anteriores
disp('Año')
floor(FechasUnicas(1)/1000000)
disp('Mediciones totales')
numel(FechasUnicas)   % despliega el Número de fechas diferentes

% empieza un ciclo para analizar todas las fechas diferentes
for i=1:totfechas        

	unafecha=FechasUnicas(i); % asigna a la variable unafecha el valor de la entrada i de FechasUnicas
	MisIndices=find(Fechas==unafecha); % Busca dentro de Fechas las que son iguales a unafecha y el total de fechas iguales se lo asigna a misindices
	CuantasEstaFecha=length(MisIndices); % Le asigna a cuantasestafecha la longitud del vector misindices, que es el total de datos que hay para esa fecha en específico
        
        Altura=[];	% Se crea el vector de alturas vacío
	Temperatura=[];     % Se crea el vector temperatura vacío 
	IndicesOrdenados=[];
	IndiceMin=[];
	TemperaturaOrdenada=[];  
	AlturaReducida=[]; 
	TemperaturaReducida=[]; % se crean el vector AlturaReducida y TemperaturaReducida para almacenar el par de datos que nos servirán para hacer el ajuste

	% Se abre otro ciclo para analizar todos los datos de cada fecha
	for j=1:CuantasEstaFecha  

                    % condiciones sobre los datos
                    if (Archivo(MisIndices(j),5) == 99999) % si en la columna de la temperatura esta el valor 99999, quiere decir que en realidad no hay datos, entonces se lo salta
                        continue;
		    elseif (Archivo(MisIndices(j),4) <= 2230) %reduce el rango de busqueda de los datos desde el numero que aparece (en MSNM), en este renglón se debería poner la altura a la cual se encuentra la estación
                        continue;
                    elseif (Archivo(MisIndices(j),4) >= 6000) % reduce el rango de los datos hasta el numero que aparece (en MSNM)
			continue;
                    else
		    % Si el valor cae en el rango que esta puesto arriba, entonces se asigna el valor de la columna 4 del archivo al vector altura, junto con el valor que le corresponde a la columna cinco, al vector temperatura 
			Altura=[Altura,[Archivo(MisIndices(j),4)]];
			Temperatura=[Temperatura,[Archivo(MisIndices(j),5)]];
                    endif  % fin del condicional
               		
	end  % fin del primer ciclo

	vacia=isempty(Altura); % Esta funcion verifica si el vector altura esta vacio
	uno=numel(Altura); % Numero de elementos del vector Altura

  if (vacia == 1)   % si el vector altura esta vacio, la funcion isempty arroja un 1, y entonces el programa se salta este calculo y se va a la siguiente fecha
	continue;
  elseif (uno == 1)  % si el vector tiene un elemento, se salta el cálculo también
	continue;
  else    % si tiene dos o más elementos la matriz, entonces hace los siguientes calculos
	P=polyfit(Temperatura,Altura,1); % ajusta los vectores Temperatura y Altura a orden 1, o sea una recta		
	cero=polyval(P,0);  % obtiene el valor cero de esa recta
	Mediciones=[Mediciones,[unafecha]];  % construye el vector Mediciones con las fechas
	Ceros=[Ceros,[cero]];  % construye el vector Ceros con los valores de la altura	a la cual se encuentra la temperatura cero
	[AlturaMinAnual,IndiceFechaMin]=min(Ceros);  %Arroja el máximo valor de ceros, que es la altura minima a la cual se encuentra la isoterma
	FechaMin=Mediciones(IndiceFechaMin); %Arroja la fecha de este máximo
	[AlturaMaxAnual,IndiceFechaMax]=max(Ceros);  %Arroja el máximo valor de ceros, que es la altura minima a la cual se encuentra la isoterma
	FechaMax=Mediciones(IndiceFechaMax); %Arroja la fecha de este máximo
	
% ESTE PEDAZO LO PUSE PARA HACER EL PROMEDIO UNICAMENTE CON DOS DATOS, EL ULTIMO POSITIVO Y EL PRIMER NEGATIVO. HAY DOS PROBLEMAS PRINCIPALES: 1. QUE LOS VALORES ANTERIOR Y POSTERIOR AL MINIMO SEAN DEL MISMO SIGNO,  2. QUE EL VALOR DE LA CELDA ANTERIOR SEA NEGATIVO MIENTRAS QUE EL VALOR DE LA CELDA POSTERIOR SEA POSITIVO.  SI LOS DATOS NO SON BUENOS Y ADEMAS NO SE CUMPLEN NINGUNO DE ESTOS DOS PROBLEMAS ENTONCES EL PROGRAMA AGARRA LOS DATOS SIN REDUCIR, ES DECIR EN EL RANGO ESCRITO ARRIBA, PARA SACAR EL PROMEDIO; ESTOS CASOS SON POCOS.
	
	IndiceMax=length(Altura); %La longitud de altura y de temperatura es la misma
	[TemperaturaOrdenada,IndicesOrdenados]=sort(abs(Temperatura)); %Ordena los valores aboslutos del vector temperaturas de menor a mayor y se lo asigna al vector 			TemperaturaOrdenada y tambien crea el vector de indices IndicesOrdenados, con el que se manipualara el resto del codigo	

	%Inicia un ciclo para asignar el menor valor que este en el rango seleccionado. Generalmente sera el numero 1, pero justamente este ciclo asegura que ese minimo caiga en el rango
	for s=1:IndiceMax
	%Un condicional para asignarle el valor minimo a datos que esten entre 3600 y 6000
	   if (Altura(IndicesOrdenados(s))<3000) || (Altura(IndicesOrdenados(s))>6000)
		continue; %si no cae en el rango va con el siguiente
	   else
		IndiceMin=IndicesOrdenados(s); %Asigna a IndiceMin, el valor minimo del vector IndicesOrdenados
		AlturaReducida=[AlturaReducida,[Altura(IndiceMin)]]; % Asigna a la variable AlturaReducida el valor de la entrada del vector Altura que tiene el indice IndicesOrdenados, es decir, asigna el valor para el cual la altura tiene una temperatura cercana a cero
		TemperaturaReducida=[TemperaturaReducida,[Temperatura(IndiceMin)]]; % asigna el valor de la temperatura mas cercano a cero a TemperaturaReducida
		break; %Rompe al encontrar el primero que cumpla las condiciones
	   end  %fin de la condición
	end %fin del ciclo
	
	%Condicional por si IndiceMin esta vacio
	if (IndiceMin==[])
		AlturaReducida=Altura;
		TemperturaReducida=Temperatura;

	%Condicionales por si el valor minimo es el primer elemento, lo toma y toma el siguiente, o por si es el último entonces lo toma y toma el anterior
     elseif      (IndiceMin == 1)
		AlturaReducida=[AlturaReducida,[Altura(IndiceMin+1)]];
		TemperaturaReducida=[TemperaturaReducida,[Temperatura(IndiceMin+1)]];
     elseif (IndiceMin == IndiceMax)
 		AlturaReducida=[AlturaReducida,[Altura(IndiceMin-1)]];
		TemperaturaReducida=[TemperaturaReducida,[Temperatura(IndiceMin-1)]];

	%Condicionales para recopilar los datos para hacer la recta reducida, estas dos instrucciones son para los datos "ideales"
     elseif  (IndiceMin>1) && (Temperatura(IndiceMin)<=0) && (Temperatura(IndiceMin-1)>0)
		AlturaReducida=[AlturaReducida,[Altura(IndiceMin-1)]];
		TemperaturaReducida=[TemperaturaReducida,[Temperatura(IndiceMin-1)]];
     elseif (IndiceMin>1) && (Temperatura(IndiceMin)>=0) && (Temperatura(IndiceMin+1)<0)
		AlturaReducida=[AlturaReducida,[Altura(IndiceMin+1)]];	
		TemperaturaReducida=[TemperaturaReducida,[Temperatura(IndiceMin+1)]];
	
	%Condicional para sortear datos anómalos. Los datos adyacentes al minimo que tienen ambos el mismo signo o que el anterior es negativo y el siguiente es positivo (cuando debería de suceder lo contrario).  Lo que hace es que busca el siguiente número más pequeño y verifica que este en el rango, despues asigna a ese como mínimo y comprueba que cumpla con las condiciones, si no lo hace se repite el ciclo hasta que encuentra uno
     elseif (IndiceMin>1) && (((Temperatura(IndiceMin-1)<0) && (Temperatura(IndiceMin+1)>0)) || ((Temperatura(IndiceMin-1)>0) && (Temperatura(IndiceMin+1)>0)) || ((Temperatura(IndiceMin-1)<0) && (Temperatura(IndiceMin+1)<0)))
	%FechasUnicas(i)-1000000000 % Me da la fecha por si se produce un error, si se quieren procesar datos de años del 2000 en adelante se escribe 2000000000 y si se quieren procesar años antes de 1999 se escribe 1000000000
       for r=2:IndiceMax-1
	 if (Altura(IndicesOrdenados(r))<3000) || (Altura(IndicesOrdenados(r))>6000)
		continue;
	 elseif (Temperatura(IndicesOrdenados(r))<0) && (Temperatura(IndicesOrdenados(r)-1)>0)
		AlturaReducida=[AlturaReducida,[Altura(IndicesOrdenados(r)-1)]];
		TemperaturaReducida=[TemperaturaReducida,[Temperatura(IndicesOrdenados(r)-1)]];
		break;
	 elseif (Temperatura(IndicesOrdenados(r))>0) && (Temperatura(IndicesOrdenados(r)+1)<0)
		AlturaReducida=[AlturaReducida,[Altura(IndicesOrdenados(r)+1)]];	
		TemperaturaReducida=[TemperaturaReducida,[Temperatura(IndicesOrdenados(r)+1)]];	
		break;
 	 endif   %Fin del condicional de datos adyacentes negativos e iguales en signo al min
	end %Fin del ciclo

	%Ultimo condicional para los casos no previstos
     else
		AlturaReducida=Altura;
		TemperaturaReducida=Temperatura;
	endif %Fin del condicional para datos anómalos

	vaciareducida=isempty(AlturaReducida);	
	un=numel(AlturaReducida);

	if (vaciareducida == 1)  %Es para prevenir que se hagan promedios con matrices vacias o con matrices con un solo elemento. Si esto llegara a pasar hay que revisar los datos
		disp('Fechas en que la matriz con datos reducidos esta vacía')
		AlturaReducida   %Esto lo puse porque 'Mediciones buenas' y 'Mediciones Reducidas' deben coincidir para simpificar el cálculo
		FechasUnicas(i)-1000000000 %Entonces me da la fecha para poder corregirlo en los datos
		continue;
	elseif (un == 1)
		disp('Fechas en que la matriz con datos reducidos tiene un elemento')
		AlturaReducida
		FechasUnicas(i)-1000000000
		continue;
	else	
   	        %Ajuste de los Vectores reducidos
 	        PRed=polyfit(TemperaturaReducida,AlturaReducida,1); % ajusta los vectores TemperaturaReducida y AlturaReducida a orden 1, o sea una recta
		cerored=polyval(PRed,0);  % obtiene el valor cero de esa recta
		CerosReducidos=[CerosReducidos,[cerored]];  % construye el vector CerosReducidos con los valores de la altura a la cual se encuentra la temperatura cero
		[AlturaMinAnualRed,IndiceFechaMinRed]=min(CerosReducidos);  %Arroja el máximo valor, que es la altura minima a la cual se encuentra la isoterma
		FechaMinRed=Mediciones(IndiceFechaMinRed); %Arroja la fecha de este máximo
		[AlturaMaxAnualRed,IndiceFechaMaxRed]=max(CerosReducidos);  %Arroja el máximo valor, que es la altura minima a la cual se encuentra la isoterma
		FechaMaxRed=Mediciones(IndiceFechaMaxRed); %Arroja la fecha de este máximo
		%MedicionesRed=[MedicionesRed,[unafecha]];
	endif

  endif  % fin del condicional


end  % fin del segundo ciclo
%Mediciones'-1000000000
disp('Mediciones buenas')
numel(Ceros)   %Cuenta cuantas entradas tiene el vector mediciones, dependiendo de las condiciones (el rango de las alturas en Ln 52 Col 57 y Ln 54 Col 57) debe dar menor o igual que las Mediciones totales
disp('Mediciones reducidas')
numel(CerosReducidos)
%Fin del promedio por medición


% PROMEDIO DIARIO
% lo que hace el programa, es que agarra el vector mediciones y divide entre 100 y deja solamente la parte entera, entonces con esto se quita la hora, y quedaran numeros iguales para los mismos días, aunque de horas diferentes. Agarra el indice del vector de esos numeros y promedia los ceros que se encuentran en esos índices
Fechasdiarias=floor(Mediciones./100);  %Divide cada entrada del vector mediciones entre 100 y se queda con la parte entera, eso se lo asigna al vector Medicionesdiarias
diasunicos=unique(Fechasdiarias);  % Busca en Fechasdiarias los que son diferentes
totaldias=length(diasunicos);    %da el valor de la longitud del vector dia
medicionespordia=[];    %crea el vector vacío
promediopordia=[];      %crea el vector vacío
promediopordiared=[];   %crea el vector vacío

%Inicio del ciclo para el calculo del promedio por día
 for k=1:totaldias
 	undia=diasunicos(k);    %Asocia la entrada k de diasunicos a undia
        indicesmediciones=find(Fechasdiarias==undia);  %busca en Fechasdiarias los que son iguales a undia y arroja el indice de esa entrada y la pone en indicesmediciones
	estedia=length(indicesmediciones);  % da la longitud de indicesmediciones
	cerospordia=[]; 	%crea el vector vacío
	cerospordiared=[];	

	% este ciclo toma el indice obtenido en indicesmediciones y busca el valor del vector ceros que corresponde a ese indice y lo asigna al vector cerospordia
 	for l=1:estedia
		cerospordia=[cerospordia,[Ceros(indicesmediciones(l))]];
	        cerospordiared=[cerospordiared,[CerosReducidos(indicesmediciones(l))]];
		% el anterior comando es para hacer el promedio reducido, con la temperatura reducida y la altura reducida
	end

	ppd=mean(cerospordia);  %saca el promedio del vector cerospordia
	ppdr=mean(cerospordiared); 
	medicionespordia=[medicionespordia,[undia]]; %construye el vector medicionporfecha que contiene las fechas sin las horas, a diferencia del vector mediciones
	promediopordia=[promediopordia,[ppd]];  % construye un vector con los promedios por dia
	promediopordiared=[promediopordiared,[ppdr]];
	
 end
% fin del promedio diario


% PROMEDIO MENSUAL
% El programa agarra el promedio diario calculado arriba y sobre de eso hace el promedio mensual
Fechasmensuales=floor(medicionespordia./100); %divide cada entrada del vector Medicionespordia entre 100 y se queda con la parte entera para quedarse solo con los meses y los años
mesesunicos=unique(Fechasmensuales);  %lo mismo que para promedio diario
totalmeses=length(mesesunicos);
medicionespormes=[];
promediopormes=[];
desvest=[];
promediopormesred=[];	
desvestred=[];
minimopormes=[];
maximopormes=[];

 for m=1:totalmeses
	unmes=mesesunicos(m);
	indicesmensuales=find(Fechasmensuales==unmes);
	estemes=length(indicesmensuales);
	cerospormes=[];
	cerospormesred=[];

	for n=1:estemes
		cerospormes=[cerospormes,[promediopordia(indicesmensuales(n))]];
		cerospormesred=[cerospormesred,[promediopordiared(indicesmensuales(n))]];
	end
	
	maxpormes=max(cerospormes); %valor máximo por cada mes
	minpormes=min(cerospormes); %valor mínimo por cada mes	

	ppm=mean(cerospormes);
	sd=std(cerospormes);
	ppmr=mean(cerospormesred);
	sdr=std(cerospormesred);
	medicionespormes=[medicionespormes,[unmes]];
	promediopormes=[promediopormes,[ppm]];  %construye el vector promediopormes que tiene en cada entrada el promedio mensual de la isoterma cero
	desvest=[desvest,[sd]];  %contruye un vecto con las desviaciones
	promediopormesred=[promediopormesred,[ppmr]];  %lo mismo pero con las reducidas
	desvestred=[desvestred,[sdr]];

	maximopormes=[maximopormes,[maxpormes]]; %vector con el valor maximo por cada mes
	minimopormes=[minimopormes,[minpormes]]; %vector con el valor minimo por cada mes
 end
% fin del promedio mensual


%************************% 3. SALIDA DE RESULTADOS ***********************************

file_id = fopen('todos_los_datos_esta_estacion.dat', 'a'); %Esta instrucción es para abrir un archivo y escribir en el.

fprintf(file_id,'%i ',floor(FechasUnicas(1)/1000000));   %Para imprimir el año 
%fprintf(file_id,'%i ',numel(FechasUnicas));    %Para imprimir los datos totales
%fprintf(file_id,'%i ',numel(Ceros));           %Para imprimir los datos buenos
%fprintf(file_id,'%i ',numel(CerosReducidos));  %Para imprimir los datos buenos reducidos

disp(' ') %Inserta una línea en blanco
disp('Datos reducidos significa que se ajusto la recta con unicamente dos pares de datos')
disp(' ')
disp('Valores Extremos')
disp('Mínimo y su fecha')
min(Ceros)  %Con esta instrucción se despliegan los datos en la pantalla y también para que se vea si esta bien
FechaMin-1000000000
fprintf(file_id,'%f ',min(Ceros)) %Esta imprime la salida de los datos en el archivo que esta abierto
fprintf(file_id,'%d ',FechaMin-1000000000) %Esta instrucción imprime la fecha de estos datos.
disp('Máximo y su fecha')
max(Ceros)
FechaMax-1000000000
fprintf(file_id,'%f ',max(Ceros))
fprintf(file_id,'%d ',FechaMax-1000000000)
disp('Valores Extremos Reducidos')
disp('Mínimo y su fecha')
min(CerosReducidos)
FechaMinRed-1000000000
fprintf(file_id,'%f ',min(CerosReducidos))
fprintf(file_id,'%d ',FechaMinRed-1000000000)
disp('Máximo y su fecha')
max(CerosReducidos)
FechaMaxRed-1000000000
fprintf(file_id,'%f ',max(CerosReducidos))
fprintf(file_id,'%d ',FechaMaxRed-1000000000)
% Promedio anual tomando cada medición
disp('Promedio anual tomando cada medición y su desviación estandar')
mean(Ceros)
std(Ceros)
fprintf(file_id,'%f ',mean(Ceros))     % la media de Ceros, es la anual de todos los datos
fprintf(file_id,'%f ',std(Ceros))      % la desviación de Ceros
disp('Promedio anual con los datos reducidos')
mean(CerosReducidos)
std(CerosReducidos)
fprintf(file_id,'%f ',mean(CerosReducidos))
fprintf(file_id,'%f ',std(CerosReducidos))
%plot(Mediciones,Ceros)     %grafica las alturas, pero creo que esta instrucción está mal

% Promedio anual tomando el promedio diario
disp('Promedio anual tomando el promedio diario y su desviación estandar')
mean(promediopordia)
std(promediopordia)
fprintf(file_id,'%f ',mean(promediopordia))
fprintf(file_id,'%f ',std(promediopordia))
disp('Promedio anual tomando el promedio diario pero con datos reducidos')
mean(promediopordiared)
std(promediopordiared)
fprintf(file_id,'%f ',mean(promediopordiared))
fprintf(file_id,'%f ',std(promediopordiared))
%plot(medicionespordia,promediopordia)

% Promedio anual tomando el promedio mensual
disp('Promedio anual tomando el promedio mensual y su desviación estandar')
mean(promediopormes)
std(promediopormes)
fprintf(file_id,'%f ',mean(promediopormes))
fprintf(file_id,'%f ',std(promediopormes))
disp('Promedio anual tomando el promedio mensual pero con datos reducidos')
mean(promediopormesred)
std(promediopormesred)
fprintf(file_id,'%f ',mean(promediopormesred))
fprintf(file_id,'%f ',std(promediopormesred))

%Promedio mensual de cada mes
file_mean_mes = fopen('promediopormes.dat', 'a');
disp('Promedio por cada mes')
promediopormes'
desvest'
for i=1:length(promediopormes)
	fprintf(file_id,'%f ',promediopormes(i))
	fprintf(file_mean_mes,'%f ',promediopormes(i))
end
for i=1:length(desvest)
	fprintf(file_id,'%f ',desvest(i))
end
fclose(file_mean_mes);

file_mean_mes_red = fopen('promediopormesred.dat','a');
disp('Promedio por cada mes reducido')
promediopormesred'
desvestred'
for i=1:length(promediopormesred)
	fprintf(file_id,'%f ',promediopormesred(i))
	fprintf(file_mean_mes_red,'%f ',promediopormesred(i))
end
for i=1:length(desvestred)
	fprintf(file_id,'%f ',desvestred(i))
end
fclose(file_mean_mes_red);
%plot(medicionespormes,promediopormes)

%Máximo por cada mes
file_max_mes= fopen('maximopormes.dat','a');
disp('Máximo por cada mes')
maximopormes'
for i=1:length(maximopormes)
	fprintf(file_id,'%f ',maximopormes(i))
	fprintf(file_max_mes,'%f ',maximopormes(i))
end
fclose(file_max_mes);

%Mínimo por mes
file_min_mes= fopen('minimopormes.dat','a');
disp('Mínimo por cada mes')
minimopormes'
for i=1:length(minimopormes)
	fprintf(file_id,'%f ',minimopormes(i))
	fprintf(file_min_mes,'%f ',minimopormes(i))
end
fclose(file_min_mes);

fprintf(file_id,'\n'); %Le inserta un salto de linea al archivo, para que la siguiente vez que se abra ese archivo, se comienze a escribir desde la linea que le sigue
fclose(file_id); %cierra el archivo abierto


% Para salvar los archivos si es que se necesitan
%pormedicion=[Mediciones',Ceros']; % se guardan los vectores en la matriz pormedicion, los comillas son para transponer los vectores
%diario=[medicionespordia',promediopordia'];
%mensual=[medicionespormes',promediopormes'];
%save('-ascii','ceros_año.dat','pormedicion');   %Para salvar la matriz pormedicion en forma de un archivo que se llamaria ceros_año.dat  Esta instrucción es mejor darla desde la ventana de comandos, ya que así se le puede cambiar el nombre la archivo de salida
%save('-ascii','ceros_año_dia.dat','diario'); %lo mismo para estas dos instrucciones
%save('-ascii','ceros_año_mes.dat','mensual');

end  % fin del programa
