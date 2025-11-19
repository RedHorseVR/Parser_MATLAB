#use#////
	
	use File::stat qw(stat);
	
sub LoadFileAsString {
	local ( $file ) = @_;
	local ( $keyfile ) ;
	open( FILE, $file );
	while(<FILE>) {
		s/^ *\n//;
		tr/\t/ /;
		$keyfile = "$keyfile$_";
		}## End of SEARCHFILE
	
	close ( FILE );
	$keyfile; }
# main 
	$cmd_line = $ENV{'QUERY_STRING'} ;#GetParams();
	$cmd_line = $ARGV[0];
	print "\n----------------------------------\nCMD INPUT:  $cmd_line\n";
	if ( $cmd_line eq  "" )
	{
		$cmd_line = "mtest/DotStereo.m" ;#<<< defualt test input file
		print( STDOUT  "\n...Using defaut test input=  $cmd_line  ...  \n" );
	}else{
		}
	$file = $cmd_line ;#<<< input file
	$lasttime = 0;#$lasttime = stat($file)->mtime;
	Parse();
	print "DONE... $I\n";
	exit ;
sub Parse{
	$outputVFC =  "$cmd_line.vfc" ;#<<<< output file
	open OUTFILE,  ">" ,   $outputVFC  or die "Cannot open $outputVFC !\n";
	open( FILE, $cmd_line );
	print( STDOUT  "\nINPUT FILE  =  $cmd_line  ...  \n" );
	print( STDOUT  "OUTPUT FILE  =  $outputVFC ...  \n" );
	my @stack;
	$lastcount = 0;# ////
	$ParsedFile  = "";
	while(<FILE>) {
		#s/^\t/    /;
		#chomp; 
		#print( STDOUT  "------> $_\n" );
		s/\n//;
		$str = $_;
		$str =~ /^\t*/;
		$count = 1+length( $1 );#  GET THE WHITE SPACE COUNTS
		s/^\s*//;
		$comment = "$_";
		#print( "------ $comment \n" );
		s/^%.*$//;#PROCESS COMMENTS
		if ( $comment =~ s/^%{1}//  )
		{
			if ( $comment =~ m/^end/ )
			{
				$line ="end($_);\//$comment";
			}else{
				$line ="set($_);\//$comment";
				}
		} else {
			$comment = "";#$comment = "+";
			}
		#print( "\t------ $comment \n" );
		$line ="set($_);\//$comment";
		#print( STDOUT  "------> $line\n" );
		
		if( $_ =~ m/^\s*(function|class)\b/ )
		{
			$line ="input($_);\//$comment";
			$ParsedFile  = "$ParsedFile$line\n";
			$line ="branch();";
			push( @stack, "bendend" );
		}  if ( m/^\s*end\b/  )  {#POP THE STACK
			$stack_value = pop( @stack );
			if ( $stack_value =~ s/bendend/bend/ )
			{
				$line ="bend();";
				$ParsedFile  = "$ParsedFile$line\n";
				$line ="end($_);\//$comment";
			}else{
				$line ="$stack_value($_);\//$comment";
				}
		} if(   m/^\s*(clear|cla|tic|toc|hold)\b/  )  {
			$line ="event($_);\//$comment";
		} if(   m/^\s*(fprintf|imshow|disp)\b/  )  {
			$line ="output($_);\//$comment";
		} if(   m/^\s*(while|for)\b/  )  {
			$line ="loop($_);\//$comment";
			push( @stack, "lend" );
		} if(   m/^\s*(switch)\b/  )  {
			$line ="branch($_);\//$comment";
			push( @stack, "bend" );
			
		} if(   m/^\s*(case|otherwise)\b/  )  {#////////
			$line ="path($_);\//$comment";
		} if(   m/^\s*(try)\b/  )  {
			$line ="branch($_);\//$comment";
			push( @stack, "bend" );
			
		} if(   m/^\s*(catch)\b/  )  { 
			$line ="path($_);\//$comment";
		} if(   m/^\s*(if)\b/  )  {
			$line ="branch($_);\//$comment";
			push( @stack, "bend" );
			
		} if(   m/^\s*(else)\b/  )  {#////////
			$line ="path($_);\//$comment";
		} if(   m/^\s*(elseif)\b/  )  {#////////
			$line ="path($_);\//$comment";
		} if(   m/^\s*(break|continue|return)\b/  )  {
			$line ="end($_);\//$comment";
			}
		$ParsedFile  = "$ParsedFile$line\n";
		$line = "";
		$lastcount = $count;# ////
		}## End of SEARCHFILE
	
	close ( FILE );
	#print( $ParsedFile );
	$stack_value = pop( @stack );
	while( $stack_value  ) {#////
		$line ="$stack_value();";
		$ParsedFile  = "$ParsedFile$line\n";
		$stack_value = pop( @stack );
		}#////
	
	print( OUTFILE $ParsedFile );
	printFooter( );
	close ( OUTFILE );
	} 
sub printFooter{
	print( OUTFILE  ";INSECT" );# ////
	print( OUTFILE  "A EMBEDDED SESSION INFORMATION\n" );# ////
	print( OUTFILE  "; 0 13158600 0 0 13158600 16711808 10485760 16777215 0 0 0 0 12632256 \n");
	print( OUTFILE  "$file   #\"\"\"  #\"\"\"  \n");
	print( OUTFILE  "; notepad++.exe \n");
	print( OUTFILE  ";INSECT" );# ////
	print( OUTFILE  "A EMBEDDED ALTSESSION INFORMATION\n");
	print( OUTFILE  "; 261 572 704 1329 31 130   395   4294966789    MATLAB.key  0");
	}




