%PROGRAMA PARA ANALIZAR DATOS DE VIENTOS
%REALIZADO POR ERIC BENJAMÍN TÉLLEZ UGALDE  erictellez@gmail.com erictellez@hotmail.com
%Junio 2012

%% ***************% 1. NOMBRE DEL PROGRAMA Y ENTRADA DE DATOS **********************
function VientosIsrael5(NombreArchivo)

Hoja1=xlsread(NombreArchivo,'Hoja1','B106:C13805');  % Carga los datos del archivo que está en formato de Excel. En este caso los datos son la velocidad y la dirección del viento en dos columnas.
DV=Hoja1(:,1);  %Asigna a DV la dirección del viento de las mediciones originales

Hoja2=xlsread(NombreArchivo,'Hoja2','A2:F3217');  % Carga los datos del archivo que está en formato de Excel. En este caso los datos son la fecha, la hora, la velocidad del viento y la dirección del viento.
%Archivo= load(NombreArchivo);   % carga el archivo
Fechaconhora=Hoja2(:,1); %Asigna a fechaconhora la columna 1
Fechas=Hoja2(:,2);  %Asigna a fechas la columna de las fechas
Horas=Hoja2(:,3);   %Asigna a horas la columna de las horas
WD2=Hoja2(:,5);  %Toma la columna de direcciones y las asigna a WD2

cajas=input('¿Cada cuantos grados quieres agrupar el campo de vientos?. El valor por defecto es de 30 grados:   ');
vac3=isempty(cajas);
if (vac3==1)
    cajas=30;
end
%PrecisiÃ³n del intervalo en que estará dividido cada ángulo
numerocajas=360/cajas; %es el nÃºmero total de intervalos

%% ***************% 2. ANALISIS DE DATOS******************************************

%% Calculos para el programa NOVAC, todavía no se como se insertan
%rotacion=90-DV;
%radianes=pi*DV./180;
%file_id = fopen('novac.dat', 'a'); %Esta instrucciÃ³n es para abrir un
%archivo y escribir en él, llamado novac.dat
%xlswrite('novac.xls',[rotacion radianes]);
%file_id =fclose('novac.dat', 'a'); 
%% Aquí se acaba el código de NOVAC

totalceldas1=length(Hoja1(:,1));  %Instrucción para el total de celdas de la hoja 1
%Con esta instrucción voy a convertir el sistema de fechas numérico de
%Excel al de Matlab que están en la hoja 2
Fechaconhora = Fechaconhora + datenum('30-Dec-1899');
totalceldas2=length(Fechaconhora);  %longitud del archivo
Fechasunicas = unique(Fechaconhora);  % busca dentro de fechas, las fechas que son diferentes o Ãºnicas y lo asigna a FechasUnicas, es decir, FechasUnicas es un vector en el que cada entrada contiene cada fecha diferente del archivo
totfechas = length(Fechasunicas);  % busca la longitud del vector anosunicos y el total se lo asigna a totanos
Fechas=Fechas + datenum('30-Dec-1899');
diasunicos=unique(Fechas);

promedioternaX=[];
promedioternaY=[];

%% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%En este pedazo se harÃ¡ un promedio de los vientos. Lo que hará el programa es meter el archivo a un ciclo para acomodar por alturas los datos, es decir, se va a poner, para una altura especÃ­fica o un rango de alturas reducidas (e.g. de 0 metros a 1000 metros),  el dato o el promedio que corresponde a ese rango para un dÃ­a especÃ­fico y luego se harÃ¡ asÃ­ para todas las alturas.
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

celdavacia=isnan(DV); %Verifica que la columna tenga datos numéricos
%este ciclo es para juntar cada terna de datos
for c=1:totalceldas1-2
    %Estos condicionales son para que reconozca las celdas correctas y solo
    %tome las ternas seguidas
    if celdavacia(c)==1
        continue;
    elseif celdavacia(c)==0 && celdavacia(c+1)==0 && celdavacia(c+2)==1
        continue;
    elseif celdavacia(c)==0 && celdavacia(c+1)==1
        continue;
    elseif celdavacia(c)==0 && celdavacia(c+1)==1 && celdavacia(c+2)==1
        continue;
    elseif celdavacia(c)==1 && celdavacia(c+1)==1 && celdavacia(c+2)==1
        continue;
    elseif celdavacia(c)==0 && celdavacia(c+1)==0 && celdavacia(c+2)==0 %Si la celda tiene un número entra a esta condicion
        ternaDV=[];
        for th=c:c+2       %Este ciclo es para construir la terna
            ternaDV=[ternaDV; DV(th)];
        end
    end
    cosenoterna=cosd(ternaDV);   %Saca el coseno de los elementos que estan en grados de ternaDV
    senoterna=sind(ternaDV);     %Saca el seno de los elementos que están  en grados de ternaDV
    
    promedioternaX=[promedioternaX; mean(cosenoterna)]; %Saca el seno del valor en grados del vector terna DV y lo asigna a promedioterna
    promedioternaY=[promedioternaY; mean(senoterna)]; %Saca el coseno del valor en grados
    
end

angulo=atand(promedioternaY./promedioternaX);  %Saca el ángulo con la función  arcotangente y lugo lo convierte a grados
%Ciclo para convertir todos los ángulos provenientes de la tangente
for d=1:length(angulo)
%Este condicional es para no perder la información que arroja
%el arcotangente, pues esta función sólo está definida de -pi/2
%hasta pi/2. Verifica entrada a entrada lo que tiene el vector ángulo y le
%asigna la conversión correspondiente
    if (promedioternaX(d) > 0) && (angulo(d) < 0)   %si los valores son de esta forma saldra un valor negativo que en realidad estara entre 270 y 360 grados
       angulo(d)=angulo(d)+360;
    elseif (promedioternaX(d) < 0)                 % si sale este valor entonces esta entre 90 y 270
        angulo(d)=angulo(d)+180;
    else
        angulo(d)=angulo(d);   %Deja el angulo igual en otro caso
    end
end

%% Estas siguientes líneas son para visualizar las gráficas.
%% Puede ser un histograma o una rosa o un campo vectorial
figure
rose(angulo,numerocajas)   %grafica una histograma polar.
title(NombreArchivo,'FontWeight','bold')
xlabel('Ángulo en grados');
ylabel('Frecuencia de los eventos');
figure
compass(promedioternaX, promedioternaY)  %Un campo de vientos, pero son muchos
%datos y se va a atascar la gráfica.

%% Este ciclo for es para hacer el promedio diario
promediodiarioX=[];
promediodiarioY=[];
for d=1:4:length(promedioternaX)
    promediodiarioX=[promediodiarioX; mean(promedioternaX(d):promedioternaX(d+3))];
    promediodiarioY=[promediodiarioY; mean(promedioternaY(d):promedioternaY(d+3))];    
end

angulodiario=atand(promediodiarioY./promediodiarioX);  %Saca el ángulo con la función  arcotangente y lugo lo convierte a grados
%Ciclo para convertir todos los ángulos provenientes de la tangente
for d=1:length(angulodiario)
%Este condicional es para no perder la información que arroja
%el arcotangente, pues esta función sólo está definida de -pi/2
%hasta pi/2. Verifica entrada a entrada lo que tiene el vector ángulo y le
%asigna la conversión correspondiente
    if (promediodiarioX(d) > 0) && (angulodiario(d) < 0)   %si los valores son de esta forma saldra un valor negativo que en realidad estara entre 270 y 360 grados
       angulodiario(d)=angulodiario(d)+360;
    elseif (promediodiarioX(d) < 0)                 % si sale este valor entonces esta entre 90 y 270
        angulodiario(d)=angulodiario(d)+180;
    else
        angulodiario(d)=angulodiario(d);   %Deja el angulo igual en otro caso
    end
end

%% Estas siguientes líneas son para visualizar las gráficas.
%% Puede ser un histograma o una rosa o un campo vectorial
figure
rose(angulodiario,numerocajas)   %grafica una histograma polar.
title(NombreArchivo,'FontWeight','bold')
xlabel('Ángulo en grados');
ylabel('Frecuencia de los eventos');
figure
compass(promediodiarioX, promediodiarioY)  %Un campo de vientos, pero son muchos
%datos y se va a atascar la gráfica.

numerodeperiodos=input('¿En cuántos periodos de tiempo vas a dividir el año?:     ');
for x=1:numerodeperiodos
periodoinicio=input('Da la fecha de inicio del periodo en formato mm/dd/aaaa:   ','s');
periodofin=input('Da la fecha de término del periodo en formato mm/dd/aaaa:   ','s');
nombreperiodo=input('Escribe el nombre del periodo:   ','s');
periodoiniciomatlab=datenum(periodoinicio);
periodofinmatlab=datenum(periodofin);

fechainicio= find(diasunicos==periodoiniciomatlab);
fechafin= find(diasunicos==periodofinmatlab);
anguloestacional=[];
for f=fechainicio:fechafin   
anguloestacional=[anguloestacional,angulodiario(f)];
end

%% Estas siguientes líneas son para visualizar las gráficas.
%Puede ser un histograma o una rosa o un campo vectorial
figure
rose(anguloestacional,numerocajas)   %grafica una histograma polar.
title(nombreperiodo,'FontWeight','bold')
xlabel('Ángulo en grados');
ylabel('Frecuencia de los eventos');
%No estoy seguro de esta función
%figure
%compass(promediodiarioX(fechainicio:fechafin), promediodiarioY(fechainicio:fechafin))  %Un campo de vientos, pero son muchos
%datos y se va a atascar la gráfica.

end  %Fin del ciclo para periodos iguales

end  %fin del programa