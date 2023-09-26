//Cada variável linguística terá três valores linguísticos:

//Pressão no freio: 
//- Alto={(50,0), (100,1)}
//- Médio={(30,0), (50,1), (70,0)}
//- Baixo={(0,1), (50,0)}

//Velocidade da roda:
//- Devagar={(0,1), (60, 0)}
//- Médio={(20,0), (50,1), (80,0)}
//- Rápido={(40,0), (100,1)}

//Velocidade do carro:
//- Devagar={(0,1), (60, 0)}
//- Médio={(20,0), (50,1), (80,0)}
//- Rápido={(40,0), (100,1)}

//Capturando Entradas
pres_pedal = input("Digite o valor da pressão no pedal (0-100):");
vel_rodas = input("Digite o valor da velocidade das rodas (0-100):");
vel_carro = input("Digite o valor da velocidade do carro (0-100):");

//Validando entradas
valid=(0 <= pres_pedal &&  pres_pedal <= 100) &&(0 <= vel_rodas && vel_rodas <= 100) &&(0 <= vel_carro && vel_carro <= 100);

if(~valid) then
    printf("Um ou mais valores estão fora do intervalo permitido (0-100)");
    abort;
end

//Valores no pedal

//Alto
pres_pedal_alta = 0;

if(pres_pedal > 50 && pres_pedal <= 100) then
    pres_pedal_alta=(pres_pedal-50)/50;
end

//Médio
pres_pedal_media = 0;

if(pres_pedal > 30 && pres_pedal <= 50) then
    pres_pedal_media = (pres_pedal-30)/20;
elseif(pres_pedal > 50 && pres_pedal < 70) then
    pres_pedal_media = 1 - (pres_pedal-50)/20;
end

//Baixo
pres_pedal_baixa=0;

if(pres_pedal >= 0 && pres_pedal < 50) then
    pres_pedal_baixa = (50-pres_pedal)/50;
end

//Valores na velocidade da roda

//Devagar
vel_rodas_devagar=0;

if(vel_rodas >= 0 && vel_rodas < 60) then
    vel_rodas_devagar = (60-vel_rodas)/60;
end

//Médio
vel_rodas_media = 0;

if(vel_rodas > 20 && vel_rodas <= 50) then
    vel_rodas_media = (vel_rodas-20)/30;
elseif(vel_rodas > 50 && vel_rodas < 80) then
    vel_rodas_media=1 - (vel_rodas-50)/30;
end

//Rápida
vel_rodas_rapida=0;

if(vel_rodas > 40 && vel_rodas < 100) then
    vel_rodas_rapida=(vel_rodas-40)/60;
end

//Valores da velocidade do carro

//Devagar
vel_carro_devagar=0;

if(vel_carro >= 0 && vel_carro < 60) then
    vel_carro_devagar = (60-vel_carro)/60;
end

//Médio
vel_carro_medio=0;

if(vel_carro > 20 && vel_carro <= 50) then
    vel_carro_medio = (vel_carro-20)/30;
elseif(vel_carro > 50 && vel_carro < 80) then
    vel_carro_medio=1 - (vel_carro-50)/30;
end

//Rápido
vel_carro_rapido=0;

if(vel_carro > 40 && vel_carro < 100) then
    vel_carro_rapido=(vel_carro-40)/60;
end

//Combinando valores

//-Apertar o freio (regra 1 ou regra 2)
prim_inferencia = pres_pedal_media + min(pres_pedal_alta, vel_carro_rapido, vel_rodas_rapida);

//-Liberar o freio (regra 3 ou regra 4)
seg_inferencia = min(pres_pedal_alta, vel_carro_rapido, vel_rodas_devagar) + pres_pedal_baixa;

//Obtendo o centroide

// Variáveis iniciais
soma = 0;
passo = 2;
denominador = 0;

// Define os limites com base em prim_inferencia e seg_inferencia
if prim_inferencia > seg_inferencia then
    limite_inf = seg_inferencia * 100;
    limite_sup = prim_inferencia * 100;
else
    limite_inf = 100 * (1 - seg_inferencia);
    limite_sup = 100 * (1 - prim_inferencia);
end

// Calcula o centroide
for i = 2:passo:limite_inf - passo
    soma = soma + seg_inferencia * i;
    denominador = denominador + seg_inferencia;
end

for i = limite_inf:passo:limite_sup - passo
    if prim_inferencia > seg_inferencia then
        soma = soma + (i^2) / 100;
    else
        soma = soma + (i * (100 - i)) / 100;
    end
    denominador = denominador + i / 100;
end

for i = limite_sup:passo:100
    soma = soma + prim_inferencia * i;
    denominador = denominador + prim_inferencia;
end

centroide = soma / denominador;

//Plotando gráfico
x = [0, limite_inf, limite_sup, 100];
y = [seg_inferencia, seg_inferencia, prim_inferencia, prim_inferencia];
plot(x,y);
plot([centroide,centroide],[0,1], 'k','LineWidth',3);
legend(['União dos gráficos'],['Reta que toca o Centróide'],2);
xlabel('Pressão');
