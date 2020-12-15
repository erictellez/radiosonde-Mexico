%PROGRAMA PARA ANALIZAR DATOS DE RADIOSONDEOS SINTÉTICO DE VIENTOS DEL POPO
%REALIZADO POR ERIC BENJAMÍN TÉLLEZ UGALDE  erictellez@gmail.com erictellez@hotmail.com
%SEPTIEMBRE 2012

%% ***************% 1. NOMBRE DEL PROGRAMA Y ENTRADA DE DATOS **********************
function VientosRobinPopo(NombreArchivo)

Hoja1=xlsread(NombreArchivo,'CONVELOCIDAD','B3:C30023');  % Carga los datos del archivo que está en formato de Excel. En este caso los datos son la velocidad y la dirección del viento en dos columnas.
DV=Hoja1(:,1);  %Asigna a DV la dirección del viento de las mediciones originales
VV=Hoja1(:,2);  %Asigna a VV la velocidad del viento de las mediciones originales
Alturas=[5120 5880 6700];
fechainicio=datenum('01-Nov-2007');
ternaVV=[];
ternaDV=[];

totalceldas=length(Hoja1(:,1));
totalfechas=totalceldas/17;

disp('Las fechas van desde el Nov/01/2007 hasta Ago/31/2012')
disp('Todas las fechas tienen horas de 12, 15, 18 y 21 hrs GMT')

otra='s';
while (otra=='s')
vac=1;
    while vac==1
    thisdate=input('¿Qué día quieres analizar? Escribe la fecha en formato mm/dd/aaaa:    ','s'); %Se pide la fecha
    vac=isempty(thisdate);
    disp('Ingresa una fecha')
    end
    
Date=datenum(thisdate);
while (Date<fechainicio && Date>totalfechas+fechainicio)
    disp('No hay datos para esa fecha, intenta otra fecha')
end

celdadefecha=(Date-fechainicio)*17;
stunde=input('Escribe la hora GMT que quieres, 12, 15, 18, 21:   ');
while (stunde~=12 && stunde~=15  && stunde~=18 && stunde~=21)
    disp('La hora no es correcta intenta de nuevo')
end %fin del while

if stunde==12
    celdadefecha=celdadefecha+1;
elseif stunde==15
    celdadefecha=celdadefecha+5;
elseif stunde==18
    celdadefecha=celdadefecha+9;
elseif stunde==21
    celdadefecha=celdadefeca+13;
end %fin del condicional
    
for th=celdadefecha:celdadefecha+2       %Este ciclo es para construir la terna
    ternaVV=[ternaVV; VV(th)];
    ternaDV=[ternaDV; DV(th)];
end  %fin diclo for

%% ********************** 3. Salida de datos ******************************
%###############################################
%aquí se va a escribir en el archivo .dat para que se pueda hacer otra cosa
Alturas=Alturas';
A=[Alturas ternaDV ternaVV];
csvwrite('fecha.dat',A);
%##############################################

%Para graficar la dirección contra la altura y la velocidad contra la
%altura
figure
scatter(ternaDV,Alturas)
title(Date,'FontWeight','bold')
xlabel('Ángulo (grados)');
ylabel('Altura (m)');
figure
scatter(ternaVV,Alturas)
title(Date,'FontWeight','bold')
xlabel('Velocidad (m/s)');
ylabel('Altura (m)');

otra=input('¿Quieres procesar otra fecha? s/n   ','s'); 

end %fin del ciclo while

end  %Fin del programa