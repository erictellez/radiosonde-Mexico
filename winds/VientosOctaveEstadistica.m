%PROGRAMA PARA ANALIZAR LOS DATOS QUE SE OBTIENEN DEL SITIO DE READY.NOAA.GOV.  EN ESPECIAL PARA PROCESAR LOS DATOS OBTENIDOS DE LOS VIENTOS Y HACER UN AN�?LISIS PROBABILISTICO DE LA DIRECCION Y LA VELOCIDAD PREDOMINANTE DE ESTE EN LAS DIFERENTES ESTACIONES DEL AnO. LOS  DATOS QUE SE TIENEN AQU�? SON DE LOS VIENTOS POR ENCIMA DEL VOLC�?N PICO DE ORIZABA
%REALIZADO POR ERIC BENJAM�N T�LLEZ UGALDE  erictellez@gmail.com erictellez@hotmail.com
%ESTE C�DIGO ES UNA ADAPTACI�N POSTERIOR PARA EJECUTARSE SOLO EN OCTAVE
%Y PARA OBTENER LA FUNCION DENSIDAD DE PROBABILIDAD DE VON MISES PARA UNA  ESTADISITICA CIRCULAR
%SEPTIEMBRE DE 2018

%·#·#·#·#·#·#·#·#·#·#·#·#·#·#·#·#·#·#·#·#·#·#·#·#·#
%Este programa solo se puede ejecutar con estratos de mil metros

%% ***************% 1. NOMBRE DEL PROGRAMA Y ENTRADA DE DATOS **********************
function VientosOctaveEstadistica(NombreArchivo)

Archivo= load(NombreArchivo);   % carga el archivo
Fechas=Archivo(:,1);
DV=Archivo(:,7);  %Toma la columna de direcciones y las asigna a DireccionesViento
VV=Archivo(:,8);

%% ***************% 2. ANALISIS DE DATOS******************************************

%con esta linea voy a poner todas las fechas como un número para poder tratarlas mejor
totalarchivo=length(Fechas);
% ciclo para homologar el formato de las fechas y para cambiar el dato del ángulo de la dirección del viento a su seno y su coseno para un tratamiento más eficaz de los datos
for p=1:totalarchivo
    if (Fechas(p) < 1000000000)  %Este condicional lo puse para poder hacer el promedio de 	todas las fechas de manera mas fácil, ya que el archivo que generó el otro programa arroja las fechas y las horas de la medición pegadas en un sólo numero de la forma aaaammddhh, pero si una medición se había realizado a las 6 de la mañana el numero que resultaba era aaaammdd6 y si la medición se había realizado a las 3 de la tarde entonces arroja aaaammdd15, dando un número 10 veces mas grande. Entonces la siguiente operación cambia por ejemplo aaaammdd6 por aaaammdd06
        Fechas(p)=10*Fechas(p)-9*rem(Fechas(p),10);
    end
end

%FechasOrdenadas=sort(Fechas);  %para ordenar las fechas de menor a mayor
sindato=99999;  %asegura que todos los valores en la matriz sean valores buenos

Fechasunicas = unique(Fechas);  % busca dentro de fechas, las fechas que son diferentes o únicas y lo asigna a FechasUnicas, es decir, FechasUnicas es un vector en el que cada entrada contiene cada fecha diferente del archivo
totfechas = length(Fechasunicas);  % busca la longitud del vector anosunicos y el total se lo asigna a totanos

%Introduccion de variables vectoriales vacias, tendr�an que ser variables
%globales de preferencia para que las evalue cada celda.
VelViento=[];	  %se crea el vector para las velocidades que estan en metros sobre segundo
DirViento=[];   %Se crea el vactor para el ángulo de la direccion que esta en radianes

MSNM=input('�A que altura est� la estaci�n, el volc�n o desde que altura quieres empezar a calcular?. Valor por defecto 0 metros:   '); %con esta instrucción puedo hacer que se
%MSNM=13;  %aqui debe ir la altura desde la que empieza la medición, como
%es para el caso del voclan chichonal debería estar aquí la altura de
%este volc�n.
vac1=isempty(MSNM);
if (vac1==1)
    MSNM=1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ESTA INSTRUCCION ES PARA PODER ACOTAR EL ANALISIS Y EL HISTOGRAMA
%TIENE VENTAJAS PUES LA ALTITUD LLEGA HASTA LOS 30 MIL METROS
MAXAltura=input('¿Cual es la altura maxima hasta la que quieres calcular? Valor por defecto es 35000 metros:    ');  %Con esta instruccion se corta el calculo a un rango especificadao por el usuario
%Las condiciones sobre esta variable vienen despues

%#########################################################################
%AQUI SE PUEDE CAMBIAR EL TAMAnO DEL ESTRATO DE ALTITUD, DEPENDIENDO DE
%LAS NECESIDADES
Tamanodelintervalo=input('�Cada cu�ntos metros quieres estratificar los vientos?. Valor por defecto 1000 metros:   ');
vac2=isempty(Tamanodelintervalo);
if (vac2==1)
    Tamanodelintervalo=1000;
end
%#########################################################################

piecewisewidth=input('Para calcular la probabilidad en la direcci�n de los vientos necesitamos agrupar estas direcciones en intervalos de un cierto n�mero de grados. �En cuanto quieres dividir los intervalos?. El valor por defecto es de 30 grados:   ');
vac3=isempty(piecewisewidth);
if (vac3==1)
    piecewisewidth=30;
end
%Precisión del intervalo en que estará dividido cada ángulo
piecewisenumber=360/piecewisewidth; %es el número total de intervalos

%% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%En este pedazo se hará un promedio de los vientos para diferentes alturas. Lo que har� el programa es meter el archivo a un ciclo para acomodar por alturas los datos, es decir, se va a poner, para una altura específica o un rango de alturas reducidas (e.g. de 0 metros a 1000 metros),  el dato o el promedio que corresponde a ese rango para un día específico y luego se hará así para todas las alturas.
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

indmalos=find(Archivo(:,4) == sindato); %Busca en las alturas las que son iguales a sindato y asigna los indices a indmalos
Archivo(indmalos,4)=Archivo(indmalos,4)-sindato-1; %Asigna a los renglones con 99999 el calor -1
valido=max(Archivo(:,4));  %asigna el nuevo valor v�lido

%Condiciones sobre MAXAltura
vac3=isempty(MAXAltura);
if (vac3==1)
    MAXAltura=valido;
end

totaldealturas=floor((MAXAltura-MSNM)/Tamanodelintervalo)+1;  %Resta valido menos MSNM y luego lo divide maxaltura entre tamanodelintervalo y se queda con la parte entera


Multimatriz=[]; %se crea una matriz multidimensional de totfechas*alturas*dos, en la primera entrada van las fechas y luego las laturas y finalmente para dividir en direccion y velocidad

DV=DV*pi/180;    %Convierte a radianes

%%Los angulos meteorologicos se miden de forma diferente que la convencion matematica. Cero grados significa que el viento viene del norte.
%%Ademas la convencion meteorologica indica que se miden en sentido horario, al reves de la convencion matematica
%%Los siguiente calculos son para corregir esa convencion
DVcompY=sin(DV);  %saca coseno negativo y lo asigna a la variable DVcompY
DVcompX=cos(DV);   %Saca seno negativo y lo asigna a la variable DVcompX


% Empieza un ciclo para analizar todas las fechas diferentes
for i=1:totfechas
    
    unafecha=Fechasunicas(i); % asigna a la variable unafecha el valor de la entrada i de FechasUnicas
    MisIndices=find(Fechas==unafecha); % Busca dentro de Anos las que son iguales a unano y los indices que pertenecen a esos anos iguales se lo asigna a indicesanos, entonces, indicesanos es un vector que tiene los índices de anos iguales para este ano en particular
    cuantasestafecha=length(MisIndices);
    
   for b=1:totaldealturas
        AlturaBaja=MSNM+(b-1)*Tamanodelintervalo;  %estas variables definen el intervalo de partici�n de las alturas
        AlturaAlta=MSNM+b*Tamanodelintervalo;
        
        EsteIntervaloVel=[];   % se crean estos vectores vacios para un promedio de datos peque�o
        EsteIntervaloDirSeno=[];
        EsteIntervaloDirCoseno=[];
        
        for s=1:cuantasestafecha
            
            % condiciones sobre los datos. La columna 7 tiene la dirección en grados y la 8 la velocidad en metros sobre segundo
            if (Archivo(MisIndices(s),7) == sindato) || (Archivo(MisIndices(s),8) == sindato) % si en la columna de la velocidad del viento está el valor 99999, quiere decir que en realidad no hay datos, entonces se lo salta
                continue;
            elseif (Archivo(MisIndices(s),4) <= MSNM) %reduce el rango de busqueda de los datos desde el numero que aparece (en MSNM)
                continue;
            elseif (Archivo(MisIndices(s),4) >= MAXAltura) %reduce el rango de busqueda de los datos hasta el numero que aparece en MAXAltura
                continue;
            elseif (Archivo(MisIndices(s),4) > AlturaBaja) && (Archivo(MisIndices(s),4) <= AlturaAlta); %condicional para estratificar las altura
                EsteIntervaloVel=[EsteIntervaloVel; Archivo(MisIndices(s),8)];
                EsteIntervaloDirSeno=[EsteIntervaloDirSeno; DVcompY(MisIndices(s))];
                EsteIntervaloDirCoseno=[EsteIntervaloDirCoseno; DVcompX(MisIndices(s))];
            end  % fin del condicional linea 91
        end
        
        empty=isempty(EsteIntervaloDirSeno); %Verifica que el vector no est� vac�o
        
        if (empty==1)  %si el vactor esta vacio se sigue a la siguiente altura
            continue;
        else             %si no esta vacio hace los calculos para promediar las alturas y dejar una sola altura por cada intervalo de alturas
            
            MediaInterY=mean(EsteIntervaloVel.*EsteIntervaloDirSeno);  %Multiplica la velocidad y la magnitud entrada a entrada para poder facilitar los cálculos. Saca la media de estos resultados.
            MediaInterX=mean(EsteIntervaloVel.*EsteIntervaloDirCoseno);  %lo mismo para la otra dirección
      
            MagEstaAltura=sqrt(MediaInterX^2+MediaInterY^2);  % Se suman las magnitudes vectorialmente para obtener el vector de velocidad final
                  
	          %La siguiente operaci�n evita la divisi�n entre cero en la funcion del arcotengente
	          if (MediaInterX == 0) && (MediaInterY > 0) 
		            DirEstaAlt = pi/2;
	          elseif (MediaInterX == 0) && (MediaInterY < 0)
		            DirEstaAlt = -pi/2;
            elseif (MediaInterX == 0) && (MediaInterY == 0)
                DirEstaAlt = 0;
	          else
                DirEstaAlt=atan2(MediaInterY,MediaInterX);  %Saca el ángulo en radianes
            end

            DirEstaAltGrad=DirEstaAlt*180/pi;  %se convierte el vector a grados
            
           
            
        end %fin del ciclo linea 112
        
        Multimatriz=[Multimatriz; [unafecha AlturaAlta MagEstaAltura DirEstaAltGrad]];  %se construye una matriz con estos valores
        
    end %fin del condicional linea 92
    
end   %fin del ciclo linea 90

%Aqu� tendr�a que ser capaz de ponerle para cualquier altura y poder
%visualizarla o incluso todaz las alturas
todasdirecciones=[];  % se crean estos vectores vac�os
todasvelocidades=[];

%file_cil = fopen('cilindro.dat', 'a'); %Esta instrucci�n es para abrir un archivo para escribir los datos del cilindro 

%Se hace un nuevo ciclo para poder graficar todas las alturas en un
%histograma
for b=1:totaldealturas
    AlturaAlta=MSNM+b*Tamanodelintervalo;  %Se hace esta igualdad para encasillar a todas las alturas de este intervalo
    indices=find(Multimatriz(:,2) == AlturaAlta);  %se buscan las alturas en la matriz
    otravac=isempty(indices);   %verifica que no este vacia
    if (otravac==1)    % si esta vacia se va con la siguiente altura
        continue;
    else                % si no se hacen estos c�lculos
        cuantos=length(indices);
        for xy=1:cuantos
            todasalturas(xy,b)=Multimatriz(indices(xy),2); % Asigna a todasalturas todos los renglones que tienen un �ndice igual a AlturaAlta de la columna 2 de Multimatriz
            todasdirecciones(xy,b)=Multimatriz(indices(xy),4); % Asigna a todasdirecciones todos los renglones que tienen un �ndice igual a AlturaAlta de la columna 2 de Multimatriz
            todasvelocidades(xy,b)=Multimatriz(indices(xy),3); % Asigna a todasvelocidades todos los renglones que tienen un �ndice igual a AlturaAlta de la columna 2 de Multimatriz
        
            % Esta parte es para hacer un archivo con los datos para el
            % histograma cil�ndrico.
            %fprintf(file_cil,'%f',todasvelocidades(xy,b));   %%inserta las velocidades que es la magnitud del vector
            %fprintf(file_cil,'\t');          %inserta un espacio de tabulador
            %fprintf(file_cil,'%f',todasdirecciones(xy,b));    %Inserta el la direccion a esta altura que es el �ngulo
            %fprintf(file_cil,'\t');          % inserta un espacio de tabulador
            %fprintf(file_cil,'%f',todasalturas(xy,b));   %Inserta la altura que es la coordenada zeta
            %fprintf(file_cil,'\n');          % inserta un salto de linea
        
        end %Fin del ciclo for
    end %Fin del condicional
    
end  %fin del ciclo for

%fclose(file_cil); %cierra el archivo .dat para el histograma

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Este pedazo de codigo es para eliminar los ceros que tiene la matriz todasdirecciones
%y que estan puestos para hacer que todas las columnas tengan la misma longiutd de datos
%Si no se quitan estos ceros, el histograma los grafica como si fueran ceros validos
L=length(todasdirecciones(:,1));
for xy=1:L
  for b=1:totaldealturas
    if (todasdirecciones(xy,b) == 0)
      todasdirecciones(xy,b) = NaN;
    else
      continue;
    end
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Aqui deberia empezar la estadistica circular descriptiva
Hdirecciones=hist(todasdirecciones,piecewisenumber) %Para guardar los calculos del histograma y hacer estadistica
sumahist=sum(Hdirecciones,2)    %Para sumar todos los segmentos circulares de cada altura
Probdirecciones=Hdirecciones./sumahist    %Divide para obtener la probabilidad de cada segmento circular y cada altura

%kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
%Segmento para ver si los datos se pueden modelar con  la distribucion de von Mises. 
%Es una distribucion circular que en el circulo tiene las propieades de la distribucion normal lineal
todasdirecciones=todasdirecciones*pi/180;  %Convierte la matriz a radianes
%find(isnan)  %Hay que buscar los que son NaN para que pueda proseguir el calculo

%%%%%%%%%%%%%%%%%%%%%%%%%%
%Primero se necesita la media de la muestra
TDseno=sin(todasdirecciones);
TDcoseno=cos(todasdirecciones);
S=0;
C=0;
N=isnan(todasdirecciones);
todasdirecc=[];

for t=1:L
if (N(t)==0)
   todasdirecc=[todasdirecc; todasdirecciones(t)]; %para quitar los NaN del vector
   S=S + TDseno(t);
   C=C + TDcoseno(t);
end
end

Erre=sqrt(S.^2+C.^2);
R=Erre/sumahist;

%Este condicional es para no perder la informaci�n que arroja 
%el arcotangente, pues esta funci�n s�lo est� definida de -pi/2
%hasta pi/2
%if (C > 0) && (S < 0)   %si los valores son de esta forma saldra un valor negativo que en realidad estara entre 270 y 360 grados
 %      angulomedio=atan(S/C)+2*pi();
  %elseif (C < 0)                 % si sale este valor entonces esta entre 90 y 270
   %    angulomedio=atan(S/C)+pi();
  %else
       angulomedio=atan2(S,C);
%end

%Para calcular kappa que es un parametro de la distribucion de von Mises
%Estos parametros se encuentran en el libro de Fischer
if R < 0.53
  kappa = 2*R + R^3 + 5*R^5/6;
elseif R>=0.53 && R<0.85
  kappa = -.4 + 1.39*R + 0.43/(1-R);
else
  kappa = 1/(R^3 - 4*R^2 + 3*R);
end

angulomedio
angulomedio*180/pi()
kappa
Besselcero = 1/(2*pi*besseli(0,kappa))     %Funcion modificada de Bessel de primer tipo de orden cero
pdf=[];

for t=1:L
if (N(t)==0)
unapdf=2*pi()*Besselcero*exp(kappa*cos(todasdirecciones(t)-angulomedio));   %Funcion densidad de probabilidad
pdf=[pdf; unapdf];
end
end

figure
polar(todasdirecc,pdf,'b*')
set(gca,'xdir', 'reverse')
title(NombreArchivo)
xlabel('Angulo en grados');
hold;

figure
plot(todasdirecc,pdf,'b*')
title(NombreArchivo,'FontWeight','bold')
xlabel('Angulo en radianes');
ylabel('Densidad de probabilidad');
hold;

end  % fin del programa