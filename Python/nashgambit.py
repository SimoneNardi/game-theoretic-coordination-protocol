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
        solver = gambit.nash.ExternalGlobalNewtonSolver()
	#solver = gambit.nash.ExternalSimpdivSolver()
	#solver = gambit.nash.ExternalIteratedPolymatrixSolver()

	solutions = solver.solve(g)

	#Interni a Python
	#solutions = gambit.nash.enumpure_solve(g)
	#solutions = gambit.nash.gnm_solve(g)
        #solutions = gambit.nash.simpdiv_solve(g)
        #solutions = gambit.nash.ipa_solve(g)
	
	print 'Solver:E GNS' 

	
	

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
		#print 'Array for MATLAB', NE

		return NE

	else:
		return False
	

	
