# Gambit module

def Nash(numPlayersArray,PayoffArray):
	
	import gambit
	import random
	import array
	import decimal
	
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
	solver = gambit.nash.ExternalIteratedPolymatrixSolver()	
	#solver = gambit.nash.ExternalGlobalNewtonSolver()

	solutions = solver.solve(g)

	numEquilibriums = len(solutions)
	
	if (numEquilibriums >0):
		
		
		lenEquilibriums = len(solutions[0])
		# Matlab compatible array
		NE = array.array('f')

		for eq in range(numEquilibriums):
			for item in range(lenEquilibriums):
				NE.append(solutions[eq].__getitem__(item))


		#print 'numPlayersArray', numPlayersArray
		#print 'Payoff array',PayoffArray
		print 'number of equilibriums:',numEquilibriums
		print solutions
		print 'Array for MATLAB', NE

		return NE

	else:
		return False

#*****************For testing the solvers:************************
#exemple 1 for testing mixed strategies	
#Nash([2,2],[1,-1,-1,1,-1,1,1,-1])
#exemple 2 for testing multiple equilibriums
Nash([2,2],[3,3,1,2,2,1,3,2])	
