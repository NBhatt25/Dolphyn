"""
DOLPHYN: Decision Optimization for Low-carbon for Power and Hydrogen Networks
Copyright (C) 2021,  Massachusetts Institute of Technology
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
A complete copy of the GNU General Public License v2 (GPLv2) is available
in LICENSE.txt.  Users uncompressing this from an archive may not have
received this license file.  If not, see <http://www.gnu.org/licenses/>.
"""

@doc raw"""
	h2_production(EP::Model, inputs::Dict, setup::Dict)

This module creates decision variables, expressions, and constraints related to various hydrogen generation technologies (electrolyzers, natural gas reforming etc.)

"""
function h2_production(EP::Model, inputs::Dict, setup::Dict)

	println("Hydrogen Production Module")
	
	if !isempty(inputs["H2_GEN"])
	# expressions, variables and constraints common to all types of hydrogen generation technologies
		EP = h2_production_all(EP::Model, inputs::Dict, setup::Dict)
	end

    H2_GEN_COMMIT = inputs["H2_GEN_COMMIT"]
	H2_GEN_NO_COMMIT = inputs["H2_GEN_NO_COMMIT"]
	dfH2Gen = inputs["dfH2Gen"]  # Input H2 generation and storage data
	Z = inputs["Z"]  # Model demand zones - assumed to be same for H2 and electricity
	T = inputs["T"]	 # Model operating time steps

	if !isempty(H2_GEN_COMMIT)
		EP = h2_production_commit(EP::Model, inputs::Dict, setup::Dict)
	end

	if !isempty(H2_GEN_NO_COMMIT)
		EP = h2_production_no_commit(EP::Model, inputs::Dict,setup::Dict)
	end

	##For CO2 Polcy constraint right hand side development - H2 Generation by zone and each time step
		@expression(EP, eH2GenerationByZone[z=1:Z, t=1:T], # the unit is tonne/hour
		sum(EP[:vH2Gen][y,t] for y in intersect(inputs["H2_GEN"], dfH2Gen[dfH2Gen[!,:Zone].==z,:R_ID]))
	)

	return EP
end