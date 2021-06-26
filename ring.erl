-module(ring). % nome do módulo
-export([send/2]). % função que pode ser chamada fora do módulo 

% Função para criar os N processos e também definir a quantidade de mensagens
send(M, N) ->

  % Statistics(runtime) registra o tempo de CPU de uma parte do código
  % Nesse caso, será do tempo necessário para criar os N processos
  statistics(runtime),

  % Criação dos processos de forma linkada (spawn_link)
  % O processos terão a função loop/3 
  % H Recebe os identificadores dos processos com o self()
  % A quantidade de processos criados é definido por lists:seq/3
  H = lists:foldl(fun(Id, Pid) -> 
			spawn_link(fun() -> loop(Id, Pid, M) end) end, 
			self(), 
			lists:seq(N, 2, -1)),

  % Temos a informação aqui de quanto tempo levou para a criação dos N processos
  {_, Time} = statistics(runtime),

  % A iformação do tempo decorrido e quantidade de processos criados é impressa
  io:format("~p processes spawned in ~p ms~n", [N, Time]),

  % Início da contagem do tempo para as mensagens
  statistics(runtime),

  % Esse H é o primeiro processo do anel
  H ! M,
	
  % Chamada da função loop, inicia o ciclo de mensagens
  loop(1, H, M).

% Função loop que envia as M mensagens no anel de processos
loop(Id, Pid, M) ->
  
  % O receive é usado para receber mensagens
  receive

    % Se a mensagem recebida é 1 não há mais mensagens a serem enviadas
    1 ->

      % Temos a informação aqui de quanto tempo levou para as M mesagens serem enviadas no anel
      {_, Time} = statistics(runtime),

      % Impressão do tempo decorrido para todas as mensagens serem enviadas
      io:format("~p messages sent in ~p ms~n", [M, Time]),

      % Fim da execução do programa
      exit(self(), ok);

    % Para qualquer outro valor que seja diferente de 1 mais uma mensagen é enviada
    Index ->
	
      % Envio da mensagem para o próximo processo do anel
      Pid ! Index - 1,

      % Chamada de loop no próximo processo
      loop(Id, Pid, M)
  end.

