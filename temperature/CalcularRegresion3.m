%PROGRAMA PARA ANALIZAR LOS DATOS QUE SE OBTIENEN CON LA SONDA METEOROLOGICA, EN ESPECIAL PARA CALCULAR LA ISOTERMA CERO
%REALIZADO POR ERIC BENJAMÍN TÉLLEZ UGALDE  erictellez@gmail.com erictellez@hotmail.com

%---------------------------------------------------------------------------------------------------------------
%El programa CalcularRegresion3 se hizo para poder analizar los datos de los años 2000, pues estos tienen otro formato diferente a los de los datos que están antes.
%Este archivo es mas pequeño
%----------------------------------------------------------------------------------------------------------------


%***************% 1. NOMBRE DEL PROGRAMA Y ENTRADA DE DATOS **********************
function [Mediciones,Ceros] = CalcularRegresion3(NombreArchivo)


%***************% 2. ANALISIS DE DATOS *******************************************
Archivo = load (NombreArchivo);   % carga el archivo
Fechas = Archivo(:,1);        % asigna todos los renglones de la columna 1 al vector fechas
totalarchivo=length(Fechas);  %longitud de Fechas

FechasUnicas = unique(Fechas);  % busca dentro de fechas, las fechas que son diferentes y lo asigna a FechasUnicas, es decir, FechasUnicas es un vector en el que cada entrada contiene cada fecha diferente del archivo
totfechas = length(FechasUnicas);  % busca la longitud del vector FechasUnicas y el total se lo asigna a totfechas

Mediciones=[];        % se crea el vector mediciones vacío
Ceros=[];             % se crea el vector ceros vacío

% empieza un ciclo para analizar todas las fechas diferentes
for i=1:totfechas        

	unafecha=FechasUnicas(i); % asigna a la variable unafecha el valor de la entrada i de FechasUnicas
	MisIndices=find(Fechas==unafecha); % Busca dentro de Fechas las que son iguales a unafecha y el total de fechas iguales se lo asigna a misindices
	Ceros=[Ceros,[Archivo(MisIndices(1),2)]];  %asigna al vector ceros la altura que corresponde al primer cero que se encuentra en el archivo	
	Mediciones=[Mediciones,[unafecha]];  % construye el vector Mediciones con las fechas
	
end  % fin del ciclo linea 26

	[AlturaMinAnual,IndiceFechaMin]=min(Ceros);  %Arroja el máximo valor de ceros, que es la altura minima a la cual se encuentra la isoterma
	FechaMin=Mediciones(IndiceFechaMin); %Arroja la fecha de este máximo
	[AlturaMaxAnual,IndiceFechaMax]=max(Ceros);  %Arroja el máximo valor de ceros, que es la altura maxima a la cual se encuentra la isoterma
	FechaMax=Mediciones(IndiceFechaMax); %Arroja la fecha de este máximo

%Fin del promedio por medición


% PROMEDIO DIARIO
% lo que hace el programa, es que agarra el vector mediciones y divide entre 100 y deja solamente la parte entera, entonces con esto se quita la hora, y quedaran numeros iguales para los mismos días, aunque de horas diferentes. Agarra el indice del vector de esos numeros y promedia los ceros que se encuentran en esos índices
Fechasdiarias=floor(Mediciones./100);  %Divide cada entrada del vector mediciones entre 100 y se queda con la parte entera, eso se lo asigna al vector Medicionesdiarias
diasunicos=unique(Fechasdiarias);  % Busca en Fechasdiarias los que son diferentes
totaldias=length(diasunicos);    %da el valor de la longitud del vector dia
medicionespordia=[];    %crea el vector vacío
promediopordia=[];      %crea el vector vacío

%Inicio del ciclo para el calculo del promedio por día
 for k=1:totaldias
 	undia=diasunicos(k);    %Asocia la entrada k de diasunicos a undia
        indicesmediciones=find(Fechasdiarias==undia);  %busca en Fechasdiarias los que son iguales a undia y arroja el indice de esa entrada y la pone en indicesmediciones
	estedia=length(indicesmediciones);  % da la longitud de indicesmediciones
	cerospordia=[]; 	%crea el vector vacío

	% este ciclo toma el indice obtenido en indicesmediciones y busca el valor del vector ceros que corresponde a ese indice y lo asigna al vector cerospordia
 	for l=1:estedia
		cerospordia=[cerospordia,[Ceros(indicesmediciones(l))]];
		% el anterior comando es para hacer el promedio reducido, con la temperatura reducida y la altura reducida
	end

	ppd=mean(cerospordia);  %saca el promedio del vector cerospordia
	medicionespordia=[medicionespordia,[undia]]; %construye el vector medicionporfecha que contiene las fechas sin las horas, a diferencia del vector mediciones
	promediopordia=[promediopordia,[ppd]];  % construye un vector con los promedios por dia
	
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
minimopormes=[];
maximopormes=[];

 for m=1:totalmeses
	unmes=mesesunicos(m);
	indicesmensuales=find(Fechasmensuales==unmes);
	estemes=length(indicesmensuales);
	cerospormes=[];

	for n=1:estemes
		cerospormes=[cerospormes,[promediopordia(indicesmensuales(n))]];
	end

	maxpormes=max(cerospormes); %valor máximo por cada mes
	minpormes=min(cerospormes); %valor mínimo por cada mes	
	ppm=mean(cerospormes);
	sd=std(cerospormes);
	medicionespormes=[medicionespormes,[unmes]];
	promediopormes=[promediopormes,[ppm]];  %construye el vector promediopormes que tiene 		en cada entrada el promedio mensual de la isoterma cero
	desvest=[desvest,[sd]];  %contruye un vecto con las desviaciones
	maximopormes=[maximopormes,[maxpormes]]; %vector con el valor maximo por cada mes
	minimopormes=[minimopormes,[minpormes]]; %vector con el valor minimo por cada mes

 end
% fin del promedio mensual


%************************% 3. SALIDA DE RESULTADOS ***********************************

file_id = fopen('todos_los_datos_esta_estacion.dat', 'a'); %Esta instrucción es para abrir un archivo y escribir en el.

fprintf(file_id,"%i ",floor(FechasUnicas(1)));   %Para imprimir el año 

disp('Mínimo y su fecha')
min(Ceros)  %Con esta instrucción se despliegan los datos en la pantalla y también para que se vea si esta bien
FechaMin
fprintf(file_id,"%f ",min(Ceros)) %Esta imprime la salida de los datos en el archivo que esta abierto
fprintf(file_id,"%d ",FechaMin) %Esta instrucción imprime la fecha de estos datos. 

disp('Máximo y su fecha')
max(Ceros)
FechaMax
fprintf(file_id,"%f ",max(Ceros))
fprintf(file_id,"%d ",FechaMax)

% Promedio anual tomando cada medición
disp('Promedio anual tomando cada medición y su desviación estandar')
mean(Ceros)
std(Ceros)
fprintf(file_id,"%f ",mean(Ceros))     % la media de Ceros, es la anual de todos los datos
fprintf(file_id,"%f ",std(Ceros))      % la desviación de Ceros

% Promedio anual tomando el promedio diario
disp('Promedio anual tomando el promedio diario y su desviación estandar')
mean(promediopordia)
std(promediopordia)
fprintf(file_id,"%f ",mean(promediopordia))
fprintf(file_id,"%f ",std(promediopordia))

% Promedio anual tomando el promedio mensual
disp('Promedio anual tomando el promedio mensual y su desviación estandar')
mean(promediopormes)
std(promediopormes)
fprintf(file_id,"%f ",mean(promediopormes))
fprintf(file_id,"%f ",std(promediopormes))

%Promedio mensual de cada mes
file_mean_mes = fopen('promediopormes.dat', 'a');
disp('Promedio por cada mes')
promediopormes'
desvest'
for i=1:length(promediopormes)
	fprintf(file_id,"%f ",promediopormes(i))
	fprintf(file_mean_mes,"%f ",promediopormes(i))
end
for i=1:length(desvest)
	fprintf(file_id,"%f ",desvest(i))
end
fclose(file_mean_mes);

%Máximo por cada mes
file_max_mes= fopen('maximopormes.dat','a');
disp('Máximo por cada mes')
maximopormes'
for i=1:length(maximopormes)
	fprintf(file_id,"%f ",maximopormes(i))
	fprintf(file_max_mes,"%f ",maximopormes(i))
end
fclose(file_max_mes);

%Mínimo por mes
file_min_mes= fopen('minimopormes.dat','a');
disp('Mínimo por cada mes')
minimopormes'
for i=1:length(minimopormes)
	fprintf(file_id,"%f ",minimopormes(i))
	fprintf(file_min_mes,"%f ",minimopormes(i))
end
fclose(file_min_mes);

fprintf(file_id,"\n"); %Le inserta un salto de linea al archivo, para que la siguiente vez que se abra ese archivo, se comienze a escribir desde la linea que le sigue
fclose(file_id); %cierra el archivo abierto

end  % fin del programa
