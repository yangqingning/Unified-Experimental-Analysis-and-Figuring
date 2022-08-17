classdef UniExpException<MATLAB.IEnumerableException
	enumeration
		Wrong_number_of_arguments
		Image_size_does_not_match
		DateTime_primary_key_has_duplicate_values
		Some_commits_are_missing_UID_definitions
		Inconsistent_cells_per_line
		Wrong_array_size
		NaN_appears_after_normalization
		No_data_matching_the_filter_criteria
		No_trials_identified
		Undefined_UID_found
		Table_is_missing_key_column
	end
end