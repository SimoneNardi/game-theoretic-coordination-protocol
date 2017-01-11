# Gambit module

# Echo server program
import gambit
import random
import array
import decimal
import subprocess
from multiprocessing import Process, Queue
import time
import socket
import signal

HOST = 'localhost' 
PORT = 50000
player_actions= 3;

#**********************************RICEZIONE DATI**********************************

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((HOST, PORT))
while True:
	s.listen(1)
	print "waiting for response from client at port ",PORT
	conn, addr = s.accept()
	print 'Connected by', addr

	total_data=[]
	while True:
		 data = conn.recv(25600)

		 total_data.append(data)
		 if data[-1:]=='t': break 

	total_data=''.join(total_data)
	#total_data[0]=total_data[0][:-1] 	
	total_data=total_data[:-1]

#********************************CREAZIONE GIOCO *********************************
	print total_data
	#data_list=total_data[0].split(';')
	data_list=total_data.split(';')
	numPlayers=int(data_list[0])
	payoff_list=data_list[1].split(',')
	PayoffArray= map(int, payoff_list)
	numPlayersArray=[player_actions]*numPlayers;

	g = gambit.Game.new_table(numPlayersArray)

	t=0
	for profile in g.contingencies:
		print profile,
		for pl in range(numPlayers):
			g[profile][pl]=decimal.Decimal(PayoffArray[t])
			t=t+1			
			if pl == numPlayers-1:
				print g[profile][pl]
			else:
				print g[profile][pl],


#*******************************SOLUZIONE DEL GIOCO********************************			


	#solver = gambit.nash.ExternalEnumPureSolver()
	#solver = gambit.nash.ExternalSimpdivSolver()
	#solver = gambit.nash.ExternalIteratedPolymatrixSolver()	
	solver = gambit.nash.ExternalGlobalNewtonSolver()

	# Creo un lista della classe multiprocessing (globale)
	q = Queue()


	def f(q):
		solutions = solver.solve(g)
		numEquilibriums = len(solutions)

		# Matlab compatible array
		#NE = array.array('f')
		NE=[]

		if (numEquilibriums >0):

			lenEquilibriums = len(solutions[0])


			for eq in range(numEquilibriums):
				for item in range(lenEquilibriums):
					NE.append(solutions[eq].__getitem__(item))
		q.put(NE)			


		print 'number of equilibriums:',numEquilibriums
		print solutions



	p = Process(target=f, args=(q,))
	p.start()
	p.join(1) #ci mette circa 0.0005


	if p.is_alive():
		p.terminate()
		print 'calcolo fallito'
		send_data='f'

	else:
		NE = q.get()
		if not NE:
			send_data='n'
		else:
			print 'lista da spedire', NE
			send_data= map(str, NE)	

#**********************************INVIO DATI*****************************************
	
	print send_data
	send_data=','.join(send_data)
	print send_data
	conn.sendall(send_data)

