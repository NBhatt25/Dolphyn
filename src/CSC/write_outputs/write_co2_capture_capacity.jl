"""
DOLPHYN: Decision Optimization for Low-carbon Power and Hydrogen Networks
Copyright (C) 2022,  Massachusetts Institute of Technology
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
	write_co2_capture_capacity(path::AbstractString, sep::AbstractString, inputs::Dict, setup::Dict, EP::Model)

Function for writing the diferent capacities for DAC.
"""
function write_co2_capture_capacity(path::AbstractString, sep::AbstractString, inputs::Dict, setup::Dict, EP::Model)
	# Capacity decisions
	dfDAC = inputs["dfDAC"]
	H = inputs["DAC_RES_ALL"]
	capcapture = zeros(size(inputs["DAC_RESOURCES_NAME"]))
	for i in 1:inputs["DAC_RES_ALL"]
		capcapture[i] = value.(EP[:vCapacity_DAC_per_type][i])
	end
	
	MaxGen = zeros(size(1:inputs["DAC_RES_ALL"]))
	for i in 1:H
		MaxGen[i] = value.(EP[:vCapacity_DAC_per_type])[i] * 8760
	end

	AnnualGen = zeros(size(1:inputs["DAC_RES_ALL"]))
	for i in 1:H
		AnnualGen[i] = sum(inputs["omega"].* (value.(EP[:vDAC_CO2_Captured])[i,:]))
	end

	CapFactor = zeros(size(1:inputs["DAC_RES_ALL"]))
	for i in 1:H
		if MaxGen[i] == 0
			CapFactor[i] = 0
		else
			CapFactor[i] = AnnualGen[i]/MaxGen[i]
		end
	end

	dfCap = DataFrame(
		Resource = inputs["DAC_RESOURCES_NAME"], Zone = dfDAC[!,:Zone],
		Capacity = capcapture[:],
		Max_Annual_Capture = MaxGen[:],
		Annual_Capture = AnnualGen[:],
		CapacityFactor = CapFactor[:]
	)

	if setup["ParameterScale"] ==1
		dfCap.Capacity = dfCap.Capacity * ModelScalingFactor
		dfCap.Max_Annual_Capture = dfCap.Max_Annual_Capture * ModelScalingFactor
		dfCap.Annual_Capture = dfCap.Annual_Capture * ModelScalingFactor
	end

	total = DataFrame(
			Resource = "Total", Zone = "n/a",
			Capacity = sum(dfCap[!,:Capacity]),
			Max_Annual_Capture = sum(dfCap[!,:Max_Annual_Capture]), Annual_Capture = sum(dfCap[!,:Annual_Capture]),
			CapacityFactor = "-"
		)

	dfCap = vcat(dfCap, total)
	CSV.write(string(path,sep,"CSC_DAC_capacity.csv"), dfCap)
	return dfCap
end
