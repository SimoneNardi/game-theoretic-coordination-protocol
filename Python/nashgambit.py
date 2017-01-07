# Gambit module

import gambit
import random
import array
import decimal
import scipy.io as sio
import numpy as np

Matlab_files=sio.loadmat('SU.mat')

numpy_S=Matlab_files['S']
numpy_U=Matlab_files['U_vector']

numPlayersArray=numpy_S[0].tolist()
PayoffArray=numpy_U[0].tolist()

numPlayers= len (numPlayersArray)
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
			
					
#solver = gambit.nash.ExternalEnumPureSolver()
#solver = gambit.nash.ExternalSimpdivSolver()
#solver = gambit.nash.ExternalIteratedPolymatrixSolver()	
solver = gambit.nash.ExternalGlobalNewtonSolver()

solutions = solver.solve(g)

numEquilibriums = len(solutions)

if (numEquilibriums >0):
	
	
	lenEquilibriums = len(solutions[0])
	
	nash_list=[]
	for eq in range(numEquilibriums):
		for item in range(lenEquilibriums):
			nash_list.append(solutions[eq].__getitem__(item))
	
	equilibriums_python=np.array(nash_list)

	sio.savemat('eq_python.mat', {'equilibriums_python':equilibriums_python})
	print solutions

else:
	equilibriums_python=np.array(0)
	sio.savemat('eq_python.mat', {'equilibriums_python':equilibriums_python})

	

