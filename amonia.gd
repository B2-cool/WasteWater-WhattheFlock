extends baseMolecule

# OVERRIDE
func canBeDamaged():
	if $Area2D.get_overlapping_areas().size() <= 0:
		return false
	for area in $Area2D.get_overlapping_areas():
		if area.is_in_group("aeration"):
			return true
	return false
