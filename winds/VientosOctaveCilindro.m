%PROGRAMA PARA ANALIZAR LOS DATOS QUE SE OBTIENEN DEL SITIO DE READY.NOAA.GOV.  EN ESPECIAL PARA PROCESAR LOS DATOS OBTENIDOS DE LOS VIENTOS Y HACER UN AN�?LISIS PROBABILISTICO DE LA DIRECCION Y LA VELOCIDAD PREDOMINANTE DE ESTE EN LAS DIFERENTES ESTACIONES DEL AnO. LOS  DATOS QUE SE TIENEN AQU�? SON DE LOS VIENTOS POR ENCIMA DEL VOLC�?N PICO DE ORIZABA
%REALIZADO POR ERIC BENJAM�N T�LLEZ UGALDE  erictellez@gmail.com erictellez@hotmail.com
%INICIADO EN ABRIL DEL 2011 Y TERMINADO EN JUNIO DE 2011
%ESTE C�DIGO ES UNA ADAPTACI�N POSTERIOR PARA EJECUTARSE SOLO EN OCTAVE
%JUNIO DE 2018

%% ***************% 1. NOMBRE DEL PROGRAMA Y ENTRADA DE DATOS **********************
function VientosOctaveCilindro(NombreArchivo)

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

MSNM=input('¿A que altura esta la estacion, el volcan o desde que altura quieres empezar a calcular? Valor por defecto 0 metros:   '); %con esta instrucción puedo hacer que se
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
Tamanodelintervalo=input('¿Cada cuantos metros quieres estratificar los vientos? Valor por defecto 1000 metros:   ');
vac2=isempty(Tamanodelintervalo);
if (vac2==1)
    Tamanodelintervalo=1000;
end
%#########################################################################

piecewisewidth=input('Para calcular la probabilidad en la direccion de los vientos necesitamos agrupar estas direcciones en intervalos de un cierto numero de grados. ¿En cuanto quieres dividir los intervalos? El valor por defecto es de 30 grados:   ');
vac3=isempty(piecewisewidth);
if (vac3==1)
    piecewisewidth=30;
end
%Precisión del intervalo en que estará dividido cada ángulo
piecewisenumber=360/piecewisewidth; %es el número total de intervalos

%% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%En este pedazo se hará un promedio de los vientos para diferentes alturas. Lo que har� el programa es meter el archivo a un ciclo para acomodar por alturas los datos, es decir, se va a poner, para una altura específica o un rango de alturas reducidas (e.g. de 0 metros a 1000 metros),  el dato o el promedio que corresponde a ese rango para un día específico y luego se hará así para todas las alturas.
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

indmalos=find(Archivo(:,4) == sindato); %Busca en las alturas las que son iguales al m�ximo y asigna los indices a indmalos
Archivo(indmalos,4)=Archivo(indmalos,4)-sindato-1; %Asigna a los renglones con 99999 un valor negativo
valido=max(Archivo(:,4));  %asigna el nuevo valor v�lido para la altura

%Condiciones sobre MAXAltura
vac3=isempty(MAXAltura);
if (vac3==1)
    MAXAltura=valido;
end

totaldealturas=floor((MAXAltura-MSNM)/Tamanodelintervalo)+1;  %Resta valido menos MSNM y luego lo divide maxaltura entre tamanodelintervalo y se queda con la parte entera


Multimatriz=[]; %se crea una matriz multidimensional de totfechas*alturas*dos, en la primera entrada van las fechas y luego las laturas y finalmente para dividir en direccion y velocidad

DV=DV*pi/180;
%DVSeno=sin(DV);
%DVCoseno=cos(DV);

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
        AlturaBaja=floor(MSNM/Tamanodelintervalo)*Tamanodelintervalo+(b-1)*Tamanodelintervalo;  %estas variables definen el intervalo de partici�n de las alturas
        AlturaAlta=floor(MSNM/Tamanodelintervalo)*Tamanodelintervalo+b*Tamanodelintervalo;
        
        EsteIntervaloVel=[];   % se crean estos vectores vacios para un promedio de datos peque�o
        EsteIntervaloDirSeno=[];
        EsteIntervaloDirCoseno=[];
        
        for s=1:cuantasestafecha
            
            % condiciones sobre los datos. La columna 7 tiene la dirección en grados y la 8 la velocidad en metros sobre segundo
            if (Archivo(MisIndices(s),7) == sindato) || (Archivo(MisIndices(s),8) == sindato) % si en la columna de la velocidad del viento está el valor 99999, quiere decir que en realidad no hay datos, entonces se lo salta
                continue;
            elseif (Archivo(MisIndices(s),4) <= MSNM) %reduce el rango de busqueda de los datos desde el numero que aparece en MSNM
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
            
	          %Hay que recordar que las direcciones del seno y el coseno est�n cambiadas porque la direcci�n 0� significa que elk viento proviene del norte
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
            
            %Este condicional es para reajusta la grafica del arcotangente
            % pues esta funci�n s�lo est� definida de -pi/2 hasta pi/2
            if (DirEstaAltGrad < 0)   %si los valores son de esta forma saldra un valor negativo que en realidad estara entre 270 y 360 grados
                DirEstaAltGrad=DirEstaAltGrad+360;
            end
            
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
    AlturaAlta=floor(MSNM/Tamanodelintervalo)*Tamanodelintervalo+b*Tamanodelintervalo;  %Se hace esta igualdad para encasillar a todas las alturas de este intervalo
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

%Hdirecciones=hist(todasdirecciones,piecewisenumber); %Para guardar los calculos del histograma y hacer estadistica

%Para graficar el histograma
figure                                  % pone una nueva figura
hist(todasdirecciones,piecewisenumber)   %grafica todas las alturas juntas. Por su puesto que hay alturas que no hay y esas no las grafica
title(NombreArchivo,'FontWeight','bold')
xlabel('�ngulo en grados');
ylabel('Frecuencia de los eventos');
hold;

%Fin del promedio para todo el mes para cada altura diferente


%%Las siguientes instrucciones son para graficar el histograma en coordenadas polares para cada altura por separado

%for e=1:todasalturas  
%figure
%polar(nan,max(max(histtheta'.*cosd(theta))));
%todasdirecciones(e,columnasnocero);

%Necesito una instruccion que me de la estadistica sobre cada direccion en la grafica polar
%Tal vez si sea necesaria una instruccion para obtener un archivo  con los datos y poder graficar en excel 
%hold;
%end  %Fin del ciclo for

%Fin de la graficacion polar para cada nivel de altura.
%Tal vez sea necesario un archivo con los datos en .dat

%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%% Este pedazo de c�digo es para poder visualizar un histograma cil�ndrico
% de los datos, pues me parece que es la manera m�s natural de verlos
% Este pedazo de c�digo se escribi� despu�s del programa original pero fue
% realizado igualmente por Eric T�llez

% Primero hay que agrupar los datos de los �ngulos con el valor definido por 
% el usuario la variable se llama piecewisenumber
%colordef(figure,'black');  %Pone el color de fondo en negro
theta_vec=linspace(0,360,piecewisenumber);%genera un vector con valores igualmente espaciados de tama�o piecewisenumber
zeta_vec = linspace(0,totaldealturas,totaldealturas); %genera totaldealturas valores entre 1 y totaldealturas incluidos los limites esto es solo para poder generar la referencia polar
[theta,zeta] = meshgrid(theta_vec,zeta_vec); %hace una matriz que relaciona los dos valores generados antes mostrados antes
histtheta=[];
th_vec=linspace(0,360,piecewisenumber+1);

%Este ciclo es para crear el vector histtheta que contiene los valores que
%una medici�n se repite en el intervalo deseado
for b=1:numel(zeta_vec)
    if todasdirecciones(1:b)==0
        continue;
    else
        for xy=1:numel(theta_vec)
            otroindice=find((todasdirecciones(:,b) >= th_vec(xy)) & (todasdirecciones(:,b) <= (th_vec(xy+1))));
            histtheta(xy,b)=numel(otroindice);
        end
    end
end

Histmax=max(histtheta(:));  %calcula el valor m�ximo del vector histtheta
z_vec=linspace(0,Tamanodelintervalo*totaldealturas,totaldealturas+1);  %Genera un vector de valores que incluye el cero, este vector si me sirve ATENCION: ESTE VECTOR ES MAS IMPORTANTE QUE EL VECTOR zeta_vec, NO SE HA DUPLICADO POR ERROR, CUMPLEN FUNCIONES DIFERENTES. La diferencia con la instrucci�n de arriba es que no tiene a�adido el 'factor' . Este factor hace que la gr�fica se vea mas regular.

figure
polar(nan,max(max(histtheta'.*cosd(theta)))); %Esta funci�n crea una grafica en coordenadas polares con angulo nan y con radio la otra funcion
hold;  %Mantiene todos los valores predeterminados para la gr�fica

for b=1:numel(z_vec)-1
    
    for xy=1:numel(th_vec)-1

            w=tand(piecewisewidth)*histtheta(xy,b); %Esta instrucci�n es para que el histograma se parezca a lo que aparece con la funci�n rose. tand calcula la tangente del �ngulo en grados
            c=cosd(piecewisewidth); %Esta instrucci�n tiene la misma funci�n, cosd calcula el coseno del �ngulo en grados
            %t=Tamanodelintervalo/factor;  % Esta instruccion es por si se necesita cambiar el tama�o en zeta
            t=Tamanodelintervalo;
            
            X=([0 0 1 0 0;
                c c c c 1;
                c 1 c 1 1;
                0 0 1 0 0])*histtheta(xy,b);  %Se define la matriz de valores del histograma para la variable X, son 5 columnas porque son 5 caras para hacer un histograma en coordenadas polares y son 4 renglones porque cada cara tiene 4 aristas
            Y=([0 0 0 0 0;
                w w w w 0;
                w 0 w 0 0;
                0 0 0 0 0]);                %Se define la matriz de valores del histograma para la Y
            Z=([0 t t 0 0;
                0 t t 0 0;
                t t 0 0 t;
                t t 0 0 t])+z_vec(b);  %Se define la matriz para Z y se le suma el valor de zeta_vec para transladar cada rectangulo
        
            h= patch(X,Y,Z,0*X+histtheta(xy,b),'edgecolor','none');  %Se crean los objetos del histograma. La instruccion patch dibuja un pol�gono con los v�rtices indicados por las coordenadas X,Y,Z pero como cada una de estas variables es una matriz entonces se dibuja un pol�gono por cada columna de la matriz de puntos, entonces  tenemos 5 cuadrados en total 
            rotate(h,[0 0 1],th_vec(xy),[0 0 0]);  %Se rota todo alrededor del eje z una cantidad igual a la que tiene el vector theta_vec

    end  % Fin del condicional
end  % Fin del condicional

%Esto es para ajustar la gr�fica del histograma cil�ndrico
[Xc,Yc,Zc] = cylinder([1 1]); %Crea un cilindro de radio 1, con un numero de divisiones laterales iguales a piecewisenumber
hc = surf(Histmax*Xc,Histmax*Yc,Tamanodelintervalo*totaldealturas*Zc); %Le da el tama�o al cilindro en cada uno de los ejes.
set(hc,'facecolor','none','edgecolor','w','edgealpha',0.2) %Ajusta los datos de la gr�fica
set(gca,{'xtick' 'ytick' 'ztick' 'vis' 'clim'},{[] [] [] 'on' [0 Histmax]})
set(gca,'xdir', 'reverse')
%AlturaBaja=floor(MSNM/Tamanodelintervalo)*Tamanodelintervalo;
%AlturaAlta=floor(MAXAltura/Tamanodelintervalo)*Tamanodelintervalo+Tamanodelintervalo;
%set(gca,'ztick',[AlturaBaja AlturaBaja+floor(totaldealturas/4)*Tamanodelintervalo AlturaBaja+floor(totaldealturas/2)*Tamanodelintervalo AlturaBaja+floor(totaldealturas*3/4)*Tamanodelintervalo AlturaAlta])
axis auto;  %ajusta los ejes de manera que se vean cuadrados
title(NombreArchivo,'FontWeight','bold')   % Le pone t�tulo a la gr�fica
xlabel('Los colores representan el n�mero de veces que se registr� la medici�n')
%text(-2.7*Histmax,-0.2*Histmax,0,'Direccion del viento, 0º=N, 90º=O, 180º=S, 270º=E.')
zlabel('Altura en MSNM')
box on;  % se activa la gr�fica
view(3)  %pone la figura en 3 dimensiones
%colorbar   %Pone la barra de colores de un lado

%Aqui se acaba el c�digo para graficar el histograma cil�ndrico

end  % fin del programa
