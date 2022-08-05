"""
DOLPHYN: Decision Optimization for Low-carbon Power and Hydrogen Networks
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
	write_p_g2p(path::AbstractString, sep::AbstractString, inputs::Dict, setup::Dict, EP::Model)

Function for writing the different values of power generated by hydrogen to power plants.
"""
function write_p_g2p(path::AbstractString, sep::AbstractString, inputs::Dict, setup::Dict, EP::Model)
	dfH2G2P = inputs["dfH2G2P"]
	H = inputs["H2_G2P_ALL"]     # Number of resources (generators, storage, DR, and DERs)
	T = inputs["T"]     # Number of time steps (hours)

	# Power injected by each resource in each time step
	# dfH2G2POut_annual = DataFrame(Resource = inputs["H2_RESOURCES_NAME"], Zone = dfH2G2P[!,:Zone], AnnualSum = Array{Union{Missing,Float32}}(undef, H))
	dfPG2POut = DataFrame(Resource = inputs["H2_G2P_NAME"], Zone = dfH2G2P[!,:Zone], AnnualSum = Array{Union{Missing,Float32}}(undef, H))

	for i in 1:H
		dfPG2POut[!,:AnnualSum][i] = sum(inputs["omega"].* (value.(EP[:vPG2P])[i,:]))
	end
	# Load hourly values
	dfPG2POut = hcat(dfPG2POut, DataFrame((value.(EP[:vPG2P])), :auto))

	# Add labels
	auxNew_Names=[Symbol("Resource");Symbol("Zone");Symbol("AnnualSum");[Symbol("t$t") for t in 1:T]]
	rename!(dfPG2POut,auxNew_Names)

	total = DataFrame(["Total" 0 sum(dfPG2POut[!,:AnnualSum]) fill(0.0, (1,T))], :auto)

	for t in  1:T
		total[:,t+3] .= sum(dfPG2POut[:,Symbol("t$t")][1:H])
	end

	rename!(total,auxNew_Names)
	dfPower = vcat(dfPG2POut, total)

 	CSV.write(string(path,sep,"HSC_G2P_H2_consumption.csv"), dftranspose(dfPG2POut, false), writeheader=false)
	return dfPG2POut


end
