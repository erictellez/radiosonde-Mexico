%% Programa para hacer un histograma tridimensional en coordenadas cil�ndricas

%Escrito solo para visualizar la base de datos de los vientos procesados
%del servicio meteorol�gico nacional
%Comenzado el 15 de febrero de 2012
%Escrito por Eric Benjam�n T�llez Ugalde, cualquier duda escribir a
%erictellez@gmail.com
%Casi todo el programa se adapt� de uno existente en un foro de Mathworks
%para realizar un histograma esf�rico


%% Este pedazo de c�digo es para ajustar la figura y los datos
%colordef(figure,'black');  %Pone el color de fondo en negro
theta_vec = linspace(0,2*pi,36); %genera 36 valores espaciados entre 0 y 2pi, incluidos los limites
zeta_vec = linspace(0,30,31);  %genera 31 valores entre 0 y 30 incluidos los limites
[theta,zeta] = meshgrid(theta_vec,zeta_vec); %hace una matriz que relaciona los dos valores generados antes mostrados antes
% H son los datos
H = 10*(rand(size(theta)));  %Crea una serie de datos a partir de una distribuci�n aleatoria
Hmax = max(H(:));  %Obtiene el m�ximo del vector
r=0.03*Hmax;  %Parece que esto no se usa
polar(nan,max(max(H.*cos(theta)))); %Esta funci�n crea una grafica en coordenadas polares con angulo nan y con radio la otra funcion
hold all;  %Mantiene todos los valores predeterminados para la gr�fica

%% Estas instrucciones son para hacer el histograma
for kk = 1:numel(theta_vec);  %Desde 1 hasta el total del vector theta_vec
    for jj = 1:numel(zeta_vec);  %Desde 1 hasta el total del vector phi_vec

        %c=1/sqrt((H(jj,kk))^2+1); %Una constante para poder hacer que el histograma en coordenadas polares tenga la misma longitud por lado
        c=1;  %Para usarse en caso de qe sea necesario
        
        X=([0 0 1 0 0;
            c c c c 1;
            c 1 c 1 1;
            0 0 1 0 0])*H(jj,kk);  %Se define la matriz de valores del histograma para la variable X, son 5 columnas porque son 5 caras para hacer un histograma en coordenadas polares y son 4 renglones porque cada cara tiene 4 aristas
        Y=([0 0 0 0 0;
            c c c c 0;
            c 0 c 0 0;
            0 0 0 0 0]);  %Se define la matriz de valores del histograma para la Y
        Z=([0 1 1 0 0;
            0 1 1 0 0;
            1 1 0 0 1;
            1 1 0 0 1])+zeta_vec(jj);  %Se define la matriz para Z y se le suma el vector zeta_vec para transladar cada rectangulo
        
        h= patch(X,Y,Z,0*X+H(jj,kk),'edgecolor','none');  %Se crean los objetos del histograma. La instruccion patch dibuja un pol�gono con los v�rtices indicados por las coordenadas X,Y,Z pero como cada una de estas variables es una matriz entonces se dibuja un pol�gono por cada columna de la matriz de puntos, entonces  tenemos 5 cuadrados en total 
          rotate(h,[0 0 1],180/pi*theta_vec(kk),[0 0 0]);  %Se rota todo alrededor del eje z
           
    end;
end;

%% Esto es para ajustar la gr�fica
[Xs,Ys,Zs] = cylinder([1 1]); %Grafica un cilindro a partir de los datos
hs = surf(Hmax*Xs,Hmax*Ys,Hmax*Zs); 
set(hs,'facecolor','none','edgecolor','w','edgealpha',0.2) %Ajusta los datos de la gr�fica
set(gca,{'xtick' 'ytick' 'ztick' 'vis' 'clim'},{[] [] [] 'on' [0 Hmax]}); 
axis auto;  %ajusta los ejes
box on;  %
view(3)  %pone la figura en 3 dimensiones
colorbar   %Pone la barra de colores de un lado

% El c�digo para el histograma cil�ndrico ya est� completo hasta aqu�,
% ahora voy a ver si puedo hacer una animaci�n con esos datos.

%Fin del programa