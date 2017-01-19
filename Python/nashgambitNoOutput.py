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

#**********************************Receiving data**********************************

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
	total_data=total_data[:-1]

#********************************Game Creation *********************************
	#print total_data
	data_list=total_data.split(';')
	numPlayers=int(data_list[0])
	payoff_list=data_list[1].split(',')
	PayoffArray= map(int, payoff_list)
	numPlayersArray=[player_actions]*numPlayers;

	g = gambit.Game.new_table(numPlayersArray)

	t=0
	for profile in g.contingencies:
		for pl in range(numPlayers):
			g[profile][pl]=decimal.Decimal(PayoffArray[t])
			t=t+1			



#*******************************solving game********************************			


	#solver = gambit.nash.ExternalEnumPureSolver()
	#solver = gambit.nash.ExternalSimpdivSolver()
	#solver = gambit.nash.ExternalIteratedPolymatrixSolver()	
	solver = gambit.nash.ExternalGlobalNewtonSolver()

	# Creo un lista della classe multiprocessing (globale)
	q = Queue()


	def f(q):
		solutions = solver.solve(g)
		numEquilibriums = len(solutions)

		NE=[]

		if (numEquilibriums >0):

			lenEquilibriums = len(solutions[0])


			for eq in range(numEquilibriums):
				for item in range(lenEquilibriums):
					NE.append(solutions[eq].__getitem__(item))
		q.put(NE)			

	p = Process(target=f, args=(q,))
	p.start()
	p.join(1) # 0.0005s for a normale execution


	if p.is_alive():
		p.terminate()
		print 'calculation failed'
		send_data='f'
		q.close()

	else:
		NE = q.get()
		q.close()
		if not NE:
			send_data='n'
			print 'no equilibriums'
		else:
			send_data= map(str, NE)	

#**********************************sending data*****************************************
	
	#print send_data
	send_data=','.join(send_data)
	#print send_data
	conn.sendall(send_data)

