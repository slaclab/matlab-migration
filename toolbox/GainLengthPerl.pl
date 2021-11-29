#!/usr/local/bin/perl 
#
# Author: Daniel Ratner
# Last Modified: Oct 15, 2008


#use warnings;
#use strict;


	


#------------------------------------------------
# Declare subs
#



sub format_gen_input($$$$$$$$$);
sub format_gen_output($$);
sub check_run_status($$);

#------------------------------------------------
#
# MAIN CODE
# 


#------------------------------------------------
# Declare Variables
#
	

my $task_m = $ARGV[0];

if ($task_m =~ m/input/) {

	my $base_file_m = $ARGV[1];
	my $input_file_m = $ARGV[2];
	my $output_file_m = $ARGV[3];
	my $master_file_m = $ARGV[4];        
	my $x_emit_m = $ARGV[5];
	my $y_emit_m = $ARGV[6];
	my $energy_m = $ARGV[7];	
	my $current_m = $ARGV[8];
	my $bl_m = $ARGV[9];
	my $e_spread_m = $ARGV[10];		

	# Make new input file
	format_gen_input($base_file_m,$input_file_m,$output_file_m,$x_emit_m,$y_emit_m,$energy_m,$current_m,$bl_m,$e_spread_m);
	make_filename_file($master_file_m,$input_file_m);

} elsif ($task_m =~ m/output/) { 

	my $gen_output_file_m = $ARGV[1];			# output file name
	my $final_file_m = $ARGV[2];			# formatted data file name
	
	format_gen_output($gen_output_file_m,$final_file_m);

} elsif  ($task_m =~ m/check run/) {
	my $result_file_m = $ARGV[1];
	my $status_file_m = $ARGV[2];
	check_run_status($result_file_m,$status_file_m);
}


#
# END MAIN
# 
#------------------------------------------------








#------------------------------------------------
# FORMAT_GEN_INPUT
#
# Change input values for genesis run

sub format_gen_input($$$$$$$$$) {
	my $base_file = shift;
	my $input_file = shift;
	my $output_file = shift;
	my $x_emit= shift;
	my $y_emit = shift;
	my $energy= shift;
	my $current = shift;
	my $bl = shift;
	my $e_spread = shift;
	my $data;

	open BASE, "$base_file" or die "Can't read file $base_file: $!\n";
	open GENINPUT, ">$input_file" or die "Can't write on file $input_file: $!\n";	

	while (<BASE>) {
		$data = $_;
		if ($data =~ m/\semitx/) { 
			# update x emittance
			$data =~ s/\d\.\d*/$x_emit/g;
		} elsif ($data =~ m/\semity/) { 
			# update y emittance
			$data =~ s/\d\.\d*/$y_emit/g;
		} elsif ($data =~ m/\sgamma0/) { 
			# update energy
			$data =~ s/\d\.\d*/$energy/g;
		} elsif ($data =~ m/\scurpeak/) { 
			# update current
			$data =~ s/\d\.\d*/$current/g;
		} elsif ($data =~ m/\sbunchlength/) { 
			# update bunch length
			$data =~ s/\d\.\d*/$bl/g;
		} elsif ($data =~ m/\senergyspread/) { 
			# update energy spread
			$data =~ s/\d\.\d*/$e_spread/g;
		} elsif ($data =~ m/\soutputfile/) { 
			# update energy spread
			$data =~ s/\'\s*\'/$output_file/g;
		}


		print GENINPUT $data;
	}




	close BASE, "$base_file" or die "Can't close file $base_file: $!\n";
	close GENINPUT, "$input_file" or die "Can't close on file $input_file: $!\n";	
}



#------------------------------------------------
# MAKE_FILENAME_FILE
#
# makes a file containing the names of all the input files for genesis

sub make_filename_file($$) {
	my $master_file = shift;
	my $input_file = shift;
	
	open MASTERFILE, ">$master_file" or die "Can't write on file $master_file: $!\n";	
	print MASTERFILE $input_file;
	print MASTERFILE "\n";
	close MASTERFILE, "$master_file" or die "Can't close on file $master_file: $!\n";	

}





#------------------------------------------------
# FORMAT_GEN_OUTPUT
#
# Format output for MATLAB

sub format_gen_output($$) {
	my $output_file = shift;
	my $final_file = shift;
	my $data;
	my $status;
	my $val;
	my $exp;

	# if status=0, looking for z
	$status = 0;

	open GENOUT, "$output_file" or die "Can't read file $output_file: $!\n";
	open FINAL, ">$final_file" or die "Can't write on file $final_file: $!\n";	

	while (<GENOUT>) {
		$data = $_;

		# Beginning of z positions
		if ($data =~ m/z\[m\]/) { 
			$status = 1;
			next;
		}


		# Beginning of power values
		if ($data =~ m/power/) { 
			$status = 1;
			next;
		}

		
		# If not in data region, go to next line
		if ($status == 0) {
			next;
		}
		

		# If no number, reached end of data section.  Look for next section
		if ($data !~ m/\d/) {
			$status = 0;
			print FINAL "\n";
			next;
		} 

		# Break number into value and exponent
		$data =~ m/\s+(\d.\d+)E(.\d\d)\s+/;
		$val = $1;
		$exp = $2;
		

		# Print to final file
		print FINAL $val, "e", $exp, "	";
	}




	close GENOUT, "$output_file" or die "Can't close file $output_file: $!\n";
	close FINAL, "$final_file" or die "Can't close on file $final_file: $!\n";	
}






#------------------------------------------------
# CHECK_RUN_STATUS
#
# Format output for MATLAB

sub check_run_status($$) {
	my $result_file = shift;
	my $status_file = shift;
	my $data;

	# see if run done yet
	my $status = 0;
	my $mycount = 0;
	my $maxcount = 100;

	while ($status == 0) {
	
		open RESULT, "$result_file" or die "Can't read file $result_file: $!\n";
		while (<RESULT>) {
			$data = $_;
	
			# Look for run finished
			if ($data =~ m/finished/) { 
				$status = 1;
				last;
			}
		}
		close RESULT, "$result_file" or die "Can't close on file $result_file: $!\n";	



		if ($status || ($mycount > $maxcount)) {
			open STATUS, ">$status_file" or die "Can't read file $status_file: $!\n";	
			print STATUS $status;
			close STATUS, "$status_file" or die "Can't close on file $status_file: $!\n";	
			last;
		} else {
			$mycount = $mycount+1;
			sleep(5);
		}



	}
}




# NOT USED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#------------------------------------------------
# GET_INPUTS(\$x_emit_m,\$y_emit_m,\$energy_m,\$current_m,\$bl_m);
#
# Get file name from user.  Check if running real time. If
# so, get file skip counter, wait time between integrations and max_delta E.

sub get_inputs(\$\$\$\$\$) {
	my $x_emit_ref = shift;
	my $y_emit_ref = shift;
	my $energy_ref = shift;
	my $current_ref = shift;
	my $bl_ref = shift;
	my $temp;
	

	$$x_emit_ref = $ARGV[0];
	$$y_emit_ref = $ARGV[1];
	$$energy_ref = $ARGV[2];	
	$$current_ref = $ARGV[3];
	$$bl_ref = $ARGV[4];


}
