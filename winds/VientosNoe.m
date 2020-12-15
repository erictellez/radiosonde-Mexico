%PROGRAMA PARA ANALIZAR LOS DATOS QUE SE OBTIENEN DEL SITIO DE READY.NOAA.GOV.  EN ESPECIAL PARA PROCESAR LOS DATOS OBTENIDOS DE LOS VIENTOS Y HACER UN AN√?LISIS PROBABILISTICO DE LA DIRECCION Y LA VELOCIDAD PREDOMINANTE DE ESTE EN LAS DIFERENTES ESTACIONES DEL AnO. LOS  DATOS QUE SE TIENEN AQU√? SON DE LOS VIENTOS POR ENCIMA DEL VOLC√?N PICO DE ORIZABA
%REALIZADO POR ERIC BENJAM√?N T√âLLEZ UGALDE  erictellez@gmail.com erictellez@hotmail.com
%INICIADO EN ABRIL DEL 2011

%% ***************% 1. NOMBRE DEL PROGRAMA Y ENTRADA DE DATOS **********************
function VientosNoe(NombreArchivo)

Archivo= load(NombreArchivo);   % carga el archivo
Anos = Archivo(:,11);        % asigna todos los renglones de la columna 11 al vector anos
Meses= Archivo(:,9);	     % asigna todos los renglones de la columna 9 al vector meses
Dias= Archivo(:,8);	     % asigna todos los renglones de la columna 8 al vector dias
Horas= Archivo(:,10);	     % asigna todos los renglones de la columna 10 al vector horas
DV=Archivo(:,6);  %Toma la columna de direcciones y las asigna a DireccionesViento

%% ***************% 2. ANALISIS DE DATOS******************************************

%con esta linea voy a poner todas las fechas como un n√∫mero para poder tratarlas mejor
Fechas=Anos*1000000+Meses*10000+Dias*100+Horas;
%FechasOrdenadas=sort(Fechas);  %para ordenar las fechas de menor a mayor
sindato=99999;  %asegura que todos los valores en la matriz sean valores buenos

Fechasunicas = unique(Fechas);  % busca dentro de fechas, las fechas que son diferentes o √∫nicas y lo asigna a FechasUnicas, es decir, FechasUnicas es un vector en el que cada entrada contiene cada fecha diferente del archivo
totfechas = length(Fechasunicas);  % busca la longitud del vector anosunicos y el total se lo asigna a totanos

%Introduccion de variables vectoriales vacias, tendrÏan que ser variables
%globales de preferencia para que las evalue cada celda.
VelViento=[];	  %se crea el vector para las velocidades que estan en metros sobre segundo
DirViento=[];   %Se crea el vactor para el √°ngulo de la direccion que esta en radianes

%###############################################
%aquÌ se va a escribir en el archivo .WIN para que se pueda leer en ashfall
file_id = fopen('vientoprueba.WIN', 'a'); %Esta instrucci√≥n es para abrir un archivo y escribir en el.
%##############################################

MSNM=input('øA que altura est· la estaciÛn, el volc·n o desde que altura quieres empezar a calcular?. Valor por defecto 0 metros:   '); %con esta instrucci√≥n puedo hacer que se
%MSNM=13;  %aqui debe ir la altura desde la que empieza la medici√≥n, como
%es para el caso del voclan chichonal deber√≠a estar aqu√≠ la altura de
%este volc·n.
vac1=isempty(MSNM);
if (vac1==1)
    MSNM=0;
end

%######################################################
%AQUI SE PUEDE CAMBIAR EL TAMAnO DEL ESTRATO DE ALTITUD, DEPENDIENDO DE
%LAS NECESIDADES
Tamanodelintervalo=input('øCada cuantos metros quieres estratificar los vientos?. Valor por defecto 1000 metros:   ');
vac2=isempty(Tamanodelintervalo);
if (vac2==1)
    Tamanodelintervalo=1000;
end
fprintf(file_id,'%i ',Tamanodelintervalo);   %Para imprimir el intervalo
fprintf(file_id,'\n');   %inserta una linea para esscribir en la siguiente
%######################################################

piecewisewidth=input('Para calcular la probabilidad en la direcciÛn de los vientos necesitamos agrupar estas direcciones en intervalos de un cierto n˙mero de grados. øEn cuanto quieres dividir los intervalos?. El valor por defecto es de 30 grados:   ');
vac3=isempty(piecewisewidth);
if (vac3==1)
    piecewisewidth=30;
end
%Precisi√≥n del intervalo en que estar√° dividido cada √°ngulo
piecewisenumber=360/piecewisewidth; %es el n√∫mero total de intervalos

confidence=input('øQue intervalo de confianza deseas para la probabilidad de los datos?. Numero entre 0 y 1:   ');
vac4=isempty(confidence);
if (vac4==1)
    confidence=0.95;
end
confidence=1-confidence;

%% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%En este pedazo se har√° un promedio de los vientos para diferentes alturas. Lo que har√° el programa es meter el archivo a un ciclo para acomodar por alturas los datos, es decir, se va a poner, para una altura espec√≠fica o un rango de alturas reducidas (e.g. de 0 metros a 1000 metros),  el dato o el promedio que corresponde a ese rango para un d√≠a espec√≠fico y luego se har√° as√≠ para todas las alturas.
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

maxaltura=max(Archivo(:,3)); %Busca en el archivo la altura m√°xima y lo asigna a maxaltura
totaldealturas=floor((maxaltura-MSNM)/Tamanodelintervalo);  %Resta maxaltura menos MSNM y luego lo divide maxaltura entre tamanodelintervalo y se queda con la parte entera

Multimatriz=[]; %se crea una matriz multidimensional de totfechas*alturas*dos, en la primera entrada van las fechas y luego las laturas y finalmente para dividir en direccion y velocidad

DV=DV*pi/180;
DVSeno=sin(DV);
DVCoseno=cos(DV);

% Empieza un ciclo para analizar todas las fechas diferentes
for i=1:totfechas
    
    unafecha=Fechasunicas(i); % asigna a la variable unafecha el valor de la entrada i de FechasUnicas
    MisIndices=find(Fechas==unafecha); % Busca dentro de Anos las que son iguales a unano y los indices que pertenecen a esos anos iguales se lo asigna a indicesanos, entonces, indicesanos es un vector que tiene los √≠ndices de anos iguales para este ano en particular
    cuantasestafecha=length(MisIndices);
    
   for b=1:totaldealturas+1
        AlturaBaja=MSNM+(b-1)*Tamanodelintervalo;  %estas variables definen el intervalo de particiÛn de las alturas
        AlturaAlta=MSNM+b*Tamanodelintervalo;
        
        EsteIntervaloVel=[];   % se crean estos vectores vacios para un promedio de datos pequeÒo
        EsteIntervaloDirSeno=[];
        EsteIntervaloDirCoseno=[];
        
        for s=1:cuantasestafecha
            
            % condiciones sobre los datos. La columna 7 tiene la direcci√≥n en grados y la 8 la velocidad en metros sobre segundo
            if (Archivo(MisIndices(s),7) == sindato) % si en la columna de la velocidad del viento est√° el valor 99999, quiere decir que en realidad no hay datos, entonces se lo salta
                continue;
            elseif (Archivo(MisIndices(s),3) <= MSNM) %reduce el rango de busqueda de los datos desde el numero que aparece (en MSNM)
                continue;
            elseif (Archivo(MisIndices(s),3) > AlturaBaja) && (Archivo(MisIndices(s),3) <= AlturaAlta); %condicional para estratificar las altura
                EsteIntervaloVel=[EsteIntervaloVel; Archivo(MisIndices(s),7)];
                EsteIntervaloDirSeno=[EsteIntervaloDirSeno; DVSeno(MisIndices(s))];
                EsteIntervaloDirCoseno=[EsteIntervaloDirCoseno; DVCoseno(MisIndices(s))];
            end  % fin del condicional linea 91
        end
        
        empty=isempty(EsteIntervaloDirSeno); %Verifica que el vector no estÈ vacÌo
        
        if (empty==1)  %si el vactor esta vacio se sigue a la siguiente altura
            continue;
        else             %si no esta vacio hace los calculos para promediar las alturas y dejar una sola altura por cada intervalo de alturas
            
            CompIntervaloY=EsteIntervaloVel.*EsteIntervaloDirSeno;  %Multiplica la velocidad y la magnitud entrada a entrada para poder facilitar los c√°lculos
            CompIntervaloX=EsteIntervaloVel.*EsteIntervaloDirCoseno;  %lo mismo para la otra direcci√≥n
            
            MediaInterX=mean(CompIntervaloX);  %Se calcula la media de este vector
            MediaInterY=mean(CompIntervaloY);  %tambien aqui
            MagEstaAltura=sqrt(MediaInterX^2+MediaInterY^2);  % Se suman las magnitudes vectorialmente para obtener el vector de velocidad final
            DirEstaAlt=atan(MediaInterY/MediaInterX);  %Saca el √°ngulo en radianes
            DirEstaAltGrad=DirEstaAlt*180/pi;  %se convierte el vector a grados
            
            %Este condicional es para no perder la informaciÛn que arroja
            %el arcotangente, pues esta funciÛn sÛlo est· definida de -pi/2
            %hasta pi/2
            if (MediaInterX > 0) && (DirEstaAlt < 0)   %si los valores son de esta forma saldra un valor negativo que en realidad estara entre 270 y 360 grados
                DirGradosEstaAltura=DirEstaAltGrad+360;
            elseif (MediaInterX < 0)                 % si sale este valor entonces esta entre 90 y 270
                DirGradosEstaAltura=DirEstaAltGrad+180;
            else
                DirGradosEstaAltura=DirEstaAltGrad;
            end
            
        end %fin del ciclo linea 112
        
        Multimatriz=[Multimatriz; [unafecha AlturaAlta MagEstaAltura DirGradosEstaAltura]];  %se construye una matriz con estos valores
        
    end %fin del condicional linea 92
    
end   %fin del ciclo linea 90

%AquÌ tendrÌa que ser capaz de ponerle para cualquier altura y poder
%visualizarla o incluso todaz las alturas
todasdirecciones=[];  % se crean estos vectores vacÌos
todasvelocidades=[];

%Se hace un nuevo ciclo para poder graficar todas las alturas en la misma
%gr·fica
for b=1:totaldealturas+1      
    AlturaAlta=MSNM+b*Tamanodelintervalo;
    var=find(Multimatriz(:,2) == AlturaAlta);  %se buscan las alturas en la matriz
    otravac=isempty(var);   %verifica que no este vacia
    indices=[];
    if (otravac==1)    % si esta vacia se va con la siguiente altura
        continue;
    else                % si no se hacen estos claculos
        indices=find(Multimatriz(:,2) == AlturaAlta);
        cuantos=length(indices);
        for xy=1:cuantos
            todasalturas(xy,b)=Multimatriz(indices(xy),2);
            todasdirecciones(xy,b)=Multimatriz(indices(xy),4);
            todasvelocidades(xy,b)=Multimatriz(indices(xy),3);
        end
    end
    
    [cuentasdir,posdir]=hist(todasdirecciones(:,b),piecewisenumber); %cuentasdir=frequencidad de la direccion  posdir=direcciones
    % si posdir=12 (360/30=12), hist va a compartir el intervale
    % [max(todasdirecciones, min(todasdirecciones)] en 12 intervales de
    % tamaÒos iguales, y de centro posdir
    [maxdir,Idir]=max(cuentasdir);  %maxdir=max de frequencia, Idir=indice de este valor max
    d=round(posdir(Idir)); %d=direccion donde hay el max de frequencia, con la funcion round se redondea al valor entero mas proximo
    [cuentasvel,posvel]=hist(todasvelocidades(:,b),piecewisenumber);
    [maxvel,Ivel]=max(cuentasvel);
    v=round(posvel(Ivel)); %velocidad la mas frecuente

    
    %con estas instrucciones se insertan los valores en el archivo .WIN
    fprintf(file_id,'%f',v);   %Para insertar el promedio de la velocidad del viento a esta altura
    fprintf(file_id,'\t');          % inserta un espacio de tabulador
    fprintf(file_id,'%f',d);    %Inserta el promedio de la direccion a esta altura
    %si se quiere conocer la altura en el archivo se escribe
    %fprintf(file_id,'%t');
    %fprintf(file_id,'%f',AlturaAlta);
    %%%%%%%%%%%%%%%%%%%%%
    fprintf(file_id,'\n');          %inserta una linea
end
    
columnasnocero=find(todasdirecciones(1,:) ~= 0);   %se asegura que las columans contengan datos
alturas=MSNM+columnasnocero*1000;                  % dice que columnas si tienen datos
figure                                  % pone una nueva figura
hist(todasdirecciones(:,columnasnocero),piecewisenumber)   %grafica todas las alturas juntas. Por su puesto que hay alturas que no hay y esas no las grafica
title(NombreArchivo)
xlabel('¡ngulo en grados');
ylabel('N˙mero de veces que el viento tuvo esta direcciÛn');
colorbar
%Fin del promedio para todo el mes para cada altura diferente

fclose(file_id); %cierra el archivo abierto

end  % fin del programa
