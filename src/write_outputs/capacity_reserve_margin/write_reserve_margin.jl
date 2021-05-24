function write_reserve_margin(path::AbstractString, sep::AbstractString, setup::Dict, EP::Model)
	temp_ResMar = dual.(EP[:cCapacityResMargin])
	if setup["ParameterScale"] == 1
		temp_ResMar = temp_ResMar * ModelScalingFactor # Convert from MillionUS$/GWh to US$/MWh
	end
	dfResMar = DataFrame(temp_ResMar)
	CSV.write(string(path,sep,"ReserveMargin.csv"), dfResMar)
	return dfResMar
end