clear;
clc;

n = 0.5; /*Passo de aprendizagem escolhido*/

w = rand(1,3); /*Gerando pesos aleatórios*/

entrada = [-1 0 0; -1 0 1; -1 1 0; -1 1 1]; /*As entradas da porta OR*/
saida_desejada = [0; 1; 1; 1] /*Saida desejada*/


indice=1; /*Indice utilizado para interaçao do laço (Para sabermos qual entrada esta sendo analisada)*/
acertos=0; /*Número de acertos*/
epocas=0; /*Número de épocas necessarias para atingirmos nosso objetivo de 4 acertos*/

tamanho_saida_desejada = length(saida_desejada) /*Armazenamos o tamanho da saida desejada*/

while %t /*Aqui inicializamos um laço infinito que vai parar apenas quando complertamos nosso objetivo de 4 acertos*/
    
    x_atual=entrada(indice,:); /*Pegamos o x atual => x(t)*/
    u = w*x_atual'; /*Realizamos o produto escalar entre o vetor de pesos o a entrada atual transposta (função de ativação)*/
    
    y = 0; /*Iniciamos a saida y com o valor 0*/
    
    if(u > 0) then /*Se o resultado do produto escalar for maior que 0 então y = 1*/
        y = 1;
    end
    
    d=saida_desejada(indice); /*Pegamos a saida desejada para x(t)*/
    erro=d - y; /*Calculamos o erro*/

    if(erro == 0) then /*Se o erro for igual a 0 incrementamos o valor de acerto em 1*/
        acertos = acertos + 1;
    else /*Se não, reiniciamos o valor de acertos (que é justamente nosso criterio de parada) e atualizamos os pesos */
        acertos = 0;
        w = w + (n*erro*x_atual); /*Atualização dos pesos utilizando a mesma equação do slides*/
    end
    
    /*Verificamos se o numero de acertos é igual a tamnaho da saida deseja, ou seja, se conseguimos acertar todas as 4 saidas*/
    if (acertos == tamanho_saida_desejada) then /*Criterio de parada do laço while*/
        break
    end 
    
    indice= indice + 1; /*Incrementamos o indice para na proxima interação avaliarmos o x(t+1)*/
    
    /*
        Se o indice for igual a 5 quer dizer que ja testamos as 4 entradas (1 época).
        Então reiniciamos o indice para começar o treinamento novamente.
    */
    if(indice == (tamanho_saida_desejada+1)) then
        epocas = epocas + 1;
        indice = 1;
    end
end

/*Mostrando resultados e plotando o grafico*/
disp("Epocas: " + string(epocas))

/*Pontos que representam a classe 1*/
classe1_x1 = [0 1 1];
classe1_x2 = [1 0 1];

plot(classe1_x1, classe1_x2, '.');

/*Pontos que representam a classe 2*/
plot(0, 0, 's');

/*Valores encontrados para teta, w1, w2*/
teta = w(1)
w1 = w(2)
w2 = w(3)

/*Equação da reta*/
x1 = linspace(-2, 2);
x2 = -((w1/w2)*x1) + (teta/w2);

title('Gráfico com classes');
xlabel('Coordenada X');
ylabel('Coordenada Y');

legend('Classe 1', 'Classe 2');
plot(x1, x2, "r");


